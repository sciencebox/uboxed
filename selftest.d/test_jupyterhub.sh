#!/bin/bash

#RUN_IN_CONTAINER jupyterhub

set -o errexit # bail out on all errors immediately
set -x

#docker images > $JH_IMLIST || exit 1
docker images > /dev/null || exit 1
docker version --format '{{.Server.Version}}' > /dev/null || exit 1
docker version --format '{{.Client.Version}}' > /dev/null || exit 1

if [[ -z $CONTAINER_IMAGE ]];
then
  echo "ERROR: Container image not set"
  echo "Please define CONTAINER_IMAGE="imagename:v0.1""
  exit 1
fi

CONTAINER_IMAGE_NAME=`echo $CONTAINER_IMAGE | cut -d ':' -f 1`	# Drop the tag
AVAILABLE_USERIMAGE=`docker images | grep "^$CONTAINER_IMAGE_NAME" | awk '{print $1":"$2}'`
if [ "$CONTAINER_IMAGE" == "$AVAILABLE_USERIMAGE" ]; then
  continue
else
  exit 1
fi

TEST_NAME="jupyter-test$RANDOM"
docker run --name $TEST_NAME -it -d $AVAILABLE_USERIMAGE tail -f /dev/null || exit 1
docker stop $TEST_NAME || exit 1
docker rm $TEST_NAME || exit 1

