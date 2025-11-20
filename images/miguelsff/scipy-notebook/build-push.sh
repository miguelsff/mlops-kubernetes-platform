#!/bin/bash
REGISTRY=miguelsff
IMAGE_NAME=scipy-notebook
TAG=python-3.11

docker build -t $REGISTRY/$IMAGE_NAME:$TAG .
docker push $REGISTRY/$IMAGE_NAME:$TAG

