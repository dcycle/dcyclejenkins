Dcycle Jenkins
=====

A Docker-based Jenkins installation.

Prerequisites
-----

 * Docker

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
