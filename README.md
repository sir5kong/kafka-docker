# https://github.com/sir5kong/kafka-docker

# Quick reference

-	**Maintained by**:  
	[sir5kong](https://github.com/sir5kong/kafka-docker)

-	**Where to file issues**:  
	[https://github.com/sir5kong/kafka-docker/issues](https://github.com/sir5kong/kafka-docker/issues)

# Supported tags and respective `Dockerfile` links

-	[`v3.5.0`, `v3.5`, `latest`](https://github.com/sir5kong/kafka-docker/blob/main/Dockerfile)
-	[`v3.4.1`, `v3.4`](https://github.com/sir5kong/kafka-docker/blob/main/Dockerfile)
-	[`v3.3.2`, `v3.3`](https://github.com/sir5kong/kafka-docker/blob/main/Dockerfile)

# What is Apache Kafka?

Apache Kafka is an open-source distributed event streaming platform used by thousands of companies for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.

- [wikipedia.org/wiki/Apache_Kafka](https://en.wikipedia.org/wiki/Apache_Kafka)

> More than 80% of all Fortune 100 companies trust, and use Kafka. 

# Why use this image

- Fully compatible with `KRaft`, say goodbye to ZooKeeper.
- Flexible use of environment variables for configuration.
- Easy to deploy.
- Provide [helm chart](https://github.com/sir5kong/kafka-docker/tree/main/charts/kafka), you can quickly deploy high-availability clusters on Kubernetes.

# How to use this image

[Docker Hub](https://hub.docker.com/r/sir5kong/kafka)

## Start a `kafka` server instance

Starting a Kafka instance is simple:

``` shell
docker run -d --name kafka-server --network host sir5kong/kafka:v3.5
```

### Persisting your data

``` shell
docker volume create kafka-data
docker run -d --name kafka-server \
  --network host \
  -v kafka-data:/opt/kafka/data \
  sir5kong/kafka:v3.5
```

> The default listener port of the broker is `9092`

### Custom listener port

``` shell
docker volume create kafka-data
docker run -d --name kafka-server \
  --network host \
  -v kafka-data:/opt/kafka/data \
  --env KAFKA_CONTROLLER_LISTENER_PORT=29091 \
  --env KAFKA_BROKER_LISTENER_PORT=29092 \
  sir5kong/kafka:v3.5
```

### Using Docker Compose

``` yaml
version: "3"

volumes:
  kafka-data: {}

## bootstrap-server: ${KAFKA_HOST_IP_ADDR}:9092

services:
  kafka:
    image: sir5kong/kafka:v3.5
    restart: always
    network_mode: host
    volumes:
      - kafka-data:/opt/kafka/data
    environment:
      - KAFKA_HEAP_OPTS=-Xmx512m -Xms512m
      #- KAFKA_CONTROLLER_LISTENER_PORT=19091
      #- KAFKA_BROKER_LISTENER_PORT=9092

```

## Environment Variables

| Variable | Default | Description |
|-----------|-------|------|
| `KAFKA_CLUSTER_ID`           | Random | Cluster ID |
| `KAFKA_BROKER_LISTENER_PORT` | `9092` | broker listener port. This will not work if `KAFKA_CFG_LISTENERS` is configured |
| `KAFKA_CONTROLLER_LISTENER_PORT` | `19091` | controller listener port. This will not work if `KAFKA_CFG_LISTENERS` is configured |
| `KAFKA_HEAP_OPTS` | `null` | Kafka Java Heap size. For example `-Xmx512m -Xms512m`|

### Kafka Configurations

Any environment variable beginning with `KAFKA_CFG_` will be mapped to its corresponding Apache Kafka key. 

For example, use `KAFKA_CFG_LISTENERS` in order to set `listeners` or `KAFKA_CFG_ADVERTISED_LISTENERS` in order to configure `advertised.listeners`.

Variable examples:

| Variable | Key |
|---------|--------|
| `KAFKA_CFG_PROCESS_ROLES`     | `process.roles` |
| `KAFKA_CFG_LISTENERS`         | `listeners` |
| `KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP`     | `listener.security.protocol.map` |
| `KAFKA_CFG_ADVERTISED_LISTENERS`               | `advertised.listeners` |
| `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS`           | `controller.quorum.voters` |
| `KAFKA_CFG_LOG_RETENTION_HOURS`                | `log.retention.hours` |

> `log.dir` and `log.dirs` are locked, you cannot overwrite them

## Using helm chart

### Prerequisites

- Kubernetes 1.18+
- Helm 3.3+

### Get Repository Info

``` shell
helm repo add kafka-repo https://sir5kong.github.io/kafka-docker
helm repo update kafka-repo
```

### Deploy a single-node cluster

- Turn off persistent storage here, only demonstrate the deployment operation

``` shell
helm upgrade --install kafka \
  --namespace kafka-demo \
  --create-namespace \
  --set broker.combinedMode.enabled="true" \
  --set broker.persistence.enabled="false" \
  kafka-repo/kafka
```

### One broker and one controller cluster

``` shell
helm upgrade --install kafka \
  --namespace kafka-demo \
  --create-namespace \
  --set broker.persistence.size="20Gi" \
  kafka-repo/kafka
```

> Persistence storage is used by default.

### Deploy a highly available cluster

``` shell
helm upgrade --install kafka \
  --namespace kafka-demo \
  --create-namespace \
  --set controller.replicaCount="3" \
  --set broker.replicaCount="3" \
  --set broker.heapOpts="-Xms4096m -Xmx4096m" \
  --set broker.resources.requests.memory="8Gi" \
  --set broker.resources.limits.memory="16Gi" \
  kafka-repo/kafka
```

> More values please refer to [examples/values-production.yml](https://github.com/sir5kong/kafka-docker/raw/main/examples/values-production.yml)

### Using LoadBalancer

Enable Kubernetes external cluster access to Kafka brokers.

``` shell
helm upgrade --install kafka \
  --namespace kafka-demo \
  --create-namespace \
  --set broker.external.enabled="true" \
  --set broker.external.service.type="LoadBalancer" \
  --set broker.external.domainSuffix="kafka.example.com" \
  kafka-repo/kafka
```

Add domain name resolution to complete this deployment

# Multi-language `README.md`

- [English](README.md)
- [简体中文](README-zh.md)
