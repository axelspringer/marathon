#!/bin/bash

build() {
  MARATHON_VERSION=$1

  TAG=${MARATHON_VERSION}

# base
  docker build \
    --compress \
    --squash \
    -t pixelmilk/marathon \
    --build-arg MARATHON_VERSION=${TAG} \
    . || exit $?

# tag
  echo
  echo Tagging pixelmilk/marathon:${TAG}
  docker tag pixelmilk/marathon pixelmilk/marathon:${TAG} \
    || exit $?
}

#     Mesos version
build "1.4.7"