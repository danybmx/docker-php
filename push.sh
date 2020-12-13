#!/bin/bash

set -ex

IMAGE_NAME="danybmx/php"
PHP_VERSIONS=("7.2" "7.3" "7.4")

for PHP_VERSION in ${PHP_VERSIONS[*]}; do
    docker push ${IMAGE_NAME}:${PHP_VERSION}-apache
done