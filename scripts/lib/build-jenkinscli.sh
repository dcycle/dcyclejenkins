#!/bin/bash
set -e

SSHDIR="$HOME/.jenkinscli-ssh"

if [ ! -f "$SSHDIR"/id_rsa.pub ]; then
    ./scripts/reset-jenkinscli-ssh.sh
fi

./scripts/jenkins-cli.sh "help"
