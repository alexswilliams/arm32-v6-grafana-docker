#!/usr/bin/env bash

set +ex

function buildAndPush {
    local version=$1
    docker build -t alexswilliams/arm32v6-grafana:${version} --build-arg VERSION=${version} --file Dockerfile.arm32v6 .
    if [[ $? -eq 0 ]]; then
        docker push alexswilliams/arm32v6-grafana:${version}
    else
        echo "Failed to build; not pushing."
        exit 1
    fi
}

buildAndPush "5.4.3"

