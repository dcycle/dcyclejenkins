#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo 'The first parameter needs to be a connection string, such as'
  echo 'core@1.2.3.4'
  exit 1
fi

docker exec -t -u jenkins myjenkins /bin/bash -c "ssh -oStrictHostKeyChecking=no '$1' 'ls'"
