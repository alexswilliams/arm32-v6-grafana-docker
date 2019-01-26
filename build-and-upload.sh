#!/usr/bin/env bash

set +ex

function buildAndPush {
    local version=$1
    docker build -t alexswilliams/arm32v6-grafana:${version} --build-arg VERSION=${version} --file Dockerfile.arm32v6 .
    docker push alexswilliams/arm32v6-grafana:${version}
}

buildAndPush "5.4.3"

