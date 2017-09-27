#!/bin/bash
#
# Destroy all running containers.
#
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

echo -e '[info] start destroying containers'
export DATADIR="$DATADIR"
docker-compose kill
docker-compose rm -f
echo -e '[info] end destroying containers'
