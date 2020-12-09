# Amazon Route 53
## 1. Amazon Route 53 是什么？
Amazon Route 53 是一种具有很高可用性和可扩展性的域名系统 (DNS) Web 服务。您可以使用 Route 53 以任意组合执行三个主要功能：域名注册（domain registration）、DNS 路由（DNS routing）和运行状况检查（health checking）。如果您选择使用 Route 53 来执行所有这三种功能，请按以下顺序执行步骤：
1。注册域名
   您的网站需要一个名称，如 example.com。利用 Route 53 可以为您的网站或 Web 应用程序注册一个名称，称为域名。
   + 有关概述，请参阅[域注册的工作原理](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-domain-registration.html)。
   + 有关步骤，请参阅[注册新域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/domain-register.html)。
   + 有关指导您注册域并在 Amazon S3 存储桶中创建简单网站的教程，请参阅[Amazon Route 53 入门](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/getting-started.html)。
2. 将 Internet 流量路由到您的域的资源
   当用户打开 Web 浏览器并在地址栏中输入您的域名 (example.com) 或子域名 (acme.example.com) 时，Route 53 会帮助将浏览器与您的网站或 Web 应用程序相连接。
   + 有关概述，请参阅[如何将 Internet 流量路由到您的网站或 Web 应用程序](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-dns-service.html)。
   + 有关步骤，请参阅[将 Amazon Route 53 配置为 DNS 服务](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-configuring.html)。
3. 检查资源的运行状况
   Route 53 会通过 Internet 将自动请求发送到资源（如 Web 服务器），以验证其是否可访问、可用且功能正常。您还可以选择在资源变得不可用时接收通知，并可选择将 Internet 流量从运行状况不佳的资源路由到别处。
   + 有关概述，请参阅[Amazon Route 53 如何检查您的资源的运行状况](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-health-checks.html)。
   + 有关步骤，请参阅[创建 Amazon Route 53 运行状况检查和配置 DNS 故障转移](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-failover.html)。
### 1.1 域注册的工作原理
如果要创建网站或 Web 应用程序，请首先注册您的网站的名称，称为[domain name](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-domain-name)。您的域名是用户在浏览器中输入以显示您的网站的名称 (如 example.com)。

以下是如何向 Amazon Route 53 注册域名的概述：
1. 选择一个域名并确认它是可用的，也就是说，没有人已经注册了您想要的域名。

  如果您想要的域名已经在使用，则您可以尝试其他名称，或尝试仅将顶级域 (例如 .com) 更改为另一个顶级域名，如 .ninja 或 .hockey。有关 Route 53 支持的顶级域的列表，请参阅[可在 Amazon Route 53 注册的域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/registrar-tld-list.html)。
2. 向 Route 53 注册域名。注册域时，您可以提供域所有者和其他联系人的姓名和联系信息。

   当您向 Route 53 注册域时，相应服务将会通过执行以下操作自动将其自身设为域的 DNS 服务：
   - 创建与您的域具有相同名称的[hosted zone](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-hosted-zone)。
   - 将一组由四个名称服务器构成的名称服务器组分配给托管区域。当有人使用浏览器访问您的网站时，例如```www.example.com```。这些名称服务器会告诉浏览器在哪里可以找到您的资源，例如Web服务器或 Amazon S3 桶([Amazon S3](https://docs.aws.amazon.com/s3/)是用于存储和检索Web上任意位置的任何量数据的对象存储。存储桶是S3中存储的对象容器。)
   - 从托管区域获取名称服务器，并将其添加到域中。

   有关更多信息，请参阅[如何将 Internet 流量路由到您的网站或 Web 应用程序](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-dns-service.html)。
3. 在注册过程结束时，我们会将您的信息发送给域注册商。[domain registrar](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-domain-registrar)为 Amazon Registrar, Inc. 或我们的注册商合作者 Gandi。要确定您的域的注册商是谁，请参阅[可在 Amazon Route 53 注册的域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/registrar-tld-list.html)。
4. 该注册商会将您的信息发送给域的注册机构。注册机构是销售一个或多个顶级域 (如 .com) 的域注册的公司。
5. 注册机构将有关您的域的信息存储在其自己的数据库中，并将一些信息存储在公共 WHOIS 数据库中。

有关如何注册域名的更多信息，请参阅[注册新域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/domain-register.html)。

如果您已经向另一个注册商注册了域名，则可以选择将该域注册转移到 Route 53。使用其他 Route 53 功能则不需要执行此操作。有关更多信息，请参阅[将域注册转移到 Amazon Route 53](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html)。
### 1.2 如何将 Internet 流量路由到您的网站或 Web 应用程序
Internet 上的所有计算机 (从您的智能手机或笔记本电脑，到为海量零售网站提供内容的服务器)，均通过使用数字相互通信。称为 IP 地址的这些数字采用以下格式之一：
- Internet 协议版本 4 (IPv4) 格式，比如 192.0.2.44
- Internet 协议版本 6 (IPv6) 格式，比如 2001:0db8:85a3:0000:0000:abcd:0001:2345

当您打开浏览器访问某个网站时，您不需要记住并输入像这么长的一串字符。相反，您可以输入像 ```example.com``` 这样的域名，仍然可访问预期的网站。DNS 服务 (如 Amazon Route 53) 有助于在域名和 IP 地址之间建立连接。
#### 有关对 Amazon Route 53 进行配置以路由域 Internet 流量的概述(route internet traffic for your domain)
下面概述了如何使用 Amazon Route 53 控制台来注册域名，以及将 Route 53 配置为将 Internet 流量路由到您的网站或 Web 应用程序。
1. 您注册希望用户用于访问您的内容的域名。有关概述，请参阅[域注册的工作原理](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-domain-registration.html)。
2. 注册您的域名后，Route 53 会自动创建与该域的名称相同的公共托管区域。有关更多信息，请参阅[使用公有托管区域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html)。
3. 要将流量路由到您的资源，请在您的托管区域中创建记录 (也称为资源记录集)。每个记录都包含有关如何要为您的域路由流量的信息，比如：
   + 姓名
     记录的名称对应于您希望 Route 53 对其路由流量的域名 (example.com) 或子域名 (www.example.com、retail.example.com)。

     托管区域中每个记录的名称必须以托管区域的名称结尾。例如，如果托管区域的名称为 example.com，则所有记录名称均必须以 example.com 结尾。Route 53 控制台会为您自动执行此操作。
   + Type
     记录类型通常决定了您希望流量路由到的资源的类型。例如，要将流量路由到电子邮件服务器，请将“Type”指定为“MX”。要将流量路由到具有 IPv4 IP 地址的 Web 服务器，请将“Type”指定为“A”。
   + Value
     “Value”与“Type”密切相关。如果您将“Type”指定为“MX”，则对“Value”指定一个或多个电子邮件服务器的名称。如果您将“Type”指定为“A”，则指定 IPv4 格式的 IP 地址，比如 192.0.2.136。

有关记录的更多信息，请参阅[使用记录](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/rrsets-working-with.html)。

您还可以创建特殊的 Route 53 记录（称为别名记录），这些记录会将流量路由到 Amazon S3 存储桶、Amazon CloudFront 分配和其他 AWS 资源。有关更多信息，请参阅[在别名记录和非别名记录之间进行选择](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html)和[将 Internet 流量路由到您的 AWS 资源](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/routing-to-aws-resources.html)。

有关将 Internet 流量路由到您的资源的更多信息，请参阅[将 Amazon Route 53 配置为 DNS 服务](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-configuring.html)。
#### Amazon Route 53 如何为您的域路由流量
在您将 Amazon Route 53 配置为将 Internet 流量路由到您的资源（比如 Web 服务器或 Amazon S3 存储桶）之后，当有人请求 www.example.com 的内容时，将在短短几毫秒内发生以下情况：

![How Route53 route traffic](images/how-route-53-routes-traffic.png)

1. 用户打开 Web 浏览器并在地址栏中输入 `www.example.com`，然后按 Enter。
2. 将对 `www.example.com` 的请求路由到 DNS 解析程序，该解析程序通常由用户的 Internet 服务提供商 (ISP) (比如有线 Internet 提供商、DSL 宽带提供商或企业网络) 进行管理。
3. ISP 的 DNS 解析程序将对 www.example.com 的请求转发到 DNS 根名称服务器。
4. DNS 解析程序将再次转发对 www.example.com 的请求，而这次会转发到 .com 域的其中一个 TLD 名称服务器。.com 域的名称服务器使用与 example.com 域关联的四个 Route 53 名称服务器的名称来响应该请求。

  DNS 解析程序会缓存 (存储) 四个 Route 53 名称服务器。下次有人浏览到 example.com 时，解析程序将跳过步骤 3 和 4，因为它已缓存了 example.com 的名称服务器。名称服务器通常缓存时长为两天。
5. DNS 解析程序选择一个 Route 53 名称服务器，并将对 www.example.com 的请求转发到该名称服务器。
6. Route 53 名称服务器在 example.com 托管区域中查找 www.example.com 记录、获取关联值 (比如 Web 服务器的 IP 地址 192.0.2.44)，并将该 IP 地址返回到 DNS 解析程序。
7. DNS 解析程序最终将获得用户所需的 IP 地址。解析程序将该值返回给 Web 浏览器。
   > **注意**：DNS 解析程序还会将 example.com 的 IP 地址缓存您指定的一段时间，以便在下次有人浏览到 example.com 时，它可以更快地做出响应。有关更多信息，请参阅[time to live (TTL)](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-time-to-live)。

8. Web 浏览器将对 www.example.com 的请求发送到它从 DNS 解析程序那里获得的 IP 地址。这是您的内容所在的位置，例如，在 Amazon EC2 实例上运行的 Web 服务器，或配置为网站终端节点的 Amazon S3 存储桶。
9. 192.0.2.44 上的 Web 服务器或其他资源将 www.example.com 的网页返回到 Web 浏览器，而 Web 浏览器会显示该页面。
### 1.3 Amazon Route 53 如何检查您的资源的运行状况
Amazon Route 53 运行状况检查可监控您的资源 (如 Web 服务器和电子邮件服务器) 的运行状况。您可以选择为运行状况检查配置 Amazon CloudWatch 警报，以便在资源变得不可用时收到通知。

如果您希望在资源变得不可用时收到通知，下面概述了运行状况检查的工作原理：

![How Route53 Health Check](images/how-health-checks-work.png)

1. 您创建运行状况检查，并指定用于定义您希望运行状况检查如何工作的值，例如：
   - 您希望 Route 53 监控的终端节点 (如 Web 服务器) 的 IP 地址或域名。(您还可以监控其他运行状况检查的状态或 CloudWatch 警报的状态。)
   - 您想要的协议 Amazon Route 53 用于执行检查: HTTP、HTTPS或TCP。
   - 您希望 Route 53 向终端节点发送请求的频率，也就是请求时间间隔。
   - 在 Route 53 认为终端节点运行状况不佳之前，终端节点必须尝试响应请求的连续次数，也就是失败阈值。
   - (可选) 当 Route 53 检测到终端节点运行状况不佳时，您希望接收通知的方式。当您配置通知时，Route 53 会自动设置 CloudWatch 警报。CloudWatch 使用 Amazon SNS 通知用户终端节点运行状况不佳。
2. Route 53 开始以您在运行状况检查中指定的时间间隔向终端节点发送请求。
   如果终端节点响应请求，则 Route 53 会认为终端节点运行状况良好，因此不会采取任何措施。
3. 如果终端节点没有响应请求，则 Route 53 会开始计算终端节点未响应的连续请求的计数：
   - 如果计数达到为失败阈值指定的值，则 Route 53 会认为终端节点运行状况不佳。
   - 如果在计数达到失败阈值之前终端节点开始再次响应，则 Route 53 会将计数重置为 0，而 CloudWatch 不会与您联系。
4. 如果 Route 53 认为终端节点运行状况不佳，并且您配置了运行状况检查通知，则 Route 53 会通知 CloudWatch。
   如果您没有配置通知，则仍然可以在 Route 53 控制台中看到 Route 53 运行状况检查的状态。有关更多信息，请参阅[监控运行状况检查状态和获取通知](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/health-checks-monitor-view-status.html)。
5. 如果您配置了运行状况检查通知，则 CloudWatch 会触发警报，并使用 Amazon SNS 向指定收件人发送通知。

除了检查指定终端节点的运行状况之外，您还可以将运行状况检查配置为检查一个或多个其他运行状况检查的运行状况，以便在指定数量的资源 (如五个 Web 服务器中的两个) 不可用时收到通知。您还可以将运行状况检查配置为检查 CloudWatch 警报的状态，以便您可以根据广泛的标准收到通知，而不仅仅限于资源是否响应请求。

如果您有执行相同功能的多个资源 (例如 Web 服务器或数据库服务器)，并且您希望 Route 53 仅将流量路由到运行状况良好的资源，则可以通过将运行状况检查与相应资源的每个记录相关联，来配置 DNS 故障转移。如果运行状况检查确定基础资源运行状况不佳，则 Route 53 会将流量从相关联的记录路由到别处。

有关使用 Route 53 监控资源运行状况的更多信息，请参阅[创建 Amazon Route 53 运行状况检查和配置 DNS 故障转移](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-failover.html)。
### 1.4 Amazon Route 53 概念
#### 域注册概念
- **域名**（domain name）
  用户在 Web 浏览器的地址栏中键入的名称 (比如 example.com)，用于访问某个网站或 Web 应用程序。要使您的网站或 Web 应用程序在 Internet 上可用，您首先要注册一个域名。有关更多信息，请参阅[域注册的工作原理](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-domain-registration.html)。
- **域注册商**（domain registrar）
  经 Internet 名称和数字地址分配机构 (ICANN) 认可的公司，旨在处理特定顶级域 (TLD) 的域注册。例如，Amazon Registrar, Inc. 是 .com、.net 和 .org 域的域注册商。我们的注册商合作者 Gandi 是数百个 TLD (比如 .apartments、.boutique 和 .camera) 的域注册商。有关更多信息，请参阅[可在 Amazon Route 53 注册的域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/registrar-tld-list.html)。
- **域注册机构**（domain registry）
  有权销售具有一个特定顶级域的域的公司。例如，[VeriSign](http://www.verisign.com/) 是有权销售具有一个 .com TLD 的域的注册机构。域注册机构可定义注册域的规则，比如地理 TLD 的住所要求。域注册机构还会维护具有相同 TLD 的所有域名的权威数据库。注册机构的数据库中包含一些信息，比如每个域的联系人信息和名称服务器等。
- **域经销商**（domain reseller）
  出售注册商（比如 Amazon Registrar）的域名的公司。Amazon Route 53 是 Amazon Registrar 和我们的注册商合作者 Gandi 的域经销商。
- **顶级域 (TLD)**（top-level domain (TLD)）
  域名的最后一部分，比如 .com、.org 或 .ninja。有两种类型的顶级域：
  + 通用顶级域
    这些 TLD 通常会让用户知道他们能够在相应网站上找到什么内容。例如，具有 TLD .bike 的域名通常与摩托车或自行车企业或组织的网站有关。除了少数例外情况外，您可以使用任何您想要的通用 TLD，因此自行车俱乐部可将 .hockey TLD 用于其域名。
  + 地理顶级域
    这些 TLD 与地理区域 (如国家/地区或城市) 相关。有些地理 TLD 注册机构具有住所要求，而有些地理 TLD 注册机构 (比如 .io（英属印度洋领地）) 则允许甚至鼓励将其用作通用 TLD。

  有关向 Route 53 注册域名时可以使用的 TLD 的列表，请参阅[可在 Amazon Route 53 注册的域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/registrar-tld-list.html)。
#### 域名系统 (DNS) 概念
- **别名记录**（alias record）
  您可以使用 Amazon Route 53 创建的一种记录，用于将流量路由到 AWS 资源（如 Amazon CloudFront 分配和 Amazon S3 存储桶）。有关更多信息，请参阅[在别名记录和非别名记录之间进行选择](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html)。
- **权威名称服务器**（authoritative name server）
  一个名称服务器，该名称服务器具有关于域名系统 (DNS) 的一部分的明确信息，并通过返回适用的信息响应来自 DNS 解析程序的请求。例如，.com 顶级域 (TLD) 的权威名称服务器知道每个已注册 .com 域的名称服务器的名称。当 .com 权威名称服务器收到来自 example.com 的 DNS 解析程序的请求时，它会使用 example.com 域的 DNS 服务的名称服务器的名称进行响应。

  Route 53 名称服务器是将 Route 53 用作 DNS 服务的每个域的权威名称服务器。这些名称服务器知道，您希望如何基于您在域的托管区域中创建的记录来路由您的域和子域的流量。（Route 53 名称服务器可存储将 Route 53 用作 DNS 服务的域的托管区域。）

  例如，如果 Route 53 名称服务器收到对 www.example.com 的请求，它将找到该记录并返回记录中指定的 IP 地址 (如 192.0.2.33)。
- **DNS 查询**（DNS query）
  通常为由某个设备 (比如计算机或智能手机) 向与某域名关联的资源的域名系统 (DNS) 提交的请求。DNS 查询最常见的示例是，用户打开浏览器并在地址栏中键入域名。对 DNS 查询的响应通常是与诸如 Web 服务器之类的资源相关联的 IP 地址。发出请求的设备使用该 IP 地址与资源进行通信。例如，浏览器可以使用该 IP 地址从 Web 服务器中获取某个网页。
- **DNS 解析程序**（DNS resolver）
  通常由 Internet 服务提供商 (ISP) 管理的 DNS 服务器，充当用户请求与 DNS 名称服务器之间的中介。当您打开浏览器并在地址栏中输入域名时，您的查询将首先发送到 DNS 解析程序。该解析程序会与 DNS 名称服务器通信，以获取相应资源 (比如 Web 服务器) 的 IP 地址。DNS 解析程序也称为递归名称服务器，因为它会将请求发送到一系列权威 DNS 名称服务器，直到它获得返回到用户设备 (例如，笔记本电脑上的 Web 浏览器) 的响应 (通常为 IP 地址)。
- **域名系统 (DNS)**（Domain Name System (DNS)）
  一个全球服务器网络，可帮助计算机、智能手机、平板电脑和其他已启用 IP 的设备之间相互通信。域名系统会将容易理解的名称 (例如 example.com) 转换为数字，这些数字称为 IP 地址，允许计算机在 Internet 上相互找到对方。

  另请参阅[IP address](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-ip-address)。
- **托管区域**（hosted zone）
  一个记录容器，其中包含有关您希望如何路由域 (比如 example.com) 及其所有子域 (比如 www.example.com、retail.example.com 和 seattle.accounting.example.com) 的流量的信息。托管区域具有与相应域相同的名称。

  例如，example.com 的托管区域可能包括如下两个记录：一个记录具有关于将 www.example.com 的流量路由到 IP 地址为 192.0.2.243 的 Web 服务器的信息；另一个记录具有关于将 example.com 的电子邮件路由到两个电子邮件服务器 (mail1.example.com 和 mail2.example.com) 的信息。每个电子邮件服务器还需要自己的记录。

  另请参阅[record (DNS record)](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-resource-record-set)。
- **IP 地址**（IP address）
  分配给 Internet 上某个设备（例如笔记本电脑、智能手机或 Web 服务器）的一个数字，允许该设备与 Internet 上的其他设备进行通信。IP 地址采用以下格式之一：
  + Internet 协议版本 4 (IPv4) 格式，比如 192.0.2.44
  + Internet 协议版本 6 (IPv6) 格式，比如 2001:0db8:85a3:0000:0000:abcd:0001:2345

  Route 53 支持 IPv4 和 IPv6 地址，以用于以下用途：
  + 您可以创建类型为 A (针对 IPv4 地址) 或类型为 AAAA (针对 IPv6 地址) 的记录。
  + 您可以创建将请求发送到 IPv4 或 IPv6 地址的运行状况检查。
  + 如果 DNS 解析程序在 IPv6 网络上，则它可以使用 IPv4 或 IPv6 向 Route 53 提交请求。
- **名称服务器**（name servers）
  域名系统 (DNS) 中的服务器，可帮助将域名转换为计算机用于彼此相互通信的 IP 地址。名称服务器为递归名称服务器 (也称为 DNS resolver) 或authoritative name server。

  有关 DNS 如何将流量路由到您的资源的概述（包括 Route 53 在此过程中的作用），请参阅[Amazon Route 53 如何为您的域路由流量](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/welcome-dns-service.html#welcome-dns-service-how-route-53-routes-traffic)。
- **私有 DNS**（private DNS）
  域名系统 (DNS) 的本地版本，允许您将域及其子域的流量路由到一个或多个 Amazon Virtual Private Cloud (VPC) 内的 Amazon EC2 实例。有关更多信息，请参阅[使用私有托管区域](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/hosted-zones-private.html)。
- **记录 (DNS 记录)**（record (DNS record)）
  托管区域中的一个对象，用于定义您要如何路由域或子域的流量。例如，您可以为 example.com 和 www.example.com 创建记录，将流量路由到 IP 地址为 192.0.2.234 的 Web 服务器。

  有关记录的更多信息（包括有关由特定于 Route 53 的记录所提供功能的信息），请参阅将[Amazon Route 53 配置为 DNS 服务](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-configuring.html)。
- **递归名称服务器**（recursive name server）
  请参阅[DNS resolver](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/route-53-concepts.html#route-53-concepts-dns-resolver)。
- **可重用的委派集**（reusable delegation set）
  一组可用于多个托管区域的四个权威名称服务器。默认情况下，Route 53 会将随机选择的名称服务器分配给每个新的托管区域。为了更轻松地将大量域的 DNS 服务迁移到 Route 53，您可以创建可重用委派集，然后将可重用委派集与新的托管区域相关联。(您无法更改与现有托管区域相关联的名称服务器。)

  创建一个可重用委派集，并以编程方式将其与托管区域相关联；不支持使用 Route 53 控制台。有关更多信息，请参阅 https://docs.aws.amazon.com/Route53/latest/APIReference/API_CreateHostedZone.html中的 CreateHostedZone 和 Amazon Route 53 API ReferenceCreateReusableDelegationSet。[AWS 开发工具包](https://docs.aws.amazon.com/)、[AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/reference/route53/index.html)和[适用于 Windows PowerShell 的 AWS 工具](https://docs.aws.amazon.com/powershell/latest/reference/)中也提供了相同的功能。
- **路由策略**（routing policy）
  用于确定 Route 53 如何响应 DNS 查询的记录设置。Route 53 支持以下路由策略：
  + **简单路由策略** – 用于将 Internet 流量路由到为您的域执行给定功能的单一资源（例如，为 example.com 网站提供内容的 Web 服务器）。
  + **故障转移路由策略** – 如果您想要配置主动-被动故障转移，则可以使用该策略。
  + **地理位置路由策略** – 用于根据用户的位置将 Internet 流量路由到您的资源。
  + **地理位置临近度路由策略** – 用于根据资源的位置来路由流量，以及（可选）将流量从一个位置中的资源转移到另一个位置中的资源。
  + **延迟路由策略** – 如果您的资源位于多个位置，并且您想要将流量路由到提供最佳延迟的资源，则可以使用该策略。
  + **多值应答路由策略** – 如果您想要让 Route 53 用随机选择的正常记录（最多八条）响应 DNS 查询，则可以使用该策略。
  + **加权路由策略** – 用于按照您指定的比例将流量路由到多个资源。

  有关更多信息，请参阅[选择路由策略](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/routing-policy.html)。
- **子域**（subdomain）
  一个域名，该域名拥有添加到已注册域名前面的一个或多个标签。例如，如果您注册了域名 example.com，则 www.example.com 为子域。如果您为 example.com 域创建了托管区域 accounting.example.com，则 seattle.accounting.example.com 为子域。

  要为子域路由流量，请创建一个具有所需名称 (如 www.example.com) 的记录，并指定适用的值，例如 Web 服务器的 IP 地址。
- **生存时间 (TTL)**（time to live (TTL)）
  在向 Route 53 提交另一个请求以获取记录的当前值之前，您希望 DNS 解析程序缓存 (存储) 该记录的值的时间量 (以秒为单位)。如果 DNS 解析程序在 TTL 到期之前收到对同一个域的另一个请求，则该解析程序将返回缓存的值。

  较长的 TTL 会降低您的 Route 53 费用，这一点部分取决于 Route 53 响应的 DNS 查询的数量。在更改记录中的值 (例如通过更改 www.example.com 的 Web 服务器的 IP 地址) 后，较短的 TTL 会缩短 DNS 解析程序将流量路由到较旧资源的时间量。
#### 运行状况检查概念
- **DNS 故障转移**（DNS failover）
  将流量从运行状况不佳的资源路由到运行状况良好的资源的一种方法。当您有多个资源（例如，多个 Web 服务器或邮件服务器）执行同一功能时，可以将 Route 53 运行状况检查配置为检查您的资源的运行状况，并在您的托管区域中配置记录，以便仅将流量路由到运行状况良好的资源。

  有关更多信息，请参阅[配置 DNS 故障转移](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-failover-configuring.html)。

- **endpoint**
  您将运行状况检查配置为监控其运行状况的资源 (比如 Web 服务器或电子邮件服务器)。您可以通过 IPv4 地址 (192.0.2.243)、IPv6 地址 (2001:0db8:85a3:0000:0000:abcd:0001:2345) 或通过域名 (example.com) 指定终端节点。

  > **注意** 您还可以创建运行状况检查，以监控其他运行状况检查的状态，或监控 CloudWatch 警报的警报状态。
- **运行状况检查**（health check）
  一个 Route 53 组件，让您可以执行以下操作：
  - 监控指定终端节点 (比如 Web 服务器) 的运行状况是否良好
  - (可选) 当某个终端节点运行状况不佳时收到通知
  - (可选) 配置 DNS 故障转移，从而让您可以将 Internet 流量从运行状况不佳的资源重新路由到运行状况良好的资源

  有关如何创建和使用运行状况检查的更多信息，请参阅[创建 Amazon Route 53 运行状况检查和配置 DNS 故障转移](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/dns-failover.html)。
### 1.5 如何开始使用 Amazon Route 53
有关 Amazon Route 53 入门的信息，请参阅本指南中的以下主题：
- [设置 Amazon Route 53](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/setting-up-route-53.html)，其中说明了如何注册 AWS、如何安全地访问您的 AWS 账户，以及如何设置 Route 53 的编程访问
- [Amazon Route 53 入门](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/getting-started.html)，其中阐述了如何注册域名、如何创建 Amazon S3 存储桶并将其配置为托管静态网站，以及如何将 Internet 流量路由到网站
### 1.6 相关服务
有关 Amazon Route 53 所集成的 AWS 服务的信息，请参阅[与其他服务集成](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/integration-with-other-services.html)。
### 1.7 访问Amazon Route 53
您可以通过下列方式访问 Amazon Route 53：
- AWS 管理控制台 – 该指南中的过程介绍了如何使用 AWS 管理控制台执行任务。
- AWS 开发工具包 – 如果使用 AWS 提供了开发工具包的编程语言，您可以使用开发工具包访问 Route 53。开发工具包可简化身份验证，与开发环境轻松集成，并有助于轻松访问 Route 53 命令。有关 更多信息，请参阅适用于 [Amazon Web Services 的工具](https://aws.amazon.com/tools)。
- Route 53 API – 如果要使用开发工具包不可用的编程语言，请参阅 [Amazon Route 53 API Reference](https://docs.aws.amazon.com/Route53/latest/APIReference/) 以了解有关 API 操作及如何发出 API 请求的信息。
- AWS Command Line Interface – 有关更多信息,请参阅[准备 AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/) 在 AWS Command Line Interface 用户指南.
- 适用于 Windows PowerShell 的 AWS 工具 – 有关更多信息，请参阅[适用于 Windows PowerShell 的 AWS 工具](https://docs.aws.amazon.com/powershell/latest/userguide/)中的设置适用于 Windows PowerShell 的 AWS 工具 用户指南。
### 1.8 AWS Identity and Access Management
Amazon Route 53 与 AWS Identity and Access Management (IAM) 集成，后者是让您可以执行以下操作的服务：
- Create users and groups under your organization's AWS account
- 轻松地在账户中的用户间共享您的 AWS 账户资源
- 为每个用户分配具有唯一性的安全凭证
- 精确地控制用户访问服务和资源的权限

例如，您可以将 IAM 与 Route 53 结合使用，以控制您的 AWS 账户中的哪些用户可以创建新的托管区域或更改记录。

有关 IAM 的一般信息，请参阅以下内容：
- [Amazon Route 53 中的 Identity and access management](https://docs.aws.amazon.com/zh_cn/Route53/latest/DeveloperGuide/auth-and-access-control.html)
- [Identity and Access Management (IAM)](https://aws.amazon.com/iam/)
- [IAM 用户指南](https://docs.aws.amazon.com/IAM/latest/UserGuide/)
### 1.9 Amazon Route 53 定价和计费
与其他 AWS 产品一样，在使用 Amazon Route 53 时，您无需签订合同或承诺最低使用量。您只需为您配置的托管区域和 Route 53 响应的 DNS 查询数量付费。有关更多信息，请参阅[Amazon Route 53 定价](https://aws.amazon.com/route53/pricing/)。

有关 AWS 服务账单的信息，包括如何查看账单和管理账户与付款，请参阅[AWS Billing and Cost Management 用户指南](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/)。
## 2. 设置
## 3. 入门
## 4. 与其他服务集成
## 5. DNS 域名格式
## 6. 注册域名
## 7. 将 Amazon Route 53 配置为 DNS 服务
## 8. 解析 VPC 与您的网络之间的 DNS 查询
## 9. 将 Internet 流量路由到您的 AWS 资源
## 10. 创建 运行状况检查和配置 DNS 故障转移
## 11. 安全性
## 12. Monitoring
## 13. 问题排查
## 14. IP 地址范围
## 15. 为资源添加标签
## 16. Tutorials

## Reference
- [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)