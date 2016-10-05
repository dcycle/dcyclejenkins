#!/bin/bash
set -e

echo "[info] (re-)starting to build the Jenkins-cli and link it to Jenkins."

SSHDIR="$HOME/.jenkinscli-ssh"

if [ ! -f "$SSHDIR"/id_rsa.pub ]; then
    ./scripts/reset-jenkinscli-ssh.sh
fi

./scripts/jenkins-cli.sh "help"

echo "[info] Jenkins-cli should be up and running."
