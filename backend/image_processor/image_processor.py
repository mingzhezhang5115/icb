from celery import Celery
import time
import dlib
from io import BytesIO
from PIL import Image
import redis
import hashlib
import json
import logging
import logging.config
from minio import Minio
import numpy as np
import os
import pydgraph
import tensorflow as tf


#TODO change the devserver ip to your own host ip
devserver_ip = "127.0.0.1"
cache_images_dir = ""
tensorflow_model_path = ""
tensorflow_labels_path = ""
if not devserver_ip:
    print("Please update devserver_ip to your own ip")
    sys.exit(1)


dictConfig = {
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {
        'sh': {
            'class': 'logging.StreamHandler',
            'formatter': 'default'
        },
        'fh': {
            'class': 'logging.FileHandler',
            'filename': 'image_processor.log',
            'formatter': 'default'
        }
    },
    'root': {
        'level': 'DEBUG',
        'handlers': ['sh', 'fh']
    }
}

logging.config.dictConfig(dictConfig)
logger = logging.getLogger('root')
app = Celery('tasks', broker='redis://' + devserver_ip)


def add_image_tag_by_key(obj_key, tag_name):
    client_stub = pydgraph.DgraphClientStub(devserver_ip + ':9080')
    client = pydgraph.DgraphClient(client_stub)
    txn = client.txn(read_only=False)
    query = """{{
        q1(func: eq(minio_obj_path, "{0}")){{
             s as uid
        }}
        q2(func: eq(tag_name,"{1}")){{
            t as uid
        }}
    }}""".format(obj_key, tag_name)
    cond = "@if(eq(len(s), 1) and eq(len(t), 1))"
    no_tag_cond = "@if(eq(len(s), 1) and eq(len(t), 0))"
    nquad = 'uid(s) <tagged_with> uid(t) .'
    no_tag_nquad = """
        _:tag <tag_name> "{0}" .
        _:tag <dgraph.type> "Tag" .
        uid(s) <tagged_with> _:tag .
    """.format(tag_name)
    mutation = txn.create_mutation(set_nquads=nquad, cond=cond)
    no_tag_mutation = txn.create_mutation(
        set_nquads=no_tag_nquad, cond=no_tag_cond)
    request = txn.create_request(query=query, mutations=[
                                 mutation, no_tag_mutation], commit_now=True)
    resp = txn.do_request(request)
    return resp


@app.task
def set_thumbnail_flag(obj_key):
    client_stub = pydgraph.DgraphClientStub(devserver_ip + ':9080')
    client = pydgraph.DgraphClient(client_stub)
    txn = client.txn(read_only=False)
    query = """{{
        store_info(func: eq(minio_obj_path, "{0}")) {{
          s as uid
        }}
      }}""".format(obj_key)
    cond = "@if(eq(len(s), 1))"
    nquad = """
      uid(s) <has_thumbnail> "True" .
    """
    mutation = txn.create_mutation(set_nquads=nquad, cond=cond)
    request = txn.create_request(query=query, mutations=[
                                 mutation], commit_now=True)
    res = txn.do_request(request)


@app.task
def process_image(bucket, obj_key):
    size = 128, 128
    minio_client = Minio(devserver_ip + ':9000',
                         access_key="minioadmin",
                         secret_key="minioadmin",
                         secure=False)
    data = minio_client.get_object(bucket, obj_key)
    data = data.read()
    m = hashlib.sha1()
    m.update(data)
    obj_checksum = m.hexdigest()
    logger.info("%s", obj_checksum)
    img = Image.open(BytesIO(data))
    img.save(cache_images_dir +  "/" + obj_key + '.png', 'PNG')
    #TODO update following variable to where your model and labels.text located
    tflite_save_model = tensorflow_model_path
    labels_text_path = tensorflow_labels_path

    interpreter = tf.lite.Interpreter(model_path=tflite_save_model)
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    floating_model = input_details[0]['dtype'] == np.float32

    # NxHxWxC, H:1, W:2
    height = input_details[0]['shape'][1]
    width = input_details[0]['shape'][2]
    logger.info("Resize image to %s,%s", height, width)
    image_copy = img.convert('RGB').resize((height, width))

    #logger.info('Shape of image before resize %s',image_copy.shape)
    logger.info('%s', image_copy)
    #image_copy.resize((width, height, 3))

    # add N dim
    #logger.info('Shape of image %s',image_copy.shape)
    input_data = np.expand_dims(image_copy, axis=0)

    if floating_model:
        input_data = (np.float32(input_data) - 127.5) / 127.5

    interpreter.set_tensor(input_details[0]['index'], input_data)

    interpreter.invoke()

    output_data = interpreter.get_tensor(output_details[0]['index'])
    results = np.squeeze(output_data)
    labels = []
    with open(labels_text_path, 'r') as f:
        labels = [line.strip() for line in f.readlines()]
    #max = results.argsort()[-5:][::-1]
    max_probability = results.argmax()
    logger.info('Probability: %s Label: %s',
                results[max_probability], labels[max_probability])
    if results[max_probability] > 0.9:
        logger.info(
            'Probability great than 0.9 of label: %s, update tag!', labels[max_probability])
        add_image_tag_by_key(obj_key, labels[max_probability])
        # if os.path.exists(os.path.join("images",labels[max_probability])):
        #    pass
        # else:
        #    os.mkdir(os.path.join("images",labels[max_probability]))
        # if os.path.exists(os.path.join("images", labels[max_probability], obj_key + '.png')):
        #    pass
        # else:
        #    os.symlink(os.path.join("..", obj_key + '.png'),
        #            os.path.join("images", labels[max_probability], obj_key + '.png'))

    # for i in top_k:
    #  if floating_model:
    #    print('{:08.6f}: {}'.format(float(results[i]), labels[i]))
    #  else:
    #    print('{:08.6f}: {}'.format(float(results[i] / 255.0), labels[i]))

    img_array = np.array(img)
    detector = dlib.get_frontal_face_detector()
    dets = detector(img_array, 1)
    if len(dets) == 1:
        logger.info("Frountal face %s detected", obj_key)
        add_image_tag_by_key(obj_key, "face")
    elif len(dets) > 1:
        logger.info("Group shot %s detected", obj_key)
        add_image_tag_by_key(obj_key, "group_shot")
    else:
        logger.info("No face in %s detected", obj_key)
    img.thumbnail(size)
    output = BytesIO()
    # with BytesIO() as output:
    img.save(output, format="PNG")
    img_length = output.getbuffer().nbytes
    output.seek(0)
    #logger.info("thumbnail size %s", img_length)
    #a = output.read(img_length)
    #logger.info("thumbnail size readed %s", len(a))
    minio_client.put_object(bucket, obj_key+'-thumbnail', output, img_length)


r = redis.Redis(host=devserver_ip, port=6379, db=0)

#(b'bucketevents', b'["2020-02-02T20:28:07Z",[{"eventVersion":"2.0","eventSource":"minio:s3","awsRegion":"","eventTime":"2020-02-02T20:28:07Z","eventName":"s3:ObjectAccessed:Get","userIdentity":{"principalId":""},"requestParameters":{"accessKey":"","region":"","sourceIPAddress":"172.17.0.1"},"responseElements":{"content-length":"5069","x-amz-request-id":"15EFAFCC96FD35D7","x-minio-deployment-id":"f5db3f0a-07b5-406d-9339-12230fa74ded","x-minio-origin-endpoint":"http://172.17.0.2:9000"},"s3":{"s3SchemaVersion":"1.0","configurationId":"Config","bucket":{"name":"mybucket","ownerIdentity":{"principalId":""},"arn":"arn:aws:s3:::mybucket"},"object":{"key":"010dd8fe-b82b-482f-b705-043de54945e2","size":5069,"eTag":"99a7f1df457426c443c0ddb5af86d691-1","contentType":"application/x-www-form-urlencoded; charset=UTF-8","userMetadata":{"content-type":"application/x-www-form-urlencoded; charset=UTF-8"},"versionId":"1","sequencer":"15EFAFCC970F1F9E"}},"source":{"host":"172.17.0.1","port":"","userAgent":"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0"}}]]')
# [2020-03-13 20:52:37,500] INFO in redis_listener: (b'bucketevents', b'[{"Event":[{"eventVersion":"2.0","eventSource":"minio:s3","awsRegion":"","eventTime":"2020-03-13T20:52:37Z","eventName":"s3:ObjectCreated:Put","userIdentity":{"principalId":"minioadmin"},"requestParameters":{"accessKey":"minioadmin","region":"","sourceIPAddress":"172.17.0.1"},"responseElements":{"x-amz-request-id":"15FBF8598F58909B","x-minio-deployment-id":"7d5c773c-c038-4a84-b41f-c62328223e3d","x-minio-origin-endpoint":"http://172.17.0.5:9000"},"s3":{"s3SchemaVersion":"1.0","configurationId":"Config","bucket":{"name":"icb-bucket","ownerIdentity":{"principalId":"minioadmin"},"arn":"arn:aws:s3:::icb-bucket"},"object":{"key":"25657207547_94965b7d01_o.jpg","size":4662794,"eTag":"a3ed7bcb0f13c497f4650cbb56daea4d-1","contentType":"image/jpeg","userMetadata":{"content-type":"image/jpeg"},"versionId":"1","sequencer":"15FBF8598FD06A24"}},"source":{"host":"172.17.0.1","port":"","userAgent":"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0"}}],"EventTime":"2020-03-13T20:52:37Z"}]')
while True:
    event = r.blpop("bucketevents", timeout=0)
    logger.info("%s", event)
    minio_event = json.loads(event[1])
    obj_info = minio_event[0]["Event"][0]
    event_name = obj_info['eventName']
    obj_key = obj_info['s3']['object']['key']
    obj_bucket = obj_info['s3']['bucket']['name']
    logger.info("%s, %s, %s", event_name, obj_key, obj_bucket)
    if event_name == 's3:ObjectCreated:Put' and not obj_key.endswith("-thumbnail"):
        process_image(obj_bucket, obj_key)
        set_thumbnail_flag(obj_key)
