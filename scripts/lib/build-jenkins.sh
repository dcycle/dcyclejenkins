#!/bin/bash
set -e

echo "[info] (re-)starting to build Jenkins."

if [ -z "$1" ]; then
  echo 'Parameter 1 needs to be a data directory, for example:'
  echo '/Users/albert/Documents/dev/docker/data'
  exit 1
fi

if [ ! -d "$1" ]; then
  echo 'The first parameter needs to be a data directory, but'
  echo "$1 is not a valid directory"
  exit 1
fi
if [ "$2" != "data-volume-reset-perms" ] && [ "$2" != "data-volume-no-reset-perms" ]; then
  echo 'The second parameter needs to be either:'
  echo "data-volume-reset-perms or data-volume-no-reset-perms"
  echo 'Using reset perms can fix https://github.com/jenkinsci/docker/issues/177#issuecomment-163656932'
  echo 'which can occur on CoreOS; on native Mac OS X Docker, data-volume-no-reset-perms is.'
  echo 'preferred.'
  exit 1
fi

DATADIR="$1"

if [ "$2" == 'data-volume-reset-perms' ]; then
  # See https://github.com/jenkinsci/docker/issues/177#issuecomment-163656932
  # This problem occurs on CoreOS without NFS but not native Mac OS Docker.
  mkdir -p "$DATADIR"/jenkins
  sudo chown 1000 "$DATADIR"/jenkins
fi

./scripts/kill-container.sh myjenkins

docker build -f="Dockerfile-jenkins" \
  -t myjenkins-image .

docker run -d --name myjenkins \
  -p 8080:8080 \
  --link myjenkinsslave:slave \
  --volume "$DATADIR"/jenkins:/var/jenkins_home \
  myjenkins-image

if [ "$(docker exec myjenkins /bin/bash -c 'cat /var/jenkins_home/users/*/config.xml 2>/dev/null |grep emailAddress || echo not-yet-installed')" == 'not-yet-installed' ]; then
  INSTALLED=false
else
  INSTALLED=true
fi

WAIT=40
echo "[info] About to wait $WAIT seconds for Jenkins to be up and running. This"
echo "       allows time for the /var/jenkins_home/secrets/initialAdminPassword"
echo "       file to be generated if this is a first-time setup; it also allows"
echo "       time for the Jenkins frontend to be != 503 (service unavailable)"
echo "       which can break the cli."
sleep "$WAIT"

if [ "$INSTALLED" == 'false' ]; then
  while [ "$(docker exec myjenkins /bin/bash -c 'if [ -f /var/jenkins_home/secrets/initialAdminPassword ]; then echo ready-for-install; else echo not-ready-for-install; fi')" == 'not-ready-for-install' ]; do
    echo "Waiting for the file /var/jenkins_home/secrets/initialAdminPassword to"
    echo "be generated on the myjenkins container. This should take less than a minute."
    sleep 5;
  done

  INITIALADMINPASSWORD="$(docker exec myjenkins /bin/bash -c 'cat /var/jenkins_home/secrets/initialAdminPassword')"

  echo "You still need to perform some manual steps in order to fully install"
  echo "Jenkins."

  while [ "$INSTALLED" == 'false' ]; do

    echo "Go to http://docker:8080 and enter the initial admin password"
    echo "($INITIALADMINPASSWORD), then select 'install suggested plugins',"
    echo "then create user 1 with the following credentials:"

    ADMINUSER='admin'
    ADMINPASS="$(./scripts/random-password.sh)"

    echo " => Use $ADMINUSER as a jenkins admin username"
    echo " => Use $ADMINPASS as a jenkins admin password"
    echo " => Use $ADMINUSER as a jenkins admin real name"
    echo " => Use $ADMINUSER@example.com as a jenkins admin email"

    echo "Please type enter when Jenkins is fully installed:"
    read USERINPUT

    if [ "$(docker exec myjenkins /bin/bash -c 'cat /var/jenkins_home/users/*/config.xml|grep emailAddress 2>/dev/null || echo not-yet-installed')" == 'not-yet-installed' ]; then
      INSTALLED=false
    else
      INSTALLED=true
    fi
  done
fi

echo "[info] Jenkins should be fully available now."
