Dcycle Jenkins
=====

A Docker-based Jenkins installation.

Prerequisites
-----

 * Docker, Docker-compose.

Installing, restart or updating
-----

    docker-compose up -d

If this is your first time running Jenkins, you will have to create your first user; first go to:

    docker-compose run jenkins /bin/bash -c 'cat /var/jenkins_home/secrets/initialAdminPassword'

Then:

 * Enter the result at my-server:8080.
 * Install suggested plugins
 * If you do not want to remember your password, use the username "admin", and see "Resetting the admin password".

Resetting your login password
-----

To change the password for the admin account and print it to the screen:

    ./scripts/reset-password.sh

Stopping containers while keeping your data
-----

    docker-compose down

Uninstalling
-----

    docker-compose down -v
