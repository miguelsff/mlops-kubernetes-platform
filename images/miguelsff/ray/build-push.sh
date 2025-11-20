#!/bin/bash
REGISTRY=miguelsff
IMAGE_NAME=ray
TAG=2.41.0-py311

docker build -t $REGISTRY/$IMAGE_NAME:$TAG .
docker push $REGISTRY/$IMAGE_NAME:$TAG
