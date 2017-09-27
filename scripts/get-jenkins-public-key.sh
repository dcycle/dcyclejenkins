#!/bin/bash
set -e

docker-compose exec -t -u jenkins jenkins /bin/bash -c 'cat ~/.ssh/id_rsa.pub'
