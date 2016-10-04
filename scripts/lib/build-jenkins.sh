#!/bin/bash
set -e

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

DATADIR="$1"

./scripts/kill-container.sh myjenkins

docker build -f="Dockerfile-jenkins" \
  -t myjenkins-image .

docker run -d --name myjenkins \
  -p 8080:8080 \
  --volume "$DATADIR"/jenkins:/var/jenkins_home \
  myjenkins-image

if [ "$(docker exec myjenkins /bin/bash -c 'cat /var/jenkins_home/users/*/config.xml 2>/dev/null |grep emailAddress || echo not-yet-installed')" == 'not-yet-installed' ]; then
  INSTALLED=false
else
  INSTALLED=true
fi

if [ "$INSTALLED" == 'false' ]; then
  while [ "$(docker exec myjenkins /bin/bash -c 'if [ -f /var/jenkins_home/secrets/initialAdminPassword ]; then echo ready-for-install; else echo not-ready-for-install; fi')" == 'not-ready-for-install' ]; do
    echo "Waiting for the file /var/jenkins_home/secrets/initialAdminPassword to"
    echo "be generated on the myjenkins container."
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
    ADMINPASS="$(./scripts/make-password.sh)"

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
