#!/usr/bin/env sh

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

docker build -t fml-ruby $DIR/ruby
docker build -t fml-build $DIR/build
docker build -t fml-test $DIR/test
docker build -t fml-app $DIR/app
docker build -t fml-web $DIR/web
