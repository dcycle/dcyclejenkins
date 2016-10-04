set -e

if [ -z "$1" ]; then
  echo 'The first parameter needs to be a container name, for example:'
  echo 'mydrupal'
  exit 1
fi

echo './kill-container.sh: if your script hangs here and you are on Mac OS X'
echo 'native docker, please restart your computer.'
docker kill "$1" 2>/dev/null || true
docker rm "$1" 2>/dev/null || true
