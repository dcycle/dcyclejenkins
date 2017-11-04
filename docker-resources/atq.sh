#!/bin/bash
#
# Check pending jobs on the Docker host, this script is meant to be used on
# the dcyclejenkins container.
#

set -e

source ~/.docker-host-ssh-credentials

ssh "$DOCKERHOSTUSER"@"$DOCKERHOST" "~/dcyclejenkins/scripts/atq.sh"
