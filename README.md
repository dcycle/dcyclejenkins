Dcycle Jenkins
=====

A Docker-based Jenkins installation.

Prerequisites
-----

 * CoreOS (recommended)
 * Docker (included by default on CoreOS)

Installation
-----

Step 1: choose a data folder, in this example we'll use:

    mkdir /home/core/data

This is the directory containing all your jobs, builds, and that you will be backing up.

Step 2: clone this repo, for example if you are on CoreOS you can do:

    cd /home/core
    git clone https://github.com/dcycleproject/dcyclejenkins.git
    cd dcyclejenkins

Step 3: run the build script and follow instructions:

    ./scripts/build-all.sh /home/core/data

If all goes well, you should now have a running Jenkins instance at port 8080.

You can reset the admin password using `./scripts/reset-password.sh `.

Updates, upgrades
-----

Step 1: back up your data folder.

Step 2: run the installation steps.

Where builds are run
-----

A "myjenkinsslave" container is provided on the Docker host, and is linked to the "myjenkins" container under the name "slave", and that container share the Docker socket with the host. This means that the "myjenkinsslave" can manage all Docker containers on the host, and potentially anything else. This means you should only run scripts you trust on containers.

Example job
-----

Let's say you want to make sure the [Ubuntu Docker image](https://hub.docker.com/_/ubuntu/) can be run correctly and that the `ls -lah /` command works, you can

 * create a new Freestyle project job called "Ubuntu-ls" on your Jenkins dashboard;
 * add the "execute shell" build step;
 * in the shell script section, add `ssh root@slave "/usr/local/bin/docker run ubuntu ls -lah /"`
 * save and run the build ("Build Now");
 * you should see a passing build.

Some useful commands
-----

 * To access Jenkins CLI use `./scripts/jenkins-cli.sh "command"`, for example `./scripts/jenkins-cli.sh "help"`
 * To reset your admin password use `./scripts/reset-password.sh `

Resources
-----

 * [Running Docker in Jenkins (in Docker), Adrian Mouat, Container-Solutions, March 11, 2015](http://container-solutions.com/running-docker-in-jenkins-in-docker/).
