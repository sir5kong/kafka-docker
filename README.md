# Kafka 容器化解决方案

Apache [Kafka](https://kafka.apache.org/) 容器化解决方案以及部署案例

本项目全面兼容 `KRaft`, 不依赖 ZooKeeper

## Docker 部署

[docker hub](https://hub.docker.com/r/sir5kong/kafka)

``` shell
docker run -d --name kafka-server \
  --network host \
  sir5kong/kafka:v3.3
```

自定义端口号：

``` shell
## 自定义端口号
docker run -d --name kafka-server \
  --network host \
  --env KAFKA_CONTROLLER_LISTENER_PORT=29091 \
  --env KAFKA_BROKER_LISTENER_PORT=29092 \
  sir5kong/kafka:v3.3
```

启动 kafka server 并持久化数据目录:

``` shell
docker volume create kafka_data
docker run -d --name kafka-server \
  --network host \
  -v kafka_data:/opt/kafka/data \
  sir5kong/kafka:v3.3
```

### Docker Compose

``` yaml
version: "3"

volumes:
  kafka-data: {}

## broker 默认端口 9092
## bootstrap-server: ${KAFKA_HOST_IP_ADDR}:9092

services:
  kafka:
    image: sir5kong/kafka:v3.3
    # restart: always
    network_mode: host
    volumes:
      - kafka-data:/opt/kafka/data
    environment:
      - KAFKA_HEAP_OPTS=-Xmx512m -Xms512m
      #- KAFKA_CONTROLLER_LISTENER_PORT=19091
      #- KAFKA_BROKER_LISTENER_PORT=9092

```

- 使用桥接网络请参考 [examples](examples/docker-compose-bridge.yml)
- 更多部署案例和注解请参考 [examples](examples/)

## 环境变量

| 环境变量 | 默认值 | 描述 |
|---------|-------|------|
| `KAFKA_CLUSTER_ID`           | 随机生成 | 集群 id |
| `KAFKA_BROKER_LISTENER_PORT` | `9092` | broker 端口号，如果配置了 `KAFKA_CFG_LISTENERS` 则此项失效 |
| `KAFKA_CONTROLLER_LISTENER_PORT` | `19091` | controller 端口号，如果配置了 `KAFKA_CFG_LISTENERS` 则此项失效 |
| `KAFKA_HEAP_OPTS` | `null` | jvm 堆内存配置，例如 `-Xmx512m -Xms512m`|

### 配置覆盖

Kafka 所有配置项可以通过环境变量覆盖，除了 `log.dir` 和 `log.dirs`。环境变量名使用前缀 `KAFKA_CFG_` 加上配置参数，`.` 需要替换为 `_`

例如 `KAFKA_CFG_LISTENERS` 对应配置参数 `listeners`，`KAFKA_CFG_ADVERTISED_LISTENERS` 对应配置参数 `advertised.listeners`

常用配置参数:

| 环境变量 | 配置参数 |
|---------|--------|
| `KAFKA_CFG_PROCESS_ROLES`     | `process.roles` |
| `KAFKA_CFG_LISTENERS`         | `listeners` |
| `KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP`     | `listener.security.protocol.map` |
| `KAFKA_CFG_ADVERTISED_LISTENERS`               | `advertised.listeners` |
| `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS`           | `controller.quorum.voters` |

## helm chart 部署案例

[chart](charts/kafka/)

``` shell
git clone https://github.com/sir5kong/kafka-docker.git
cd kafka-docker

# kubectl create namespace your-namespace

## 部署单节点集群, 仅启动一个 Pod
helm install kafka -n your-namespace -f ./examples/values-combined.yml ./charts/kafka

## 部署生产集群, 3 个 controller 实例, 3 个 broker 实例
helm install kafka -n your-namespace -f ./examples/values-production.yml ./charts/kafka

######  组合使用 values 文件  ######
## 部署生产集群，并开启 kafka-ui 和 kafka exporter
helm install kafka -n your-namespace \
  -f ./examples/values-exporter.yml \
  -f ./examples/values-ui.yml \
  -f ./examples/values-production.yml \
  ./charts/kafka

## 以 NodePort 对集群外暴露
helm install kafka -n your-namespace -f ./examples/values-nodeport.yml ./charts/kafka

## 以 LoadBalancer 对集群外暴露
helm install kafka -n your-namespace -f ./examples/values-loadbalancer.yml ./charts/kafka

## 开启 kafka-ui
helm install kafka -n your-namespace -f ./examples/values-ui.yml ./charts/kafka

```
