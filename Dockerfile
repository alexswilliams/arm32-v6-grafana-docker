# Modified from https://github.com/grafana/grafana/blob/master/packaging/docker/Dockerfile to use arm32v6 base images and alpine commands

ARG ALPINE_VERSION
FROM arm32v6/alpine:${ALPINE_VERSION} as binaries
WORKDIR /
ARG GRAFANA_VERSION
RUN wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-armv6.tar.gz \
    && tar xzf grafana-${GRAFANA_VERSION}.linux-armv6.tar.gz \
    && mv /grafana-${GRAFANA_VERSION} /grafana


ARG ALPINE_VERSION
FROM arm32v6/alpine:${ALPINE_VERSION}
ARG GRAFANA_VERSION
ARG GF_UID="472"
ARG GF_GID="472"
ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

WORKDIR $GF_PATHS_HOME

COPY --from=binaries /grafana ${GF_PATHS_HOME}

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
    chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    apk add --no-cache fontconfig ca-certificates

ADD https://raw.githubusercontent.com/grafana/grafana/master/packaging/docker/run.sh /run.sh
RUN sed -i 's#/bin/bash#/bin/sh#' /run.sh \
    && chmod 0755 /run.sh
EXPOSE 3000
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
