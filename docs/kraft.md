# KRaft

> This project uses KRaft mode by default

In KRaft mode each Kafka server can be configured as a controller, a broker, or both using the process.roles property. This property can have the following values:

- If process.roles is set to broker, the server acts as a broker.
- If process.roles is set to controller, the server acts as a controller.
- If process.roles is set to broker,controller, the server acts as both a broker and a controller.
- If process.roles is not set at all, it is assumed to be in ZooKeeper mode.

Kafka servers that act as both brokers and controllers are referred to as "combined" servers. Combined servers are simpler to operate for small use cases like a development environment. The key disadvantage is that the controller will be less isolated from the rest of the system. For example, it is not possible to roll or scale the controllers separately from the brokers in combined mode. Combined mode is not recommended in critical deployment environments.