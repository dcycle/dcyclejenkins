#!/bin/bash
set -e

SSHDIR="$HOME/.jenkinscli-ssh"

rm -rf "$SSHDIR"
mkdir -p "$SSHDIR"
ssh-keygen -t rsa -f "$SSHDIR"/id_rsa -N ""

echo "Please enter the follwing public key in <MYJENKINS>:8080/user/admin/configure"
echo "and press any key when done."
echo ""
cat "$SSHDIR"/id_rsa.pub
read USERINPUT
