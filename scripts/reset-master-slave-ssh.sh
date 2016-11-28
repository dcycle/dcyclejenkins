#!/bin/bash
set -e

# Create an ssh key pair only if one does not already exist. The key pair may be
# used to link Jenkins to external servers so we don't want to rebuild it if
# it exists.
docker exec myjenkins /bin/bash -c \
  'if [ ! -f /var/jenkins_home/.ssh/id_rsa ]; then rm -rf /var/jenkins_home/.ssh/id_rsa && ssh-keygen -t rsa -f /var/jenkins_home/.ssh/id_rsa -N ""; fi'

rm -rf /tmp/jenkins-public-key
mkdir -p /tmp/jenkins-public-key

docker exec myjenkinsslave /bin/sh -c \
  'mkdir -p /root/.ssh'

docker cp myjenkins:/var/jenkins_home/.ssh/id_rsa.pub /tmp/jenkins-public-key
docker cp /tmp/jenkins-public-key/id_rsa.pub myjenkinsslave:/root/.ssh/authorized_keys

docker exec myjenkinsslave /bin/sh -c "chmod go-w ~/ ~/.ssh ~/.ssh/authorized_keys"

docker exec myjenkins /bin/bash -c 'ssh -oStrictHostKeyChecking=no root@slave "ls"'

echo "[info] Your myjenkins container should now be able to run jobs in the myjenkinsslave"
echo "       container, which has Docker installed, and shares the docker socket with the docker host."
echo "       For example you can run:"
echo ""
echo "       docker exec myjenkins /bin/bash -c 'ssh root@slave \"/usr/local/bin/docker ps\"'"
echo ""
echo "       Your Jenkins jobs can have shell steps which can contain, for example:"
echo ""
echo "       ssh root@slave \"/usr/local/bin/docker run ubuntu /bin/bash -c 'ls -lah /'\""
