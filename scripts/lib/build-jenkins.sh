#!/bin/bash
#
# Installs the Jenkins server if necessary based on the state of the persistent
# data.
#
set -e

#
if [ "$(docker-compose exec jenkins /bin/bash -c 'cat /var/jenkins_home/users/*/config.xml 2>/dev/null | grep emailAddress || echo not-yet-installed')" == 'not-yet-installed' ]; then
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
  while [ "$(docker-compose exec jenkins /bin/bash -c 'if [ -f /var/jenkins_home/secrets/initialAdminPassword ]; then echo ready-for-install; else echo not-ready-for-install; fi')" == 'not-ready-for-install' ]; do
    echo "Waiting for the file /var/jenkins_home/secrets/initialAdminPassword to"
    echo "be generated on the myjenkins container. This should take less than a minute."
    sleep 5;
  done

  INITIALADMINPASSWORD="$(docker-compose exec jenkins /bin/bash -c 'cat /var/jenkins_home/secrets/initialAdminPassword')"

  echo "You still need to perform some manual steps in order to fully install"
  echo "Jenkins."

  while [ "$INSTALLED" == 'false' ]; do

    echo "Go to $(docker-compose port jenkins 8080) and enter the initial admin password"
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

    if [ "$(docker-compose exec jenkins /bin/bash -c 'cat /var/jenkins_home/users/*/config.xml|grep emailAddress 2>/dev/null || echo not-yet-installed')" == 'not-yet-installed' ]; then
      INSTALLED=false
    else
      INSTALLED=true
    fi
  done
fi

echo "[info] Jenkins should be fully available now."
