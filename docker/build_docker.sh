#!/bin/bash

set -e

cd "${BASH_SOURCE%/*}/" || exit

docker build -t fml-ruby ruby
docker build -t fml-build build
docker build -t fml-test test
docker build -t fml-app app
docker build -t fml-web web
