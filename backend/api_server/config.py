import os
import logging
from logging import config
DGRAPH_ADDR = os.getenv('DGRAPH_ADDR', '127.0.0.1')
MINIO_BUCKET_NAME = os.getenv('MINIO_BUCKET_NAME', 'icb-bucket')
MINIO_ADDR = os.getenv('MINIO_ADDR', '127.0.0.1')
REDIS_ADDR = os.getenv('REDIS_ADDR', '127.0.0.1')
LOGGER_CONFIG = {
    'version': 1,
    'formatters': {'default': {
        'format': '[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    }},
    'handlers': {
        'wsgi': {
            'class': 'logging.StreamHandler',
            'formatter': 'default'
        },
        'fh': {
            'class': 'logging.FileHandler',
            'filename': 'log/api.log',
            'formatter': 'default'

        }
    },
    'root': {
        'level': 'DEBUG',
        'handlers': ['wsgi', 'fh']
    }
}
   
