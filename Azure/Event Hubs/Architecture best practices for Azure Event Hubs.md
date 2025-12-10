## Azure Event Hubs 最佳架构实践

[Azure Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-about)是一个可伸缩的事件处理服务，它摄入和处理大规模事件和数据，而且具有低延迟和高可靠性。它每秒可接收和处理几百万件事件。发送给 event hub 的数据可通过使用实时分析服务或批处理及存储适配器进行转换和排序。

关于使用 Event Hubs 的更多信息，请参见[Azure Event Hubs 文档](https://learn.microsoft.com/en-us/azure/event-hubs/)以学习如何使用 Event Hubs 来从连接的设备和应用每秒摄入几百万条事件。

为了理解 Event Hubs 帮助你达到你的工作负载所需的操作便利性和可靠性，请参考下面的文档：
- [监控 Azure Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/monitor-event-hubs)
- [Stream Azure Diagnostics data using Event Hubs](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/diagnostics-extension-stream-event-hubs)
- [Scaling with Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-scalability)

下面的章节是从良好架构框架的视角专注于 `Azure Event Hubs` 的：

- 设计考量
- 配置检查列表
- 推荐配置选项
- 源头工件

## 设计考量
`Azure Event Hubs` 提供了一个正常运行时间 SLA，更多信息，请参见 [SLA for Event Hubs](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services?lang=1)。

## 工作负载设计检查列表

你已经考虑过将 Azure Event Hubs 配置成极具可操作性吗？

- 对事件发布者和消费者分别创建 `只发送(SendOnly)` 和 `只监听(ListenOnly)` 策略。
- 当使用 SDK 发送事件至 `Event Hubs` 时，确保重试策略抛出的异常（`EventHubsException` 或 `OperationCancelledException`）被适当的捕捉。
- 在高通量的场景下，使用批处理事件。
- 每个消费者能够读取 Event Hubs [SKU](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-quotas#basic-vs-standard-vs-premium-vs-dedicated-tiers) 支持的一个至最大分区。
- 当开发新的应用时，使用 `EventProcessorClient` (.NET 和 Java) 或 `EventHubConsumerClient` (Python 和 JavaScript) 作为客户端软件软件开发包。
- 作为你的方案级别高可用性和灾难恢复策略的一部分，考虑启用 Event Hubs 地理灾难恢复选项。
- 当一个方案拥有大量独立事件发布者，考虑使用Event Publishers来启用细粒度访问控制。
- 不要发布事件到一个特定分区。
- 当频繁发布事件时，可能的话使用 AMQP 协议。
- 分区数反映了下游你期望取得的并行度。
- 确保每一个消费者应用使用了一个单独的消费者组（consumer group），且每个消费者组仅有一个活跃的接收者。
- 为处理特定事件的非瞬态错误处理制定计划，Event Hubs 没有内建死信队列。

  在你的工作负载内创建自定义死信机制。如果处理一个事件导致了一个非瞬态错误，将事件拷贝到一个自定义死信队列。将事件复制到一个专有队列允许你稍后重试处理该事件，使用一个补偿交易，或者别的措施。
- 当使用捕获特性时，谨慎考虑时间窗口和文件大小配置，尤其在数据量不大时。

## 推荐配置选项

当配置 Azure Event Hubs 时考虑下面的建议以优化可靠性。

推荐|描述
--|--
使用[zone redundancy](https://learn.microsoft.com/en-us/azure/reliability/reliability-event-hubs#availability-zone-support)|当 zone redundancy 被启用时，Event Hubs 在多个可用区之间法制事件。如果一个可用区不可用了，故障转移自动触发。
使在使用 SDK 发送事件至Event Hubs 时，确保由重试策略抛出的异常（`EventHubsException` 或`OperationCancelledException`）被正确地捕获|当使用 HTTPS 时，确保实现了一个合适的重试模式。
在高通量的场景下，使用批处理事件|服务将发送一个携带多个事件的 json 数组给订阅者，而非只包含一个事件的数组。消费程序必须处理这些数组。
每个消费者能够读取 Event Hubs [SKU](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-quotas#basic-vs-standard-vs-premium-vs-dedicated-tiers) 支持的一个至最大分区|对于消费者应用，为了取得最大扩展性，每个消费者应该只消费一个分区。
当开发新的应用时，使用 `EventProcessorClient` (.NET 和 Java) 或 `EventHubConsumerClient` (Python 和 JavaScript) 作为客户端软件软件开发包|`EventProcessorHost` 已经被废弃
如果你的层级可用，作为你的方案级别高可用性和灾难恢复策略的一部分，考虑[启用异地复制](https://learn.microsoft.com/en-us/azure/event-hubs/geo-replication)选项。|这个选项允许元数据和消息在另一个区域的辅助名字空间异步复制。客户端在另一个区域的辅助名字空间重启消费时应该拥有幂等性。
作为你的方案级别高可用性和灾难恢复策略的一部分，考虑启用 [Event Hubs 地理灾难恢复](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-geo-dr)选项。|这个选项允许在另一个区域创建辅助名字空间。任何时候只有活跃的名字空间能够收到消息。消息和事件并不会被复制到另一个区域。区域故障转移的 RTO 约为30分钟。确认这个 RTO 符合客户需求，并匹配更广泛的可用性策略。如果需要更高的 RTO，考虑实现一个客户端故障转移模式。
当一个方案拥有大量独立事件发布者，考虑使用Event Publishers来启用细粒度访问控制。|事件发布者自动设置分区键为发布者名字，因此这个特性只有当所有发布者发布的时间均匀分布时才有用。
不要发布事件到一个特定分区。|如果有序事件很重要，在下游实现排序，或者使用一个不同的消息服务。
当频繁发布事件时，可能的话使用 `AMQP` 协议。|当初始化会话时，AMQP 拥有更高的网络成本，但 `HTTPS` 在每次请求都带有额外的 `TLS` 载荷。对频繁的发布者 `AMQP` 拥有更好的性能。
当使用捕获特性时，谨慎考虑时间窗口和文件大小配置，尤其在数据量不大时。|Data Lake gen2 需要为极小的交易付费。如果你设置窗口过低，以致文件未达最小大小，你将会产生额外费用。
需要消费者[执行检查点](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features#checkpointing)|检查点允许消费者追踪最后消费成功的事件，使它们能够在处理失败时从该检查点重启消费。这对于确保没有事件丢失和维护处理效率时至关重要的，客户端可以最小化重复处理的数据--现在只需要处理最后的检查点和失败点之后的数据。

## 源头工件

为了使用基本 SKU 找到 Event Hubs 名字空间，使用下面的查询：

```
Resources 
| where type == 'microsoft.eventhub/namespaces'
| where sku.name == 'Basic'
| project resourceGroup, name, sku.name
```

## Reference

- [Architecture best practices for Azure Event Hubs](https://learn.microsoft.com/en-us/azure/well-architected/service-guides/event-hubs)
- [Features and terminology in Azure Event Hubs](https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-features)