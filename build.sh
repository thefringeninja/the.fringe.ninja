#!/usr/bin/env bash

set -e

docker build -t ninja-snacks .
docker run --rm -it --name ninja-snacks -p 1313:1313 ninja-snacks
