#!/usr/bin/env bash

set -e

mkdir -p /tmp/hugo_cache

docker run --rm \
  --name ninja-snacks \
  -v ${PWD}:/src \
  -v /tmp/hugo_cache:/tmp/hugo_cache \
  -p 1313:1313 \
  hugomods/hugo:exts-non-root \
  server --contentDir site/content \
    --layoutDir site/layouts \
    --themesDir site/themes \
    --config site/config.toml
