# 深入探讨Kubernetes 指标（Kubernetes Metrics）
Kubernetes 正在吃下整个世界，这个平台的快速增长前所未见。每个主流的云提供商都提供了全管理的 Kubernetes 平台。伴随容器编排平台带来的各种好处，它也带来了许多新的挑战，

在新的平台上运行的应用的可观察性有其自有的挑战。我将在另一个系列里讨论它。平台本身的可观察性如何？Kubernetes 暴露了平台本身的很多指标。这些指标对于成功运行 Kubernetes 是重要的，无论你是以[hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)运行 Kubernetes 还是利用云提供商脱管你的系统。

在这个多篇系列里我讲深入 Kubetnetes 平台中各种可用的指标源，如何收集它们，如何在重要的指标上发警报，我也将谈及一些指标如何回馈到系统中以帮助调度和扩展 Kubernetes 负载，
> 为了我们的目的我将指标定义为在固定时间间隔收集的数字采样并被存储到时间序列数据库中。在X轴上随时间可视化，另外我假设你在一个基于 Linux 的系统上运行 Kubernetes ，我并不打算讨论在Windows 上的 Kubernetes 。

下面是我将讨论的领域：
- [深入讨论 Kubernetes 指标--Part 1 节点指标](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-66936addedae)
- [深入讨论 Kubernetes 指标--Part 2 USE方法及“node_exporter”指标](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-2-c869581e9f29)
- [深入讨论 Kubernetes 指标--Part 3 容器资源指标](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66)
- [深入讨论 Kubernetes 指标--Part 4 Kubernetes API Server](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-4-the-kubernetes-api-server-72f1e1210770)
- [深入讨论 Kubernetes 指标--Part 5 etcd 指标](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-5-etcd-metrics-6502693fa58)
- [深入讨论 Kubernetes 指标--Part 6 kube-state-metrics](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-6-kube-state-metrics-14f4e7c8710b)

我在CubeCon 2018上有一个关于这个主题的[讲座](https://www.youtube.com/watch?v=1oJXMdVi0mM)。

**利用Prometheus 做指标收集及报警**
为了讨论指标，选择一个合适的具体的指标平台是有帮助的，可以用于演示如何收集及报警。

在云原生技术的世界里，Prometheus 是指标收集及报警的明显选择，并可利用 Granfana 来实现可视化。
**从底部主键开始**
我将从监控人员最熟悉的指标开始，节点（机器）指标，CPU, memory, 网络和磁盘。Linux 暴露了很多指标，它们对你理解你的 Kubernetes 集群至关重要。让我们开始把。
## USE 方法及 node_exporter 指标

## Reference
- [A Deep Dive into Kubernetes Metrics](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-b190cc97f0f6)
- [A Deep Dive into Kubernetes Metrics — Part 2](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-2-c869581e9f29)
- [A Deep Dive into Kubernetes Metrics — Part 3 Container Resource Metrics](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66)