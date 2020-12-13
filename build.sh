#!/bin/bash

set -ex

IMAGE_NAME="danybmx/php"
PHP_VERSIONS=("7.2" "7.3" "7.4")

for PHP_VERSION in ${PHP_VERSIONS[*]}; do
    docker build --build-arg PHP_VERSION=${PHP_VERSION} -t ${IMAGE_NAME}:${PHP_VERSION}-apache .
    echo "docker push ${IMAGE_NAME}:${PHP_VERSION}-apache"
    docker push ${IMAGE_NAME}:${PHP_VERSION}-apache
done
