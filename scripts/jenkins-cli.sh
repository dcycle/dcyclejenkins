#!/bin/bash
set -e

SSHDIR="$HOME/.jenkinscli-ssh"

docker run -it --rm \
  --link myjenkins:jenkins \
  -v "$SSHDIR":/ssh \
  -e "JENKINS_URL=http://jenkins:8080" \
  chickenzord/jenkins-cli $1
