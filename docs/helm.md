# Kafka helm chart

## Prerequisites

- Kubernetes 1.18+
- Helm 3.3+

## Get Repository Info

``` shell
helm repo add kafka-repo https://helm-charts.itboon.top/kafka
helm repo update kafka-repo
```

## Deploy Kafka

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

## combined mode

- If process.roles is set to broker, the server acts as a broker.
- If process.roles is set to controller, the server acts as a controller.
- If process.roles is set to broker,controller, the server acts as both a broker and a controller.

> Kafka servers that act as both brokers and controllers are referred to as "combined" servers. Combined servers are simpler to operate for small use cases like a development environment. The key disadvantage is that the controller will be less isolated from the rest of the system. For example, it is not possible to roll or scale the controllers separately from the brokers in combined mode. Combined mode is not recommended in critical deployment environments.

### Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| broker.combinedMode.enabled | bool | `false` | Whether to enable the combined mode |

``` yaml
broker:
  combinedMode:
    enabled: true
  replicaCount: 1
  heapOpts: "-Xms1024m -Xmx1024m"
  persistence:
    enabled: true
    size: 20Gi
```

## Cluster ID 

In earlier versions, Kafka will automatically initialize the data directory, the current version needs to provide a `Cluster ID` and manually initialize the data directory:

``` shell
KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties
```

All nodes in a cluster need to use the same `Cluster ID`. In order to solve this problem, this project will automatically generate a `Cluster ID` and save it to `Secret` when it is deployed for the first time.

## External Access

In order to connect to the Kafka server outside the cluster, each Broker must be exposed and `advertised.listeners` must be correctly configured.

There are two ways to expose, `NodePort` and `LoadBalancer`, each broker node needs a `NodePort` or `LoadBalancer`.

### Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| broker.external.enabled | bool | `false` | Whether to enable external access |
| broker.external.service.type | string | `NodePort` | `NodePort` or `LoadBalancer` |
| broker.external.service.annotations | object | `{}` | External serivce annotations |
| broker.external.nodePorts | list | `[]` | Provide at least one port number, if the count of ports is less than the count of broker nodes, it will be automatically incremented |
| broker.external.domainSuffix | string | `kafka.example.com` | If you use `LoadBalancer` for external access, you must use a domain name. The external domain name corresponding to the broker is `POD_NAME` + `domain name suffix`, such as `kafka-broker-0.kafka.example.com`. After the deployment, you need to complete the domain name resolution operation |

``` yaml
## NodePort example
broker:
  replicaCount: 3
  external:
    enabled: true
    service:
      type: "NodePort"
      annotations: {}
    nodePorts:
      - 31050
      - 31051
      - 31052
```

``` yaml
## LoadBalancer example
broker:
  replicaCount: 3
  external:
    enabled: true
    service:
      type: "LoadBalancer"
      annotations: {}
    domainSuffix: "kafka.example.com"
```
