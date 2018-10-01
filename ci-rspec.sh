#!/usr/bin/env sh

set -e

./bin/rake db:create
./bin/rake db:migrate > /dev/null
./bin/rspec --format documentation
