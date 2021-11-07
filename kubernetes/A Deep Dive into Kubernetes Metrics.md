# 深入探讨Kubernetes 指标（Kubernetes Metrics）
Kubernetes 正在吃下整个世界，这个平台的快速增长前所未见。每个主流的云供应商都提供了全管理的 Kubernetes 平台。伴随容器编排平台带来的各种好处，它也带来了许多新的挑战，

在新的平台上运行的应用的可观察性有其自有的挑战。我将在另一个系列里讨论它。平台本身的可观察性如何？Kubernetes 暴露了平台本身的很多指标。这些指标对于成功运行 Kubernetes 是重要的，无论你是以[hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)运行 Kubernetes 还是利用云供应商托管你的系统。

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
**从底部逐渐开始**
我将从监控人员最熟悉的指标开始，节点（机器）指标，CPU, memory, 网络和磁盘。Linux 暴露了很多指标，它们对你理解你的 Kubernetes 集群至关重要。让我们开始把。
## Part 1: 节点指标
### 节点（机器）指标
只要我们拥有计算机及操作系统，我们就会测量这些系统的性能和行为。有大量的程序基于Linux梓潼产生的指标采样，展示并报警。

这些指标的来源（大部分）来自于Linux内核，可以被系统调用访问，也可以围绕 `/proc` 文件系统得到更多（信息）。这些指标会被收集并存储这些值的系统采用。

在这方面 Prometheus 并没有什么不同。通过 Prometheus 生态来转换指标的模式被称为 “导出器”（“exporter”）。有[许多导出器](https://prometheus.io/docs/instrumenting/exporters/)存在用来将指标转换为 “Prometheus 导出格式”（“Prometheus Exposition Format”），这种格式的数据才可以被 Prometheus 服务器消费。导出器是小的独立运行的程序，有时候被部署为 Kubernetes 里容器的 side-car，从而被用作目标系统和 用作 Prometheus 指标的转换器。

[node_exporter](https://github.com/prometheus/node_exporter) 是一个 Prometheus 官方项目，它导出 Linux 内核运行时和性能数据以便 Prometheus 服务器收集。这是一个活跃的项目并定期发布。
> **在Kubernetes里安装**
> 
> 我忘了提到有许多优秀的包来处理 Prometheus 安装，它支持将 `node_exporter` 安装进你的 Kubernetes 集群。
> 
> [Prometheus 操作者（Prometheus Operator）](https://github.com/coreos/prometheus-operator)，一个来自 CoreOs 的优秀的[操作者模式](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)的实现，可用于将 Prometheus 安装进 Kubernetes 集群。
> 
> [Prometheus Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/prometheus)，一个使用 helm 来安装 Prometheus 的 helm chart。
> 
> 来自 Kausal 用于 Prometheus （安装）的 [ksonnet mix-in](https://github.com/kausalco/public/blob/master/prometheus-ksonnet/README.md)。
### `node_exporter` 作为 DaemonSet
一个单实例的 `node_exporter` 需要内安装到你的集群内的每一个节点上以便收集这些节点的指标，在每一个机器上安装一件程序的 Kubernetes 的方式是利用 [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)。Kubernetes 将确保每个节点只会安装一个实例，并在必要时重启它。非常智能！
#### 什么指标会被收集？
`node_exporter` 默认打开 30 个不同的指标分类，另有 14 指标分类可以选择性开启。在我们的产品集群中，每个主机收集超过 `1000` 个指标系列。
#### 什么指标是重要的？
面对 `node_exporter` 收集的数百个指标，很容易淹没在众多的指标海洋里。在大部分云提供商，你应该首先考虑“核心”资源指标，即 CPU，内存，磁盘和网络。

在一个 Kubernetes 集群里，CPU，内存，磁盘和网络会由 kubetlet 暴露（通过 cAdvisor）。这些核心容器指标属于每个容器范畴，并被直接映射到由 node_exporter 导出的核心指标。由于容器运行时可以限制单个容器的资源消耗，我们必须得有新的工具来判断资源是用饱和度。
## Part 2: USE 方法及 node_exporter 指标
本节将深入讨论由 node_exporter 导出的节点指标。首先，我们将快速查看几种决定什么是重要指标的方法，接下来我将检视核心节点指标；基于使用率，饱和度及错误各个方面的CPU，内存，磁盘及网络。
## Part 3: 容器资源指标
## Part 4: Kubernetes API Server
## Part 5: etcd 指标
## Part 6: kube-state-metrics

## Reference
- [A Deep Dive into Kubernetes Metrics](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-b190cc97f0f6)