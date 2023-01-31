#!/bin/bash
#
# Get data from remote server.
#
set -e

if [ -z "$1" ]; then
    echo 'Please provide as password as the first parameter.'
    exit 1;
fi

PASSWORD="$1"
SALT="$(./scripts/random-password.sh)"

# See http://stackoverflow.com/questions/6988849
HASH=$(docker run ubuntu /bin/bash -c "echo -n '$PASSWORD{$SALT}' | sha256sum | sed 's/[ -]//g'")
docker-compose exec jenkins /bin/bash -c "sed -i.bak 's/<passwordHash>.*<\/passwordHash>/<passwordHash>$SALT:$HASH<\/passwordHash>/g' /var/jenkins_home/users/admin/config.xml"

docker-compose restart jenkins

echo " => Admin password is now $PASSWORD"
