#!/bin/bash

set -e

apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-get install docker-ce

groupadd docker || true
gpasswd -a vagrant docker

service docker restart