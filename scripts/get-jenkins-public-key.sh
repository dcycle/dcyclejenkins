#!/bin/bash
set -e

docker exec -t -u jenkins myjenkins /bin/bash -c 'cat ~/.ssh/id_rsa.pub'
