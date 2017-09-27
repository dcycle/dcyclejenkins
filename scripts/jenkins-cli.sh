#!/bin/bash
set -e

if [ ! -z "$2" ]; then
  INPUT_FILE="$2"
fi

SSHDIR="$HOME/.jenkinscli-ssh"

if [ ! -z "$INPUT_FILE" ]; then
  docker-compose run \
    --link jenkins:jenkins \
    -v "$SSHDIR":/ssh \
    -v $(pwd)/jenkins-jobs:/my-xml \
    -e "INPUT_FILE=/my-xml/$INPUT_FILE" \
    -e "JENKINS_URL=http://jenkins:8080" \
    dcycle/docker-jenkins-cli $1
else
  docker-compose run \
    --link jenkins:jenkins \
    -v "$SSHDIR":/ssh \
    -e "JENKINS_URL=http://jenkins:8080" \
    dcycle/docker-jenkins-cli $1
fi
