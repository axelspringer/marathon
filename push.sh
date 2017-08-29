#!/bin/bash

push() {
  MARATHON_VERSION=${1}

  TAG=${MARATHON_VERSION}

# base
  echo
  echo Pushing pixelmilk/marathon:${TAG}
  docker push pixelmilk/marathon:${TAG} || exit $?
}

# login docker before push
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

#    Mesos version
push "1.4.7"
