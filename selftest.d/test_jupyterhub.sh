#!/bin/bash

#RUN_IN_CONTAINER jupyterhub

set -o errexit # bail out on all errors immediately
set -x


#JH_IMLIST="/test_dockerimagelist.log"
#JH_VER="/test_dockerversion.log"

JH_USERIMAGE="cernphsft/systemuser"
JH_USERIMAGE_VER="v2.11"

#docker images > $JH_IMLIST || exit 1
docker images > /dev/null || exit 1
docker version --format '{{.Server.Version}}' > /dev/null || exit 1
docker version --format '{{.Client.Version}}' > /dev/null || exit 1

AVAILABLE_USERIMAGE=`docker images | grep -i $JH_USERIMAGE | grep -i $JH_USERIMAGE_VER | tr -s ' ' | cut -d ' ' -f 1,2 | tr ' ' ':'`
if [ "$JH_USERIMAGE:$JH_USERIMAGE_VER" == "$AVAILABLE_USERIMAGE" ]; then
	continue
else
	exit 1
fi

TEST_NAME="jupyter-test$RANDOM"
docker run --name $TEST_NAME -it -d $AVAILABLE_USERIMAGE tail -f /dev/null || exit 1
docker stop $TEST_NAME || exit 1
docker rm $TEST_NAME || exit 1

