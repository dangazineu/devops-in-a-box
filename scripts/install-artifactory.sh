#!/bin/bash

set -e

DIR=$(dirname $0)
NAME="artifactory"
EXTERNAL_REGISTRY="docker.bintray.io"
IMAGE="jfrog/artifactory-oss"
VERSION="6.3.3"

DOCKER=/usr/bin/docker

PULL_CMD="$DIR/pull-image.sh $EXTERNAL_REGISTRY $IMAGE $VERSION"
RUN_CMD="$DOCKER run -p 8081:8081 -e START_TMO=120 -e RUNTIME_OPTS=\"-Xms512m -Xmx4g\" -v /vagrant/artifactory/data:/var/opt/jfrog/artifactory/data -v /vagrant/artifactory/logs:/var/opt/jfrog/artifactory/logs  -v /vagrant/artifactory/backup:/var/opt/jfrog/artifactory/backup  -v /vagrant/artifactory/etc:/var/opt/jfrog/artifactory/etc --restart=always --name $NAME $EXTERNAL_REGISTRY/$IMAGE:$VERSION"
STOP_CMD="$DOCKER stop $NAME"
RM_CMD="$DOCKER rm $NAME"

cat <<EOF > /etc/systemd/system/artifactory.service
[Unit]
Description=Docker Artifactory Container
After=docker.registry.service
Requires=docker.registry.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-$STOP_CMD
ExecStartPre=-$RM_CMD
ExecStartPre=$PULL_CMD
ExecStart=$RUN_CMD

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/artifactory.service

echo "Installing Artifactory..."

systemctl daemon-reload
systemctl start artifactory

echo -e "\033[0;32mArtifactory installed!\033[0m"