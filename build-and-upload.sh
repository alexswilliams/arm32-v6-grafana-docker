#!/usr/bin/env bash

set -ex

function buildAndPush {
    local version=$1
    local file=$2
    docker build -t alexswilliams/arm32v6-grafana:${version} --build-arg VERSION=${version} --file "${file}" .
    if [[ $? -eq 0 ]]; then
        docker push alexswilliams/arm32v6-grafana:${version}
    else
        echo "Failed to build; not pushing."
        exit 1
    fi
}

# buildAndPush "5.4.3" "Dockerfile-build.arm32v6"
# buildAndPush "6.0.2" "Dockerfile-fetch.arm32v6"   # doesn't work as binaries are not linked against musl.
buildAndPush "6.0.2" "Dockerfile-build.arm32v6"

