# 服务、负载均衡和联网（Services, Load Balancing, and Networking）
## 1. Service 拓扑（Service Topology）
Service 拓扑可以让一个服务基于集群的 Node 拓扑进行流量路由。例如，一个服务可以指定流量是被优先路由到一个和客户端在同一个 Node 或者在同一可用区域的端点。
> **该特性始于**：Kubernetes v1.17 [alpha]
### 1.1 介绍
默认情况下，发往 ClusterIP 或者 NodePort 服务的流量可能会被路由到任意一个服务后端的地址上。从 Kubernetes 1.7 开始，可以将“外部”流量路由到节点运行的 pod 上，但该pod不支持 ClusterIP 服务，更复杂的拓扑 — 比如分区路由 — 也还不支持。通过允许 Service 创建者根据源 Node 和目的 Node 的标签来定义流量路由策略，Service 拓扑特性实现了服务流量的路由。

通过对源 Node 和目的 Node 标签的匹配，运营者可以使用任何符合运营者要求的度量值来指定彼此“较近”和“较远”的节点组。例如，对于在公有云上的运营者来说，更偏向于把流量控制在同一可用区（zone）内，因为区域间（interzonal）的流量是有费用成本的，而区域内（intrazonal）的流量没有。其它常用需求还包括把流量路由到由 DaemonSet 管理的本地 Pod 上，或者把保持流量在连接同一机架交换机的 Node 上，以获得低延时。
### 1.2 前提条件
为了启用拓扑感知服务路由功能，必须要满足以下一些前提条件：
- Kubernetes 的版本不低于 1.17
- Kube-proxy 运行在 iptables 模式或者 IPVS 模式
- 启用 [端点切片](https://kubernetes.io/zh/docs/concepts/services-networking/endpoint-slices/)功能
### 1.3 启用 Service 拓扑
要启用 Service 拓扑，就要给 kube-apiserver 和 kube-proxy 启用 ServiceTopology 功能：
`--feature-gates="ServiceTopology=true"`
### 1.4 使用 Service 拓扑
如果集群启用了 Service 拓扑功能后，就可以在 Service 配置中指定 topologyKeys 字段，从而控制 Service 的流量路由。此字段是 Node 标签的优先顺序字段，将用于在访问这个 Service 时对端点进行排序。流量会被定向到第一个标签值和源 Node 标签值相匹配的 Node。如果这个 Service 没有匹配的后端 Node，那么第二个标签会被使用做匹配，以此类推，直到没有标签。

如果没有匹配到，流量会被拒绝，就如同这个 Service 根本没有后端。这是根据有可用后端的第一个拓扑键来选择端点的。如果这个字段被配置了而没有后端可以匹配客户端拓扑，那么这个 Service 对那个客户端是没有后端的，链接应该是失败的。这个字段配置为 "*" 意味着任意拓扑。这个通配符值如果使用了，那么只有作为配置值列表中的最后一个才有用。

如果 topologyKeys 没有指定或者为空，就没有启用这个拓扑功能。

一个集群中，其 Node 的标签被打为其主机名，区域名和地区名。那么就可以设置 Service 的 topologyKeys 的值，像下面的做法一样定向流量了：
- 只定向到同一个 Node 上的端点，Node 上没有端点存在时就失败：配置 ["kubernetes.io/hostname"]。
- 偏向定向到同一个 Node 上的端点，回退同一区域（zone）的端点上，然后是同一地区（region），其它情况下就失败：配置 ["kubernetes.io/hostname", "topology.kubernetes.io/zone", "topology.kubernetes.io/region"]。这或许很有用，例如，数据局部性很重要的情况下。
- 偏向于同一区域（zone），但如果此区域中没有可用的终结点，则回退到任何可用的终结点：配置 ["topology.kubernetes.io/zone", "*"]。
### 1.5 约束条件
- Service 拓扑和 externalTrafficPolicy=Local 是不兼容的，所以 Service 不能同时使用这两种特性。但是在同一个集群的不同 Service 上是可以分别使用这两种特性的，只要不在同一个 Service 上就可以。
- 有效的拓扑键目前只有：kubernetes.io/hostname，topology.kubernetes.io/zone 和 topology.kubernetes.io/region，但是未来会推广到其它的 Node 标签。
- 拓扑键必须是有效的标签，并且最多指定16个。
- 通配符："*"，如果要用，那必须是拓扑键值的最后一个值。
## 2. 服务
将运行在一组 Pods 上的应用程序公开为网络服务的抽象方法。

使用 Kubernetes，您无需修改应用程序即可使用不熟悉的服务发现机制。 Kubernetes 为 Pods 提供自己的 IP 地址，并为一组 Pod 提供相同的 DNS 名， 并且可以在它们之间进行负载平衡。
### 2.1 动机
Kubernetes Pod 是有生命周期的。 它们可以被创建，而且销毁之后不会再启动。 如果您使用 Deployment 来运行您的应用程序，则它可以动态创建和销毁 Pod。

每个 Pod 都有自己的 IP 地址，但是在 Deployment 中，在同一时刻运行的 Pod 集合可能与稍后运行该应用程序的 Pod 集合不同。

这导致了一个问题： 如果一组 Pod（称为“后端”）为群集内的其他 Pod（称为“前端”）提供功能， 那么前端如何找出并跟踪要连接的 IP 地址，以便前端可以使用工作量的后端部分？

进入 Services。
### 2.2 Service 资源
Kubernetes Service 定义了这样一种抽象：逻辑上的一组 Pod，一种可以访问它们的策略 —— 通常称为微服务。 这一组 Pod 能够被 Service 访问到，通常是通过 选择算符 （查看下面了解，为什么你可能需要没有 selector 的 Service）实现的。

举个例子，考虑一个图片处理后端，它运行了 3 个副本。这些副本是可互换的 —— 前端不需要关心它们调用了哪个后端副本。 然而组成这一组后端程序的 Pod 实际上可能会发生变化， 前端客户端不应该也没必要知道，而且也不需要跟踪这一组后端的状态。 Service 定义的抽象能够解耦这种关联。
#### 2.2.1 云原生服务发现
如果您想要在应用程序中使用 Kubernetes API 进行服务发现，则可以查询 API 服务器 的 Endpoints 资源，只要服务中的 Pod 集合发生更改，Endpoints 就会被更新。

对于非本机应用程序，Kubernetes 提供了在应用程序和后端 Pod 之间放置网络端口或负载均衡器的方法。
### 2.3 定义 Service
Service 在 Kubernetes 中是一个 REST 对象，和 Pod 类似。 像所有的 REST 对象一样，Service 定义可以基于 POST 方式，请求 API server 创建新的实例。

例如，假定有一组 Pod，它们对外暴露了 9376 端口，同时还被打上 app=MyApp 标签。
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
上述配置创建一个名称为 "my-service" 的 Service 对象，它会将请求代理到使用 TCP 端口 9376，并且具有标签 "app=MyApp" 的 Pod 上。 Kubernetes 为该服务分配一个 IP 地址（有时称为 "集群IP"），该 IP 地址由服务代理使用。 (请参见下面的 VIP 和 Service 代理). 服务选择算符的控制器不断扫描与其选择器匹配的 Pod，然后将所有更新发布到也称为 “my-service” 的 Endpoint 对象。
> **说明**： 需要注意的是，Service 能够将一个接收 port 映射到任意的 targetPort。 默认情况下，targetPort 将被设置为与 port 字段相同的值。

Pod 中的端口定义是有名字的，你可以在服务的 targetTarget 属性中引用这些名称。 即使服务中使用单个配置的名称混合使用 Pod，并且通过不同的端口号提供相同的网络协议，此功能也可以使用。 这为部署和发展服务提供了很大的灵活性。 例如，您可以更改Pods在新版本的后端软件中公开的端口号，而不会破坏客户端。

服务的默认协议是TCP。 您还可以使用任何[其它受支持的协议](https://kubernetes.io/zh/docs/concepts/services-networking/service/#protocol-support)。

由于许多服务需要公开多个端口，因此 Kubernetes 在服务对象上支持多个端口定义。 每个端口定义可以具有相同的 protocol，也可以具有不同的协议。
#### 2.3.1 没有选择算符的 Service 
服务最常见的是抽象化对 Kubernetes Pod 的访问，但是它们也可以抽象化其他种类的后端。 实例:
- 希望在生产环境中使用外部的数据库集群，但测试环境使用自己的数据库。
- 希望服务指向另一个 命名空间 中或其它集群中的服务。
- 您正在将工作负载迁移到 Kubernetes。 在评估该方法时，您仅在 Kubernetes 中运行一部分后端。

在任何这些场景中，都能够定义没有选择算符的 Service。 实例:
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
由于此服务没有选择算符，因此 不会 自动创建相应的 Endpoint 对象。 您可以通过手动添加 Endpoint 对象，将服务手动映射到运行该服务的网络地址和端口：
```
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
```
> **说明**： 端点 IPs 必须不可以 是：本地回路（IPv4 的 127.0.0.0/8, IPv6 的 ::1/128）或 本地链接（IPv4 的 169.254.0.0/16 和 224.0.0.0/24，IPv6 的 fe80::/64)。 端点 IP 地址不能是其他 Kubernetes 服务的集群 IP，因为 kube-proxy 不支持将虚拟 IP 作为目标。

访问没有选择算符的 Service，与有选择算符的 Service 的原理相同。 请求将被路由到用户定义的 Endpoint，YAML 中为：192.0.2.42:9376（TCP）。

ExternalName Service 是 Service 的特例，它没有选择算符，但是使用 DNS 名称。 有关更多信息，请参阅本文档后面的[ExternalName](https://kubernetes.io/zh/docs/concepts/services-networking/service/#externalname)。
#### 2.3.2 Endpoint 切片
> 该特性始于：Kubernetes v1.16 [alpha]

Endpoint 切片是一种 API 资源，可以为 Endpoint 提供更可扩展的替代方案。 尽管从概念上讲与 Endpoint 非常相似，但 Endpoint 切片允许跨多个资源分布网络端点。 默认情况下，一旦到达100个 Endpoint，该 Endpoint 切片将被视为“已满”， 届时将创建其他 Endpoint 切片来存储任何其他 Endpoint。

Endpoint 切片提供了附加的属性和功能，这些属性和功能在 [Endpoint 切片](https://kubernetes.io/zh/docs/concepts/services-networking/endpoint-slices/)中有详细描述。
#### 2.3.3 应用程序协议
> 该特性始于：Kubernetes v1.18 [alpha]

appProtocol 字段提供了一种为每个 Service 端口指定应用程序协议的方式。

作为一个 alpha 特性，该字段默认未启用。要使用该字段，请启用 ServiceAppProtocol [特性门控](https://kubernetes.io/zh/docs/reference/command-line-tools-reference/feature-gates/)。
### 2.4 VIP 和 Service 代理
在 Kubernetes 集群中，每个 Node 运行一个 kube-proxy 进程。 kube-proxy 负责为 Service 实现了一种 VIP（虚拟 IP）的形式，而不是 [ExternalName](https://kubernetes.io/zh/docs/concepts/services-networking/service/#externalname) 的形式。
#### 2.4.1 为什么不使用 DNS 轮询？
时不时会有人问道，就是为什么 Kubernetes 依赖代理将入站流量转发到后端。 那其他方法呢？ 例如，是否可以配置具有多个A值（或IPv6为AAAA）的DNS记录，并依靠轮询名称解析？

使用服务代理有以下几个原因：
- DNS 实现的历史由来已久，它不遵守记录 TTL，并且在名称查找结果到期后对其进行缓存。
- 有些应用程序仅执行一次 DNS 查找，并无限期地缓存结果。
- 即使应用和库进行了适当的重新解析，DNS 记录上的 TTL 值低或为零也可能会给 DNS 带来高负载，从而使管理变得困难。
#### 2.4.2 版本兼容性
从 Kubernetes v1.0 开始，您已经可以使用[用户空间代理模式](https://kubernetes.io/zh/docs/concepts/services-networking/service/#proxy-mode-userspace)。 Kubernetes v1.1 添加了 iptables 模式代理，在 Kubernetes v1.2 中，kube-proxy 的 iptables 模式成为默认设置。 Kubernetes v1.8 添加了 ipvs 代理模式。
#### 2.4.3 userspace 代理模式
这种模式，kube-proxy 会监视 Kubernetes 主控节点对 Service 对象和 Endpoints 对象的添加和移除操作。 对每个 Service，它会在本地 Node 上打开一个端口（随机选择）。 任何连接到“代理端口”的请求，都会被代理到 Service 的后端 Pods 中的某个上面（如 Endpoints 所报告的一样）。 使用哪个后端 Pod，是 kube-proxy 基于 SessionAffinity 来确定的。

最后，它配置 iptables 规则，捕获到达该 Service 的 clusterIP（是虚拟 IP） 和 Port 的请求，并重定向到代理端口，代理端口再代理请求到后端Pod。

默认情况下，用户空间模式下的 kube-proxy 通过轮转算法选择后端。
![userspace 代理模式](images/services-userspace-overview.svg)
#### 2.4.4 iptables 代理模式
这种模式，kube-proxy 会监视 Kubernetes 控制节点对 Service 对象和 Endpoints 对象的添加和移除。 对每个 Service，它会配置 iptables 规则，从而捕获到达该 Service 的 clusterIP 和端口的请求，进而将请求重定向到 Service 的一组后端中的某个 Pod 上面。 对于每个 Endpoints 对象，它也会配置 iptables 规则，这个规则会选择一个后端组合。

默认的策略是，kube-proxy 在 iptables 模式下随机选择一个后端。

使用 iptables 处理流量具有较低的系统开销，因为流量由 Linux netfilter 处理， 而无需在用户空间和内核空间之间切换。 这种方法也可能更可靠。

如果 kube-proxy 在 iptables 模式下运行，并且所选的第一个 Pod 没有响应， 则连接失败。 这与用户空间模式不同：在这种情况下，kube-proxy 将检测到与第一个 Pod 的连接已失败， 并会自动使用其他后端 Pod 重试。

您可以使用 [Pod 就绪探测器](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/#container-probes) 验证后端 Pod 可以正常工作，以便 iptables 模式下的 kube-proxy 仅看到测试正常的后端。 这样做意味着您避免将流量通过 kube-proxy 发送到已知已失败的Pod。

![iptables 代理模式](images/services-iptables-overview.svg)
#### 2.4.5 IPVS 代理模式
> 该特性始于：Kubernetes v1.11 [stable]

在 ipvs 模式下，kube-proxy监视Kubernetes服务和端点，调用 netlink 接口相应地创建 IPVS 规则， 并定期将 IPVS 规则与 Kubernetes 服务和端点同步。 该控制循环可确保IPVS 状态与所需状态匹配。访问服务时，IPVS 将流量定向到后端Pod之一。

IPVS代理模式基于类似于 iptables 模式的 netfilter 挂钩函数， 但是使用哈希表作为基础数据结构，并且在内核空间中工作。 这意味着，与 iptables 模式下的 kube-proxy 相比，IPVS 模式下的 kube-proxy 重定向通信的延迟要短，并且在同步代理规则时具有更好的性能。 与其他代理模式相比，IPVS 模式还支持更高的网络流量吞吐量。

IPVS提供了更多选项来平衡后端Pod的流量。 这些是：
- rr: round-robin
- lc: least connection (smallest number of open connections)
- dh: destination hashing
- sh: source hashing
- sed: shortest expected delay
- nq: never queue

> **说明**：要在 IPVS 模式下运行 kube-proxy，必须在启动 kube-proxy 之前使 IPVS Linux 在节点上可用。
> 
> 当 kube-proxy 以 IPVS 代理模式启动时，它将验证 IPVS 内核模块是否可用。 如果未检测到 IPVS 内核模块，则 kube-proxy 将退回到以 iptables 代理模式运行。

![IPVS 代理模式](images/services-ipvs-overview.svg)

在这些代理模型中，绑定到服务IP的流量： 在客户端不了解Kubernetes或服务或Pod的任何信息的情况下，将Port代理到适当的后端。 如果要确保每次都将来自特定客户端的连接传递到同一 Pod， 则可以通过将 `service.spec.sessionAffinity` 设置为 "ClientIP" （默认值是 "None"），来基于客户端的 IP 地址选择会话关联。

您还可以通过适当设置 `service.spec.sessionAffinityConfig.clientIP.timeoutSeconds` 来设置最大会话停留时间。（默认值为 10800 秒，即 3 小时）。
### 2.5 多端口 Service
对于某些服务，您需要公开多个端口。 Kubernetes 允许您在 Service 对象上配置多个端口定义。 为服务使用多个端口时，必须提供所有端口名称，以使它们无歧义。

例如：
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
    - name: https
      protocol: TCP
      port: 443
      targetPort: 9377
```
> **说明**：与一般的Kubernetes名称一样，端口名称只能包含小写字母数字字符 和 -。 端口名称还必须以字母数字字符开头和结尾。
> 
> 例如，名称 123-abc 和 web 有效，但是 123_abc 和 -web 无效。
### 2.6 选择自己的 IP 地址
在 `Service` 创建的请求中，可以通过设置 `spec.clusterIP` 字段来指定自己的集群 IP 地址。 比如，希望替换一个已经已存在的 DNS 条目，或者遗留系统已经配置了一个固定的 IP 且很难重新配置。

用户选择的 IP 地址必须合法，并且这个 IP 地址在 `service-cluster-ip-range CIDR` 范围内， 这对 API 服务器来说是通过一个标识来指定的。 如果 IP 地址不合法，API 服务器会返回 HTTP 状态码 422，表示值不合法。
### 2.7 服务发现
Kubernetes 支持两种基本的服务发现模式 —— 环境变量和 DNS。
#### 2.7.1 环境变量
当 Pod 运行在 Node 上，kubelet 会为每个活跃的 Service 添加一组环境变量。 它同时支持 Docker links兼容 变量 （查看 [makeLinkVariables](https://releases.k8s.io/master/pkg/kubelet/envvars/envvars.go#L49)）、 简单的 `{SVCNAME}_SERVICE_HOST` 和 `{SVCNAME}_SERVICE_PORT` 变量。 这里 `Service` 的名称需大写，横线被转换成下划线。

举个例子，一个名称为 "redis-master" 的 Service 暴露了 TCP 端口 6379， 同时给它分配了 Cluster IP 地址 10.0.0.11，这个 Service 生成了如下环境变量：
```
REDIS_MASTER_SERVICE_HOST=10.0.0.11
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_PORT=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379
REDIS_MASTER_PORT_6379_TCP_ADDR=10.0.0.11
```
> **说明**：当您具有需要访问服务的Pod时，并且您正在使用环境变量方法将端口和群集 IP 发布到客户端 Pod 时，必须在客户端 Pod 出现 之前 创建服务。 否则，这些客户端 Pod 将不会设定其环境变量。
> 
> 如果仅使用 DNS 查找服务的群集 IP，则无需担心此设定问题。
#### 2.7.2 DNS
您可以（几乎总是应该）使用[附加组件](https://kubernetes.io/zh/docs/concepts/cluster-administration/addons/)为 Kubernetes 集群设置 DNS 服务。

支持群集的 DNS 服务器（例如 CoreDNS）监视 Kubernetes API 中的新服务，并为每个服务创建一组 DNS 记录。 如果在整个群集中都启用了 DNS，则所有 Pod 都应该能够通过其 DNS 名称自动解析服务。

例如，如果您在 Kubernetes 命名空间 "my-ns" 中有一个名为 "my-service" 的服务， 则控制平面和DNS服务共同为 "my-service.my-ns" 创建 DNS 记录。 "my-ns" 命名空间中的 Pod 应该能够通过简单地对 my-service 进行名称查找来找到它 （"my-service.my-ns" 也可以工作）。

其他命名空间中的Pod必须将名称限定为 my-service.my-ns。这些名称将解析为为服务分配的群集 IP。

Kubernetes 还支持命名端口的 DNS SRV（服务）记录。 如果 "my-service.my-ns" 服务具有名为 "http"　的端口，且协议设置为 TCP， 则可以对 _http._tcp.my-service.my-ns 执行 DNS SRV 查询查询以发现该端口号, "http" 以及 IP 地址。

Kubernetes DNS 服务器是唯一的一种能够访问 ExternalName 类型的 Service 的方式。 更多关于 ExternalName 信息可以查看[DNS Pod 和 Service](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)。
### 2.8 Headless Services
有时不需要或不想要负载均衡，以及单独的 Service IP。 遇到这种情况，可以通过指定 Cluster IP（spec.clusterIP）的值为 "None" 来创建 Headless Service。

您可以使用无头 Service 与其他服务发现机制配合使用，而不必与 Kubernetes 的实现捆绑在一起。

无头 Service 并不会分配 Cluster IP，kube-proxy 不会处理它们， 而且平台也不会为它们进行负载均衡和路由。 DNS 如何实现自动配置，依赖于 Service 是否定义了选择算符。
#### 2.8.1 带选择算符的服务
对定义了选择算符的无头服务，Endpoint 控制器在 API 中创建了 Endpoints 记录， 并且修改 DNS 配置返回 A 记录（地址），通过这个地址直接到达 Service 的后端 Pod 上。
#### 2.8.2 无选择算符的服务
对没有定义选择算符的无头服务，Endpoint 控制器不会创建 Endpoints 记录。 然而 DNS 系统会查找和配置，无论是：
- ExternalName 类型 Service 的 CNAME 记录
- 记录：与 Service 共享一个名称的任何 Endpoints，以及所有其它类型
### 2.9 发布服务 —— 服务类型
对一些应用（如前端）的某些部分，可能希望通过一个Kubernetes 集群之外的外部 IP 地址暴露 Service。

Kubernetes ServiceTypes 允许指定一个需要的类型的 Service，默认是 ClusterIP 类型。

Type 的取值以及行为如下：
- ClusterIP：通过集群的内部 IP 暴露服务，选择该值，服务只能够在集群内部可以访问，这也是默认的 ServiceType。
- NodePort：通过每个 Node 上的 IP 和静态端口（NodePort）暴露服务。 NodePort 服务会路由到 ClusterIP 服务，这个 ClusterIP 服务会自动创建。 通过请求 <NodeIP>:<NodePort>，可以从集群的外部访问一个 NodePort 服务。
- LoadBalancer：使用云提供商的负载局衡器，可以向外部暴露服务。 外部的负载均衡器可以路由到 NodePort 服务和 ClusterIP 服务。
- ExternalName：通过返回 CNAME 和它的值，可以将服务映射到 externalName 字段的内容（例如， foo.bar.example.com）。 没有任何类型代理被创建。
> **说明**： 您需要 CoreDNS 1.7 或更高版本才能使用 ExternalName 类型。

您也可以使用 [Ingress](https://kubernetes.io/zh/docs/concepts/services-networking/ingress/) 来暴露自己的服务。 Ingress 不是服务类型，但它充当集群的入口点。 它可以将路由规则整合到一个资源中，因为它可以在同一IP地址下公开多个服务。
#### 2.9.1 NodePort 类型
如果将 type 字段设置为 NodePort，则 Kubernetes 控制平面将在 --service-node-port-range 标志指定的范围内分配端口（默认值：30000-32767）。 每个节点将那个端口（每个节点上的相同端口号）代理到您的服务中。 您的服务在其 .spec.ports[*].nodePort 字段中要求分配的端口。

如果您想指定特定的 IP 代理端口，则可以将 kube-proxy 中的 --nodeport-addresses 标志设置为特定的 IP 块。从 Kubernetes v1.10 开始支持此功能。

该标志采用逗号分隔的 IP 块列表（例如，10.0.0.0/8、192.0.2.0/25）来指定 kube-proxy 应该认为是此节点本地的 IP 地址范围。

例如，如果您使用 --nodeport-addresses=127.0.0.0/8 标志启动 kube-proxy，则 kube-proxy 仅选择 NodePort Services 的环回接口。 --nodeport-addresses 的默认值是一个空列表。 这意味着 kube-proxy 应该考虑 NodePort 的所有可用网络接口。 （这也与早期的 Kubernetes 版本兼容）。

如果需要特定的端口号，则可以在 nodePort 字段中指定一个值。控制平面将为您分配该端口或向API报告事务失败。 这意味着您需要自己注意可能发生的端口冲突。您还必须使用有效的端口号，该端口号在配置用于NodePort的范围内。

使用 NodePort 可以让您自由设置自己的负载平衡解决方案，配置 Kubernetes 不完全支持的环境， 甚至直接暴露一个或多个节点的 IP。

需要注意的是，Service 能够通过 <NodeIP>:spec.ports[*].nodePort 和 spec.clusterIp:spec.ports[*].port 而对外可见。

例如：
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: MyApp
  ports:
      # 默认情况下，为了方便起见，`targetPort` 被设置为与 `port` 字段相同的值。
    - port: 80
      targetPort: 80
      # 可选字段
      # 默认情况下，为了方便起见，Kubernetes 控制平面会从某个范围内分配一个端口号（默认：30000-32767）
      nodePort: 30007
```
#### 2.9.2 LoadBalancer 类型
在使用支持外部负载均衡器的云提供商的服务时，设置 type 的值为 "LoadBalancer"， 将为 Service 提供负载均衡器。 负载均衡器是异步创建的，关于被提供的负载均衡器的信息将会通过 Service 的 status.loadBalancer 字段发布出去。

实例:
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
      - ip: 146.148.47.155
```
来自外部负载均衡器的流量将直接重定向到后端 Pod 上，不过实际它们是如何工作的，这要依赖于云提供商。

在这些情况下，将根据用户设置的 loadBalancerIP 来创建负载均衡器。 某些云提供商允许设置 loadBalancerIP。如果没有设置 loadBalancerIP，将会给负载均衡器指派一个临时 IP。 如果设置了 loadBalancerIP，但云提供商并不支持这种特性，那么设置的 loadBalancerIP 值将会被忽略掉。

> **说明**： 如果您使用的是 SCTP，请参阅下面有关 LoadBalancer 服务类型的 注意事项。

> **说明**： 在 Azure 上，如果要使用用户指定的公共类型 loadBalancerIP ，则首先需要创建静态类型的公共IP地址资源。 此公共IP地址资源应与群集中其他自动创建的资源位于同一资源组中。 例如，MC_myResourceGroup_myAKSCluster_eastus。

将分配的IP地址指定为 loadBalancerIP。 确保您已更新云提供程序配置文件中的 securityGroupName。 有关对 CreatingLoadBalancerFailed 权限问题进行故障排除的信息， 请参阅[与Azure Kubernetes服务（AKS）负载平衡器一起使用静态IP地址](https://docs.microsoft.com/en-us/azure/aks/static-ip)或[通过高级网络在AKS群集上创建LoadBalancerFailed](https://github.com/Azure/AKS/issues/357)。
##### 2.9.2.1 内部负载均衡器 (Internal load balancer)
在混合环境中，有时有必要在同一(虚拟)网络地址块内路由来自服务的流量。

在水平分割 DNS 环境中，您需要两个服务才能将内部和外部流量都路由到您的端点（Endpoints）。 您可以通过向服务添加以下注释之一来实现此目的。 要添加的注释取决于您使用的云服务提供商。
```
[...]
metadata:
    name: my-service
    annotations:
        service.beta.kubernetes.io/aws-load-balancer-internal: "true"
[...]
```
或
```
[...]
metadata:
    name: my-service
    annotations:
        service.beta.kubernetes.io/azure-load-balancer-internal: "true"
[...]
```
##### 2.9.2.2 AWS TLS 支持
为了对在AWS上运行的集群提供部分TLS / SSL支持，您可以向 LoadBalancer 服务添加三个注释：
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
```
第一个指定要使用的证书的ARN。 它可以是已上载到 IAM 的第三方颁发者的证书，也可以是在 AWS Certificate Manager 中创建的证书。

```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: (https|http|ssl|tcp)
```
第二个注释指定 Pod 使用哪种协议。 对于 HTTPS 和 SSL，ELB 希望 Pod 使用证书通过加密连接对自己进行身份验证。

HTTP 和 HTTPS 选择第7层代理：ELB 终止与用户的连接，解析标头，并在转发请求时向 X-Forwarded-For 标头注入用户的 IP 地址（Pod 仅在连接的另一端看到 ELB 的 IP 地址）。

TCP 和 SSL 选择第4层代理：ELB 转发流量而不修改报头。

在某些端口处于安全状态而其他端口未加密的混合使用环境中，可以使用以下注释：
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443,8443"
```
从 Kubernetes v1.9 起可以使用[预定义的 AWS SSL 策略](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html) 为您的服务使用 HTTPS 或 SSL 侦听器。 要查看可以使用哪些策略，可以使用 aws 命令行工具：
```
aws elb describe-load-balancer-policies --query 'PolicyDescriptions[].PolicyName'
```
然后，您可以使用 "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" 注解; 例如：
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: "ELBSecurityPolicy-TLS-1-2-2017-01"
```
##### 2.9.2.3 AWS 上的 PROXY 协议支持
为了支持在 AWS 上运行的集群，启用[PROXY 协议](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)。 您可以使用以下服务注释：
```
metadata:
      name: my-service
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
```
从 1.3.0 版开始，此注释的使用适用于 ELB 代理的所有端口，并且不能进行其他配置。
##### 2.9.2.4 外部 IP
如果有一些外部 IP 地址能够路由到一个或多个集群节点，Kubernetes 服务可以在这些 externalIPs 上暴露出来。 通过外部 IP 进入集群的入站请求，如果指向的是服务的端口，会被路由到服务的末端之一。 externalIPs 不受 Kubernets 管理；它们由集群管理员管理。 在服务规约中，externalIPs 可以和 ServiceTypes 一起指定。 在上面的例子中，客户端可以通过 "80.11.12.10:80" (externalIP:port) 访问 "my-service" 服务。
```
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 9376
  externalIPs:
  - 80.11.12.10
```
##### 2.9.2.5 AWS 上的 ELB 访问日志
有几个注释可用于管理 AWS 上 ELB 服务的访问日志。
- 注释 service.beta.kubernetes.io/aws-load-balancer-access-log-enabled 控制是否启用访问日志。
- 注解 service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval 控制发布访问日志的时间间隔（以分钟为单位）。您可以指定 5 分钟或 60 分钟的间隔。
- 注释 service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name 控制存储负载均衡器访问日志的 Amazon S3 存储桶的名称。
- 注释 service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-prefix 指定为 Amazon S3 存储桶创建的逻辑层次结构。

```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-access-log-enabled: "true"
    # Specifies whether access logs are enabled for the load balancer
    service.beta.kubernetes.io/aws-load-balancer-access-log-emit-interval: "60"
    # The interval for publishing the access logs. You can specify an interval of either 5 or 60 (minutes).
    service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name: "my-bucket"
    # The name of the Amazon S3 bucket where the access logs are stored
    service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-prefix: "my-bucket-prefix/prod"
    # The logical hierarchy you created for your Amazon S3 bucket, for example `my-bucket-prefix/prod`
```
##### 2.9.2.6 AWS 上的连接排空
可以将注解 service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled 设置为 "true" 来管理 ELB 的连接排空。 注释 service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout 也可以用于设置最大时间（以秒为单位），以保持现有连接在注销实例之前保持打开状态。
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout: "60"
```
##### 2.9.2.7 其他 ELB 注解
还有其他一些注释，用于管理经典弹性负载均衡器，如下所述。
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
    # 按秒计的时间，表示负载均衡器关闭连接之前连接可以保持空闲
    # （连接上无数据传输）的时间长度

    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    # 指定该负载均衡器上是否启用跨区的负载均衡能力

    service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: "environment=prod,owner=devops"
    # 逗号分隔列表值，每一项都是一个键-值耦对，会作为额外的标签记录于 ELB 中

    service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: ""
    # 将某后端视为健康、可接收请求之前需要达到的连续成功健康检查次数。
    # 默认为 2，必须介于 2 和 10 之间

    service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "3"
    # 将某后端视为不健康、不可接收请求之前需要达到的连续不成功健康检查次数。
    # 默认为 6，必须介于 2 和 10 之间

    service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: "20"
    # 对每个实例进行健康检查时，连续两次检查之间的大致间隔秒数
    # 默认为 10，必须介于 5 和 300 之间

    service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout: "5"
    # 时长秒数，在此期间没有响应意味着健康检查失败
    # 此值必须小于 service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval
    # 默认值为 5，必须介于 2 和 60 之间

    service.beta.kubernetes.io/aws-load-balancer-extra-security-groups: "sg-53fae93f,sg-42efd82e"
    # 要添加到 ELB 上的额外安全组列表
```
##### 2.9.2.8 AWS 上负载均衡器支持
> 该特性始于：Kubernetes v1.15 [beta]

要在 AWS 上使用网络负载均衡器，可以使用注解 service.beta.kubernetes.io/aws-load-balancer-type，将其取值设为 nlb。
```
metadata:
  name: my-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```
> **说明**： NLB 仅适用于某些实例类。有关受支持的实例类型的列表， 请参见[AWS文档](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#register-deregister-targets)中关于所支持的实例类型的 Elastic Load Balancing 说明。

与经典弹性负载平衡器不同，网络负载平衡器（NLB）将客户端的 IP 地址转发到该节点。 如果服务的 `.spec.externalTrafficPolicy` 设置为 `Cluster`，则客户端的IP地址不会传达到最终的 Pod。

通过将 `.spec.externalTrafficPolicy` 设置为 `Local`，客户端IP地址将传播到最终的 Pod， 但这可能导致流量分配不均。 没有针对特定 `LoadBalancer` 服务的任何 Pod 的节点将无法通过自动分配的 `.spec.healthCheckNodePort` 进行 NLB 目标组的运行状况检查，并且不会收到任何流量。

为了获得均衡流量，请使用 DaemonSet 或指定 [Pod 反亲和性](https://kubernetes.io/zh/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) 使其不在同一节点上。

你还可以将 NLB 服务与[内部负载平衡器](https://kubernetes.io/zh/docs/concepts/services-networking/service/#internal-load-balancer)注解一起使用。

为了使客户端流量能够到达 NLB 后面的实例，使用以下 IP 规则修改了节点安全组：
Rule|Protocol|Port(s)|IpRange(s)|IpRange Description
--------|--------|--------|--------|--------
Health Check|TCP|NodePort(s) (.spec.healthCheckNodePort for .spec.externalTrafficPolicy=Local)|VPC CIDR|kubernetes.io/rule/nlb/health=<loadBalancerName>
Client Traffic|TCP|NodePort(s)|.spec.loadBalancerSourceRanges (defaults to 0.0.0.0/0)|kubernetes.io/rule/nlb/client=<loadBalancerName>
MTU Discovery|ICMP|3,4|.spec.loadBalancerSourceRanges (defaults to 0.0.0.0/0)|kubernetes.io/rule/nlb/mtu=<loadBalancerName>

为了限制哪些客户端IP可以访问网络负载平衡器，请指定 loadBalancerSourceRanges：
```
spec:
  loadBalancerSourceRanges:
    - "143.231.0.0/16"
```
> **说明**： 如果未设置 .spec.loadBalancerSourceRanges ，则 Kubernetes 允许从 0.0.0.0/0 到节点安全组的流量。 如果节点具有公共 IP 地址，请注意，非 NLB 流量也可以到达那些修改后的安全组中的所有实例。
#### 2.9.3 ExternalName 类型
类型为 ExternalName 的服务将服务映射到 DNS 名称，而不是典型的选择器，例如 my-service 或者 cassandra。 您可以使用 spec.externalName 参数指定这些服务。

例如，以下 Service 定义将 prod 名称空间中的 my-service 服务映射到 my.database.example.com：
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```
> **说明**： ExternalName 服务接受 IPv4 地址字符串，但作为包含数字的 DNS 名称，而不是 IP 地址。 类似于 IPv4 地址的外部名称不能由 CoreDNS 或 ingress-nginx 解析，因为外部名称旨在指定规范的 DNS 名称。 要对 IP 地址进行硬编码，请考虑使用[headless Services](https://kubernetes.io/zh/docs/concepts/services-networking/service/#headless-services)。

当查找主机 `my-service.prod.svc.cluster.local` 时，集群 DNS 服务返回 CNAME 记录， 其值为 `my.database.example.com`。 访问 my-service 的方式与其他服务的方式相同，但主要区别在于重定向发生在 DNS 级别，而不是通过代理或转发。 如果以后您决定将数据库移到群集中，则可以启动其 Pod，添加适当的选择器或端点以及更改服务的 type。

> **说明**：本部分感谢 Alen Komljen的 [Kubernetes Tips - Part1](https://akomljen.com/kubernetes-tips-part-1/) 博客文章。
##### 2.9.3.1 外部 IP
如果外部的 IP 路由到集群中一个或多个 Node 上，Kubernetes Service 会被暴露给这些 externalIPs。 通过外部 IP（作为目的 IP 地址）进入到集群，打到 Service 的端口上的流量，将会被路由到 Service 的 Endpoint 上。 externalIPs 不会被 Kubernetes 管理，它属于集群管理员的职责范畴。

根据 Service 的规定，externalIPs 可以同任意的 ServiceType 来一起指定。 在上面的例子中，my-service 可以在 "80.11.12.10:80"(externalIP:port) 上被客户端访问。
```
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
  externalIPs:
    - 80.11.12.10
```
### 2.10 不足之处
为 VIP 使用用户空间代理，将只适合小型到中型规模的集群，不能够扩展到上千 Service 的大型集群。 查看最初设计方案 获取更多细节。

使用用户空间代理，隐藏了访问 Service 的数据包的源 IP 地址。 这使得一些类型的防火墙无法起作用。 iptables 代理不会隐藏 Kubernetes 集群内部的 IP 地址，但却要求客户端请求必须通过一个负载均衡器或 Node 端口。

Type 字段支持嵌套功能 —— 每一层需要添加到上一层里面。 不会严格要求所有云提供商（例如，GCE 就没必要为了使一个 LoadBalancer 能工作而分配一个 NodePort，但是 AWS 需要 ），但当前 API 是强制要求的。
### 2.11 虚拟IP实施
对很多想使用 Service 的人来说，前面的信息应该足够了。 然而，有很多内部原理性的内容，还是值去理解的。
#### 2.11.1 避免冲突
Kubernetes 最主要的哲学之一，是用户不应该暴露那些能够导致他们操作失败、但又不是他们的过错的场景。 对于 Service 资源的设计，这意味着如果用户的选择有可能与他人冲突，那就不要让用户自行选择端口号。 这是一个隔离性的失败。

为了使用户能够为他们的 Service 选择一个端口号，我们必须确保不能有2个 Service 发生冲突。 Kubernetes 通过为每个 Service 分配它们自己的 IP 地址来实现。

为了保证每个 Service 被分配到一个唯一的 IP，需要一个内部的分配器能够原子地更新 etcd 中的一个全局分配映射表， 这个更新操作要先于创建每一个 Service。 为了使 Service 能够获取到 IP，这个映射表对象必须在注册中心存在， 否则创建 Service 将会失败，指示一个 IP 不能被分配。

在控制平面中，一个后台 Controller 的职责是创建映射表 （需要支持从使用了内存锁的 Kubernetes 的旧版本迁移过来）。 同时 Kubernetes 会通过控制器检查不合理的分配（如管理员干预导致的） 以及清理已被分配但不再被任何 Service 使用的 IP 地址。
#### 2.11.2 Service IP 地址
不像 Pod 的 IP 地址，它实际路由到一个固定的目的地，Service 的 IP 实际上不能通过单个主机来进行应答。 相反，我们使用 iptables（Linux 中的数据包处理逻辑）来定义一个虚拟IP地址（VIP），它可以根据需要透明地进行重定向。 当客户端连接到 VIP 时，它们的流量会自动地传输到一个合适的 Endpoint。 环境变量和 DNS，实际上会根据 Service 的 VIP 和端口来进行填充。

kube-proxy支持三种代理模式: 用户空间，iptables和IPVS；它们各自的操作略有不同。
##### Userspace
作为一个例子，考虑前面提到的图片处理应用程序。 当创建后端 Service 时，Kubernetes master 会给它指派一个虚拟 IP 地址，比如 10.0.0.1。 假设 Service 的端口是 1234，该 Service 会被集群中所有的 kube-proxy 实例观察到。 当代理看到一个新的 Service， 它会打开一个新的端口，建立一个从该 VIP 重定向到新端口的 iptables，并开始接收请求连接。

当一个客户端连接到一个 VIP，iptables 规则开始起作用，它会重定向该数据包到 "服务代理" 的端口。 "服务代理" 选择一个后端，并将客户端的流量代理到后端上。

这意味着 Service 的所有者能够选择任何他们想使用的端口，而不存在冲突的风险。 客户端可以简单地连接到一个 IP 和端口，而不需要知道实际访问了哪些 Pod。
##### iptables
再次考虑前面提到的图片处理应用程序。 当创建后端 Service 时，Kubernetes 控制面板会给它指派一个虚拟 IP 地址，比如 10.0.0.1。 假设 Service 的端口是 1234，该 Service 会被集群中所有的 kube-proxy 实例观察到。 当代理看到一个新的 Service， 它会配置一系列的 iptables 规则，从 VIP 重定向到每个 Service 规则。 该特定于服务的规则连接到特定于 Endpoint 的规则，而后者会重定向（目标地址转译）到后端。

当客户端连接到一个 VIP，iptables 规则开始起作用。一个后端会被选择（或者根据会话亲和性，或者随机）， 数据包被重定向到这个后端。 不像用户空间代理，数据包从来不拷贝到用户空间，kube-proxy 不是必须为该 VIP 工作而运行， 并且客户端 IP 是不可更改的。 当流量打到 Node 的端口上，或通过负载均衡器，会执行相同的基本流程， 但是在那些案例中客户端 IP 是可以更改的。
##### IPVS
在大规模集群（例如 10000 个服务）中，iptables 操作会显着降低速度。 IPVS 专为负载平衡而设计，并基于内核内哈希表。 因此，您可以通过基于 IPVS 的 kube-proxy 在大量服务中实现性能一致性。 同时，基于 IPVS 的 kube-proxy 具有更复杂的负载平衡算法（最小连接，局部性，加权，持久性）。
### 2.12 API 对象
Service 是 Kubernetes REST API 中的顶级资源。您可以在以下位置找到有关A PI 对象的更多详细信息：[Service 对象 API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#service-v1-core).
### 2.13 受支持的协议
#### 2.13.1 TCP：该特性始于：Kubernetes v1.0 [stable]
您可以将 TCP 用于任何类型的服务，这是默认的网络协议。
#### 2.13.2 UDP：该特性始于：Kubernetes v1.0 [stable]
您可以将 UDP 用于大多数服务。 对于 type=LoadBalancer 服务，对 UDP 的支持取决于提供此功能的云提供商。
#### 2.13.3 HTTP：该特性始于：Kubernetes v1.1 [stable]
如果您的云提供商支持它，则可以在 LoadBalancer 模式下使用服务来设置外部 HTTP/HTTPS 反向代理，并将其转发到该服务的 Endpoints。
> **说明**： 您还可以使用 Ingres 代替 Service 来公开 HTTP/HTTPS 服务。
#### 2.13.4 PROXY 协议：该特性始于：Kubernetes v1.1 [stable]
如果您的云提供商支持它（例如, [AWS](https://kubernetes.io/zh/docs/concepts/cluster-administration/cloud-providers/#aws)）， 则可以在 LoadBalancer 模式下使用 Service 在 Kubernetes 本身之外配置负载均衡器， 该负载均衡器将转发前缀为 [PROXY协议](https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt) 的连接。

负载平衡器将发送一系列初始字节，描述传入的连接，类似于此示例：
```
  PROXY TCP4 192.0.2.202 10.0.42.7 12345 7\r\n
```
接下来是来自客户端的数据。
#### 2.13.5 SCTP：该特性始于：Kubernetes v1.12 [alpha]
作为一种 alpha 功能，Kubernetes 支持 SCTP 作为 Service、Endpoint、NetworkPolicy 和 Pod 定义中的 protocol 值。 要启用此功能，集群管理员需要在 API 服务器上启用 `SCTPSupport` 特性门控， 例如 `--feature-gates=SCTPSupport=true,...`。

启用特性门控后，你可以将 Service、Endpoints、NetworkPolicy 或 Pod 的 `protocol` 字段设置为 SCTP。 Kubernetes 相应地为 SCTP 关联设置网络，就像为 TCP 连接所做的一样。

##### 警告
- 支持多宿主SCTP关联
  > **警告**： 对多宿主 SCTP 关联的支持要求 CNI 插件可以支持将多个接口和 IP 地址分配给 Pod。 用于多宿主 SCTP 关联的 NAT 在相应的内核模块中需要特殊的逻辑。
- Service 类型为 LoadBalancer 的服务
  > **警告**： 如果云提供商的负载平衡器实现支持将 SCTP 作为协议，则只能使用 type LoadBalancer 加上 protocol SCTP 创建服务。否则，服务创建请求将被拒绝。 当前的云负载平衡器提供商（Azure、AWS、CloudStack、GCE、OpenStack）都缺乏对 SCTP 的支持。
- Windows
  > **警告**： 基于 Windows 的节点不支持 SCTP。
- 用户空间 kube-proxy
  > **警告**： 当 kube-proxy 处于用户空间模式时，它不支持 SCTP 关联的管理。
### 2.14 未来工作
未来我们能预见到，代理策略可能会变得比简单的轮转均衡策略有更多细微的差别，比如主控节点选举或分片。 我们也能想到，某些 Service 将具有 “真正” 的负载均衡器，这种情况下 VIP 将简化数据包的传输。

Kubernetes 项目打算为 L7（HTTP）服务改进支持。

Kubernetes 项目打算为 Service 实现更加灵活的请求进入模式， 这些模式包含当前的 ClusterIP、NodePort 和 LoadBalancer 模式，或者更多。
## 3. 端点切片（Endpoint Slices）
> 该特性始于：Kubernetes v1.17 [beta]

端点切片（Endpoint Slices） 提供了一种简单的方法来跟踪 Kubernetes 集群中的网络端点 （network endpoints）。它们为 Endpoints 提供了一种可伸缩和可拓展的替代方案。
### 3.1 Endpoint Slice 资源
在 Kubernetes 中，EndpointSlice 包含对一组网络端点的引用。 指定选择器后，EndpointSlice 控制器会自动为 Kubernetes 服务创建 EndpointSlice。 这些 EndpointSlice 将包含对与服务选择器匹配的所有 Pod 的引用。EndpointSlice 通过唯一的服务和端口组合将网络端点组织在一起。

例如，这里是 Kubernetes服务 example 的示例 EndpointSlice 资源。
```
apiVersion: discovery.k8s.io/v1beta1
kind: EndpointSlice
metadata:
  name: example-abc
  labels:
    kubernetes.io/service-name: example
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 80
endpoints:
  - addresses:
    - "10.1.2.3"
    conditions:
      ready: true
    hostname: pod-1
    topology:
      kubernetes.io/hostname: node-1
      topology.kubernetes.io/zone: us-west2-a
```
默认情况下，由 EndpointSlice 控制器管理的 Endpoint Slice 将有不超过 100 个端点。 低于此比例时，Endpoint Slices 应与 Endpoints 和服务进行 1:1 映射，并具有相似的性能。

当涉及如何路由内部流量时，Endpoint Slices 可以充当 kube-proxy 的真实来源。 启用该功能后，在服务的 endpoints 规模庞大时会有可观的性能提升。
### 3.2 地址类型
EndpointSlice 支持三种地址类型：
- IPv4
- IPv6
- FQDN (完全合格的域名)
### 3.3 动机
Endpoints API 提供了一种简单明了的方法在 Kubernetes 中跟踪网络端点。 不幸的是，随着 Kubernetes 集群与服务的增长，该 API 的局限性变得更加明显。 最值得注意的是，这包含了扩展到更多网络端点的挑战。

由于服务的所有网络端点都存储在单个 Endpoints 资源中， 因此这些资源可能会变得很大。 这影响了 Kubernetes 组件（尤其是主控制平面）的性能，并在 Endpoints 发生更改时导致大量网络流量和处理。 Endpoint Slices 可帮助您缓解这些问题并提供可扩展的 附加特性（例如拓扑路由）平台。
## 4. Pod 与 Service 的 DNS
本页面提供 Kubernetes 对 DNS 的支持的概述。
## 5. 使用 Service 连接到应用
## 6. Ingress
## 7. Ingress 控制器
## 8. 网络策略
## 9. 使用 HostAliases 向 Pod /etc/hosts 文件添加条目
## 10. IPv4/IPv6 双协议栈

## Reference
- [服务、负载均衡和联网](https://kubernetes.io/zh/docs/concepts/services-networking/)
- [Services, Load Balancing, and Networking](https://kubernetes.io/docs/concepts/services-networking/)