#!/usr/bin/env bash

IMG_NAME="mnubo/wordpress-memcached"
IMG_TAG="4.7-php5.6-apache"

set -e

docker build -t ${IMG_NAME}:${IMG_TAG} .
echo "Finished building [ ${IMG_NAME}:${IMG_TAG} ]"
echo "Please update the upstream image by using [ docker push ${IMG_NAME}:${IMG_TAG} ] with the right credentials"

