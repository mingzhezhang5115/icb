# Image Collection Backend for Smartphones

A scalable client-server system for photo management with semi-automatically tagging system.


## Code structure

```
.
├── backend #code of backend
│   ├── api_server #flask api server source code and Dockerfile
│   ├── image_processor #python script for image processing
│   ├── model_builder #python script to build new model with transfer learning
│   └── setup #ansbile playbook for environment setup
└── client #code of client
    ├── android #android code to implementt jobservice, workmanager, methodchannel
    ├── build
    ├── gen
    ├── images
    ├── ios
    ├── lib #dart code to generate ui and do http requests
    └── test

```

