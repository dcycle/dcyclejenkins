Dcycle Jenkins
=====

A Docker-based Jenkins installation.

Prerequisites
-----

 * CoreOS (recommended)
 * Docker (included by default on CoreOS)

Usage
-----

Step 1: choose a data folder, in this example we'll use:

    mkdir /home/core/data

Step 2: clone this repo, for example if you are on CoreOS you can do:

    cd /home/core
    git clone https://github.com/dcycleproject/dcyclejenkins.git
    cd dcyclejenkins

Step 3: run the build script and follow instructions:

    ./scripts/build-all.sh /home/core/data

If all goes well, you should now have a running Jenkins instance at port 8080.

Some useful commands
-----

* To access Jenkins CLI use `./scripts/jenkins-cli.sh "command"`, for example `./scripts/jenkins-cli.sh "help"`
* To reset your admin password use `./scripts/reset-password.sh `
