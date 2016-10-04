set -e

if [ ! -d "$1" ]; then
  echo 'The first parameter needs to be a data directory, but'
  echo "$1 is not a valid directory"
  exit 1
fi

DATADIR="$1"

./scripts/destroy-all.sh

./scripts/lib/build-jenkins.sh "$DATADIR"
./scripts/lib/build-jenkinscli.sh

echo " => You can now acces your Jenkins instance at port 8080."
echo " => Your data is at $DATADIR."
