#!/usr/bin/env bash

BASE_DIR=~docker

pushd ${BASE_DIR}/signon > /dev/null

echo "Dockerizing 'signon'..."

bash ${BASE_DIR}/templates/redis.yml > config/redis.yml

popd > /dev/null
