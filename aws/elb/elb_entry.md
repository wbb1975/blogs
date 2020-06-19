# Elastic Load Balancing (ELB)
Elastic Load Balancing 把应用程序的输入流量自动分配间到多个目标，如Amazon EC2 实例。它监控已注册目标的健康状况并将流量路由到健康的节点上。Elastic Load Balancing 支持三种负载均衡器：应用程序负载均衡器（Application Load Balancers）、网络负载均衡器（Network Load Balancers）和 Classic 负载均衡器（Classic Load Balancers）。
## 第一章 什么是 Elastic Load Balancing？
Elastic Load Balancing 跨多个可用区中的多个目标（如 Amazon EC2 实例、容器和 IP 地址）分发传入应用程序或网络流量。Elastic Load Balancing 会在应用程序的传入流量随时间的流逝发生更改时扩展负载均衡器。它可以自动扩展来处理绝大部分工作负载。
### 1.1 负载均衡器优势
负载均衡器跨多个计算资源 (如虚拟服务器) 分布工作负载。使用负载均衡器可提高您的应用程序的可用性和容错性。

可以根据需求变化在负载均衡器中添加和删除计算资源，而不会中断应用程序的整体请求流。

您可以配置运行状况检查，这些检查监控计算资源的运行状况，以便负载均衡器只将请求发送到正常运行的目标。此外，您可以将加密和解密的工作交给负载均衡器完成，以使您的计算资源能够专注于完成主要工作。
### 1.2 Elastic Load Balancing 的功能
Elastic Load Balancing 支持三种类型的负载均衡器：Application Load Balancer、Network Load Balancer 和 Classic Load Balancer。可以根据应用程序需求选择负载均衡器。有关更多信息，请参阅 [Elastic Load Balancing 产品比较](http://www.amazonaws.cn/elasticloadbalancing/details/#compare)。

有关使用每种负载均衡器的更多信息，请参阅[Application Load Balancer 用户指南](https://docs.amazonaws.cn/elasticloadbalancing/latest/application/)、[Network Load Balancer 用户指南](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/) 和 [Classic Load Balancer 用户指南](https://docs.amazonaws.cn/elasticloadbalancing/latest/classic/)。
### 1.3 访问 Elastic Load Balancing
可以使用以下任意接口创建、访问和管理负载均衡器：
- **AWS 管理控制台**— 提供您可用来访问 Elastic Load Balancing 的 Web 界面。
- **AWS 命令行界面 (AWS CLI)** — 为众多 AWS 服务（包括 Elastic Load Balancing）提供命令。AWS CLI 在 Windows、macOS 和 Linux 上受支持。有关更多信息，请参阅 [AWS Command Line Interface](http://www.amazonaws.cn/cli/)。
- **AWS 开发工具包** — 提供了特定于语言的 API，并关注许多连接详细信息，例如计算签名、处理请求重试和错误处理。有关更多信息，请参阅 [AWS 开发工具包](http://www.amazonaws.cn/tools/#SDKs)。
- **查询 API** — 提供了您使用 HTTPS 请求调用的低级别 API 操作。使用查询 API 是访问 Elastic Load Balancing 的最直接方式。但是，查询 API 需要您的应用程序处理低级别的详细信息，例如生成哈希值以签署请求以及进行错误处理。有关更多信息，请参阅下列内容：
   + Application Load Balancer 和 Network Load Balancer — [API 版本 2015-12-01](https://docs.amazonaws.cn/elasticloadbalancing/latest/APIReference/)
   + Classic Load Balancer — [API 版本 2012-06-01](https://docs.amazonaws.cn/elasticloadbalancing/2012-06-01/APIReference/)
### 1.4 相关服务
Elastic Load Balancing 可与以下服务一起使用来提高应用程序的可用性和可扩展性。
- **Amazon EC2** — 在云中运行应用程序的虚拟服务器。您可以将负载均衡器配置为将流量路由到您的 EC2 实例。有关更多信息，请参阅 [Amazon EC2 用户指南（适用于 Linux 实例）](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/) 或 [Amazon EC2 用户指南（适用于 Windows 实例）](https://docs.amazonaws.cn/AWSEC2/latest/WindowsGuide/)。
- **Amazon EC2 Auto Scaling** — 确保运行所需数量的实例（即使实例失败也是如此）。Amazon EC2 Auto Scaling 还可让您根据实例需求的变化自动增加或减少实例数。如果使用 Elastic Load Balancing 启用 Auto Scaling，则 Auto Scaling 所启动的实例会自动注册到负载均衡器。同样，Auto Scaling 所终止的实例会自动从负载均衡器取消注册。有关更多信息，请参阅 [Amazon EC2 Auto Scaling 用户指南](https://docs.amazonaws.cn/autoscaling/latest/userguide/)。
- **AWS Certificate Manager** — 在创建 HTTPS 侦听器时，您必须指定由 ACM 提供的证书。负载均衡器使用证书终止连接并解密来自客户端的请求。
- **Amazon CloudWatch** — 使您能够监控负载均衡器并执行所需操作。有关更多信息，请参阅 [Amazon CloudWatch 用户指南](https://docs.amazonaws.cn/AmazonCloudWatch/latest/monitoring/)。
- **Amazon ECS** — 使您能够在 EC2 实例集群上运行、停止和管理 Docker 容器。您可以将负载均衡器配置为将流量路由到您的容器。有关更多信息，请参阅 [Amazon Elastic Container Service Developer Guide](https://docs.amazonaws.cn/AmazonECS/latest/developerguide/)。
- **AWS Global Accelerator** — 提高应用程序的可用性和性能。使用加速器在一个或多个 AWS 区域的多个负载均衡器之间分配流量。有关更多信息，请参阅 [AWS Global Accelerator 开发人员指南](https://docs.amazonaws.cn/global-accelerator/latest/dg/)。
- **Route 53** — 通过将域名转换为计算机相互连接所用的数字 IP 地址，以一种可靠且经济的方式将访问者路由至网站。例如，它会将 www.example.com 转换为数字 IP 地址 192.0.2.1。AWS 将向您的资源 (如负载均衡器) 分配 URL。不过，您可能希望使用方便用户记忆的 URL。例如，您可以将域名映射到负载均衡器。有关更多信息，请参阅 [Amazon Route 53 开发人员指南](https://docs.amazonaws.cn/Route53/latest/DeveloperGuide/)。
- **AWS WAF** — 您可以结合使用 AWS WAF 和 应用程序负载均衡器 以根据 Web 访问控制列表 (Web ACL) 中的规则允许或阻止请求。有关更多信息，请参阅 [AWS WAF 开发人员指南](https://docs.amazonaws.cn/waf/latest/developerguide/)。
### 1.5 定价
#### 1.5.1 Classic Load Balancer 定价
使用 Elastic Load Balancing，您只需按实际使用量付费。您需要按 Elastic Load Balancer 的运行小时数及其传输的数据 GB 数付费，不足 1 小时按 1 小时算。您应在每个月的月底为您实际使用的 Elastic Load Balancing 资源付费。

未满一小时的按一小时计费。常规的 Amazon EC2 服务费照常收取并将单独计费。
#### 1.5.2 Application Load Balancer 定价
使用 Application Load Balancer，您只需按实际使用量付费。您需要按 Application Load Balancer 的运行小时数（不足 1 小时按 1 小时算）及其使用的负载均衡器容量单元 (LCU) 数付费。

未满一小时的按一小时计费。常规的 Amazon EC2 服务费照常收取并将单独计费。
#### 1.5.3 网络负载均衡器定价
使用网络负载均衡器，您只需按实际使用量付费。您需要按网络负载均衡器的运行小时数（不足 1 小时按 1 小时算）及其使用的负载均衡器容量单元 (LCU) 数付费。

未满一小时的按一小时计费。常规的 Amazon EC2 服务费照常收取并将单独计费。
## 第二章 Elastic Load Balancing 的工作原理
负载均衡器接受来自客户端的传入流量并将请求路由到一个或多个可用区中的已注册目标 (例如 EC2 实例)。负载均衡器还会监控已注册目标的运行状况，并确保它只将流量路由到正常运行的目标。当负载均衡器检测到不正常目标时，它会停止将流量路由到该目标。然后，当它检测到目标再次正常时，它会恢复将流量路由到该目标。

您可通过指定一个或多个侦听器（listeners）将您的负载均衡器配置为接受传入流量。侦听器是用于检查连接请求的进程。它配置了用于从客户端连接到负载均衡器的协议和端口号。同样，它配置了用于从负载均衡器连接到目标的协议和端口号。

Elastic Load Balancing 支持三种类型的负载均衡器：
- Application Load Balancer
- Network Load Balancer
- Classic Load Balancer

负载均衡器类型的配置方式具有一个关键区别。对于 Application Load Balancer 和 Network Load Balancer，可以在目标组（target groups）中注册目标，并将流量路由到目标组。对于 Classic Load Balancer，可以向负载均衡器注册实例（instances）。
### 2.1 可用区与负载均衡器节点（Availability Zones and Load Balancer Nodes）
如果为负载均衡器启用可用区，Elastic Load Balancing 会在该可用区中创建一个负载均衡器节点。如果您在可用区中注册目标但不启用可用区，这些已注册目标将无法接收流量。当您确保每个启用的可用区均具有至少一个已注册目标时，负载均衡器将具有最高效率。

我们建议您启用多个可用区。（对于 应用程序负载均衡器，我们要求您启用多个可用区。） 此配置有助于确保负载均衡器可以继续路由流量。如果一个可用区变得不可用或没有正常目标，则负载均衡器会将流量路由到其他可用区中的正常目标。

在禁用一个可用区后，该可用区中的目标将保持已注册到负载均衡器的状态。但是，即使它们保持已注册状态，负载均衡器也不会将流量路由到它们。
### 2.2 跨可用区负载均衡 （Cross-Zone Load Balancing）
负载均衡器的节点将来自客户端的请求分配给已注册目标。启用了跨可用区负载均衡后，每个负载均衡器节点会在所有启用的可用区中的已注册目标之间分配流量。禁用了跨可用区负载均衡后，每个负载均衡器节点会仅在其可用区中的已注册目标之间分配流量。

下图演示了可用区负载均衡的效果。有 2 个已启用的可用区，其中可用区 A 中有 2 个目标，可用区 B 中有 8 个目标。客户端发送请求，Amazon Route 53 使用负载均衡器节点（load balancer nodes）之一的 IP 地址响应每个请求。这会分配流量，以便每个负载均衡器节点接收来自客户端的 50% 的流量。每个负载均衡器节点会在其范围中的已注册目标之间分配其流量份额。

**如果启用了跨可用区负载均衡**，则 10 个目标中的每个目标接收 10% 的流量。这是因为每个负载均衡器节点可将其 50% 的客户端流量路由到所有 10 个目标。
![启用跨可用区负载均衡](images/cross_zone_load_balancing_enabled.png)

**如果禁用了跨可用区负载均衡**：
- 可用区 A 中的两个目标中的每个目标接收 25% 的流量。
- 可用区 B 中的八个目标中的每个目标接收 6.25% 的流量。

这是因为每个负载均衡器节点只能将其 50% 的客户端流量路由到其可用区中的目标。

![禁用跨可用区负载均衡](images/cross_zone_load_balancing_disabled.png)

对于 Application Load Balancer，始终启用跨可用区负载均衡。

对于 Network Load Balancer，默认情况下禁用跨可用区负载均衡。创建网络负载均衡器后，您随时可以启用或禁用跨可用区负载均衡。有关更多信息，请参阅 Network Load Balancer 用户指南中的[跨可用区负载均衡](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancers.html#cross-zone-load-balancing)。

在创建传统负载均衡器时，跨可用区负载均衡的默认值取决于创建负载均衡器的方式。默认情况下，使用 API 或 CLI 时将禁用跨可用区负载均衡。默认情况下，使用 AWS 管理控制台时启用跨可用区负载均衡的选项处于选中状态。创建传统负载均衡器 后，您随时可以启用或禁用跨可用区负载均衡。有关更多信息，请参阅 Classic Load Balancer 用户指南 中的[启用跨可用区负载均衡](https://docs.amazonaws.cn/elasticloadbalancing/latest/classic/enable-disable-crosszone-lb.html#enable-cross-zone)。
### 2.3 请求路由选择
在客户端将请求发送到负载均衡器之前，它会利用域名系统 (DNS) 服务器解析负载均衡器的域名。DNS 条目由 Amazon 控制，因为您的负载均衡器位于 amazonaws.com 域中。Amazon DNS 服务器会将一个或多个 IP 地址返回到客户端。这些是您的负载均衡器的负载均衡器节点的 IP 地址。对于 Network Load Balancer，Elastic Load Balancing 将为启用的每个可用区创建一个网络接口。可用区内的每个负载均衡器节点使用该网络接口来获取一个静态 IP 地址。在您创建负载均衡器时，可以选择将一个弹性 IP 地址与每个网络接口关联。

当流向应用程序的流量随时间变化时，Elastic Load Balancing 会扩展负载均衡器并更新 DNS 条目。DNS 条目还指定生存时间 (TTL) 为 60 秒。这有助于确保可以快速重新映射 IP 地址以响应不断变化的流量。

客户端可以确定使用哪个 IP 地址将请求发送到负载均衡器。用于接收请求的负载均衡器节点会选择一个正常运行的已注册目标，并使用其私有 IP 地址将请求发送到该目标。
#### 2.3.1 路由算法
借助 **Application Load Balancer**，接收请求的负载均衡器节点使用以下过程：
1. 按优先级顺序评估侦听器规则以确定要应用的规则。
2. 使用为目标组配置的路由算法，从目标组中为规则操作选择目标。默认路由算法是轮询。每个目标组的路由都是单独进行的，即使某个目标已在多个目标组中注册。

借助 **Network Load Balancer**，接收连接的负载均衡器节点使用以下过程：
1. 使用流哈希算法从目标组中为默认规则选择目标。它使算法基于：
   + 协议
   + 源 IP 地址和源端口
   + 目标 IP 地址和目标端口
   + TCP 序列号
2. 将每个单独的 TCP 连接在连接的有效期内路由到单个目标。来自客户端的 TCP 连接具有不同的源端口和序列号，可以路由到不同的目标。

借助 **Classic Load Balancer**，接收请求的负载均衡器节点按照以下方式选择注册实例：
+ 使用适用于 TCP 侦听器的轮询路由算法
+ 使用适用于 HTTP 和 HTTPS 侦听器的最少未完成请求路由算法
#### 2.3.2 HTTP 连接
Classic Load Balancer 使用提前打开的连接，但 Application Load Balancer 不使用。Classic Load Balancer 和 Application Load Balancer 都使用多路复用连接。也就是说，来自多个前端连接上的多个客户端的请求可通过单一的后端连接路由到指定目标。多路复用连接可缩短延迟并减少您的应用程序上的负载。要禁止多路复用连接，请在您的 HTTP 响应中设置 Connection: close 标头来禁用 HTTP keep-alives。

对于前端连接（客户端到负载均衡器），Classic Load Balancer 支持以下协议：HTTP/0.9、HTTP/1.0 和 HTTP/1.1。

对于前端连接，Application Load Balancer 支持以下协议：HTTP/0.9、HTTP/1.0、HTTP/1.1 和 HTTP/2。HTTP/2 仅适用于 HTTPS 侦听器，使用一个 HTTP/2 连接可并行发送多达 128 个请求。Application Load Balancer 还支持将连接从 HTTP 升级到 WebSockets。

Application Load Balancer 和 Classic Load Balancer 都在后端连接（负载均衡器到已注册目标）上使用 HTTP/1.1。默认情况下，后端连接支持 Keep-alive。如果 HTTP/1.0 请求来自没有主机标头的客户端，负载均衡器会对后端连接发送的 HTTP/1.1 请求生成一个主机标头。对于应用程序负载均衡器，主机标头包含负载均衡器的 DNS 名称。对于传统负载均衡器，主机标头包含负载均衡器节点的 IP 地址。

对于前端连接，Application Load Balancer 和 Classic Load Balancer 均支持管道化 HTTP。对于后端连接它们均不支持管道化 HTTP。
#### 2.3.3 HTTP 标头
Application Load Balancer 和 Classic Load Balancer 会将 X-Forwarded-For、X-Forwarded-Proto 和 X-Forwarded-Port 标头添加到请求。

对于使用 HTTP/2 的前端连接，标头名称是小写的。使用 HTTP/1.1 将请求发送到目标之前，以下标头名称将转换为混合大小写：X-Forwarded-For、X-Forwarded-Proto、X-Forwarded-Port、Host、X-Amzn-Trace-Id、Upgrade 和 Connection。所有其他标头名称是小写的。

Application Load Balancer 和 Classic Load Balancer 将响应代理返回客户端后，遵守来自传入客户端请求的连接标头。
#### 2.3.3 HTTP 标头限制
Application Load Balancer 的以下大小限制是无法更改的硬限制。

**HTTP/1.x 标头**
- 请求行：16K
- 单个标头：16K
- 整个标头：64K

**HTTP/2 标头**
- 请求行：8K
- 单个标头：8K
- 整个标头：64K
### 2.4 负载均衡器模式
在创建负载均衡器时，您必须选择使其成为内部负载均衡器还是面向 Internet 的负载均衡器。请注意，当您在 EC2-Classic 中创建 Classic负载均衡器 时，它必须是面向 Internet 的负载均衡器。

面向 Internet 的负载均衡器的节点具有公共 IP 地址。面向 Internet 的负载均衡器的 DNS 名称可公开解析为节点的公共 IP 地址。因此，面向 Internet 的负载均衡器可以通过 Internet 路由来自客户端的请求。

内部负载均衡器的节点只有私有 IP 地址。内部负载均衡器的 DNS 名称可公开解析为节点的私有 IP 地址。因此，内部负载均衡器可路由的请求只能来自对负载均衡器的 VPC 具有访问权限的客户端。

面向 Internet 的负载均衡器和内部负载均衡器均使用私有 IP 地址将请求路由到您的目标。因此，您的目标无需使用公有 IP 地址从内部负载均衡器或面向 Internet 的负载均衡器接收请求。

如果您的应用程序具有多个层，则可以设计一个同时使用内部负载均衡器和面向 Internet 的负载均衡器的架构。例如，如果您的应用程序使用必须连接到 Internet 的 Web 服务器，以及仅连接到 Web 服务器的应用程序服务器，则可以如此。创建一个面向 Internet 的负载均衡器并向其注册 Web 服务器。创建一个内部负载均衡器并向它注册应用程序服务器。Web 服务器从面向 Internet 的负载均衡器接收请求，并将对应用程序服务器的请求发送到内部负载均衡器。应用程序服务器从内部负载均衡器接收请求。
## 第三章 Elastic Load Balancing 入门
有三种类型的负载均衡器：Application Load Balancer、Network Load Balancer 和 Classic Load Balancer。可以根据应用程序需求选择负载均衡器。

有关常见负载均衡器配置的演示，请参阅 [Elastic Load Balancing 演示](https://exampleloadbalancer.com/)。

如果您现在有传统负载均衡器，则可以迁移到 应用程序负载均衡器或网络负载均衡器。有关更多信息，请参阅[迁移您的传统负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/migrate-to-application-load-balancer.html)。
### 3.1 创建应用程序负载均衡器
要使用 AWS 管理控制台创建 应用程序负载均衡器，请使用 Application Load Balancer 用户指南中的 [Application Load Balancer 入门](https://docs.amazonaws.cn/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html)。

要使用 AWS CLI 创建应用程序负载均衡器，请参阅 Application Load Balancer 用户指南中的[使用 AWS CLI 创建应用程序负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/application/tutorial-application-load-balancer-cli.html)
### 3.2 创建网络负载均衡器
要使用 AWS 管理控制台创建网络负载均衡器，请参阅 Network Load Balancer 用户指南中的 [Network Load Balancer 入门](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancer-getting-started.html)。

要使用 AWS CLI 创建网络负载均衡器，请参阅 Network Load Balancer 用户指南中的使用 [AWS CLI 创建网络负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancer-cli.html)
### 3.3 创建传统负载均衡器
要使用 AWS 管理控制台 创建 传统负载均衡器，请参阅 Classic Load Balancer 用户指南中的[创建传统负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/classic/elb-getting-started.html)。
## 4. 迁移您的 传统负载均衡器
如果您在 VPC 中已经有 传统负载均衡器，并且确信应用程序负载均衡器或网络负载均衡器满足您的需求，那么您就可以迁移 传统负载均衡器。在迁移过程完成后，您就可以利用新负载均衡器的功能了。
### 4.1 步骤 1：创建新负载均衡器
创建配置等同于您的传统负载均衡器的应用程序负载均衡器或网络负载均衡器。您可以使用以下方法之一来创建负载均衡器和目标组：
#### 4.1.1 选项 1：使用迁移向导进行迁移
迁移向导根据 传统负载均衡器的配置创建应用程序负载均衡器或网络负载均衡器。所创建负载均衡器的类型取决于传统负载均衡器的配置。

**迁移向导发行说明**：
- 传统负载均衡器必须位于 VPC 中。
- 如果传统负载均衡器具有 HTTP 或 HTTPS 侦听器，则该向导可以创建应用程序负载均衡器。如果传统负载均衡器具有 TCP 侦听器，则该向导可以创建网络负载均衡器。
- 如果传统负载均衡器的名称与现有应用程序负载均衡器或网络负载均衡器的名称匹配，则该向导将要求您在迁移过程中指定不同的名称。
- 如果 传统负载均衡器具有一个子网，则该向导将要求您在创建应用程序负载均衡器时指定另一个子网。
- 如果传统负载均衡器已在 EC2-Classic 中注册实例，这些实例不会注册到新负载均衡器的目标组。
- 如果传统负载均衡器具有以下类型的已注册实例，不会向网络负载均衡器的目标组注册它们：C1、CC1、CC2、CG1、CG2、CR1、CS1、G1、G2、HI1、HS1、M1、M2、M3 和 T1。
- 如果传统负载均衡器具有 HTTP/HTTPS 侦听器，但使用 TCP 运行状况检查，则向导将更改为 HTTP 运行状况检查。然后在创建应用程序负载均衡器 时，默认情况下，它将路径设置为“/”。
- 如果将传统负载均衡器迁移到网络负载均衡器，则将更改运行状况检查设置以满足 Network Load Balancer 的要求。
- 如果传统负载均衡器有多个 HTTPS 侦听器，则向导将选择一个侦听器并使用其证书和策略。如果端口 443 上有一个 HTTPS 侦听器，向导将选择此侦听器。如果所选侦听器使用自定义策略或 Application Load Balancer 不支持的策略，则向导将更改为默认安全策略。
- 如果传统负载均衡器具有安全的 TCP 侦听器，则网络负载均衡器使用 TCP 侦听器。但它不使用证书或安全策略。
- 如果传统负载均衡器有多个侦听器，该向导将使用端口值最低的侦听器端口作为目标组端口。注册到这些侦听器的每个实例都会在所有侦听器的侦听器端口上注册到目标组。
- 如果传统负载均衡器的一些标签在标签名称中具有 aws 前缀，则这些标签不会添加到新的负载均衡器。

**使用迁移向导迁移传统负载均衡器**：
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 **LOAD BALANCING** 下，选择 **Load Balancers**。
3. 选择您的传统负载均衡器。
4. 在 **Migration** 选项卡上，选择 **Launch ALB Migration Wizard** 或 **Launch NLB Migration Wizard**。显示的按钮取决于在检查 传统负载均衡器后由向导选择的负载均衡器类型。
5. 在 **Review** 页面上，验证向导选择的配置选项。要更改某个选项，请选择 **Edit**。
6. 当您完成配置新的负载均衡器时，选择 **Create**。
#### 4.1.2 选项 2：使用负载均衡器复制实用程序进行迁移
此实用程序在 GitHub 上提供。有关更多信息，请参阅[负载均衡器复制实用程序](https://github.com/aws/elastic-load-balancing-tools)。 
#### 4.1.3 选项 3：手动迁移
以下信息提供了基于传统负载均衡器手动创建新负载均衡器的一般说明。您可以使用 AWS 管理控制台、AWS CLI 或 AWS 软件开发工具包进行迁移。有关更多信息，请参阅[Elastic Load Balancing 入门](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/load-balancer-getting-started.html)。
- 创建具有与传统负载均衡器 相同的模式（面向 Internet 或内部）、子网和安全组的新负载均衡器。
- 使用传统负载均衡器的运行状况检查设置为负载均衡器创建一个目标组。
- 执行以下任一操作：
   + 如果您的传统负载均衡器附加到 Auto Scaling 组，请将您的目标组附加到 Auto Scaling 组。这样还可以向目标组注册 Auto Scaling 实例。
   + 向目标组注册您的 EC2 实例。
- 创建一个或多个侦听器，每个都具有将请求转发到目标组的默认规则。如果创建 HTTPS 侦听器，则可指定您为传统负载均衡器所指定的同一证书。建议您使用默认安全策略。
- 如果您的传统负载均衡器有标签，请进行检查并将相关标签添加到新负载均衡器。
### 4.2 步骤 2：逐步将流量重定向到您的新负载均衡器
在您的实例注册到新负载均衡器后，您可以开始将流量重定向到它的过程。这允许您测试新负载均衡器。
1. 将新负载均衡器的 DNS 名称粘贴到已连接 Internet 的 Web 浏览器的地址栏中。如果一切正常，浏览器会显示您服务器的默认页面。
2. 创建一个用于将域名与您的新负载均衡器关联的新 DNS 记录。如果您的 DNS 服务支持权重，则在新 DNS 记录中指定权重为 1；对于您传统负载均衡器的现有 DNS 记录，指定权重为 9。这样可以将 10% 的流量定向到新负载均衡器，而将 90% 的流量定向到 传统负载均衡器。
3. 监控您的新负载均衡器，验证它能否接收流量并将请求路由到您的实例。
   > **注意**: DNS 记录中的生存时间 (TTL) 为 60 秒。这意味着，解析域名的任何 DNS 服务器在其缓存中保留记录信息的时间为 60 秒，同时更改会传播。因此，在您完成上一步后，这些 DNS 服务器仍然可以在 60 秒内将流量路由到 传统负载均衡器。在传输过程中，流量可以定向到任一负载均衡器。
4. 继续更新您的 DNS 记录的权重，直到所有流量都定向到您的新负载均衡器。完成后，您可以删除传统负载均衡器的 DNS 记录。
### 4.3 步骤 3：更新对您的传统负载均衡器的引用
现在您已迁移到 传统负载均衡器，请务必更新对它的任何引用，如下所示：
- 使用 AWS CLI aws elb 命令（而不是 aws elbv2 命令）的脚本
- 使用 Elastic Load Balancing 版本 2012-06-01 (而不是 API 版本 2015-12-01) 的代码
- 使用 API 版本 2012-06-01 (而不是 2015-12-01 版本) 的 IAM 策略
- 使用 CloudWatch 指标的过程
- AWS CloudFormation 模板

**资源**
- AWS CLI Command Reference 中的 [elbv2](https://docs.amazonaws.cn/cli/latest/reference/elbv2/index.html)
- [Elastic Load Balancing API 参考第 2015-12-01 版](https://docs.amazonaws.cn/elasticloadbalancing/latest/APIReference/)
- [适用于 Elastic Load Balancing 的 Identity and Access Management](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/load-balancer-authentication-access-control.html)
- Application Load Balancer 用户指南中的[应用程序负载均衡器 指标](https://docs.amazonaws.cn/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html#load-balancer-metrics-alb)
- Network Load Balancer 用户指南中的[网络负载均衡器 指标](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-cloudwatch-metrics.html#load-balancer-metrics-nlb)
- AWS CloudFormation 用户指南 中的 [AWS::ElasticLoadBalancingV2::LoadBalancer](https://docs.amazonaws.cn/AWSCloudFormation/latest/UserGuide/aws-resource-elasticloadbalancingv2-loadbalancer.html)
### 4.4 步骤 4：删除传统负载均衡器
在满足以下条件后，您可以删除 传统负载均衡器：
- 您已将所有流量都重定向到新负载均衡器。
- 路由到 传统负载均衡器 的所有现有请求都已完成。

## 引用
- [ELB入口](https://docs.amazonaws.cn/en_us/elasticloadbalancing/?id=docs_gateway)
- [ELB入门](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/load-balancer-getting-started.html)