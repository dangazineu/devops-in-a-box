#!/bin/bash

set -e

EXTERNAL_REGISTRY=$1
IMAGE=$2
VERSION=$3
LOCAL_REGISTRY=localhost:5000

echo "Pulling image $EXTERNAL_REGISTRY/$IMAGE:$VERSION"

if ! docker pull $LOCAL_REGISTRY/$IMAGE:$VERSION  ; then
    echo "Failed to load image from local registry, will pull from remote and push locally"
    docker pull $EXTERNAL_REGISTRY/$IMAGE:$VERSION
    docker tag $EXTERNAL_REGISTRY/$IMAGE:$VERSION $LOCAL_REGISTRY/$IMAGE:$VERSION
    docker push $LOCAL_REGISTRY/$IMAGE:$VERSION
else
    echo "Pulled image from local registry"
    docker tag $LOCAL_REGISTRY/$IMAGE:$VERSION $EXTERNAL_REGISTRY/$IMAGE:$VERSION
fi
