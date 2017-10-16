#!/bin/bash
#
# Update Jenkins with SSL
#
docker pull jenkins/jenkins:lts
docker-compose -f docker-compose.yml \
  -f docker-compose.ssl.yml up -d
