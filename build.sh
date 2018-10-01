#!/usr/bin/env sh

set -e

yarn install --production=true
bundle install --binstubs --deployment --without development
$(yarn bin)/webpack -p
