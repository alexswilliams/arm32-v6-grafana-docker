#!/usr/bin/env bash

set -ex

export DOCKER_BUILDKIT=1

function buildAndPush {
    local grafanaVersion=$1
    local alpineVersion=$2
    local goVersion=$3
    local imagename="alexswilliams/arm32v6-grafana"
    local latest="last-build"
    if [ "$4" == "latest" ]; then latest="latest"; fi

    docker build \
        --platform=linux/arm/v6 \
        --build-arg GRAFANA_VERSION=${grafanaVersion} \
        --build-arg ALPINE_VERSION=${alpineVersion} \
        --build-arg GO_VERSION=${goVersion} \
        --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --build-arg VCS_REF=$(git rev-parse --short HEAD) \
        --tag ${imagename}:${grafanaVersion} \
        --tag ${imagename}:${grafanaVersion}-${alpineVersion} \
        --tag ${imagename}:${grafanaVersion}-${alpineVersion}-${goVersion} \
        --tag ${imagename}:${latest} \
        --file Dockerfile .

    docker push ${imagename}:${grafanaVersion}
    docker push ${imagename}:${grafanaVersion}-${alpineVersion}
    docker push ${imagename}:${grafanaVersion}-${alpineVersion}-${goVersion}
    docker push ${imagename}:${latest}
}


# Grafana version       # Alpine version        # Go version

# buildAndPush "7.0.3" "3.12.0"  "1.14.2-alpine3.11"
buildAndPush "7.1.0" "3.12.0"  "1.14.6-alpine3.12" latest


curl -X POST "https://hooks.microbadger.com/images/alexswilliams/arm32v6-grafana/GWMYS1iqVhxm1h7lTOo8AK6Qx1w="
