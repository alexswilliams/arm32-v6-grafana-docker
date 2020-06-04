# Modified from https://github.com/grafana/grafana/blob/master/Dockerfile to use arm32v6 base images and alpine commands

ARG ALPINE_VERSION
ARG GO_VERSION

FROM arm32v6/alpine:${ALPINE_VERSION} as sourcecode
ARG GRAFANA_VERSION
RUN wget https://github.com/grafana/grafana/archive/v${GRAFANA_VERSION}.tar.gz \
    && tar xzf v${GRAFANA_VERSION}.tar.gz \
    && mv /grafana-${GRAFANA_VERSION} /grafana


FROM arm32v6/alpine:${ALPINE_VERSION} as prebuilt
ARG GRAFANA_VERSION
WORKDIR /
ARG GRAFANA_VERSION
RUN wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-armv6.tar.gz \
    && tar xzf grafana-${GRAFANA_VERSION}.linux-armv6.tar.gz \
    && mv /grafana-${GRAFANA_VERSION} /grafana



FROM arm32v6/golang:${GO_VERSION} as go-builder
RUN apk add --no-cache gcc g++
WORKDIR $GOPATH/src/github.com/grafana/grafana

COPY --from=sourcecode /grafana/go.mod /grafana/go.sum ./
RUN go mod verify
RUN go mod download

COPY --from=sourcecode /grafana/pkg pkg
COPY --from=sourcecode /grafana/build.go /grafana/package.json ./
RUN go run build.go -goarch=armv6 build



FROM arm32v6/alpine:${ALPINE_VERSION} as runtime
ARG GF_UID="472"
ARG GF_GID="472"
ENV PATH="/usr/share/grafana/bin:$PATH" \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

RUN apk add --no-cache ca-certificates bash tzdata && \
    apk add --no-cache --upgrade openssl musl-utils

COPY --from=sourcecode /grafana/conf ./conf

RUN mkdir -p "$GF_PATHS_HOME/.aws" && \
    addgroup -S -g $GF_GID grafana && \
    adduser -S -u $GF_UID -G grafana grafana && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_PROVISIONING/notifiers" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG" && \
    cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING" && \
    chmod -R 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" "$GF_PATHS_PROVISIONING"

COPY --from=go-builder /go/src/github.com/grafana/grafana/bin/linux-armv6/grafana-server /go/src/github.com/grafana/grafana/bin/linux-armv6/grafana-cli ./bin/
COPY --from=prebuilt /grafana/public ./public

EXPOSE 3000

COPY --from=sourcecode /grafana/packaging/docker/run.sh /run.sh

USER grafana
ENTRYPOINT [ "/run.sh" ]



ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Grafana (arm32v6)" \
      org.label-schema.description="Grafana OSS - Repackaged for ARM32v6" \
      org.label-schema.url="https://grafana.com/oss/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/alexswilliams/arm32-v6-grafana-docker" \
      org.label-schema.version=$GRAFANA_VERSION \
      org.label-schema.schema-version="1.0"
