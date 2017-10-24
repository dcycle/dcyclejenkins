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

To update, assuming you are using SSL, run:

    ./scripts/update.sh

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

Start by making sure you have a private-public ssh keypair. To check if there already is one, type:

    docker-compose exec jenkins /bin/bash -c 'cat ~/.ssh/id_rsa.pub'

To create one, run:

    docker-compose exec jenkins /bin/bash -c 'ssh-keygen -t rsa && cat ~/.ssh/id_rsa.pub'

Now, add the resulting public key at /user/admin/configure.

Go to /configureSecurity/ and set the SSHD port to fixed and enter a random number between 50000 and 55000.

You might need to restart jenkins by visiting /restart

Now you can use the command line:

    docker-compose exec jenkins /bin/bash -c 'java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -ssh -user admin help'

Here is a [nifty trick](https://stackoverflow.com/questions/7709993/how-can-i-update-jenkins-plugins-from-the-terminal) if you want to automate the updating of Jenkins plugins, you need to run this on the container itself (`docker-compose exec jenkins /bin/bash`):

    UPDATE_LIST=$( java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -ssh -user admin list-plugins | grep -e ')$' | awk '{ print $1 }' );
    if [ ! -z "${UPDATE_LIST}" ]; then
      echo Updating Jenkins Plugins: ${UPDATE_LIST};
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -ssh -user admin install-plugin ${UPDATE_LIST};
      java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -ssh -user admin safe-restart;
    fi

This might cause Jenkins to restart.
