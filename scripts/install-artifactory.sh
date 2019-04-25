#!/bin/bash

set -e

EXTERNAL_REGISTRY="docker.bintray.io"
IMAGE="jfrog/artifactory-oss"
VERSION="6.3.3"

pull-image.sh $EXTERNAL_REGISTRY $IMAGE $VERSION

cat <<EOF > /etc/init.d/artifactory

#!/bin/sh
### BEGIN INIT INFO
# Provides:          artifactory
# Required-Start:
# Required-Stop:
# Default-Start:
# Default-Stop:
# Description:       Artifactory
### END INIT INFO

start() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
docker ps --filter "name=artifactory" | grep artifactoryasdasd


  docker run -d \
    -p 8081:8081 \
    -e START_TMO=120 \
    -e RUNTIME_OPTS="-Xms512m -Xmx4g" \
    -v /vagrant/artifactory/data:/var/opt/jfrog/artifactory/data \
    -v /vagrant/artifactory/logs:/var/opt/jfrog/artifactory/logs  \
    -v /vagrant/artifactory/backup:/var/opt/jfrog/artifactory/backup  \
    -v /vagrant/artifactory/etc:/var/opt/jfrog/artifactory/etc \
    --restart=always \
    --name artifactory \
    $EXTERNAL_REGISTRY/$IMAGE:$VERSION
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

status() {
  docker ps --filter "name=artifactory" | grep artifactory > /dev/null
  return
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  retart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
esac


EOF

chmod 755 /etc/init.d/artifactory.sh

