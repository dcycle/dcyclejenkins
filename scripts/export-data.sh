#!/bin/bash
#
# Export data.
#
set -e

rm -rf ./do-not-commit/export
mkdir -p ./do-not-commit/export
docker cp $(docker-compose ps -q jenkins):/var/jenkins_home ./do-not-commit/export

echo ""
echo " ==> Data exported to ./do-not-commit/export/jenkins_home"
echo ""
