#!/bin/bash

set -e

DIR=$(dirname $0)

NAME="registry"
IMAGE="registry"
VERSION="2"

DOCKER=/usr/bin/docker

PULL_CMD="$DOCKER pull $IMAGE:$VERSION"
RUN_CMD="$DOCKER run -p 5000:5000 -v /vagrant/docker-registry/data:/var/lib/registry --restart=always --name $NAME $IMAGE:$VERSION"
STOP_CMD="$DOCKER stop $NAME"
RM_CMD="$DOCKER rm $NAME"

cat <<EOF > /etc/systemd/system/docker.registry.service
[Unit]
Description=Docker Registry Container
After=docker.service
Requires=docker.service

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

chmod 644 /etc/systemd/system/docker.registry.service

echo "Installing Docker Registry..."

systemctl daemon-reload
systemctl start docker.registry

echo -e "\033[0;32mDocker Registry installed!\033[0m"