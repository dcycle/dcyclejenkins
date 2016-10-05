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
if [ "$2" != "data-volume-reset-perms" ] && [ "$2" != "data-volume-no-reset-perms" ]; then
  echo 'The second parameter needs to be either:'
  echo "data-volume-reset-perms or data-volume-no-reset-perms"
  echo 'Using reset perms can fix https://github.com/jenkinsci/docker/issues/177#issuecomment-163656932'
  echo 'which can occur on CoreOS; on native Mac OS X Docker, data-volume-no-reset-perms is.'
  echo 'preferred.'
  exit 1
fi

DATADIR="$1"

./scripts/destroy-all.sh

./scripts/lib/build-jenkinsslave.sh
./scripts/lib/build-jenkins.sh "$DATADIR" "$2"
./scripts/lib/build-jenkinscli.sh

./scripts/reset-master-slave-ssh.sh

echo " => You can now acces your Jenkins instance at port 8080."
echo " => Your data is at $DATADIR."
echo " => You can always reset the admin password by typing ./scripts/reset-password.sh"
