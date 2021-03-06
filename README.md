Dcycle Jenkins
=====

A Docker-based Jenkins installation.

Prerequisites
-----

 * Docker, Docker-compose.

Installing, restart or updating
-----

To deploy this **without** SSL on HTTP:

  docker-compose -f docker-compose.yml \
    -f docker-compose.nossl.yml up -d

And your Jenkins server will be at myserver:8080.

To deploy this **with** SSL on HTTPS:

    echo 'VIRTUAL_HOST=my-domain.example.com' >> ~/.dcyclejenkins.encryption.env
    echo 'LETSENCRYPT_HOST=my-domain.example.com' >> ~/.dcyclejenkins.encryption.env
    echo 'LETSENCRYPT_EMAIL=myemail@example.com' >> ~/.dcyclejenkins.encryption.env

    docker-compose -f docker-compose.yml \
      -f docker-compose.ssl.yml up -d

And follow the instructions at [Letsencrypt HTTPS for Drupal on Docker, Oct. 3, Dcycle blog](http://blog.dcycle.com/blog/170a6078/letsencrypt-drupal-docker/) and [Deploying Letsencrypt with Docker-Compose, Oct. 6, Dcycle blog](http://blog.dcycle.com/blog/7f3ea9e1/letsencrypt-docker-compose/).

If this is your first time running Jenkins, you will have to create your first user; first go to:

    docker-compose run jenkins /bin/bash -c 'cat /var/jenkins_home/secrets/initialAdminPassword'

Then:

 * Enter the result at my-server:8080.
 * Install suggested plugins
 * If you do not want to remember your password, use the username "admin", and see "Resetting the admin password".

To update to the latest version, assuming you are using SSL, run:

    ./scripts/update.sh

You should also update your plugins:

* go to /pluginManager/
* select all by clicking "Select all"
* install and restart Jenkins by checking the "Restart Jenkins when installation is complete and no jobs are running" checkbox

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

About SSH keys
-----

You might need to generate SSH keys on your Jenkins container in order to access git repos or servers. Because the Jenkins home folder is stored as a persistent volume, generated ssh keys will persist over time.

Here is an example of how you might use SSH in order to access a Git repo on Github:

### Step 1: Generate a ssh key.

docker-compose exec jenkins /bin/bash -c 'ssh-keygen -t rsa'

### Step 2: Get your public key.

docker-compose exec jenkins /bin/bash -c 'cat ~/.ssh/id_rsa.pub'

### Step 3: Copy it into Github under the name "My Jenkins"

You can do this on a repo-by-repo basis by going to https://github.com/MY/REPO/settings/keys

Allow write access if necessary.

### Step 4: Store the fingerprint

Often you will get a "Host key verification failed" on the Jenkins frontend.

To avoid this you must log in with a trusted network, type:

    docker-compose exec jenkins /bin/bash -c 'git ls-remote -h git@github.com:MY/REPO.git HEAD'

And then, if [the fingerprint is valid](https://help.github.com/articles/github-s-ssh-key-fingerprints/), when prompted "Are you sure you want to continue connecting (yes/no)", type:

    yes.

Command line (CLI) access
-----

Start by making sure you have a private-public ssh keypair (see above). To check if there already is one, type:

    docker-compose exec jenkins /bin/bash -c 'cat ~/.ssh/id_rsa.pub'

To create one, run:

    docker-compose exec jenkins /bin/bash -c 'ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub'

Now, add the resulting public key at /user/admin/configure.

Go to /configureSecurity/ and set the SSHD port to fixed and enter a random number between 50000 and 55000.

You might need to restart jenkins by visiting /restart

Now you can use the command line:

    docker-compose exec jenkins /bin/bash -c '/scripts/cli.sh help'

Updating installed plugins
-----

Make sure you have CLI access (see above), then run, from the command line:

    docker-compose exec jenkins /bin/bash -c '/scripts/update-plugins.sh'

(This might cause Jenkins to restart.)

To run this from a job (for example to periodically and automatically update plugins), run:

    /scripts/update-plugins.sh

Setup
-----

This project is meant to be used with a Ubuntu Docker host; and the Jenkins Docker container is meant to have ssh access to the host. Do not put any critical software on the host other than Jenkins. You can use throw-away virtual machines (using for example [this](https://github.com/dcycle/docker-digitalocean-php) or another API client for DigitalOcean or another cloud VM provider).

Scripts
-----

A collection of scripts, which might be useful to you, is included. The scripts are meant to be called from Jenkins, and might require access to the Ubuntu host.

To use these, make sure this repo is at `~/dcyclejenkins` on the host, and enter the ssh credentials in `~/.docker-host-ssh-credentials` on the container:

    DOCKERHOSTUSER=notroot
    DOCKERHOST=ci.example.com

* `/scripts/atq.sh`: lists the pending jobs set up using [at](http://manpages.ubuntu.com/manpages/xenial/en/man1/at.1posix.html)

What if my secure site breaks?
-----

If your secure (https) server is overloaded or in some other circumstances, you may see a "Bad Gateway" issue or your site may refuse to connect to the secure port. Wait 5 minutes, and if this still occurs, you can use the following script to kill all your containers (assuming you have nothing else important on your server) and start over (the data will remain intact):

    docker network disconnect dcyclejenkins_default nginx-proxy
    (docker stop $(docker ps -a -q) &
    docker update --restart=no $(docker ps -a -q) &
    docker stop $(docker ps -a -q) &
    docker update --restart=no $(docker ps -a -q) &
    systemctl restart docker)
    docker ps
    docker-compose -f docker-compose.yml -f docker-compose.ssl.yml up -d
    docker rm nginx-proxy
    docker run -d -p 80:80 -p 443:443 \
      --name nginx-proxy \
      -v "$HOME"/certs:/etc/nginx/certs:ro \
      -v /etc/nginx/vhost.d \
      -v /usr/share/nginx/html \
      -v /var/run/docker.sock:/tmp/docker.sock:ro \
      --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
      --restart=always \
      jwilder/nginx-proxy
    docker rm nginx-letsencrypt
    docker run -d \
      --name nginx-letsencrypt \
      -v "$HOME"/certs:/etc/nginx/certs:rw \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --volumes-from nginx-proxy \
      --restart=always \
      jrcs/letsencrypt-nginx-proxy-companion
    docker ps
