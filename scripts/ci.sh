#!/bin/bash
#
# CI script.
#
set -e

docker-compose -f docker-compose.yml \
  -f docker-compose.nossl.yml up -d

docker-compose down -v
