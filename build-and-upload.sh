#!/usr/bin/env bash

set -ex

export DOCKER_BUILDKIT=1

function buildAndPush {
    local grafanaVersion=$1
    local alpineVersion=$2
    local imagename="alexswilliams/arm32v6-grafana"
    local latest="last-build"
    if [ "$3" == "latest" ]; then latest="latest"; fi

    docker build \
        --platform=linux/arm/v6 \
        --build-arg GRAFANA_VERSION=${grafanaVersion} \
        --build-arg ALPINE_VERSION=${alpineVersion} \
        --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --build-arg VCS_REF=$(git rev-parse --short HEAD) \
        --tag ${imagename}:${grafanaVersion} \
        --tag ${imagename}:${grafanaVersion}-${alpineVersion} \
        --tag ${imagename}:${latest} \
        --file Dockerfile .

#    docker push ${imagename}:${grafanaVersion}
#    docker push ${imagename}:${grafanaVersion}-${alpineVersion}
#    docker push ${imagename}:${latest}
}

buildAndPush "7.0.3" "3.12.0" latest


# curl -X POST "https://hooks.microbadger.com/images/alexswilliams/arm32v6-prometheus/H8lh7yTJah4vJT69Kjz-00QLM44="
