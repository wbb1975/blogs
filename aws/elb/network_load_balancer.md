# 网络负载均衡器
## 1. 什么是网络负载均衡器？
负载均衡器充当客户端的单一接触点。负载均衡器在多个目标 (如 Amazon EC2 实例) 之间分配传入的流量。这将提高应用程序的可用性。可以向您的负载均衡器添加一个或多个侦听器（listeners）。

侦听器使用您配置的协议和端口检查来自客户端的连接请求，然后将请求转发给目标组。

每个目标组 使用您指定的 TCP 协议和端口号，再将请求路由到一个或多个注册目标，例如 EC2 实例。您可以向多个目标组注册一个目标。您可以对每个目标组配置运行状况检查。在注册到目标组 (它是使用负载均衡器的侦听器规则指定的) 的所有目标上，执行运行状况检查。
### 1.1 网络负载均衡器 概述
网络负载均衡器在开放系统互连 (OSI) 模型的第四层运行。它每秒可以处理数百万个请求。在负载均衡器收到连接请求后，它会从默认规则的目标组中选择一个目标。它尝试在侦听器配置中指定的端口上打开一个到该选定目标的 TCP 连接。

当您为负载均衡器启用可用区时，Elastic Load Balancing 会在该可用区中创建一个负载均衡器节点。默认情况下，每个负载均衡器节点仅在其可用区中的已注册目标之间分配流量。如果您启用了跨区域负载均衡，则每个负载均衡器节点会在所有启用的可用区中的已注册目标之间分配流量。有关更多信息，请参阅[可用区](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancers.html#availability-zones)。

如果为负载均衡器启用多个可用区，并确保每个目标组在每个启用的可用区中至少有一个目标，那么这将提高应用程序的容错能力。例如，如果一个或多个目标组在可用区中没有运行状况良好的目标，我们会从 DNS 中删除相应子网的 IP 地址，但其他可用区中的负载均衡器节点仍可用于路由流量。如果一个客户端不遵守生存时间 (TTL) 而将请求发送到已从 DNS 删除的 IP 地址，则请求会失败。

对于 TCP 流量，负载均衡器基于协议、源 IP 地址、源端口、目标 IP 地址、目标端口和 TCP 序列号，使用流哈希算法选择目标。来自客户端的 TCP 连接具有不同的源端口和序列号，可以路由到不同的目标。每个单独的 TCP 连接在连接的有效期内路由到单个目标。

对于 UDP 流量，负载均衡器基于协议、源 IP 地址、源端口、目标 IP 地址和目标端口，使用流哈希算法选择目标。UDP 流具有相同的源和目标，因此始终在其整个生命周期内路由到单个目标。不同 UDP 流具有不同的源 IP 地址和端口，因此它们可以路由到不同的目标。

Elastic Load Balancing 为您启用的每个可用区创建一个网络接口。可用区内的每个负载均衡器节点使用该网络接口来获取一个静态 IP 地址。在您创建面向 Internet 的负载均衡器时，可以选择将一个弹性 IP 地址与每个子网关联。

在创建目标组时，应指定其目标类型，这决定您是否通过实例 ID 或 IP 地址注册目标。如果您使用实例 ID 注册目标，则客户端的源 IP 地址将保留并提供给您的应用程序。如果您使用 IP 地址注册目标，则源 IP 地址是负载均衡器节点的私有 IP 地址。

可以根据需求变化在负载均衡器中添加和删除目标，而不会中断应用程序的整体请求流。Elastic Load Balancing 根据传输到应用程序的流量随时间的变化对负载均衡器进行扩展。Elastic Load Balancing 能够自动扩展以处理绝大部分工作负载。

您可以配置运行状况检查，这些检查可用来监控注册目标的运行状况，以便负载均衡器只能将请求发送到正常运行的目标。

有关更多信息，请参阅 Elastic Load Balancing 用户指南 中的 [Elastic Load Balancing 工作原理](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html)。
### 1.2 从传统负载均衡器迁移的好处
使用 网络负载均衡器而非 传统负载均衡器有下列好处：
- 可以处理急剧波动的工作负载，并可以扩展到每秒处理数百万个请求。
- 支持将静态 IP 地址用于负载均衡器。还可以针对为负载均衡器启用的每个子网分配一个弹性 IP 地址。
- 支持通过 IP 地址注册目标，包括位于负载均衡器的 VPC 之外的目标。
- 支持将请求路由到单个 EC2 实例上的多个应用程序。可以使用多个端口向同一个目标组注册每个实例或 IP 地址。
- 支持容器化的应用程序。计划任务时，Amazon Elastic Container Service (Amazon ECS) 可以选择一个未使用的端口，并可以使用此端口向目标组注册该任务。这样可以高效地使用您的群集。
- 支持单独监控每个服务的运行状况，因为运行状况检查是在目标组级别定义的，而且许多 Amazon CloudWatch 指标也是在目标组级别报告的。将目标组挂载到 Auto Scaling 组的功能使您能够根据需求动态扩展每个服务。
### 1.3 如何开始
要创建网络负载均衡器，请尝试以下某个教程中介绍的方法：
- [Network Load Balancer 入门](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancer-getting-started.html)
- [教程：使用 AWS CLI 创建网络负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancer-cli.html)
## 2. Network Load Balancer 入门
本教程介绍通过 AWS 管理控制台（基于 Web 的界面）创建 Network Load Balancer 的实际操作。要创建第一个网络负载均衡器，请完成以下步骤。

开始前的准备工作：
- 确定将用于 EC2 实例的可用区。在每个这些可用区中配置至少带有一个公有子网的 Virtual Private Cloud (VPC)。这些公有子网用于配置负载均衡器。您可以改为在这些可用区的其它子网中启动您的 EC2 实例。
- 在每个可用区中至少启动一个 EC2 实例。确保这些实例的安全组允许侦听器端口上来自客户端的 TCP 访问和来自您的 VPC 的运行状况检查请求。有关更多信息，请参阅[目标安全组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups)。
### 2.1 步骤 1：选择负载均衡器类型
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航栏上，选择您的负载均衡器的区域。请确保选择用于 EC2 实例的同一区域。
3. 在导航窗格中的 **LOAD BALANCING** 下，选择 **Load Balancers**。
4. 选择 **Create Load Balancer**。
5. 对于**网络负载均衡器**，选择 **Create** (创建)。
### 2.2 步骤 2：配置负载均衡器和侦听器
在 Configure Load Balancer 页面上，完成以下过程配置负载均衡器和侦听器：
1. 对于 **Name**，键入负载均衡器的名称。

   在区域的 Application Load Balancer 和 Network Load Balancer 集内，网络负载均衡器 的名称必须唯一，最多可以有 32 个字符，只能包含字母数字字符和连字符，不能以连字符开头或结尾，并且不能以“internal-”开头。
2. 对于 **Scheme**，保留默认值 **internet-facing**。
3. 对于 **Listeners**，保留默认值，默认侦听器负责接收端口 80 上的 TCP 流量。
4. 对于 **Availability Zones (可用区)**，选择用于 EC2 实例的 VPC。对于用于启动 EC2 实例的每个可用区，选择一个可用区，然后为该可用区选择公有子网。

   默认情况下，AWS 会针对其可用区从子网中为每个负载均衡器节点分配 IPv4 地址。另外，当您创建面向 Internet 的负载均衡器时，您可以为每个可用区选择弹性 IP 地址。这将为您的负载均衡器提供静态 IP 地址。
5. 选择 **Next: Configure Routing**。
### 2.3 步骤 3：配置目标组
创建一个要在请求路由中使用的目标组。侦听器的规则将请求路由到此目标组中的注册目标。负载均衡器使用为目标组定义的运行状况检查设置来检查此目标组中目标的运行状况。在 Configure Routing 页面上，完成以下过程。
1. 对于 **Target group**，保留默认值 **New target group**。
2. 对于 **Name**，键入新目标组的名称。
3. 将 **Protocol** 保留为“TCP”，**Port** 为“80”，**Target type** 为“instance”。
4. 对于 **Health checks**，保留默认协议。
5. 选择 **Next: Register Targets**。
### 2.4 步骤 4：向您的目标组注册目标
在 Register Targets 页面上，完成以下过程：
1. 对于 **Instances**，选择一个或多个实例。
2. 保留默认端口 80，并选择 **Add to registered**。
3. 当您完成选择实例后，选择 **Next: Review**。
### 2.5 步骤 5：创建并测试您的负载均衡器
在创建负载均衡器之前，请检查您的设置。在创建负载均衡器之后，可以验证其是否将流量发送到您的 EC2 实例。
1. 在 **Review** 页面上，选择 **Create** 。
2. 在您收到已成功创建负载均衡器的通知后，选择 **Close**。
3. 在导航窗格上的 **LOAD BALANCING** 下，选择 **Target Groups**。
4. 选择新创建的目标组。
5. 选择 **Targets** 并验证您的实例是否已就绪。如果实例状态是 initial，很可能是因为，实例仍在注册过程中，或者未通过视为正常运行所需的运行状况检查最小数量。在您的至少一个实例的状态为 healthy 后，便可测试负载均衡器。
6. 在导航窗格中的 **LOAD BALANCING** 下，选择 **Load Balancers**。
7. 选择新创建的负载均衡器。
8. 选择 **Description (描述)** 并复制负载均衡器的 DNS 名称（例如，my-load-balancer-1234567890abcdef.elb.us-west-2.amazonaws.com.cn）。将该 DNS 名称粘贴到已连接 Internet 的 Web 浏览器的地址栏中。如果一切正常，浏览器会显示您服务器的默认页面。
### 2.6 步骤 6：删除您的负载均衡器 (可选)
在您的负载均衡器可用之后，您需要为保持其运行的每小时或部分小时支付费用。当您不再需要负载均衡器时，可将其删除。当负载均衡器被删除之后，您便不再需要支付负载均衡器费用。请注意，删除负载均衡器不会影响在负载均衡器中注册的目标。例如，您的 EC2 实例会继续运行。

**删除您的负载均衡器**：
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 **LOAD BALANCING** 下，选择 **Load Balancers**。
3. 选择负载均衡器，然后选择 **Actions** 和 **Delete**。
4. 当系统提示进行确认时，选择 **Yes, Delete**。
## 3. 教程：使用 AWS CLI 创建 网络负载均衡器
开始前的准备工作：
- 安装 AWS CLI，或如果您使用的是不支持 Network Load Balancer 的版本，则更新到最新版本的 AWS CLI。有关更多信息，请参阅 AWS Command Line Interface 用户指南中的[安装 AWS 命令行界面](https://docs.amazonaws.cn/cli/latest/userguide/installing.html)。
- 确定将用于 EC2 实例的可用区。在每个这些可用区中配置至少带有一个公有子网的 Virtual Private Cloud (VPC)。
- 在每个可用区中至少启动一个 EC2 实例。确保这些实例的安全组允许侦听器端口上来自客户端的 TCP 访问和来自您的 VPC 的运行状况检查请求。有关更多信息，请参阅[目标安全组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups)。
### 3.1 创建负载均衡器
1. 使用 [create-load-balancer](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-load-balancer.html) 命令创建负载均衡器，并为在其中启动实例的每个可用区指定公有子网。每个可用区您只能指定一个子网。   
   ```
   aws elbv2 create-load-balancer --name my-load-balancer --type network --subnets subnet-12345678
   ```
   输出包含负载均衡器的 Amazon 资源名称 (ARN)，格式如下：
   ```
   arn:aws-cn:elasticloadbalancing:us-west-2:123456789012:loadbalancer/net/my-load-balancer/1234567890123456
   ```
2. 使用 [create-target-group](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-target-group.html) 命令创建目标组，并指定用于 EC2 实例的相同 VPC：
   ```
   aws elbv2 create-target-group --name my-targets --protocol TCP --port 80 --vpc-id vpc-12345678
   ```
   输出包含目标组的 ARN，格式如下：
   ```
   arn:aws-cn:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/1234567890123456
   ```
3. 使用 [register-targets](https://docs.amazonaws.cn/cli/latest/reference/elbv2/register-targets.html) 命令将您的实例注册到目标组：
   ```
   aws elbv2 register-targets --target-group-arn targetgroup-arn --targets Id=i-12345678 Id=i-23456789
   ```
4. 使用 [create-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-listener.html) 命令为您的负载均衡器创建侦听器，该侦听器带有将请求转发到目标组的默认规则：
   ```
   aws elbv2 create-listener --load-balancer-arn loadbalancer-arn --protocol TCP --port 80  --default-actions Type=forward,TargetGroupArn=targetgroup-arn
   ```
   输出包含侦听器的 ARN，格式如下：
   ```
   arn:aws-cn:elasticloadbalancing:us-west-2:123456789012:listener/net/my-load-balancer/1234567890123456/1234567890123456
   ```
5. (可选) 您可以使用此[describe-target-health](https://docs.amazonaws.cn/cli/latest/reference/elbv2/describe-target-health.html)命令验证目标组的已注册目标的运行状况：
   ```
   aws elbv2 describe-target-health --target-group-arn targetgroup-arn
   ```
### 3.2 为负载均衡器指定弹性 IP 地址
在创建网络负载均衡器时，可以使用子网映射为每个子网指定一个弹性 IP 地址。
```
aws elbv2 create-load-balancer --name my-load-balancer --type network --subnet-mappings SubnetId=subnet-12345678,AllocationId=eipalloc-12345678
```
### 3.3 使用端口覆盖添加目标
如果您有一个微服务架构，它在单个实例上有多个服务，则每个服务在不同的端口上接受连接。您可以将实例注册到目标组多次，每次使用不同的端口进行注册。
1. 使用 [create-target-group](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-target-group.html) 命令创建目标组：
   ```
   aws elbv2 create-target-group --name my-targets --protocol TCP --port 80 --vpc-id vpc-12345678
   ```
2. 使用 [register-targets](https://docs.amazonaws.cn/cli/latest/reference/elbv2/register-targets.html) 命令将您的实例注册到目标组。请注意，每个容器的实例 ID 相同，但端口不同。
   ```
   aws elbv2 register-targets --target-group-arn targetgroup-arn  --targets Id=i-12345678,Port=80 Id=i-12345678,Port=766
   ```
3. 使用 [create-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-listener.html) 命令为您的负载均衡器创建侦听器，该侦听器带有将请求转发到目标组的默认规则：
   ```
   aws elbv2 create-listener --load-balancer-arn loadbalancer-arn --protocol TCP --port 80  --default-actions Type=forward,TargetGroupArn=targetgroup-arn
   ```
### 3.4 删除负载均衡器
当您不再需要负载均衡器和目标组时，可以将其删除，如下所示：
```
aws elbv2 delete-load-balancer --load-balancer-arn loadbalancer-arn
aws elbv2 delete-target-group --target-group-arn targetgroup-arn
```
## 4. 负载均衡器
### 4.1 负载均衡器基本概念
负载均衡器 充当客户端的单一接触点。客户端将请求发送到负载均衡器，然后负载均衡器将请求发送到一个或多个可用区中的目标 (例如 EC2 实例)。

要配置您的负载均衡器，可以创建目标组，然后将目标注册到[目标组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-target-groups.html)。如果您确保每个启用的可用区均具有至少一个注册目标，则负载均衡器将具有最高效率。您还可以创建[侦听器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-listeners.html)来检查来自客户端的连接请求，并将来自客户端的请求路由到目标组中的目标。

Network Load Balancer 通过 VPC 对等连接、AWS 托管 VPN 和第三方 VPN 解决方案支持来自客户端的连接。
#### 4.1.1 负载均衡器状态
负载均衡器可能处于下列状态之一：
- provisioning：正在设置负载均衡器。
- active：负载均衡器已完全设置并准备好路由流量。
- failed：负载均衡器无法设置。
#### 4.1.2 负载均衡器属性
- deletion_protection.enabled：指示是否启用[删除保护](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancers.html#deletion-protection)。默认为 false。
- load_balancing.cross_zone.enabled：指示是否启用了[跨可用区负载均衡](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancers.html#cross-zone-load-balancing)。默认为 false。
#### 4.1.3 可用区
在创建负载均衡器时，可为其启用一个或多个可用区。如果为负载均衡器启用多个可用区，则可以提高应用程序的容错能力。您无法在创建网络负载均衡器后对网络负载均衡器 禁用这些可用区，但您可以启用其它可用区。

当启用某个可用区时，应指定该可用区中的一个子网。Elastic Load Balancing ; 会在该可用区中创建一个负载均衡器节点，并为子网创建一个网络接口（描述以“ELB net”开头并包括负载均衡器的名称）。可用区内的每个负载均衡器节点使用该网络接口来获取一个 IPv4 地址。请注意，您可以查看此网络接口，但不能修改它。

在您创建面向 Internet 的负载均衡器时，可以选择为每个子网指定一个弹性 IP 地址。如果您不选择自己的弹性 IP 地址之一，Elastic Load Balancing 将为你对每个子网提供一个弹性 IP 地址。这些弹性 IP 地址为您的负载均衡器提供静态 IP 地址，这些地址在负载均衡器的生命周期内不会更改。创建负载均衡器后，无法更改这些弹性 IP 地址。

在您创建内部负载均衡器时，可以选择为每个子网指定一个私有 IP 地址。如果您没有从子网指定 IP 地址，Elastic Load Balancing 将为您选择一个 IP 地址。这些私有 IP 地址为您的负载均衡器提供静态 IP 地址，这些地址在负载均衡器的生命周期内不会更改。创建负载均衡器后，无法更改这些私有 IP 地址。

**要求**：
- 对于面向 Internet 的负载均衡器，您指定的子网必须至少具有 8 个可用 IP 地址。对于内部负载均衡器，仅当您让 AWS 从子网中选择私有 IPv4 地址时，才需要执行此操作。
- 无法指定受约束可用区中的子网。错误消息为“Load balancers with type 'network' are not supported in az_name (az_name 中不支持“网络”类型的负载均衡器)”。您可以在不受约束的其他可用区中指定子网，并使用跨区域负载均衡将流量分发至受约束可用区中的目标。
- 您无法在本地区域中指定子网。

在启用一个可用区后，负载均衡器会开始将请求路由到该可用区中的已注册目标。如果您确保每个启用的可用区均具有至少一个注册目标，则负载均衡器将具有最高效率。

##### **使用控制台添加可用区**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 **LOAD BALANCING** 下，选择 **Load Balancers**。
3. 选择负载均衡器。
4. 在 **Description (描述)** 选项卡上的 **Basic Configuration (基本配置)** 下，选择 **Edit subnets (编辑子网)**。
5. 要启用一个可用区，请选中该可用区的复选框。如果该可用区有一个子网，则将选择此子网。如果该可用区有多个子网，请选择其中一个子网。请注意，您只能为每个可用区选择一个子网。
   
   对于面向 Internet 的负载均衡器，您可以为每个可用区选择弹性 IP 地址。对于内部负载均衡器，您可以从每个子网的 IPv4 范围分配私有 IP 地址，而不是让 Elastic Load Balancing 分配一个 IP 地址。
6. 选择 Save。
##### **使用 AWS CLI 添加可用区**
使用 [set-subnets](https://docs.amazonaws.cn/cli/latest/reference/elbv2/set-subnets.html) 命令。
##### **跨可用区负载均衡**：
默认情况下，每个负载均衡器节点仅在其可用区中的已注册目标之间分配流量。如果您启用了跨可用区负载均衡，则每个负载均衡器节点会在所有启用的可用区中的已注册目标之间分配流量。有关更多信息，请参阅 Elastic Load Balancing 用户指南中的[跨可用区负载均衡](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html#cross-zone-load-balancing)。
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器。
4. 选择 Description、Edit attributes。
5. 在编辑负载均衡器属性页面上，为跨区域负载均衡选择启用，然后选择保存。
##### **使用 AWS CLI 启用跨可用区负载均衡**
使用带 load_balancing.cross_zone.enabled 属性的 [modify-load-balancer-attributes](https://docs.amazonaws.cn/cli/latest/reference/elbv2/modify-load-balancer-attributes.html) 命令。
#### 4.1.4 删除保护
为了防止您的负载均衡器被意外删除，您可以启用删除保护。默认情况下，已为负载均衡器禁用删除保护。

如果您为负载均衡器启用删除保护，则必须先禁用删除保护，然后才能删除负载均衡器。

##### 使用控制台启用删除保护
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器。
4. 选择 Description、Edit attributes。
5. 在编辑负载均衡器属性页面上，为删除保护选择启用，然后选择保存。
##### 使用控制台禁用删除保护
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器。
4. 选择 Description、Edit attributes。
5. 在 Edit load balancer attributes 页面上，清除 Enable delete protection 并选择 Save。
##### 使用 AWS CLI 启用或禁用删除保护
使用带 deletion_protection.enabled 属性的 [modify-load-balancer-attributes](https://docs.amazonaws.cn/cli/latest/reference/elbv2/modify-load-balancer-attributes.html) 命令。
#### 4.1.5 连接空闲超时
对于客户端通过 网络负载均衡器 发出的每个 TCP 请求，都将跟踪该连接的状态。如果客户端或目标通过连接发送数据的间隔超过空闲超时期限，则连接将关闭。如果客户端或目标在空闲超时期限后发送数据，则会收到一个 TCP RST 数据包，以指示连接不再有效。

对于 TCP 流，Elastic Load Balancing 将空闲超时值设为 350 秒。您不能修改此值。对于 TCP 侦听器，客户端或目标可以使用 TCP keepalive 数据包重置空闲超时。TCP keepalive 数据包不支持 TLS 侦听器。

虽然 UDP 无连接，但是负载均衡器将基于源和目标 IP 地址和端口保持 UDP 流状态，从而确保属于同一个流中的数据包始终发送到相同的目标。空闲超时期限后，负载均衡器会考虑将传入的 UDP 数据包作为新流，并路由到新的目标。对于 UDP 流，Elastic Load Balancing 将空闲超时值设为 120 秒。

EC2 实例必须在 30 秒内响应新请求，才能建立返回路径。
#### 4.1.6 DNS 名称
每个网络负载均衡器都使用以下语法接收默认域名系统 (DNS) 名称：name-id.elb.region.amazonaws.com.cn。例如，my-load-balancer-1234567890abcdef.elb.us-west-2.amazonaws.com.cn。

如果您更喜欢使用更容易记住的 DNS 名称，则可以创建自定义域名并将其与负载均衡器的 DNS 名称相关联。在客户端使用此自定义域名进行请求时，DNS 服务器将它解析为负载均衡器的 DNS 名称。

首先，向经认可的域名注册商注册域名。下一步，通过您的 DNS 服务（如您的域注册商）创建一条别名记录将请求路由到您的负载均衡器。有关更多信息，请参阅您的 DNS 服务的文档。例如，您可以使用 Amazon Route 53 作为 DNS 服务。有关更多信息，请参阅 Amazon Route 53 开发人员指南 中的[将流量路由到 ELB 负载均衡器](https://docs.amazonaws.cn/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html)。

负载均衡器针对每个启用的可用区都有一个 IP 地址。这些是负载均衡器节点的地址。负载均衡器的 DNS 名称解析为这些地址。例如，假设您的负载均衡器的自定义域名是 example.networkloadbalancer.com。使用以下 dig 或 nslookup 命令确定负载均衡器节点的 IP 地址。
+ Linux 或 Mac
   ```
   dig +short example.networkloadbalancer.com
   ```
+ Windows
   ```
   nslookup example.networkloadbalancer.com
   ```

负载均衡器具有其负载均衡器节点的 DNS 记录。您可以使用具有以下语法的 DNS 名称来确定负载均衡器节点的 IP 地址：az.name-id.elb.region.amazonaws.com.cn。
+ Linux 或 Mac
   ```
   $ dig +short us-west-2b.my-load-balancer-1234567890abcdef.elb.us-west-2.amazonaws.com.cn
   ```
+ Windows
   ```
   nslookup us-west-2b.my-load-balancer-1234567890abcdef.elb.us-west-2.amazonaws.com.cn
   ```
### 4.2 创建负载均衡器
负载均衡器接收来自客户端的请求，并将请求分发给目标组中的目标 (如 EC2 实例)。

在开始之前，请确保您的负载均衡器的 Virtual Private Cloud (VPC) 在目标使用的每个可用区中至少有一个公有子网。

要使用 AWS CLI 创建负载均衡器，请参阅教程：[使用 AWS CLI 创建 网络负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancer-cli.html)。

要使用 AWS 管理控制台创建负载均衡器，请完成以下任务。
#### 步骤 1：配置负载均衡器和侦听器
首先，为负载均衡器提供一些基本配置信息，如名称、网络及一个或多个侦听器。侦听器是用于检查连接请求的进程。它配置了用于从客户端连接到负载均衡器的协议和端口。有关受支持的协议和端口的更多信息，请参阅[侦听器配置](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-listeners.html#listener-configuration)。

**配置负载均衡器和侦听器**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择 Create Load Balancer。
4. 对于 网络负载均衡器，选择 Create (创建)。
5. 对于 Name，键入负载均衡器的名称。例如：my-nlb。
6. 对于 Scheme，面向 Internet 的负载均衡器将来自客户端的请求通过 Internet 路由到目标。内部负载均衡器使用私有 IP 地址将请求路由到目标。
7. 对于 Listeners，默认值是负责接收端口 80 上的 TCP 流量的侦听器。您可保留默认侦听器设置，修改协议或修改端口。选择 Add 添加另一个侦听器。
8. 对于 Availability Zones (可用区)，选择用于 EC2 实例的 VPC。对于用于启动 EC2 实例的每个可用区，选择一个可用区，然后为该可用区选择公有子网。

   默认情况下，AWS 会针对其可用区从子网中为每个负载均衡器节点分配 IPv4 地址。另外，如果您创建面向 Internet 的负载均衡器，您可以为每个可用区选择弹性 IP 地址。这将为您的负载均衡器提供静态 IP 地址。如果您创建内部负载均衡器，您可以从每个子网的 IPv4 范围分配私有 IP 地址，而不是让 AWS 分配一个 IP 地址。
9. 选择 Next: Configure Routing。
#### 步骤 2：配置目标组
将目标 (例如 EC2 实例) 注册到目标组。您在此步骤中配置的目标组将用作侦听器规则中的目标组，侦听器规则负责将请求转发到目标组。有关更多信息，请参阅[Network Load Balancer 的目标组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-target-groups.html)。

**配置目标组**
1. 对于 Target group，保留默认值 New target group。
2. 对于 Name，键入目标组的名称。
3. 对于 Protocol (协议)，选择协议，如下所示：
   + 如果侦听器协议为 TCP，选择 TCP 或 TCP_UDP。
   + 如果侦听器协议为 TLS，选择 TCP 或 TLS。
   + 如果侦听器协议为 UDP，选择 UDP 或 TCP_UDP。
   + 如果侦听器协议为 TCP_UDP，选择 TCP_UDP。
4. （可选）设置 Port (端口) 。
5. 对于 Target type，选择 instance 通过实例 ID 指定目标，或选择 ip 通过 IP 地址指定目标。如果目标组协议是 UDP 或 TCP_UDP，您必须选择 instance。
6. 对于 Health checks，保留默认运行状况检查设置。
7. 选择 Next: Register Targets。
#### 步骤 3：向目标组注册目标
可将 EC2 实例注册为目标组中的目标。

**通过实例 ID 注册目标**
1. 对于 Instances，选择一个或多个实例。
2. 保留默认实例侦听器端口，或键入一个新端口并选择 Add to registered。
3. 当您注册完实例后，选择 Next: Review。

**通过 IP 地址注册目标**
1. 对于每个要注册的 IP 地址，请执行以下操作：
   + 对于 Network，如果 IP 地址来自目标组 VPC 的子网，则选择该 VPC。否则，请选择 Other private IP address。
   + 对于 Availability Zone，选择一个可用区或选择 all。这将决定目标是只从指定可用区的负载均衡器节点接收流量，还是从所有启用的可用区接收流量。如果您要注册来自 VPC 的 IP 地址，则不会显示此字段。在这种情况下，会自动检测可用区。
   + 对于 IP，键入地址。
   + 对于 Port，键入端口。
   + 选择 Add to list。
2. 在将 IP 地址添加到列表中后，选择 Next: Review。
#### 步骤 4：创建负载均衡器
在创建负载均衡器之后，您可验证您的 EC2 实例是否通过了初始运行状况检查，然后测试负载均衡器是否会将流量发送至您的 EC2 实例。使用完负载均衡器之后，您可将其删除。有关更多信息，请参阅 [删除网络负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-delete.html)。

**创建负载均衡器**
1. 在 Review 页面上，选择 Create 。
2. 创建负载均衡器之后，选择 Close。
3. 在导航窗格上的 LOAD BALANCING 下，选择 Target Groups。
4. 选择新创建的目标组。
5. 选择 Targets 并验证您的实例是否已就绪。如果实例状态是 initial，很可能是因为，实例仍在注册过程中，或者未通过视为正常运行所需的运行状况检查最小数量。在至少一个实例的状态为正常后，便可测试负载均衡器。
### 4.3 更新标签
使用标签可帮助您按各种标准对负载均衡器进行分类，例如按用途、所有者或环境。

您可以为每个负载均衡器添加多个标签。每个负载均衡器的标签键必须唯一。如果您添加的标签中的键已经与负载均衡器关联，它将更新该标签的值。

当您用完标签时，可以从负载均衡器中将其删除。

#### 限制
- 每个资源的最大标签数 — 50
- 最大密钥长度—127 个 Unicode 字符
- 最大值长度—255 个 Unicode 字符
- 标签键和值区分大小写。允许使用的字符包括可用 UTF-8 格式表示的字母、空格和数字，以及以下特殊字符：+ - = . _ : / @。请不要使用前导空格或尾随空格。
- 请勿在标签名称或值中使用 aws: 前缀，因为它专为 AWS 使用预留。您无法编辑或删除带此前缀的标签名称或值。具有此前缀的标签不计入每个资源的标签数限制。
#### 使用控制台更新负载均衡器的标签
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器。
4. 选择 Tags、Add/Edit Tags，然后执行下列一个或多个操作：
   + 要更新标签，请编辑 Key 和 Value 的值。
   + 要添加新标签，请选择 Create Tag。对于 Key 和 Value，键入值。
   + 要删除标签，请选择标签旁边的删除图标 (X)。
5. 完成更新标签后，选择 Save。
#### 使用 AWS CLI 更新负载均衡器的标签
使用 [add-tags](https://docs.amazonaws.cn/cli/latest/reference/elbv2/add-tags.html) 和 [remove-tags](https://docs.amazonaws.cn/cli/latest/reference/elbv2/remove-tags.html) 命令。
### 4.4 删除负载均衡器
在您的负载均衡器可用之后，您需要为保持其运行的每小时或部分小时支付费用。当您不再需要该负载均衡器时，可将其删除。当负载均衡器被删除之后，您便不再需要支付负载均衡器费用。

如果已启用删除保护，则无法删除负载均衡器。有关更多信息，请参阅[删除保护](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/network-load-balancers.html#deletion-protection)。

删除负载均衡器也将删除其侦听器。删除负载均衡器不会影响其注册目标。例如，您的 EC2 实例将继续运行并仍注册到其目标组。要删除目标组，请参阅[删除目标组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/delete-target-group.html)。
#### 使用控制台删除负载均衡器
1. 如果您有一个指向负载均衡器的域的一个别名记录，请将它指向新的位置并等待 DNS 更改生效，然后再删除您的负载均衡器。
2. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
3. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
4. 选择负载均衡器。
5. 依次选择 Actions 和 Delete。
6. 当系统提示进行确认时，选择 Yes, Delete。
#### 使用 AWS CLI 删除负载均衡器
使用 [delete-load-balancer](https://docs.amazonaws.cn/cli/latest/reference/elbv2/delete-load-balancer.html) 命令。
## 5. 侦听器
在开始使用 网络负载均衡器 之前，您必须添加一个或多个侦听器。侦听器是一个使用您配置的协议和端口检查连接请求的进程。为侦听器定义的规则可以确定负载均衡器将请求路由到一个或多个目标组中的目标的方式。

有关更多信息，请参阅 Elastic Load Balancing 用户指南 中的[请求路由](https://docs.amazonaws.cn/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html#request-routing)。
### 5,1 侦听器配置
侦听器支持以下协议和端口：
- 协议：TCP，TLS，UDP，TCP_UDP
- 端口：1-65535

可以使用 TLS 侦听器将加密和解密的工作交给负载均衡器完成，以便应用程序可以专注于其业务逻辑。如果侦听器协议为 TLS，您必须在侦听器上确切地部署一个 SSL 服务器证书。有关更多信息，请参阅 [网络负载均衡器的 TLS 侦听器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-tls-listener.html)。

要在同一端口上同时支持 TCP 和 UDP，请创建一个 TCP_UDP 侦听器。TCP_UDP 侦听器的目标组必须使用 TCP_UDP 协议。

可以将 WebSockets 与您的侦听器结合使用。

已配置侦听器的所有网络流量都归类为预期流量。与配置的侦听器不匹配的网络流量被归类为非预期流量。类型 3 之外的 ICMP 请求也被视为非预期流量。Network Load Balancer会删除非预期流量而不将其转发给任何目标。作为非预期流量的一部分的 TCP 数据包因 TCP 重置 (RST) 而被拒绝。
### 5,2 侦听器规则
在创建侦听器时，将会指定用于路由请求的规则。该规则将请求转发到指定的目标组。要更新此规则，请参阅[更新网络负载均衡器的侦听器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-rules.html)。
### 5,3 为网络负载均衡器创建侦听器
侦听器是用于检查连接请求的进程。您可在创建负载均衡器时定义侦听器，并可随时向负载均衡器添加侦听器。
#### 5.3.1 先决条件
+ 必须为侦听器规则指定目标组。有关更多信息，请参阅[为网络负载均衡器创建目标组](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-target-group.html)。
+ 您必须指定 TLS 监听器的 SSL 证书。负载均衡器先使用证书终止连接，然后解密来自客户端的请求，最后再将请求路由到目标。有关更多信息，请参阅[服务器证书](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-tls-listener.html#tls-listener-certificates)。
#### 5.3.2 添加侦听器
您为侦听器配置用于从客户端连接到负载均衡器的协议和端口，并为默认侦听器规则配置目标组。有关更多信息，请参阅[侦听器配置](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-listeners.html#listener-configuration)。

**使用控制台添加侦听器**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 选择 Add listener (添加侦听器)。
5. 对于 Protocol : port (协议: 端口)，选择 TCP、UDP、TCP_UDP 或 TLS。保留默认端口或键入其他端口。
6. 对于 Default actions (默认操作)，选择 Add action (添加操作)、Forward to (转发至)，然后选择可用目标组。
7. [TLS 侦听器] 对于 Security policy (安全策略)，建议您保留默认安全策略。
8. [TLS 侦听器] 对于 Default SSL certificate (默认 SSL 证书)，请执行下列操作之一：
   + 如果使用 AWS Certificate Manager 创建或导入了证书，请选择 From ACM (来自 ACM) 并选择证书。
   + 如果使用 IAM 上传了证书，则选择 From IAM (来自 IAM) 并选择证书。
9. 选择 Save。
10.  [TLS 侦听器] 要添加用于 SNI 协议的可选证书列表，请参阅[将证书添加到证书列表](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-certificates.html#add-certificates)。

**使用 AWS CLI 添加侦听器**

使用 [create-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/create-listener.html) 命令来创建侦听器。
### 5,4 网络负载均衡器的 TLS 侦听器
要使用 TLS 侦听器，您必须在负载均衡器上部署至少一个服务器证书。负载均衡器先使用此服务器证书终止前端连接，再解密来自客户端的请求，然后将请求发送到目标。

Elastic Load Balancing 使用 TLS 协商配置（称为安全策略）在客户端与负载均衡器之间协商 TLS 连接。安全策略是协议和密码的组合。协议在客户端与服务器之间建立安全连接，确保在客户端与负载均衡器之间传递的所有数据都是私密数据。密码是使用加密密钥创建编码消息的加密算法。协议使用多种密码对 Internet 上的数据进行加密。在 连接协商过程中，客户端和负载均衡器会按首选项顺序提供各自支持的密码和协议的列表。为安全连接选择服务器列表中与任一客户端的密码匹配的第一个密码。

Network Load Balancer 不支持 TLS 重新协商。

要创建 TLS 侦听器，请参阅[添加侦听器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-listener.html#add-listener)。要查看相关演示，请参阅[网络负载均衡器 上的 TLS 支持](https://exampleloadbalancer.com/nlbtls_demo.html)以及[网络负载均衡器 上的 SNI 支持](https://exampleloadbalancer.com/nlbsni_demo.html)。
#### 5.4.1 服务器证书
负载均衡器需要 X.509 证书（服务器证书）。证书是由证书颁发机构 (CA) 颁发的数字化身份。证书包含标识信息、有效期限、公有密钥、序列号以及发布者的数字签名。

在创建用于负载均衡器的证书时，您必须指定域名。

我们建议您使用[AWS Certificate Manager (ACM)](http://www.amazonaws.cn/certificate-manager/)为负载均衡器创建证书。ACM 已与 Elastic Load Balancing 集成，以便您可以在负载均衡器上部署证书。有关更多信息，请参阅[AWS Certificate Manager 用户指南](https://docs.amazonaws.cn/acm/latest/userguide/)。

此外，还可以使用 TLS 工具创建证书签名请求 (CSR)，然后获取由 CA 签署的 CSR 以生成证书，并将证书导入 ACM，或将证书上传至 AWS Identity and Access Management (IAM)。有关更多信息，请参阅 AWS Certificate Manager 用户指南 中的[导入证书](https://docs.amazonaws.cn/acm/latest/userguide/import-certificate.html)或 IAM 用户指南 中的[使用服务器证书](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_server-certs.html)。
> **重要**: 您无法在网络负载均衡器上安装具有大于 2048 位的 RSA 密钥或 EC 密钥的证书。https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-certificates.html#replace-default-certificate
##### 5.4.1.1 默认证书
创建 TLS 侦听器时，必须仅指定一个证书。此证书称为默认证书。创建 TLS 侦听器后，您可以替换默认证书。有关更多信息，请参阅[替换默认证书]()。

如果在[证书列表](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-tls-listener.html#sni-certificate-list)中指定其他证书，则仅当客户端在不使用服务器名称指示 (SNI) 协议的情况下连接以指定主机名或证书列表中没有匹配的证书时，才使用默认证书。

如果您未指定其他证书但需要通过单一负载平衡器托管多个安全应用程序，则可以使用通配符证书或为证书的每个其他域添加使用者备用名称 (SAN)。
##### 5.4.1.2 证书列表
创建 TLS 侦听器后，它具有默认证书和空证书列表。您可以选择将证书添加到侦听器的证书列表中。使用证书列表可使负载均衡器在同一端口上支持多个域，并为每个域提供不同的证书。有关更多信息，请参阅[将证书添加到证书列表](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-certificates.html#add-certificates)。

负载均衡器使用支持 SNI 的智能证书选择算法。如果客户端提供的主机名与证书列表中的一个证书匹配，则负载均衡器将选择此证书。如果客户端提供的主机名与证书列表中的多个证书匹配，则负载均衡器将选择客户端可支持的最佳证书。根据以下标准，按下面的顺序选择证书：
+ 公有密钥算法 (ECDSA 优先于 RSA)
+ 哈希算法 (SHA 优先于 MD5)
+ 密钥长度 (首选最大值)
+ 有效期
负载均衡器访问日志条目指示客户端指定的主机名和向客户端提供的证书。有关更多信息，请参阅[访问日志条目](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-access-logs.html#access-log-entry-format)。
##### 5.4.1.3 证书续订
每个证书都有有效期限。您必须确保在有效期结束之前续订或替换负载均衡器的每个证书。这包括默认证书和证书列表中的证书。续订或替换证书不影响负载均衡器节点已收到的进行中的请求，并暂停指向正常运行的目标的路由。续订证书之后，新的请求将使用续订后的证书。更换证书之后，新的请求将使用新证书。

您可以按如下方式管理证书续订和替换：
+ 由 AWS Certificate Manager 提供、部署在负载均衡器上的证书可以自动续订。ACM 将尝试在到期之前续订证书。有关更多信息，请参阅 AWS Certificate Manager 用户指南 中的[托管续订](https://docs.amazonaws.cn/acm/latest/userguide/acm-renewal.html)。
+ 如果您将证书导入 ACM，则必须监视证书的到期日期并在到期前续订。有关更多信息，请参阅 AWS Certificate Manager 用户指南 中的[导入证书](https://docs.amazonaws.cn/acm/latest/userguide/import-certificate.html)。
+ 如果您已将证书导入 IAM 中，则必须创建一个新证书，将该新证书导入 ACM 或 IAM 中，将该新证书添加到负载均衡器，并从负载均衡器删除过期的证书。
#### 5.4.2 安全策略
创建 TLS 侦听器时，您必须选择一个安全策略。可以根据需要更新安全策略。有关更多信息，请参阅[更新安全策略](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-certificates.html#update-security-policy)。

您可以选择用于前端连接的安全策略。ELBSecurityPolicy-2016-08 安全策略始终用于后端连接。Network Load Balancer不支持自定义安全策略。

Elastic Load Balancing 为Network Load Balancer提供以下安全策略：
- ELBSecurityPolicy-2016-08 (默认值)
- ELBSecurityPolicy-TLS-1-0-2015-04
- ELBSecurityPolicy-TLS-1-1-2017-01
- ELBSecurityPolicy-TLS-1-2-2017-01
- ELBSecurityPolicy-TLS-1-2-Ext-2018-06
- ELBSecurityPolicy-FS-2018-06
- ELBSecurityPolicy-FS-1-1-2019-08
- ELBSecurityPolicy-FS-1-2-2019-08
- ELBSecurityPolicy-FS-1-2-Res-2019-08
- ELBSecurityPolicy-2015-05（与 ELBSecurityPolicy-2016-08 相同）

我们建议使用 ELBSecurityPolicy-2016-08 策略以确保兼容性。如果您需要向前保密 (FS)，可使用 ELBSecurityPolicy-FS 策略之一。您可以使用 ELBSecurityPolicy-TLS 策略之一，以满足需要禁用特定 TLS 协议版本的合规性和安全标准，或者支持需要已弃用密码的旧客户端。只有一小部分 Internet 客户端需要 TLS 版本 1.0。要查看针对负载均衡器的请求的 TLS 协议版本，请为负载均衡器启用访问日志记录并查看访问日志。有关更多信息，请参阅[访问日志](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/load-balancer-access-logs.html)。

下表描述了默认策略和 ELBSecurityPolicy-TLS 策略。

下表描述了默认策略和 ELBSecurityPolicy-FS 策略。

要使用 AWS CLI 查看负载均衡器的安全策略的配置，请使用 [describe-ssl-policies](https://docs.amazonaws.cn/cli/latest/reference/elbv2/describe-ssl-policies.html) 命令。
### 5,5 更新网络负载均衡器的侦听器
您可以更新侦听器端口、侦听器协议或默认侦听器规则。

默认侦听器规则将请求转发到指定的目标组。

如果您将协议从 TCP 更改为 UDP 或 TLS，则必须指定安全策略和服务器证书。如果您将协议从 TLS 更改为 TCP 或 UDP，则将删除安全策略和服务器证书。

**使用控制台更新侦听器**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 选中该侦听器的复选框，然后选择 Edit (编辑)。
5. （可选）更改 Protocol: port (协议: 端口) 的指定值。
6. （可选）单击铅笔图标来为 Default action (默认操作) 选择不同的目标组。
7. 选择 Update。

**使用 AWS CLI 更新侦听器**

使用 [modify-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/modify-listener.html) 命令。
### 5,6 更新您的 网络负载均衡器 的 TLS 侦听器
创建 TLS 侦听器后，您可以替换默认证书、更新证书列表或替换安全策略。
> **限制** 您无法在网络负载均衡器上安装具有大于 2048 位的 RSA 密钥或 EC 密钥的证书。
#### 5.6.1 替换默认证书
您可以使用以下过程替换 TLS 侦听器的默认证书。有关更多信息，请参阅 默认证书。

**使用控制台更改默认证书**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 选中侦听器对应的复选框，然后选择 Edit (编辑)。
5. 对于 Default SSL certificate (默认 SSL 证书)，请执行下列操作之一：
   + 如果使用 AWS Certificate Manager 创建或导入了证书，请选择 From ACM (来自 ACM) 并选择证书。
   + 如果使用 IAM 上传了证书，则选择 From IAM (来自 IAM) 并选择证书。
6. 选择 Update。

**使用 AWS CLI 更改默认证书**

使用 [modify-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/modify-listener.html) 命令。
#### 5.6.2 将证书添加到证书列表
您可使用以下过程将证书添加到侦听器的证书列表。首次创建 TLS 侦听器时，证书列表为空。可以添加一个或多个证书。您可以选择添加默认证书，以确保此证书与 SNI 协议一起使用，即使它被替换为默认证书也是如此。有关更多信息，请参阅[证书列表](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-tls-listener.html#sni-certificate-list)。

**使用控制台将证书添加到证书列表**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 对于要更新的 HTTPS 侦听器，请选择 View/edit certificates (查看/编辑证书)，这将显示默认证书，后跟已添加到侦听器的任何其他证书。
5. 选择菜单栏中的 Add certificates (添加证书) 图标（加号），这将显示默认证书，后跟由 ACM 和 IAM 管理的任何其他证书。如果已将证书添加到侦听器，则其复选框处于选中和禁用状态。
6. 要添加已由 ACM 或 IAM 管理的证书，请选中证书对应的复选框并选择 Add (添加)。
7. 如果您有一个未由 ACM 或 IAM 管理的证书，则按如下方式将其导入 ACM 中，并将其添加到侦听器：
   + 选择 Import certificate。
   + 对于 Certificate private key，粘贴证书的 PEM 编码的未加密私有密钥。
   + 对于 Certificate body，粘贴 PEM 编码的证书。
   + (可选) 对于 Certificate chain，粘贴 PEM 编码的证书链。
   + 选择 Import。新导入的证书将显示在可用证书列表中并处于选中状态。
   + 选择 Add。
8. 要离开此屏幕，请选择菜单栏中的 Back to the load balancer (返回到负载均衡器) 图标（后退按钮）。

**使用 AWS CLI 将证书添加到证书列表**

使用 [add-listener-certificates 命令](https://docs.amazonaws.cn/cli/latest/reference/elbv2/add-listener-certificates.html)
#### 5.6.3 从证书列表中删除证书
您可以使用以下过程从 TLS 侦听器的证书列表中删除证书。要删除 TLS 侦听器的默认证书，请参阅[替换默认证书](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/listener-update-certificates.html#replace-default-certificate)。

**使用控制台从证书列表中删除证书**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 对于要更新的侦听器，请选择 View/edit certificates (查看/编辑证书)，这将显示默认证书，后跟已添加到侦听器的任何其他证书。
5. 在菜单栏中选择 Remove certificates 图标 (减号)。
6. 选中证书对应的复选框，然后选择 Remove (删除)。
7. 要离开此屏幕，请选择菜单栏中的 Back to the load balancer (返回到负载均衡器) 图标（后退按钮）。

**使用 AWS CLI 从证书列表中删除证书**

使用 [remove-listener-certificates](https://docs.amazonaws.cn/cli/latest/reference/elbv2/remove-listener-certificates.html) 命令。
#### 5.6.4 更新安全策略
在创建 TLS 侦听器时，您可以选择满足您的需求的安全策略。添加新的安全策略后，您可以将 TLS 侦听器更新为使用此新安全策略。Network Load Balancer不支持自定义安全策略。有关更多信息，请参阅[安全策略](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/create-tls-listener.html#describe-ssl-policies)。

**使用控制台更新安全策略**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格上的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。
4. 选中 TLS 侦听器对应的复选框，然后选择 Edit (编辑)。
5. 对于 Security policy (安全策略)，选择安全策略。
6. 选择 Update。

**使用 AWS CLI 更新安全策略**

使用 [modify-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/modify-listener.html) 命令。
### 5.7 删除网络负载均衡器的侦听器
可以随时删除侦听器。

**使用控制台删除侦听器**
1. 打开 Amazon EC2 控制台 https://console.amazonaws.cn/ec2/。
2. 在导航窗格中的 LOAD BALANCING 下，选择 Load Balancers。
3. 选择负载均衡器，然后选择 Listeners。选中侦听器对应的复选框，然后选择 Delete (删除)。
4. 当系统提示进行确认时，选择 Yes, Delete。

**使用 AWS CLI 删除侦听器**

使用 [delete-listener](https://docs.amazonaws.cn/cli/latest/reference/elbv2/delete-listener.html) 命令。
## 6. 目标组
## 7. 监控负载均衡器
## 8. 故障排除
## 9. 配额

## Referece
- [什么是网络负载均衡器](https://docs.amazonaws.cn/elasticloadbalancing/latest/network/introduction.html)