#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo 'Parameter 1 needs to be a data directory, for example:'
  echo '/Users/albert/Documents/dev/docker/data'
  exit 1
fi

if [ -z "$2" ]; then
  echo 'Parameter 2 needs to be a password description: server-root'
  exit 1
fi

DATADIR="$1"
PASSDESC="$2"

mkdir -p "$DATADIR"/passwords

PASSWORD="$(./scripts/make-password.sh)"

echo "$PASSWORD" > "$DATADIR"/passwords/"$PASSDESC"
echo "$PASSWORD"
