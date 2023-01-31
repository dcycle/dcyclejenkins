#!/bin/bash
#
# Export data.
#
set -e

SOURCE=./do-not-commit/export/jenkins_home

if [ ! -d "$SOURCE" ]; then
  >&2 echo "$SOURCE must exist for import to work. See README.md."
  exit 1
fi

docker-compose exec --user root jenkins /bin/bash -c 'rm -rf /imported'

docker cp ./do-not-commit/export/jenkins_home $(docker-compose ps -q jenkins):/imported

docker-compose exec --user root jenkins /bin/bash -c 'rm -rf /var/jenkins_home/*'
docker-compose exec --user root jenkins /bin/bash -c 'mv /imported/* /var/jenkins_home/'

echo ""
echo " ==> Data imported from $SOURCE"
echo ""
