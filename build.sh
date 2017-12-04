#!/bin/bash

build() {
  MARATHON_VERSION=$1

  TAG=${MARATHON_VERSION}

# base
  docker build \
    --compress \
    --squash \
    -t axelspringer/marathon \
    --build-arg MARATHON_VERSION=${TAG} \
    . || exit $?

# tag
  echo
  echo Tagging axelspringer/marathon:${TAG}
  docker tag axelspringer/marathon axelspringer/marathon:${TAG} \
    || exit $?
}

#     Mesos version
build "1.5.2"