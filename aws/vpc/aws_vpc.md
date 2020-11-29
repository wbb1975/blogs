# Amazon Virtual Private Cloud
## 1. Amazon VPC 是什么？
## 2. Amazon VPC 的工作原理
## 3. 开始使用
## 4. VPC 的示例
## 5. VPC 和子网
## 6. 默认 VPC 和默认子网
## 7. IP 寻址
## 8. 安全
## 9. VPC 联网组件
## 10. VPC 终端节点和 VPC 终端节点服务 (AWS PrivateLink) (VPC endpoints and VPC endpoint services (AWS PrivateLink))
VPC 终端节点使您能够将 VPC 私密地连接到支持的 AWS 服务和 VPC 终端节点服务（由 AWS PrivateLink 提供支持），而无需互联网网关、NAT 设备、VPN 连接或 AWS Direct Connect 连接。VPC 中的实例无需公有 IP 地址便可与服务中的资源通信。VPC 和其他服务之间的通信不会离开 Amazon 网络。

终端节点是虚拟设备。它们是水平扩展、冗余和高度可用的 VPC 组件。通过它们，可以在 VPC 中的实例与服务之间进行通信，而不会对网络通信带来可用性风险或带宽约束。
### 10.1 VPC 终端节点
通过 VPC 终端节点可在您的 VPC 与受支持的 AWS 服务以及由 AWS PrivateLink 支持的 VPC 终端节点服务之间建立私有连接。VPC 终端节点不需要互联网网关、NAT 设备、VPN 连接或 AWS Direct Connect 连接。VPC 中的实例无需公有 IP 地址便可与服务中的资源通信。VPC 和其他服务之间的通信不会离开 Amazon 网络。

终端节点是虚拟设备。它们是水平扩展、冗余和高度可用的 VPC 组件。通过它们，可以在 VPC 中的实例与服务之间进行通信，而不会对网络通信带来可用性风险或带宽约束。

下面是不同VPC 终端节点类型，你应该创建受支持的服务所需要的 VPC 终端节点类型。
**接口终端节点**
[接口终端节点](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-interface.html)是一个弹性网络接口，具有来自子网 IP 地址范围的私有 IP 地址，用作发送到受支持的服务的通信的入口点。接口终端节点由 AWS PrivateLink 提供支持，该技术使您能够通过使用私有 IP 地址私下访问服务。AWS PrivateLink 将 VPC 和服务之间的所有网络流量限制在 Amazon 网络以内。您无需互联网网关、NAT 设备或虚拟私有网关。

有关与 AWS PrivateLink 集成的 AWS 服务的信息，请参阅[可以与 AWS PrivateLink 一起使用的 AWS 服务](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/integrated-services-vpce-list.html)。你也可以查看所有可用的 AWS 服务名称，请参阅[查看可用的 AWS 服务名称](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-interface.html#vpce-view-services)。

**网关负载均衡终端节点**
[网关负载均衡终端节点](https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway-load-balancer.html)是一个弹性网络接口，具有来自子网 IP 地址范围的私有 IP 地址。网关负载均衡终端节点由 AWS PrivateLink 提供支持。例如，为了安全检查，这种终端节点用作拦截流量并将其路由到使用[网关负载均衡器](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html)配置的服务的入口点。你指定一个网关负载均衡器作为您在路由表中指定的路由的目标。网关负载均衡终端节点仅仅支持由网关负载均衡器配置的终端节点服务。

**网关终端节点**
[网关终端节点](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-gateway.html)是一个网关，作为您在路由表中指定的路由的目标，用于发往受支持的 AWS 服务的流量。支持以下 AWS 服务：
- Amazon S3
- DynamoDB
#### 10.1.1 接口 VPC 终端节点 (AWS PrivateLink)
利用接口 VPC 终端节点（接口终端节点），您可连接到由 AWS PrivateLink 提供支持的服务。这些服务包括一些 AWS 服务，由其它 AWS 客户和合作伙伴在他们自己的 VPC 中托管的服务（称为终端节点服务），以及受支持的 AWS Marketplace 合作伙伴服务。服务的拥有者是服务提供商，您 (作为创建接口终端节点的委托人) 是服务使用者。

以下是设置接口终端节点的常规步骤：
1. 选择要在其中创建接口终端节点的 VPC，然后提供您要连接到的 AWS 服务、终端节点服务或 AWS Marketplace 服务的名称。
2. 在 VPC 中选择使用接口终端节点的子网。我们将在该子网中创建一个终端节点网络接口。您可以在不同的可用区中指定多个子网 (在服务支持的情况下)，以帮助确保您的接口终端节点能够在出现可用区故障时复原。在此情况下，我们将在您指定的每个子网中创建一个终端节点网络接口。
   > **注意** 终端节点网络接口从您的子网 IP 地址范围分配一个私有 IP 地址，并保留此 IP 地址，直到该接口终端节点被删除为止。
   > 终端节点网络接口是由请求者管理的网络接口。您可以在您的账户中查看它，但不能亲自管理。有关更多信息，请参阅[请求者托管的网络接口](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requester-managed-eni.html)。
3. 指定要与终端节点网络接口关联的安全组。安全组规则将控制从 VPC 中的资源发送到终端节点网络接口的通信。如果您未指定安全组，我们将关联 VPC 的默认安全组。
4. （可选；仅限 AWS 服务和 AWS Marketplace 合作伙伴服务）为终端节点启用私有 DNS 以使您能够使用服务的默认 DNS 主机名对服务发出请求。
   > **重要** 默认情况下，为 AWS 服务和 AWS Marketplace 合作伙伴服务创建的终端节点启用私有 DNS。
   > 私有 DNS 在其他子网中启动，该子网位于同一 VPC 和可用区或本地区域。
5. 当服务提供商与使用者处于不同的账户中时，请参阅[接口终端节点可用区](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-interface.html#vpce-interface-availability-zones)注意事项了解如何使用可用区 ID 识别接口终端节点可用区。
6. 已创建的接口终端节点在服务提供商接受后即可使用。服务提供商必须将服务配置为自动或手动接受请求。AWS 服务和 AWS Marketplace 服务一般会自动接受所有终端节点请求。有关[终端节点生命周期](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-interface.html#vpce-interface-lifecycle)的更多信息，请参阅接口终端节点生命周期。

服务无法通过终端节点发起对您的 VPC 中的资源的请求。终端节点仅返回对从您的 VPC 中的资源启动的通信的响应。在集成服务和终端节点之前，请查看特定于服务的 VPC 终端节点文档，了解任何特定于服务的配置和限制。
##### 用于接口终端节点的私有 DNS
当您创建接口终端节点时，我们将生成您可用于与服务通信的终端节点特定 DNS 主机名。对于 AWS 服务和 AWS Marketplace 合作伙伴服务，私有 DNS 选项（默认启用）会将私有托管区域与您的 VPC 相关联。托管区域包含服务的默认 DNS 名称（例如，ec2.us-east-1.amazonaws.com）的记录集，用于解析为您的 VPC 中的终端节点网络接口的私有 IP 地址。这使您能够使用服务的默认 DNS 主机名而不是终端节点特定 DNS 主机名向服务发出请求。例如，如果您的现有应用程序向 AWS 服务发出请求，则这些应用程序将继续通过接口终端节点发出请求，而无需任何配置更改。

在下图显示的示例中，子网 2 中有一个接口终端节点（对应 Amazon Kinesis Data Streams）和一个终端节点网络接口。您尚未为接口终端节点启用私有 DNS。子网的路由表具有以下路由：

![子网的路由表](images/route_table_without_private_dns.png)

任一子网中的实例都可以使用特定于终端节点的 DNS 主机名通过接口终端节点向 Amazon Kinesis Data Streams 发送请求。子网 1 中的实例可以使用其默认 DNS 名称，通过 AWS 区域中的公有 IP 地址空间与 Amazon Kinesis Data Streams 通信。

![不带私有DNS的接口终端节点](images/vpc-endpoint-kinesis-diagram.png)

在下图中，已为终端节点启用私有 DNS。任一子网中的实例都可以使用默认的 DSN 主机名或特定于终端节点的 DNS 主机名，通过接口终端节点向 Amazon Kinesis Data Streams 发送请求。

![带私有DNS的接口终端节点](images/vpc-endpoint-kinesis-private-dns-diagram.png)
> **重要** 要使用私有 DNS，您必须将以下 VPC 属性设置为 true：enableDnsHostnames 和 enableDnsSupport。有关更多信息，请参阅[查看和更新针对 VPC 的 DNS 支持](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpc-dns.html#vpc-dns-updating)。IAM 用户必须有权使用托管区域。有关更多信息，请参阅[Route 53 的身份验证和访问控制](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/auth-and-access-control.html)。
##### 接口终端节点属性和限制
要使用接口终端节点，您需要了解它们的属性和当前限制：
- 对于每个接口终端节点，每个可用区您只能选择一个子网。
- 某些服务支持使用终端节点策略来控制对服务的访问。有关支持终端节点策略的服务的更多信息，请参阅[使用 VPC 终端节点控制对服务的访问](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpc-endpoints-access.html)。
- 可能无法在所有可用区中通过接口终端节点使用服务。要了解支持的可用区，请使用 [describe-vpc-endpoint-services](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpc-endpoint-services.html) 命令或使用 Amazon VPC 控制台。有关更多信息，请参阅[创建接口终端节点](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-interface.html#create-interface-endpoint)。
- 创建接口终端节点时，将在映射至您的账户且独立于其他账户的可用区中创建此终端节点。当服务提供商与使用者处于不同的账户中时，请参阅[接口终端节点可用区注意事项](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpce-interface.html#vpce-interface-availability-zones)了解如何使用可用区 ID 识别接口终端节点可用区。
- **当服务提供商和使用者具有不同的账户并使用多个可用区，并且使用者查看 VPC 终端节点服务信息时，响应仅包括公共可用区。例如，当服务提供商账户使用 us-east-1a 和 us-east-1c 而使用者使用 us-east-1a 和 us-east-1b 时，响应包括公共可用区 us-east-1a 中的 VPC 终端节点服务**。
- 默认情况下，每个可用区的每个接口终端节点可支持高达 10 Gbps 的带宽，以及高达 40Gbps 的突增。如果您的应用程序需要更高的突增或持续的吞吐量，请联系 AWS support。
- 如果子网的网络 ACL 限制流量，您可能无法通过终端节点网络接口发送流量。请确保您增加了相应的规则，允许与子网的 CIDR 块之间的往返流量。
- 确保与终端网络接口关联的安全组允许终端网络接口与 VPC 中与此服务通信的资源之间进行通信。为确保 AWS 命令行工具（例如 AWS CLI）可以通过 HTTPS 从 VPC 中的资源向 AWS 服务发出请求，安全组必须允许入站 HTTPS（端口 443）流量。
- 接口终端节点仅支持 TCP 流量。
- 在创建终端节点时，您可为其连接终端节点策略来控制对连接到的服务的访问。有关更多信息，请参阅[策略最佳实践](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-policy-examples.html#security_iam_service-with-iam-policy-best-practices)和使用 [VPC 终端节点控制对服务的访问](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/vpc-endpoints-access.html)。
- 查看终端节点服务的服务特定的限制。
- 仅在同一区域内支持终端节点。无法在 VPC 和其他区域内的服务之间创建终端节点。
- 终端节点仅支持 IPv4 流量。
- 无法将终端节点从一个 VPC 转移到另一个 VPC，也无法将终端节点从一项服务转移到另一项服务。
- 您可以为每个 VPC 创建的终端节点的数量有配额。有关更多信息，请参阅[VPC 终端节点](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/amazon-vpc-limits.html#vpc-limits-endpoints)。
##### 连接到本地数据中心
您可以使用以下类型的连接进行接口终端节点与本地数据中心之间的连接：
- [AWS Direct Connect](https://docs.aws.amazon.com/directconnect/latest/UserGuide/)
- [AWS Site-to-Site VPN](https://docs.aws.amazon.com/vpn/latest/s2svpn/)
##### 接口终端节点生命周期
##### 接口终端节点可用区注意事项
##### 接口终端节点的定价
##### 查看可用的 AWS 服务名称
##### 创建接口终端节点
##### 查看您的接口终端节点
##### 为接口终端节点创建和管理通知
##### 通过接口终端节点访问服务
##### 修改接口终端节点
#### 10.1.2 网关负载均衡终端节点
#### 10.1.3 网关终端节点
#### 10.1.4 使用 VPC 终端节点控制对服务的访问
#### 10.1.5 删除 VPC 终端节点
### 10.2 VPC 终端节点服务 (AWS PrivateLink)
### 10.3 Identity and Access Management
### 10.4 终端节点服务的私有 DNS 名称
### 10.5 可以与 AWS PrivateLink 一起使用的 AWS 服务
## 11. VPN 连接
## 12. 配额

## Reference
- [VPC用户指南](https://docs.aws.amazon.com/zh_cn/vpc/latest/userguide/index.html)