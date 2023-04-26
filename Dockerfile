# builder
FROM alpine as builder

ARG kafka_version=3.3.2
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

COPY --from=0 /tmp/kfk/kafka "$KAFKA_HOME"

COPY entrypoint.sh /entrypoint.sh

RUN set -ex \
  ; useradd kafka --uid 1000 -m -s /bin/bash \
  ; usermod -g root kafka \
  ; chown -R 1000:1000 "$KAFKA_HOME" \
  ; mkdir -pv "/etc/kafka" && chown -R 1000:1000 "/etc/kafka"

WORKDIR $KAFKA_HOME
EXPOSE 9092

# USER 1000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "start" ]
