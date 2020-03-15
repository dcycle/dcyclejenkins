#!/bin/bash
#
# Update Jenkins with SSL
#
set -e
git pull origin master
docker pull jenkins/jenkins:lts
docker-compose -f docker-compose.yml \
  -f docker-compose.ssl.yml up -d
docker restart nginx-proxy
docker restart nginx-letsencrypt
