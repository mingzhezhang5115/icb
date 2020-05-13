# Image Collection Backend

Backend components and installation ansible playbook

## Code Structure 

```

backend/
├── api_server 
│   ├── api.py # A flask api server work with Dgraph and MinIO
│   ├── config.py # config file, update before build
│   ├── Dockerfile # ship this app as Docker container
│   └── requirements.txt # python packages used in this flask app
├── image_processor
│   ├── image_processor.py # python script work with celery, tensorflow, MinIO and Dgraph for thumbnail generation, face detection, general classification
│   └── requirements.txt # packages required for this processor
├── model_builder
│   ├── requirements.txt 
│   └── transfer_learning.py # python script to build new model with tensorflowlist based on transfer learning
├── README.md
└── setup
    └── development_env.yml # an Ansible playbook to install prerequisite for this backend

```


