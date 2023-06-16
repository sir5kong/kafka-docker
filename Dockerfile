# builder
FROM alpine as builder

ARG kafka_version=3.5.0
ARG scala_version=2.13

ENV dl_url="https://downloads.apache.org/kafka/${kafka_version}/kafka_${scala_version}-${kafka_version}.tgz"

RUN set -ex \
  ; mkdir -pv /tmp/kfk \
  ; wget "$dl_url" -O /tmp/kfk/kafka.tgz \
  ; cd /tmp/kfk && tar -xf kafka.tgz \
  ; rm -f /tmp/kfk/kafka.tgz \
  ; mv kafka_* kafka

# container
FROM eclipse-temurin:17-jre-focal

ENV KAFKA_HOME="/opt/kafka" \
    KAFKA_CONF_FILE="/etc/kafka/server.properties"

RUN set -ex \
  ; useradd kafka --uid 1000 -m -s /bin/bash \
  ; usermod -g root kafka \
  ; mkdir -pv "/etc/kafka" && chown -R 1000:1000 "/etc/kafka"

COPY --from=0 --chown=1000:1000 /tmp/kfk/kafka "$KAFKA_HOME"

RUN set -ex \
    ; apt-get update \
    ; apt-get install \
      iproute2 -y --no-install-recommends \
    ; rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

WORKDIR $KAFKA_HOME
EXPOSE 9092

# USER 1000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]
