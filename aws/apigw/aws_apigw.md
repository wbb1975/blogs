# Amazon API Gateway
## 1. 什么是 Amazon API Gateway？
Amazon API Gateway 是一项 AWS 服务，用于创建、发布、维护、监控和保护任意规模的 REST、HTTP 和 WebSocket API。API 开发人员可以创建能够访问 AWS、其他 Web 服务以及存储在 [AWS 云](http://aws.amazon.com/what-is-cloud-computing/)中的数据的 API。作为 API Gateway API 开发人员，您可以创建 API 以在您自己的客户端应用程序中使用。或者，您可以将您的 API 提供给第三方应用程序开发人员。有关更多信息，请参阅[谁使用 API Gateway？](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-overview-developer-experience.html#apigateway-who-uses-api-gateway)。

API Gateway 创建符合下列条件的 RESTful API：
- 基于 HTTP 的。
- 启用无状态客户端-服务器通信。
- 实施标准 HTTP 方法例，如 GET、POST、PUT、PATCH 和 DELETE。

有关 API Gateway REST API 和 HTTP API 的更多信息，请参阅[在 HTTP API 和 REST API 之间进行选择](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/http-api-vs-rest.html)、使用 [HTTP API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/http-api.html)、[使用 API Gateway 创建 REST API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-overview-developer-experience.html#api-gateway-overview-rest) 和[在 Amazon API Gateway 中创建 REST API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/how-to-create-api.html)。

API Gateway 创建以下 WebSocket API：
- 遵守 [WebSocket](https://tools.ietf.org/html/rfc6455) 协议，从而支持客户端和服务器之间的有状态的全双工通信。
- 基于消息内容路由传入的消息。

有关 API Gateway WebSocket API 的更多信息，请参阅[使用 API Gateway 创建 WebSocket API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-overview-developer-experience.html#api-gateway-overview-websocket)和[关于 API Gateway 中的 WebSocket API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-websocket-api-overview.html)。

**API Gateway 的架构**

![ API Gateway 架构](images/Product-Page-Diagram_Amazon-API-Gateway-How-Works.png)

此图表说明您在 Amazon API Gateway 中构建的 API 如何为您或开发人员客户提供用于构建 AWS 无服务器应用程序的集成且一致的开发人员体验。API Gateway 将处理涉及接受和处理多达几十万个并发 API 调用的所有任务。这些任务包括流量管理、授权和访问控制、监控以及 API 版本管理。

API Gateway 充当应用程序从后端服务访问数据、业务逻辑或功能的“前门”，例如，在 Amazon Elastic Compute Cloud (Amazon EC2) 上运行的负载、在 AWS Lambda 上运行的代码、任何 Web 应用程序或实时通信应用程序。

**API Gateway 的功能**
- 支持有状态 ([WebSocket](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-websocket-api.html)) 和无状态（[HTTP](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/http-api.html) 和 [REST](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-rest-api.html)）API。
- 功能强大、灵活的身份验证机制，例如 AWS Identity and Access Management 策略、Lambda 授权方函数以及 Amazon Cognito 用户池。
- 用于发布您的 API 的[开发人员门户](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-developer-portal.html)。
- 用以安全地推出更改的[金丝雀版本部署](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/canary-release.html)。
- [CloudTrail](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/cloudtrail.html) 记录和监控 API 使用情况和 API 更改。
- CloudWatch 访问日志记录和执行日志记录，包括设置警报的能力。有关更多信息，请参阅[使用 Amazon CloudWatch 指标监控 REST API 执行](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/monitoring-cloudwatch.html) 和[使用 CloudWatch 指标监控 WebSocket API 执行](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-websocket-api-logging.html)。
- 能够使用 AWS CloudFormation 模板来启用 API 创建。有关更多信息，请参阅[Amazon API Gateway 资源类型参考](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-reference-apigateway.html)和[Amazon API Gateway V2 资源类型参考](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-reference-apigatewayv2.html)。
- 支持自定义域名。
- 与 [AWS WAF](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-control-access-aws-waf.html) 集成，以保护您的 API 免遭常见 Web 漏洞的攻击。
- 与 [AWS X-Ray](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-xray.html) 集成，以了解性能延迟和对其进行分类。

有关 API Gateway 功能版本的完整列表，请参阅[文档历史记录](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/history.html)。

**访问 API Gateway**
- **AWS 管理控制台** – 本指南中的过程阐述如何使用 AWS 管理控制台执行任务。
- **AWS 开发工具包** – 如果您使用 AWS 为其提供开发工具包的编程语言，您可以使用开发工具包访问 API Gateway。开发工具包可简化身份验证、与您的开发环境轻松集成，并有助于访问 API Gateway 命令。有关更多信息，请参阅用于[Amazon Web Services 的工具](http://aws.amazon.com/tools)。
- **API Gateway V1 和 V2 API** – 如果您使用的是开发工具包不适用的编程语言，请参阅 [Amazon API Gateway 版本 1 API 参考](https://docs.aws.amazon.com/apigateway/api-reference/)和 [Amazon API Gateway 版本 2 API 参考](https://docs.aws.amazon.com/apigatewayv2/latest/api-reference/api-reference.html)。
- **AWS 命令行界面** – 有关更多信息，请参阅《AWS 命令行界面用户指南》中的[开始使用 AWS 命令行界面](https://docs.aws.amazon.com/cli/latest/userguide/)。
- **AWS Tools for Windows PowerShell** – 有关更多信息，请参阅《AWS Tools for Windows PowerShell 用户指南》中的[设置 AWS Tools for Windows PowerShell](https://docs.aws.amazon.com/powershell/latest/userguide/)。

**AWS 无服务器基础设施的一部分**
API Gateway 与 AWS Lambda 一起构成了 AWS 无服务器基础设施中面向应用程序的部分。

对于调用公开的 AWS 服务的应用程序，您可以使用 Lambda 与所需的服务交互，并通过 API Gateway 中的 API 方法来使用 Lambda 函数。AWS Lambda 在高可用性计算基础设施上运行代码。它会进行必要的计算资源执行和管理工作。为了启用无服务器应用程序，API Gateway 支持与 AWS Lambda 和 HTTP 终端节点进行[简化的代理集成](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html)。
### 1.1 API Gateway 使用案例
#### 1.1.1 使用 API Gateway 创建 HTTP API
使用 HTTP API，您可以创建比 REST API 具有更低延迟和更低成本的 RESTful API。

您可以使用 HTTP API 向 AWS Lambda 函数或任何可公开路由的 HTTP 终端节点发送请求。

例如，您可以创建一个与后端上的 Lambda 函数集成的 HTTP API。当客户端调用您的 API 时，API Gateway 将请求发送到 Lambda 函数并将该函数的响应返回给客户端。

HTTP API 支持 [OpenID Connect](https://openid.net/connect/) 和 [OAuth 2.0](https://oauth.net/2/) 授权。它们内置了对跨域资源共享 (CORS) 和自动部署的支持。

要了解更多信息，请参阅“[在 HTTP API 和 REST API 之间进行选择](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/http-api-vs-rest.html)”。
#### 1.1.2 使用 API Gateway 创建 REST API
API Gateway REST API 由资源和方法组成。资源是一种逻辑实体，应用程序可以通过资源路径来访问资源。方法与您的 API 用户提交的 REST API 请求以及返回给该用户的相应响应对应。

例如，/incomes 可以是代表应用程序用户收入的资源路径。一个资源可以包含一个或多个由适当的 HTTP 动词 (如 GET、POST、PUT、PATCH 和 DELETE) 定义的操作。资源路径和操作的组合构成 API 的方法。例如，POST /incomes 方法可以添加调用方获得的收入，GET /expenses 方法可以查询报告的调用方支出。

应用程序不需要知道在后端所请求数据的存储位置和提取位置。在 API Gateway REST API 中，前端由方法请求 和方法响应 封装。API 通过集成请求和集成响应与后端连接。

例如，使用 DynamoDB 作为后端，API 开发人员会设置集成请求以便将传入方法请求转发到所选的后端。该设置包括适当 DynamoDB 操作的规范、所需的 IAM 角色和策略以及所需的输入数据转换。后端将结果作为集成响应返回到 API Gateway。

要将与指定 HTTP 状态代码的适当方法响应对应的集成响应路由到客户端，您可以配置集成响应，将所需的响应参数从集成映射到方法。然后，您可以根据需要将后端的输出数据格式转换为前端的输出数据格式。API Gateway 让您能够为负载定义一个架构或模型，以方便设置正文映射模板。

API Gateway 提供 REST API 管理功能，如下所示：
- 支持使用 API Gateway 对 OpenAPI 的扩展生成开发工具包和创建 API 文档
- HTTP 请求的限制
#### 1.1.3 使用 API Gateway 创建 WebSocket API
在 WebSocket API 中，客户端和服务器都可以随时相互发送消息。后端服务器可以轻松地将数据推送到连接的用户和设备，从而无需实施复杂的轮询机制。

例如，您可以使用 API Gateway WebSocket API 和 AWS Lambda 来构建无服务器应用程序，以便在聊天室中向个人用户或用户组发送消息以及从个人用户或用户组接收消息。或者，您可以根据消息内容调用后端服务，例如 AWS Lambda、Amazon Kinesis 或 HTTP 终端节点。

您可以使用 API Gateway WebSocket API 来构建安全的实时通信应用程序，而无需预置或管理任何服务器来管理连接或大规模数据交换。目标使用案例包括实时应用程序，如下所示：
- 聊天应用程序
- 实时控制面板，如股票代码
- 实时提醒和通知

API Gateway 提供 WebSocket API 管理功能，如下所示：
- 连接和消息的监控和限制
- 使用 AWS X-Ray 在消息经由 API 传递到后端服务时跟踪消息
- 易于与 HTTP/HTTPS 终端节点集成
#### 1.1.4 谁使用 API Gateway？
使用 API Gateway 的开发人员有两种：API 开发人员和应用程序开发人员。

API 开发人员创建和部署 API，以便启用 API Gateway 中所需的功能。API 开发人员必须是拥有 API 的 AWS 账户中的 IAM 用户。

应用程序开发人员通过在 API Gateway 中调用由 API 开发人员创建的 WebSocket 或 REST API 来构建一个正常运行的应用程序以调用 AWS 服务。

应用程序开发人员是 API 开发人员的客户。应用程序开发人员不需要拥有 AWS 账户，前提是 API 不需要 IAM 权限或通过[Amazon Cognito 用户池联合身份](https://docs.aws.amazon.com/cognito/latest/developerguide/)所支持的第三方联合身份提供商来支持用户授权。此类身份提供商包括 Amazon、Amazon Cognito 用户池、Facebook 和 Google。

**创建和管理 API Gateway API**
API 开发人员使用名为 apigateway 的用于 API 管理的 API Gateway 服务组件来创建、配置和部署 API。

作为 API 开发人员，您可以按照[开始使用 Amazon API Gateway](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/getting-started.html)中所述使用 API Gateway 控制台或者通过调用 API 参考 来创建和管理 API。这一 API 有若干种调用方式。其中包括使用 AWS 命令行界面 (AWS CLI)，或者使用 AWS 开发工具包。此外，还可以使用 [AWS CloudFormation 模板](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html)或（在 REST API 和 HTTP API 的情况下）[使用基于 OpenAPI 的 API Gateway 扩展](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-swagger-extensions.html)启用 API 创建。

有关提供 API Gateway 的区域以及相关控制服务终端节点的列表，请参阅[Amazon API Gateway 终端节点和配额](https://docs.aws.amazon.com/general/latest/gr/apigateway.html)。

**调用 API Gateway API**
应用程序开发人员使用名为 execute-api 的用于 API 执行的 API Gateway 服务组件来调用在 API Gateway 中创建或部署的 API。底层编程实体由创建的 API 公开。此类 API 有若干种调用方式。要了解更多信息，请参阅[在 Amazon API Gateway 中调用 REST API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/how-to-call-api.html)和[调用 WebSocket API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-how-to-call-websocket-api.html)。
### 1.2 API Gateway 概念
- **API Gateway**
   API Gateway 是一项 AWS 服务，支持以下操作：
   + 创建、部署和管理 [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) 应用程序编程接口 (API) 以便使用后端 HTTP 终端节点、AWS Lambda 函数或其他 AWS 服务。
   + 创建、部署和管理 [WebSocket](https://tools.ietf.org/html/rfc6455) API 以公开 AWS Lambda 函数或其他 AWS 服务。
   + 通过前端 HTTP 和 WebSocket 终端节点调用公开的 API 方法。
- **API Gateway REST API**
   与后端 HTTP 终端节点、Lambda 函数或其他 AWS 服务集成的 HTTP 资源与方法的集合。您可以在一个或多个阶段部署此集合。通常情况下，根据应用程序逻辑将 API 资源组织成资源树形式。每个 API 资源均可公开一个或多个 API 方法，这些方法具有受 API Gateway 支持的唯一 HTTP 命令动词。
- **API Gateway HTTP API**
  与后端 HTTP 终端节点或 Lambda 函数集成的路由和方法的集合。您可以在一个或多个阶段部署此集合。每个路由均可公开一个或多个 API 方法，这些方法具有受 API Gateway 支持的唯一 HTTP 命令动词。
- **API Gateway WebSocket API**
  与后端 HTTP 终端节点、Lambda 函数或其他 AWS 服务集成的 WebSocket 路由和路由键的集合。您可以在一个或多个阶段部署此集合。API 方法通过可以与注册的自定义域名关联的前端 WebSocket 连接进行调用。
- **API 部署**
  API Gateway API 的时间点快照。要使客户端可用，必须将部署与一个或多个 API 阶段关联。
- **API 开发人员**
  拥有 API Gateway 部署的 AWS 账户（例如，也支持编程访问的服务提供商。）
- **API 终端节点**
  API Gateway 中部署到特定区域的 API 的主机名。主机名的格式是 {api-id}.execute-api.{region}.amazonaws.com。支持以下类型的 API 终端节点：
  + [边缘优化的 API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-edge-optimized-api-endpoint)
  + [私有 API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-private-api-endpoint)
  + [区域 API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-regional-api-endpoint)
- **API 密钥**
  API Gateway 用于识别使用 REST 或 WebSocket API 的应用程序开发人员的字母数字字符串。API Gateway 可以代表您生成 API 密钥，也可以从 CSV 文件中导入 API 密钥。您可以将 API 密钥与 [Lambda 授权方](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html)或[使用计划](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-api-usage-plans.html)一起使用来控制对 API 的访问。

  请参阅 [API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-api-endpoints)。
- **API 所有者**
  请参阅 [API 开发人员](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-api-developer)。
- **API 阶段**
  对您的 API 生命周期状态（例如，“dev”、“prod”、“beta”、“v2”）的逻辑引用。API 阶段由 API ID 和阶段名称标识。
- **应用程序开发人员**
  应用程序创建者，可能拥有也可能不拥有 AWS 账户并与您（API 开发人员）部署的 API 交互。应用程序开发人员是您的客户。应用程序开发人员通常由 [API 密钥](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-api-key)标识。
-- **回调 URL**
  当新客户端通过 WebSocket 连接进行连接时，您可以调用 API Gateway 中的集成来存储客户端的回调 URL。然后，您可以使用该回调 URL 从后端系统向客户端发送消息。
- **开发人员门户**
  一个能让您的客户注册、发现和订阅 API 产品（API Gateway 使用计划），管理其 API 密钥以及查看 API 使用指标的应用程序。
- **边缘优化的 API 终端节点**
  API Gateway API 的默认主机名，它部署到指定区域，并使用 CloudFront 分配以方便客户端跨 AWS 区域进行常规访问。API 请求将路由至最近的 CloudFront 接入点 (POP)，通常可改进不同地理位置客户端的连接时间。

  请参阅 [API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-api-endpoints)。
- **集成请求**
  API Gateway 中的 WebSocket API 路由或 REST API 方法的内部接口，在其中您会将路由请求的正文或方法请求的参数和正文映射到后端所需的格式。
- **集成响应**
  API Gateway 中的 WebSocket API 路由或 REST API 方法的内部接口，在其中您会将从后端接收到的状态代码、标头和负载映射到返回到客户端应用程序的响应格式。
- **映射模板**
  使用 [Velocity 模板语言 (VTL)](https://velocity.apache.org/engine/devel/vtl-reference.html) 表示的脚本，此脚本用于将请求正文从前端数据格式转换为后端数据格式，或将响应正文从后端数据格式转换为前端数据格式。映射模板可以在集成请求中或在集成响应中指定。它们可以将运行时提供的数据引用为上下文和阶段变量。

  映射可以像[身份转换](https://en.wikipedia.org/wiki/Identity_transform)一样简单，它通过集成将标头或正文从客户端按原样传递到请求的后端。对于响应也是如此，在其中负载从后端传递到客户端。
- **方法请求**
  API Gateway 中 API 方法的公共接口，定义了应用程序开发人员在通过 API 访问后端时必须在请求中发送的参数和正文。
- **方法响应**
  REST API 的公共接口，定义应用程序开发人员期望在 API 的响应中收到的状态代码、标头和正文模型。
- **模拟集成**
  在模拟集成中，API 响应直接从 API Gateway 生成，而无需集成后端。作为 API 开发人员，您可以决定 API Gateway 响应模拟集成的方式。为此，您可以配置方法的集成请求和集成响应，以将响应与给定的状态代码相关联。
- **模型**
  指定请求或响应负载的数据结构的数据架构。生成 API 的强类型的开发工具包时需要使用模型。它还用于验证负载。模型可以方便地用于生成示例映射模板，以便开始创建生产映射模板。虽然模型很有用，但不是创建映射模板所必需的。
- **私有 API**
  请参阅[私有 API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-private-api)。
- **私有 API 终端节点**
  一个通过接口 VPC 终端节点公开的 API 终端节点，能让客户端安全地访问 VPC 内的私有 API 资源。私有 API 与公有 Internet 隔离，只能使用已授予访问权限的 API Gateway 的 VPC 终端节点访问它们。
- **私有集成**
  一种 API Gateway 集成类型，供客户端通过私有 REST API 终端节点访问客户 VPC 中的资源，而不向公有 Internet 公开资源。
- **代理集成**
  简化的 API Gateway 集成配置。您可以将代理集成设置为 HTTP 代理集成或 Lambda 代理集成。

  对于 HTTP 代理集成，API Gateway 在前端与 HTTP 后端之间传递整个请求和响应。对于 Lambda 代理集成，API Gateway 将整个请求作为输入发送到后端 Lambda 函数。API Gateway 随后将 Lambda 函数输出转换为前端 HTTP 响应。

  在 REST API 中，代理集成最常与代理资源一起使用，以“贪婪”路径变量（例如 {proxy+}）与“捕获所有”ANY 方法相结合的方式表示。
- **快速创建**
  您可以使用快速创建来简化 HTTP API 的创建。使用“快速创建”可以创建具有 Lambda 或 HTTP 集成、默认“捕获全部”路由和默认阶段（配置为自动部署更改）的 API。有关更多信息，请参阅 [使用 AWS CLI 创建 HTTP API](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/http-api-develop.html#http-api-examples.cli.quick-create)。
- **区域 API 终端节点**
  部署到指定区域并旨在服务于同一 AWS 区域中的客户端（例如 EC2 实例）的 API 的主机名。API 请求直接以区域特定的 API Gateway API 为目标而不经过任何 CloudFront 分配。对于区域内请求，区域性终端节点会绕过到 CloudFront 分配的不必要往返行程。

  此外，您可以在区域性终端节点上应用[基于延迟的路由](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency)，从而使用相同的区域性 API 终端节点配置将 API 部署到多个区域，为每个已部署的 API 设置相同的自定义域名，以及在 Route 53 中配置基于延迟的 DNS 记录以将客户端请求路由到具有最低延迟的区域。

  请参阅 [API 终端节点](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/api-gateway-basic-concept.html#apigateway-definition-api-endpoints)。
- **路由**
  API Gateway 中的 WebSocket 路由用于根据消息内容将传入消息定向到特定集成，例如 AWS Lambda 函数。在定义 WebSocket API 时，指定路由键和集成后端。路由键是消息正文中的一种属性。当路由键在传入消息中匹配时，将会调用集成后端。

  还可以为不匹配的路由键设置默认路由，或者设置默认路由来指定一个将消息按原样传递给执行路由和处理请求的后端组件的代理模型。
- **路由请求**
  API Gateway 中 WebSocket API 方法的公共接口，定义了应用程序开发人员在通过 API 访问后端时必须在请求中发送的正文。
- **路由响应**
  WebSocket API 的公共接口，定义应用程序开发人员期望从 API Gateway 收到的状态代码、标头和正文模型。
- **使用计划**
  使用计划可以提供能够访问一个或多个部署的 REST 或 WebSocket API 的选定 API 客户端。您可以通过使用计划来配置限制和配额限制，这些限制会应用到单独的客户端 API 密钥。
- **WebSocket 连接**
  API Gateway 在客户端和 API Gateway 本身之间维护持久连接。API Gateway 和后端集成（如 Lambda 函数）之间没有持久连接。基于从客户端收到的消息内容，根据需要来调用后端服务。
### 1.3 选择 HTTP API 或 REST API
HTTP API 专为低延迟、经济高效地与 AWS 服务（包括 AWS Lambda 和 HTTP 终端节点）集成而设计。HTTP API 支持 OIDC 和 OAuth 2.0 授权，并配备了对 CORS 和自动部署的内置支持。上一代 REST API 目前提供了更多功能，并完全控制 API 请求和响应。

下表汇总在 HTTP API 和 REST API 中可用的核心功能。

授权方|HTTP API|REST API
--------|--------|--------
AWS Lambda|✓|✓
IAM|✓|✓
Amazon Cognito|✓ *|✓
本机 OpenID Connect / OAuth 2.0|✓|
> **您可以使用 Amazon Cognito 作为 JWT 颁发者**。

集成|HTTP API|REST API
--------|--------|--------
HTTP|✓|✓
Lambda|✓|✓
AWS 服务|✓|✓
私有集成|✓|✓
模拟||✓

API 管理|HTTP API|REST API
--------|--------|--------
使用计划||✓|
API 密钥||✓|
自定义域名|✓ *|✓
> **HTTP API 不支持 TLS 1.0**。

开发|HTTP API|REST API
--------|--------|--------
API 缓存||✓
请求转换||✓
请求/响应验证||✓
测试调用||✓
CORS 配置|✓|✓ *
自动部署|✓|
默认阶段|✓|
默认路由|✓|
> **您可以结合 REST API 的不同功能来支持 CORS。要了解更多信息，请参阅“[为 REST API 资源启用 CORS](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/how-to-cors.html)”**。


安全|HTTP API|REST API
--------|--------|--------
AP客户端证书||✓
AWS WAF||✓
资源策略||✓

API 类型|HTTP API|REST API
--------|--------|--------
区域性的|✓|✓
边缘优化||✓
私密||✓

监控|HTTP API|REST API
--------|--------|--------
访问 Amazon CloudWatch Logs 的日志|✓|✓
访问 Amazon Kinesis Data Firehose 的日志||✓
执行日志||✓
Amazon CloudWatch 指标|✓|✓
AWS X-Ray||✓
### 1.4 API Gateway 定价
## 2. 开始使用 API Gateway
## 3. 教程
## 4. 使用 HTTP API
## 5. 使用 REST API
## 6. 使用 WebSocket API
## 7. API Gateway ARN
## 8. OpenAPI 扩展
## 9. 安全
## 10. 标记
## 11. API 参考
## 12. 配额和重要提示


## Reference
- [Amazon API Gateway](https://docs.aws.amazon.com/zh_cn/apigateway/latest/developerguide/welcome.html)