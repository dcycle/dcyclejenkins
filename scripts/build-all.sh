#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo 'Parameter 1 needs to be a data directory, for example:'
  echo '/Users/albert/Documents/dev/docker/data'
  exit 1
fi

if [ ! -d "$1" ]; then
  echo 'The first parameter needs to be a data directory, but'
  echo "$1 is not a valid directory"
  exit 1
fi

DATADIR="$1"

./scripts/destroy-all.sh "$DATADIR"

export DATADIR="$DATADIR"
echo -e '[info] start building images'
docker-compose build
echo -e '[info] start running containers'
docker-compose up -d
echo -e '[info] end running containers'

./scripts/lib/build-jenkins.sh
./scripts/lib/build-jenkinscli.sh

echo " => You can now acces your Jenkins instance at port $(docker-compose port jenkins 8080)."
echo " => Your data is at $DATADIR."
echo " => You can always reset the admin password by typing ./scripts/reset-password.sh"
