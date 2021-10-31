#! /usr/bin/bash

image="shri-infrastructure"

docker build . -f Dockerfile -t ${image}

if [ $? -ne 0 ]
then
    echo "ERROR with create docker image"
    exit 1
else
    echo "Create docker image: ${image}"
fi