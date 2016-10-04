#!/bin/bash
set -e

PASSWORD="$(./scripts/random-password.sh)"

./scripts/reset-password-as.sh "$PASSWORD"
