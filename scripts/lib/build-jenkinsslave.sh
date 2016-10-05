#!/bin/bash
set -e

echo "[info] (re-)building the Jenkins Slave."

./scripts/kill-container.sh myjenkinsslave

docker build -f="Dockerfile-jenkinsslave" \
  -t myjenkinsslave-image .

docker run \
  --name myjenkinsslave \
  -v /var/run/docker.sock:/var/run/docker.sock -dti myjenkinsslave-image /bin/sh

echo "[info] Jenkins Slave should be fully available now."
