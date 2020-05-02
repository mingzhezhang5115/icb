import os
import time
import datetime
from datetime import timedelta
import json
import uuid
import config
from flask import Flask, request, jsonify, g
from flask_restful import Resource, Api
import redis
import pydgraph
from minio import Minio
from minio.error import NoSuchKey
from minio.error import ResponseError
from logging.config import dictConfig

dictConfig(config.LOGGER_CONFIG)
app = Flask(__name__)
app.config.from_object('config')

class ImageDetailView:
    image_uuid = ''
    image_url = ''
    image_thumbnail_url = ''
    image_tags = []

    def __init__(self, image_uuid='', image_url='', image_thumbnail_url='', image_tags=[]):
        self.image_uuid = image_uuid
        self.image_url = image_url
        self.image_thumbnail_url = image_thumbnail_url
        self.image_tags = image_tags


class ImagePutError(Exception):
    status_code = 400

    def __init__(self, message, status_code=None, payload=None):
        Exception.__init__(self)
        self.message = message
        if status_code is not None:
            self.status_code = status_code
        self.payload = payload

    def to_dict(self):
        rv = dict(self.payload or ())
        rv['message'] = self.message
        return rv


def get_store():
    store = getattr(g, '_store', None)
    if store is None:
        store = g._store = Minio(
            app.config['MINIO_ADDR'] + ':9000',
            access_key="minioadmin",
            secret_key="minioadmin",
            secure=False)
    return store


def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        g._database_stub = pydgraph.DgraphClientStub(app.config['DGRAPH_ADDR'] + ':9080')
        db = g._database = pydgraph.DgraphClient(g._database_stub)
    return db


@app.errorhandler(ImagePutError)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response


@app.teardown_appcontext
def close_connection(exception):
    db_stub = getattr(g, '_database_stub', None)
    if db_stub is not None:
        db_stub.close()


@app.route('/images', methods=['POST', 'GET', 'PUT', 'DELETE'])
def images():
    if request.method == 'GET':
        time_start = time.time()
        image_sha1 = None
        human_readable_name = None
        offset = 0
        limit = 10
        #request_payload = request.get_json()
        # if request_payload:
        image_sha1 = request.args.get("image_sha1", "")
        offset = request.args.get("offset", 0)
        limit = request.args.get("limit", 10)
        tag = request.args.get("tag", "")
        if image_sha1:
            image = get_images(image_sha1, offset=offset, limit=limit)
        elif tag:
            image = get_images_by_tag(tag, offset=offset, limit=limit)
        else:
            image = get_images(offset=offset, limit=limit)
        if image:
            time_inteval = time.time() - time_start
            app.logger.debug('Time interval %s', time_inteval)
            return image

    elif request.method == 'PUT':
        image_sha1 = None
        human_readable_name = None
        request_payload = request.get_json()
        if request_payload:
            image_sha1 = request_payload.get("image_sha1", '')
            human_readable_name = request_payload.get(
                "human_readable_name", 'Unkown')
        if not image_sha1:
            raise ImagePutError(
                'Please provide sha1 of the images for validation')
        app.logger.debug('Get images put request of image_sha1 %s', image_sha1)
        uploaded = is_uploaded(image_sha1)
        if uploaded:
            raise ImagePutError('Image already uploaded')
        else:
            onetime_uuid = str(uuid.uuid4())
            image_uuid = str(uuid.uuid4())
            onetime_upload_url = get_store().presigned_put_object(
                app.config['MINIO_BUCKET_NAME'],
                onetime_uuid,
                expires=timedelta(seconds=3000))
            add_new_image(
                minio_url=app.config['MINIO_ADDR'] + ':9000',
                minio_bucket=app.config['MINIO_BUCKET_NAME'],
                minio_obj_path=onetime_uuid,
                image_sha1=image_sha1,
                human_readable_name=human_readable_name,
                image_uuid=image_uuid)

            app.logger.info('return one time url %s', onetime_upload_url)
            return jsonify({'upload_url': onetime_upload_url, 'image_uuid': image_uuid})
    return jsonify({})


@app.route('/images/<string:image_id>', methods=['POST', 'GET', 'PUT', 'DELETE'])
def image_detail(image_id):
    if request.method == 'GET':
        image = get_image_by_id(image_id)
        image = get_image_view(image)
        if image:
            return jsonify(image)
        else:
            raise ImagePutError('Image not found'.format())
        image = get_images(image_sha1, offset=offset, limit=limit)
        if image:
            return image

    elif request.method == 'PUT':
        pass
    elif request.method == 'POST':
        pass
    elif request.method == 'DELETE':
        image = delete_image_by_id(image_id)
        return jsonify({"Result": "Deleted"})
    raise ImagePutError(
        'Sorry, the method {0} has not been implemented'.format(request.method))
    return jsonify({"Result": "Not implemented"})


@app.route('/images/<string:image_id>/tags', methods=['POST', 'GET', 'PUT'])
def image_tags(image_id):
    if request.method == 'GET':
        tags = get_image_tags(image_id)
        return jsonify(tags)
    elif request.method == 'PUT':
        tags = ''
        request_payload = request.get_json()
        app.logger.debug('request payload %s', request_payload)
        if request_payload:
            tags = request_payload.get("tags", [])
        if not tags:
            raise ImagePutError('Please provide a tag for this image')
        update_image_tags(image_id, tags)
        tags = get_image_tags(image_id)
        return jsonify(tags)
    return jsonify({"result": "something wrong"})

@app.route('/images/<string:image_id>/tags/<string:tag_name>',
           methods=['POST', 'GET', 'PUT', 'DELETE'])
def image_tag_detail(image_id, tag_name):
    if request.method == 'GET':
        pass
    elif request.method == 'PUT':
        obj_key = ''
        resp = add_image_tag(image_id, tag_name)
        return jsonify(json.loads(resp.json))
    elif request.method == 'DELETE':
        resp = delete_image_tag(image_id, tag_name)
        return jsonify(json.loads(resp.json))
    return jsonify({"Result": "Unsupported action"})


@app.route('/images/<string:image_id>/tag_confirmed', methods=['POST', 'GET', 'PUT', 'DELETE'])
def image_tag_confirmed(image_id):

    app.logger.debug('Confirm tag request')
    if request.method == 'GET':
        pass
        #tag_detail = get_image_tag_detail(image_id,tag_name)
        # return jsonify(tag_detall)
    elif request.method == 'PUT':
        tag_confirmed = ''
        request_payload = request.get_json()
        app.logger.debug('request payload %s', request_payload)
        if request_payload:
            tag_confirmed = request_payload.get("confirmed", False)
            app.logger.debug('Confirm tag request parameter %s', tag_confirmed)
            if tag_confirmed == True:
                confirm_image_tag_by_id(image_id)
                image_detail = get_image_by_id(image_id)
                obj_key = get_storage_obj_key(image_detail)
                tag_list = get_tags_from_image_detail(image_detail)
                for tag_name in tag_list:
                    if os.path.exists(os.path.join("/images", tag_name)):
                        pass
                    else:
                        os.mkdir(os.path.join("/images", tag_name))
                    if obj_key:
                        os.symlink(
                            os.path.join("..", obj_key + '.png'),
                            os.path.join("/images", tag_name, obj_key + '.png'))
        return jsonify({"Result": "Succeed"})
    elif request.method == 'DELETE':
        pass
    return jsonify({"Result": "Unsupported action"})


@app.route('/tags', methods=['POST', 'GET', 'PUT', 'DELETE'])
def tags():
    if request.method == 'PUT':
        tag_name = ''
        request_payload = request.get_json()
        if request_payload:
            tag_name = request_payload.get("tag_name", '')
        if not tag_name:
            raise ImagePutError('Please provide a valid tag name')
        add_tag(tag_name)

    elif request.method == 'GET':
        resp = get_tags()
        tags = get_tags_view(resp)
        return jsonify(tags)
    elif request.method == 'DELETE':
        remove_unused_tags()
    return jsonify({"Result": "Tag Added"})


@app.route('/tags/<string:tag_name>', methods=['POST', 'GET', 'PUT'])
def tag_detail(tag_name):
    if request.method == 'PUT':
        pass
    elif request.method == 'GET':
        resp = get_tag_detail(tag_name)
        tag = get_tag_detail_view(resp)
        return jsonify(tag)
    return jsonify({"Result": "Tag Added"})


@app.route('/upload', methods=['POST'])
def upload():

    image_sha1 = request.get_json()
    image_sha1 = image_sha1["image_sha1"]
    app.logger.info('Get query for %s', str(image_sha1))

    if is_uploaded(image_sha1):
        return jsonify({})
    else:
        onetime_uuid = str(uuid.uuid4())
        onetime_upload_url = get_store().presigned_put_object(
            app.config['MINIO_BUCKET_NAME'],
            onetime_uuid,
            expires=timedelta(seconds=3000))

        app.logger.info('return one time url %s', onetime_upload_url)
        return jsonify({'upload_url': onetime_upload_url})


def get_image_tags(image_id):
    client = get_db()
    txn = client.txn(read_only=True)
    query = """{{
        result(func: eq(image_uuid,"{0}")){{
            stored_at{{
                tagged_with{{
                    tag_name
                }}
            }}
        }}
    }}""".format(image_id)
    res = txn.query(query=query)
    res = json.loads(res.json)["result"]
    if len(res) == 1:
        res = get_image_tags_view(res)
    else:
        res = {}
    return res


def get_image_tags_view(res):
    res_view = []
    for idx, tag in enumerate(res):
        tags_info = tag.get("stored_at", {}).get("tagged_with", {})
        if tags_info:
            for tag in tags_info:
                res_view.append(tag.get("tag_name", ""))
    logging.debug("%s", res_view)
    return res_view


def get_tag_id(tag_name):
    client = get_db()
    txn = client.txn(read_only=True)
    query = """query result($tag_name: string) {
        result(func: eq(tag_name,$tag_name)){
            uid
        }
    }"""
    variables = {'$tag_name': tag_name}
    res = txn.query(query=query, variables=variables)
    res = json.loads(res.json)["result"]
    if len(res) == 1:
        uid = res[0].get("uid", "None")
        if not uid:
            raise Exception("Get tag uid error")
        else:
            return uid
    return None


def get_images(tag='', image_sha1='', image_uuid='', limit=10, offset=0):
    time_start = time.time()
    client = get_db()
    txn = client.txn(read_only=True)
    query = """{{
        count(func: type(Image)){{
            count(uid)
        }}
        images(func: type(Image), first:{0}, offset: {1}, orderdesc: updated_at){{
            uid
       	    image_uuid
            updated_at
            stored_at{{
                expand(_all_){{
                    expand(_all_)
                }}
            }}
        }}
    }}""".format(limit, offset)
    res = txn.query(query=query)
    app.logger.debug('%s', res)
    app.logger.debug('time_spend_query %s', time.time()-time_start)
    res = json.loads(res.json)
    res = get_images_view(res)
    return res


def get_images_by_tag(tag='', limit=10, offset=0):
    client = get_db()
    txn = client.txn(read_only=True)
    query = """{{
        tag(func: eq(tag_name,"{0}")){{
          Tag as uid
        }}
        images(func: uid(Tag)){{
          tagged_by: ~tagged_with (first:{1}, offset:{2}){{
            uid 
          	refer_to: ~stored_at{{
          		expand(_all_)
        		}}
            expand(_all_){{
              expand(_all_){{
            	}}
            }}
        	}}
        count: count(~tagged_with)
        }}
      }}""".format(tag, limit, offset)
    res = txn.query(query=query)
    app.logger.debug('%s', res)
    res = json.loads(res.json)
    res = get_images_by_tag_view(res)
    #app.logger.debug('Get tag id %s for %s',res, tag_name)
    return res


def get_images_by_tag_view(res):
    result = {"count": 0, "images": []}
    res_view = {
        'images': []
    }
    image_info_list = res_view['images']
    if len(res['images']) != 1:
        return jsonify(result)
    if not res['images'][0].get('tagged_by', []):
        return jsonify(result)
    result["count"] = res['images'][0].get('count')
    storage_info_list = sorted(res['images'][0].get('tagged_by', []),
                               key=lambda image: image.get("refer_to", [])[0]['image_uuid'])
    for idx, storage_info in enumerate(storage_info_list):
        logging.debug("%s", storage_info.get(
            storage_info["refer_to"][0]['image_uuid'], ''))
    for idx, storage_info in enumerate(storage_info_list):
        image_uuid = storage_info["refer_to"][0]['image_uuid']
        image = {"image_uuid": image_uuid}
        onetime_get_url = ''
        bucket = storage_info.get("minio_bucket", '')
        obj_path = storage_info.get("minio_obj_path", '')
        has_thumbnail = storage_info.get("has_thumbnail", False)
        app.logger.info("Thumb nail is %s",
                        storage_info.get("has_thumbnail", False))
        if (has_thumbnail == "true"):
            # Todo error handle
            app.logger.info("Todo error handle")
            pass
        else:
            app.logger.info("Todo error handle")
            pass
        if bucket and obj_path and has_thumbnail:
            try:
                get_store().stat_object(bucket, obj_path + "-thumbnail")
                onetime_get_url = get_store().presigned_get_object(
                    bucket,
                    obj_path+"-thumbnail",
                    expires=timedelta(seconds=3000))
            except ResponseError as err:
                app.logger.info(err)
            except NoSuchKey as err:
                app.logger.info(
                    "The image %s has wrong storage info", image.get("image_uuid", ''))
                app.logger.info(err)
            onetime_get_url = get_store().presigned_get_object(
                bucket,
                obj_path+"-thumbnail",
                expires=timedelta(seconds=3000))
        if not onetime_get_url:
            continue
        else:
            image["url"] = onetime_get_url
            image["thumbnail_url"] = onetime_get_url
            image_info_list.append(image)
        tags = storage_info.get("tagged_with", [])
        if tags:
            image["tags"] = []
            for tag in tags:
                image["tags"].append(tag.get("tag_name", ""))
    logging.debug("%s", image_info_list)
    result['images'] = image_info_list
    resp = jsonify(result)
    return resp


def get_image_view(res):
    image_detail_view = None
    image_detail = json.loads(res.json)
    image_detail = image_detail.get('image_detail', [])
    if len(image_detail) == 0:
        pass
    elif len(image_detail) == 1:
        image_detail = image_detail[0]
        app.logger.debug('%s', image_detail)
        image_uuid = image_detail.get("image_uuid", "")
        image_url = image_detail.get("image_url", "")
        image_thumbnail_url = image_detail.get("image_thumbnail_url", "")
        image_tags = image_detail.get("image_tags", [])
        storage_info = image_detail.get("stored_at", {})
        onetime_get_url = ''
        onetime_get_thumbnail_url = ''
        if storage_info:
            has_thumbnail = storage_info.get("has_thumbnail", False)
            bucket = storage_info.get("minio_bucket", '')
            obj_path = storage_info.get("minio_obj_path", '')
            image_tags = [x["tag_name"]
                          for x in storage_info.get("tagged_with", [])]
            if bucket and obj_path:
                onetime_get_url = get_store().presigned_get_object(
                    bucket,
                    obj_path,
                    expires=timedelta(seconds=3000))
            if not onetime_get_url:
                pass
            else:
                if has_thumbnail:
                    onetime_get_thumbnail_url = get_store().presigned_get_object(
                        bucket,
                        obj_path+"_thumbnail",
                        expires=timedelta(seconds=3000))
                else:
                    onetime_get_thumbnail_url = onetime_get_url
                tag_confirmed = storage_info.get("tag_confirmed", False)
                app.logger.debug(
                    'get image view, image_uuid is %s', image_uuid)
                image_detail_view = {
                    "image_uuid": image_uuid,
                    "image_url": onetime_get_url,
                    "image_thumbnail_url": onetime_get_thumbnail_url,
                    "image_tags": image_tags,
                    "tag_confirmed": tag_confirmed,
                }
    else:
        pass
    return image_detail_view


def get_storage_obj_key(res):
    obj_key = ''
    image_detail_view = None
    image_detail = json.loads(res.json)
    image_detail = image_detail.get('image_detail', [])
    if len(image_detail) == 0:
        pass
    elif len(image_detail) == 1:
        image_detail = image_detail[0]
        obj_key = image_detail.get("stored_at", {}).get("minio_obj_path", '')
    else:
        pass
    return obj_key


def get_tags_from_image_detail(res):
    tags = []
    image_detail_view = None
    image_detail = json.loads(res.json)
    image_detail = image_detail.get('image_detail', [])
    if len(image_detail) == 0:
        pass
    elif len(image_detail) == 1:
        image_detail = image_detail[0]
        storage_info = image_detail.get("stored_at", {})
        if storage_info:
            image_tags = [x["tag_name"]
                          for x in storage_info.get("tagged_with", [])]
            tags = image_tags
    else:
        pass
    return tags


def get_images_view(res):
    image_count = res['count'][0].get('count')
    res_view = {
        'images': []
    }
    image_info_list = res_view['images']
    #res['images'] = sorted(res['images'], key=lambda image: image['image_uuid'])
    for idx, image in enumerate(res['images']):
        logging.debug("%s", image.get("image_uuid", ''))
    for idx, image in enumerate(res['images']):
        logging.debug("%s", image.get("image_uuid", ''))
        storage_info = image.get("stored_at", {})
        onetime_get_url = ''
        if storage_info:
            logging.debug("%s", image.get("image_uuid", ''))
            bucket = storage_info.get("minio_bucket", '')
            obj_path = storage_info.get("minio_obj_path", '')
            has_thumbnail = storage_info.get("has_thumbnail", False)
            app.logger.info("Thumb nail is %s",
                            storage_info.get("has_thumbnail", False))
            if (has_thumbnail == "true"):
                pass
            if bucket and obj_path and has_thumbnail:
                try:
                    get_store().stat_object(bucket, obj_path + "-thumbnail")
                    onetime_get_url = get_store().presigned_get_object(
                        bucket,
                        obj_path+"-thumbnail",
                        expires=timedelta(seconds=3000))
                except ResponseError as err:
                    app.logger.info(err)
                except NoSuchKey as err:
                    app.logger.info(
                        "The image %s has wrong storage info", image.get("image_uuid", ''))
                    app.logger.info(err)
                onetime_get_url = get_store().presigned_get_object(
                    bucket,
                    obj_path+"-thumbnail",
                    expires=timedelta(seconds=3000))
            if not onetime_get_url:
                continue
            else:
                image["url"] = onetime_get_url
                image["thumbnail_url"] = onetime_get_url
                image_info_list.append(image)
            tags = storage_info.get("tagged_with", [])
            tag_confirmed = storage_info.get("tag_confirmed", False)
            image["tag_confirmed"] = tag_confirmed
            if tags:
                image["tags"] = []
                for tag in tags:
                    image["tags"].append(tag.get("tag_name", ""))
            del image["stored_at"]
    logging.debug("%s", image_info_list)
    resp = jsonify(res_view)
    resp.headers['X-Total-Count'] = image_count
    return resp


def get_image_storage_info(image_uuid):
    client = get_db()

    txn = client.txn(read_only=True)
    query = """query result($image_uuid: string) {
        result(func: eq(image_uuid,$image_uuid)){
            stored_at {
                uid
            }
        }
    }"""
    variables = {'$image_uuid': image_uuid}
    res = txn.query(query=query, variables=variables)
    res = json.loads(res.json)["result"]
    if len(res) == 1:
        uid = res[0].get("stored_at", {}).get("uid", None)
        if not uid:
            raise Exception("Get image storage info error")
        else:
            return uid
    #app.logger.debug('Get tag id %s for %s',res, tag_name)
    return None


def add_image_tag(image_uuid, tag_name):
    client = get_db()

    txn = client.txn(read_only=False)
    query = """{{
        q1(func: eq(image_uuid,"{0}")){{
            stored_at{{
             s as uid
            }}
        }}
        q2(func: eq(tag_name,"{1}")){{
            t as uid
        }}
    }}""".format(image_uuid, tag_name)
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
    request = txn.create_request(
        query=query,
        mutations=[
            mutation,
            no_tag_mutation],
        commit_now=True)
    resp = txn.do_request(request)
    return resp


def update_image_tags(image_uuid, tags):
    current_tags = get_image_tags(image_uuid)
    to_add_tags = set(tags).difference(current_tags)
    to_del_tags = set(current_tags).difference(tags)
    add_tags(to_add_tags)
    client = get_db()
    for tag_name in to_add_tags:
        txn = client.txn(read_only=False)
        query = """{{
            q1(func: eq(image_uuid,"{0}")){{
                stored_at{{
                 s as uid
                }}
            }}
            q2(func: eq(tag_name,"{1}")){{
                t as uid
            }}
        }}""".format(image_uuid, tag_name)
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
        request = txn.create_request(
            query=query,
            mutations=[
                mutation,
                no_tag_mutation],
            commit_now=True)
        txn.do_request(request)
    for tag_name in to_del_tags:
        txn = client.txn(read_only=False)
        query = """{{
            q1(func: eq(image_uuid,"{0}")){{
                stored_at{{
                 s as uid
                }}
            }}
            q2(func: eq(tag_name,"{1}")){{
                t as uid
            }}
        }}""".format(image_uuid, tag_name)
        cond = "@if(eq(len(s), 1) and eq(len(t), 1))"
        nquad = 'uid(s) <tagged_with> uid(t) .'
        mutation = txn.create_mutation(del_nquads=nquad, cond=cond)
        request = txn.create_request(
            query=query,
            mutations=[mutation],
            commit_now=True)
        txn.do_request(request)


def delete_image_tag(image_uuid, tag_name):
    client = get_db()
    txn = client.txn(read_only=False)
    query = """{{
        q1(func: eq(image_uuid,"{0}")){{
            stored_at{{
             s as uid
            }}
        }}
        q2(func: eq(tag_name,"{1}")){{
            t as uid
        }}
    }}""".format(image_uuid, tag_name)
    cond = "@if(eq(len(s), 1) and eq(len(t), 1))"
    nquad = 'uid(s) <tagged_with> uid(t) .'
    mutation = txn.create_mutation(del_nquads=nquad, cond=cond)
    request = txn.create_request(
        query=query,
        mutations=[mutation],
        commit_now=True)
    resp = txn.do_request(request)
    return resp


def delete_image_by_id(image_uuid):
    client = get_db()

    txn = client.txn(read_only=False)
    query = """{{
        q1(func: eq(image_uuid,"{0}")){{
            i as uid
            stored_at{{
             s as uid
            }}
        }}
    }}""".format(image_uuid)
    cond = "@if(eq(len(s), 1))"
    nquad = '''
          uid(s) * * .
          uid(i) * * .
          '''
    mutation = txn.create_mutation(del_nquads=nquad, cond=cond)
    request = txn.create_request(
        query=query,
        mutations=[
            mutation],
        commit_now=True)
    resp = txn.do_request(request)
    return resp


def confirm_image_tag_by_id(image_uuid):
    client = get_db()

    txn = client.txn(read_only=False)
    query = """{{
        q1(func: eq(image_uuid,"{0}")){{
            stored_at{{
             s as uid
            }}
        }}
    }}""".format(image_uuid)
    cond = "@if(eq(len(s), 1))"
    nquad = '''
          uid(s) <tag_confirmed> "True" .
          '''
    mutation = txn.create_mutation(set_nquads=nquad, cond=cond)
    request = txn.create_request(
        query=query,
        mutations=[mutation],
        commit_now=True)
    resp = txn.do_request(request)
    return resp


def add_tags(tags):
    r = redis.Redis(host=app.config['REDIS_ADDR'] + '', port=6379, db=0)
    all_tags = r.hgetall('all_tags')
    if len(all_tags) == 0:
        all_tags = get_tags_mapping()
        r.hmset("all_tags", mapping=all_tags)
    new_tags = set(tags).difference(all_tags.keys())
    client = get_db()

    for tag_name in tags:
        txn = client.txn(read_only=False)
        query = """{{
            q2(func: eq(tag_name,"{0}")){{
                t as uid
            }}
        }}""".format(tag_name)
        cond = "@if(eq(len(t), 0))"
        nquad = """
            _:tag <tag_name> "{0}" .
            _:tag <dgraph.type> "Tag" .
        """.format(tag_name)
        mutation = txn.create_mutation(set_nquads=nquad, cond=cond)
        request = txn.create_request(
            query=query,
            mutations=[mutation],
            commit_now=True)
        txn.do_request(request)
    all_tags = get_tags_mapping()
    r.hmset("all_tags", mapping=all_tags)


def add_tag(tag_name):
    client = get_db()

    txn = client.txn(read_only=False)
    query = """{{
        u as var(func: eq(tag_name, "{0}"))
    }}""".format(tag_name)
    app.logger.debug('Add new tag name %s', tag_name)
    cond = "@if(eq(len(u), 0))"
    nquad = """
        uid(u) <dgraph.type> "Tag" .
        uid(u) <tag_name> "{0}" .
    """.format(tag_name)
    app.logger.debug('Add new tag name nquad %s', nquad)
    mutation = txn.create_mutation(set_nquads=nquad)
    request = txn.create_request(
        query=query,
        mutations=[mutation],
        commit_now=True)
    txn.do_request(request)
    return


def remove_unused_tags():
    client = get_db()

    txn = client.txn(read_only=False)
    query = """{
        tags(func: Type(Tag)) @filter(lt(count(~tagged_with),1)){
            u as uid,
            tag_name,
            count(~tagged_with)
        }
     }"""
    nquad = """
      uid(u) * * .
    """
    mutation = txn.create_mutation(del_nquads=nquad)
    request = txn.create_request(
        query=query,
        mutations=[mutation],
        commit_now=True)
    txn.do_request(request)
    return


def delete_tag():
    return


def update_tag():
    return


def add_new_image(
        minio_obj_path,
        image_sha1,
        human_readable_name='Unkown',
        minio_url= app.config['MINIO_ADDR'] + ':9000',
        minio_bucket=app.config['MINIO_BUCKET_NAME'],
        image_uuid=''):

    client = get_db()

    txn = client.txn(read_only=False)
    query = """{{
      u as var(func: eq(has_sha1, "{0}"))
    }}""".format(image_sha1)
    app.logger.debug('Add new image query %s', query)
    cond = "@if(eq(len(u), 0))"
    nquad = """
        uid(u) <dgraph.type> "StorageInfo" .
        uid(u) <minio_url> "{0}" .
        uid(u) <minio_bucket> "{1}" .
        uid(u) <minio_obj_path> "{2}" .
        uid(u) <has_sha1> "{3}" .
        uid(u) <tag_confirmed> "False" .
        _:image <dgraph.type> "Image" .
        _:image <stored_at> uid(u) . 
        _:image <image_uuid> "{4}" .
        _:image <readable_name> "{5}" .
        _:image <updated_at> "{6}" . 
    """.format(minio_url,
               minio_bucket,
               minio_obj_path,
               image_sha1,
               image_uuid,
               human_readable_name,
               datetime.datetime.now().isoformat())
    app.logger.debug('Add new image nquad %s', nquad)
    mutation = txn.create_mutation(set_nquads=nquad, cond=cond)
    request = txn.create_request(
        query=query,
        mutations=[mutation],
        commit_now=True)
    res = txn.do_request(request)


def is_uploaded(image_sha1_key):
    res = []
    if image_sha1_key:
        db = get_db()
        txn = db.txn(read_only=True)
        # Run query.
        query = """query all($a: string) {
            all(func: eq(has_sha1, $a))
            {
                has_sha1
                minio_url
            }
        }"""
        variables = {'$a': image_sha1_key}

        res = txn.query(query, variables=variables)
        res = json.loads(res.json)["all"]
        app.logger.info("is uploaded result %s", res)
    return res


def get_image_by_hash(image_sha1):
    if image_sha1:
        db = get_db()
        txn = db.txn(read_only=True)
        # Run query.
        query = """query all($a: string) {
            all(func: eq(hash_id, $a))
            {
                hash_id
            }
        }"""
        variables = {'$a': image_sha1}

    res = txn.query(query, variables=variables)

    return res


def get_image_by_id(image_uuid):
    if image_uuid:
        db = get_db()
        txn = db.txn(read_only=True)
        # Run query.
        query = """query image_detail($a: string) {
            image_detail(func: eq(image_uuid, $a))
            {
                expand(_all_){
                    expand(_all_){
                        expand(_all_){
                        }
                    }
                }
            }
        }"""
        variables = {'$a': image_uuid}
    res = txn.query(query, variables=variables)
    return res


def get_image_by_id(image_uuid):
    if image_uuid:
        db = get_db()
        txn = db.txn(read_only=True)
        # Run query.
        query = """query image_detail($a: string) {
            image_detail(func: eq(image_uuid, $a))
            {
                expand(_all_){
                    expand(_all_){
                        expand(_all_){
                        }
                    }
                }
            }
        }"""
        variables = {'$a': image_uuid}

    res = txn.query(query, variables=variables)

    return res


def get_all_images(image_sha1=''):
    db = get_db()
    txn = db.txn(read_only=True)
    res = None
    if image_sha1:
        # Run query.
        query = """query all($a: string) {
          all(func: eq(hash_id, $a))
          {
            hash_id
          }
        }"""
        variables = {'$a': image_sha1}

        res = txn.query(query, variables=variables)

    return res


def get_tags():
    db = get_db()
    txn = db.txn(read_only=True)
    res = None
    query = """{
        tags(func: Type(Tag)) @filter(gt(count(~tagged_with),0) ){
            uid,
            tag_name,
            number_of_images: count(~tagged_with)
        }
    }"""
    res = txn.query(query)
    return res


def get_tag_detail(tag_name):
    db = get_db()
    txn = db.txn(read_only=True)
    res = None
    query = """query tag($tag_name: string) {
        tag(func: eq(tag_name, $tag_name)){
            uid,
            tag_name
        }
    }"""
    variables = {'$tag_name': tag_name}
    res = txn.query(query, variables=variables)
    return res


def get_tags_view(resp):
    tags = {"tags": {}}
    for i in json.loads(resp.json).get("tags", {}):
        tag = i.get("tag_name", "")
        if tag:
            tags["tags"][tag] = int(i.get("number_of_images", "0"))
    return tags


def get_tags_mapping():
    tags_mapping = {}
    tags = get_tags()
    for i in json.loads(tags.json).get("tags", {}):
        tag = i.get("tag_name", "")
        if tag:
            tags_mapping[tag] = i.get("uid")
    return tags_mapping


def get_tag_detail_view(resp):
    tag = json.loads(resp.json).get("tag", [])
    if not len(tag) == 1:
        return {}
    tag = tag[0]
    tag = {"tag": {"tag_name": tag["tag_name"], "uid": tag["uid"]}}
    return tag


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
