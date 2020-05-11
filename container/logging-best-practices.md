# Docker架构引用：Docker日志设计与最佳实践
## 简介
传统上设计与实现集中式日志是一件事后工作。直到问题出现，一个可供查询，查看，分析日志的集中式日志方案才被提到一个高优先级，以此来帮助定位问题根源。当时，在容器化的时代，当利用Docker企业平台来设计一个“容器即服务”(CaaS)的平台时，集中式日志方案的优先级是至关重要的。随着在容器中部署的微服务日趋增多，由它们产生的日志（事件）格式数据数量呈指数级增长。
## 你将学到什么
这份架构引用提供了一份Docker日志如何工作的概观，解释了Docker日志的两种类别，然后讨论Docker日志最佳实践。
## 理解Docker日志（机制）
在深入讨论Docker日志设计考量之前，最好了解一些Docker日志的基础知识。

Docker支持不同的日志驱动用于存储或流化来自主容器进程（pid 1）的容器标准输出和错误输出。缺省地，Docker使用`json-file`日志驱动，但它可通过修改`/etc/docker/daemon.json`中`log-driver`的配置值来使用其它许多日志驱动，注意需要重启Docker服务以重新加载配置。

新的日志驱动将应用于重新配置（重新配置日志驱动后重启已存在的容器并不会导致容器使用更新后的设置）之后启动的所有容器。为了覆盖缺省日志驱动可以使用`--log-driver` 或 `--log-opt`选项启动容器。另一方面，Swarm-mode的服务可以在运行时使用`docker service update --log-driver <DRIVER_NAME> --log-opt <LIST OF OPTIONS> <SERVICE NAME>`动态修改其日志驱动。

那Docker引擎本身的日志呢？这些日志被系统缺省管理日志器（default system manager logger）处理。大部分现代操作系统 (CentOS 7, RHEL 7, Ubuntu 16等)使用systemd，它使用journald记录日志，journalctl来访问日志。可使用`journalctl -u docker.service`来访问驱动日志。
## Docker日志类别和源
现在我们已经讨论过Docker日志的基础知识，这一节将解释日志类别和日志源。

Docker日志典型地划分为两类：基础设施管理和应用日志。大多数日志基于访问它们的角色自然地进入以上两种类型：
+ 运维人员主要担心平台的稳定性和服务的可用性
+ 开发人员主要担心应用代码以及服务如何运行

为了拥有一个自服务平台（self-service platform），为了执行他们的角色的职责运维人员和开发人员都需要访问日志。DevOps实践建议两者应对服务的可用性及性能有综合的，共享的责任。但是，每人并不需要访问平台上的每个日志（类型）。比如，开发人员应该仅仅访问它们的服务，以及集成点的日志。运维人员更关心Docker服务日志，UCP与DTR可用性，以及服务可用性。因为运维人员和开发人员都关注服务可用性，他们的日志关注点可能有点重合。每个角色需要访问的日志允许当问题出现时问题定位更简单，平均解决时间（(MTTR)）不断下降。
### 基础设施管理日志
基础设施管理日志包括Docker引擎日志，运行UCP或DTR的容器日志，以及任何部署的集中式基础设施服务（考虑容器化的监控代理）。
#### Docker引擎日志
正如前面提到，Docker引擎日志由操作系统系统管理器捕获。这些日志可被发送到一个集中式日志服务。
#### UCP与DTR系统日志
UCP与DTR被部署为Docker容器。它们的日志在容器的标准输出与错误输出（`STDOUT/STDERR`）中被捕获。Docker引擎的缺省日志驱动捕获这些日志。

UCP可被配置为使用远程syslog日志设施 ，这可以在安装后从UCP UI上为其所有容器修改。
> **注意**：推荐在安装UCP与DTR之前配置Docker引擎缺省日志驱动，这样它们的日志可被选择的日志驱动捕获。这是由于容器一旦被创建，就不能够改变其日志驱动。这个规则的唯一例外是`ucp-agent`，它是UCP 的一个组件，被部署为一个Swarm服务。
#### 基础设施服务
基础设施运维团队部署集中式的基础设施服务用于各种各样的基础设施运维操作，例如监控，审计，报告，配置部署等等。这些服务也会产生重要日志，需要捕获。典型地，这些日志限于其容器的标准输出与错误输出，因此它们都会被Docker引擎的缺省日志驱动捕获。如果没有，它们就需要被单独处理。
### 应用日志
应用产生的日志可包括定制的应用日志以及应用主进程的`STDOUT/STDERR`日志。正如前面描述的，所有容器的`STDOUT/STDERR`日志被Docker引擎的缺省日志驱动捕获。因此，不需要去做任何定制配置来捕获它们。如果应用有定制的日志（比如将日志写入容器内的/var/log/myapp.log），你就必须考了你到这一点（如何捕获它们）。
## Docker日志设计考量
理解Docker引擎的类型是重要的。定义消费及拥有它们的入口也是很重要的。
### Docker日志类别
主要地，Docker日志分为两类：基础设施日志和应用日志。
### 定义组织所有权
根据组织结构和策略决定这些类别可否与现有团队有直接的映射。如果没有，定义这些组织或团队的对应日志类别是非常重要的。

类别|团队
--------|--------
系统和管理日志|基础设施运维
应用日志|应用维护

如果组织是大的组织的一部分，这些类型可能更多，可将它们细分到更特定的团队。

类别|团队
--------|--------
Docker引擎日志|基础设施运维
基础设施服务|基础设施运维
UCP与DTR日志|UCP与DTR维护
应用A日志|应用A维护
应用B日志|应用B维护

有些组织并不区分基础设施运维和应用维护，因此它们可能合并这两类并由一个运维团队负责拥有它们。

类别|团队
--------|--------
系统和管理日志|基础设施运维
应用日志|基础设施运维
### 选择一个日志基础设施
Docker可以很容易地与现有日志工具和方案集成。日志生态系统中的大部分日志工具已经开发了Docker日志，并提供了与Docker集成的合适的文档。

选取日志方案如下：
+ 允许上节定义的日志所有权模型实现。例如，某些组织可能选择发送所有日志到一个简单的日志基础设施，然后对不同运营团队提供不同的访问级别。
+ 组织最熟悉它。Docker能够与大多数流行的日志供应商集成。请参考你的日志供应商的文档以获取更多信息。
+ 拥有Docker集成：预配置的仪表板，稳定的Docker插件，合适的文档等。
### 应用日志驱动
Docker拥有几种可用的日志驱动可被用于应用程序日志的管理。检查[Docker docs](https://docs.docker.com/config/containers/logging/#supported-logging-drivers)可获取其完整列表以及如何使用它们的细节信息。许多日志供应商拥有收集和发送日志的代理，请参阅其正式文档以了解如何配置代理以便和Docker企业版集成。

一个通用规则，如果已经有一个到位的日志基础设施，你应该使用已有基础设施的日志驱动。下面是一个Docker企业版内建的日志引擎列表。

驱动|优点|缺点
--------|--------|--------
none|极其安全，因为什么都不记录|没有日志，定位问题相当困难
[local](https://docs.docker.com/config/containers/logging/local/)|为性能和磁盘使用而优化，缺省日志大小有优化|由于文件格式（它是压缩的）的问题它不能用于集中式日志
[json-file](https://docs.docker.com/engine/admin/logging/json-file/)|缺省驱动，支持标签|日志驻于本地，并不聚集，如果不设限制日志可能填满磁盘。查阅文档以获取更多信息。额外的磁盘I/O，如果你需要传送这些日志你需要额外的工具
[syslog](https://docs.docker.com/engine/admin/logging/syslog/)|大多数机器提供了syslog，支持加密TLS传输，支持标签。集中式日志视图|需要被设置为高可用性，否则如果起不可用容器启动就会有问题。额外的网络I/O，易受网络问题影响
[journald](https://docs.docker.com/engine/admin/logging/journald/)|日志聚集，不受本地假脱机影响，它也可收集Docker服务日志|因为journal日志是二进制格式，需要采取额外步骤把它们转送到日志收集器。额外的磁盘I/O
[gelf](https://docs.docker.com/engine/admin/logging/gelf/)|缺省提供可索引的字段（容器id，主机名，容器名等）以及标记，集中式日志视图，弹性|额外的网络I/O，易受网络问题影响，有更多组件需维护
[fluentd](https://docs.docker.com/config/containers/logging/fluentd/)|缺省提供容器id，容器名，fluentd支持多个输出。集中式日志视图，弹性|没有TLS支持，额外的网络I/O，易受网络问题影响，有更多组件需维护
[awslogs](https://docs.docker.com/engine/admin/logging/awslogs/)|使用AWS时易于集成，需要维护的基础设施更少，支持标记。集中式日志视图|对混合云配置和本地（机房）安装并非最理想的选择。额外的网络I/O，易受网络问题影响
[splunk](https://docs.docker.com/engine/admin/logging/splunk/)|易于与Splunk集成，TLS支持，高可配置性，标记支持，额外度量。集中式日志视图|Splunk需要是高可用的，否则容器启动可能会有问题--通过`set splunk-verify-connection = false`可防止该问题。额外的网络I/O，易受网络问题影响
[etwlogs](https://docs.docker.com/engine/admin/logging/etwlogs/)|Windows上的通用日志框架，缺省为可索引的值|只工作于Windows，这些日志将不得不从Windows机器通过不同的工具传送到汇聚器
[gcplogs](https://docs.docker.com/engine/admin/logging/gcplogs/)|易于与Google计算集成，需要维护的基础设施更少，支持标记。集中式日志视图|对混合云配置和本地（机房）安装并非最理想的选择。额外的网络I/O，易受网络问题影响
[logentries](https://docs.docker.com/config/containers/logging/logentries/)|需管理的东西更少，基于SaaS的日志汇集与分析，支持TLS|需要[logentries](https://logentries.com/)订阅
## 收集日志
利用Docker企业版，有一些不同的方式执行集群级别的日志（记录）。
+ 在节点级别使用日志驱动
+ 当利用Swarm部署为[global](https://docs.docker.com/engine/reference/commandline/service_create/#set-service-mode---mode)服务，或利用Kubernetes部署为[DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)时使用日志代理
+ 让应用自己向你的日志基础设施发送日志
### 节点级别日志
为了实现节点级别日志，简单在Linux机器上在`/etc/docker/daemon.json`中添加一个条目来指定日志驱动。在Windows机器上缺省的Docker引擎配置文件位于`%programdata%\docker\config\daemon.json`。

> 使用缺省的`json-file`或`journald`也可以实现节点级别的日志，缺省地没有提供自动回转设置。为确保磁盘不被日志填满，推荐在安装Docker企业版前修改配置为自动回转选项，如下所示：
```
{
 "log-driver": "json-file",
 "log-opts": {
   "max-size": "10m",
   "max-file": "3" 
 }
}
```

Docker企业版用户可以使用“双日志”，这可使你利用`docker logs`来指定任何日志驱动。请参阅[Docker文档](https://docs.docker.com/config/containers/logging/dual-logging/)来了解Docker企业版特性的更多细节。
### Windows日志
ETW日志驱动是Windows支持的。ETW代表Event Tracing in Windows，它是在Windows上追踪应用的常用框架。每条ETW事件含有一条消息，其带有一个日志及其上下文信息。一个客户可以创建一个ETW监听器来监听这些事件。

可选地，如果Splunk在你的组织中可用，Splunk可被用于收集Windows容器日志。为了让此功能正常工作，一个[HTTP连接器](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector)需要在Splunk服务器端设置好。下面是一个发送容器日志到Splunk的Windows机器的`daemon.json`实例：
```
{
  "data-root": "d:\\docker",
  "labels": ["os=windows"],
  "log-driver": "splunk",
  "log-opts": {
    "splunk-token": "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE",
    "splunk-url": "https://splunk.example.com",
    "splunk-format": "json",
    "splunk-index": "main",
    "splunk-insecureskipverify": "true",
    "splunk-verify-connection": "false",
    "tag":"{{.ImageName}} | {{.Name}} | {{.ID}}"
   }
}
```
### 节点级别Swarm日志范例
为了实现系统级别日志，请在`/etc/docker/daemon.json`中添加一个条目。例如，使用下面的配置来开启`gelf`输出差件：
```
{
    "log-driver": "gelf",
    "log-opts": {
     "gelf-address": "udp://1.2.3.4:12201",
     "tag":"{{.ImageName}}/{{.Name}}/{{.ID}}"
    }
}
```
然后重启Docker服务，所有的日志驱动可以通过`/etc/docker/daemon.json`以同样的方式配置。在上面使用`gelf`的例子中，`tag`指定了当日志被收集后可被查询和索引的数据。请查阅每一种日志驱动的文档以获取设置日志驱动的额外字段。

通过`/etc/docker/daemon.json`文件设置日子将在节点级别设置缺省日志的行为。这可以通过服务级别或容器级别设置改写。改写缺省日志行为对问题定位是有好处的--我们可以看到实时日志。

如果一个服务在一个`daemon.json`配置为使用`gelf`日志驱动的系统上创建，然后该主机上运行的所有容器日志都会被发送到`gelf-address`指定的机器上去。

如果喜欢一个不同的日志驱动，比如从容器的`stdout`上查看日志流，那么可以覆盖缺省的的日志驱动行为：
```
docker service create \
      -–log-driver json-file --log-opt max-size=10m \
      nginx:alpine
```
这可以与Docker服务日志耦合以更方便地定位服务问题。
### Docker Swarm服务日志
当一个服务拥有多路重复的任务时，`docker service logs`提供了日志流的多路复用。通过输入`docker service logs <service_id>`，日志在第一栏显示了其来源任务名称，接下来是右边每个复制任务的实时日志。例如：
```
$ docker service create -d --name ping --replicas=3 alpine:latest ping 8.8.8.8
5x3enwyyr1re3hg1u2nogs40z

$ docker service logs ping
ping.2.n0bg40kksu8e@m00    | 64 bytes from 8.8.8.8: seq=43 ttl=43 time=24.791 ms
ping.3.pofxdol20p51@w01    | 64 bytes from 8.8.8.8: seq=44 ttl=43 time=34.161 ms
ping.1.o07dvxfx2ou2@w00    | 64 bytes from 8.8.8.8: seq=44 ttl=43 time=30.111 ms
ping.2.n0bg40kksu8e@m00    | 64 bytes from 8.8.8.8: seq=44 ttl=43 time=25.276 ms
ping.3.pofxdol20p51@w01    | 64 bytes from 8.8.8.8: seq=45 ttl=43 time=24.239 ms
ping.1.o07dvxfx2ou2@w00    | 64 bytes from 8.8.8.8: seq=45 ttl=43 time=26.403 ms
```
这个命令在在查看一个拥有多个任务副本的服务输出时很有用。跨越多个副本实时地，流式查看日志允许整个集群范围的服务issue的快速理解和定位。
## 部署日志代理
许多日志供应商拥有他们自己的日志代理，请参阅其各自的文档来获取使用其工具套件的详细指令。

一般来讲，这些代理或被部署为[全局性](https://docs.docker.com/engine/reference/commandline/service_create/#set-service-mode---modeglobal)Swarm服务，或者为一个Kubernetes [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) 。
## Brownfield应用日志
有时候，尤其在处理brownfield（已存在）的应用是，并非所有的日志都会被输出到标准输出。在这种情况下，部署一个边车容器来确保写到磁盘的日志都会被收集是有用的。请参阅[Kubernetes文档](https://kubernetes.io/docs/concepts/cluster-administration/logging/#using-a-sidecar-container-with-the-logging-agent)以获取一个使用`fluentd`以及一个边车容器来收集额外日志的例子。
## 日志基础设施
推荐日志基础设施布置于与你的应用部署独立的环境中。如果你的日志基础设施不可用，则定位集群和应用问题将变得复杂。使用Docker企业版时创建一个工具集群来收集度量和日志是一个最佳实践。
## 结论
Docker提供了许多选项来控制日志， 当采用Docker平台时制定一个日志战略是有帮助的。对大多数系统，将日志数据留在宿主机上是不够的。能够索引，搜索，有一个自服务平台可以对运维和开发人员提供平滑的体验。

## Reference
- [Docker Reference Architecture: Docker Logging Design and Best Practices](https://success.docker.com/article/logging-best-practices)