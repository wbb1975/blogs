# 什么是 AWS Lambda？
AWS Lambda 是一项计算服务，可使您无需预配置或管理服务器即可运行代码。AWS Lambda 只在需要时执行您的代码并自动缩放，从每天几个请求到每秒数千个请求。您只需按消耗的计算时间付费 – 代码未运行时不产生费用。借助 AWS Lambda，您几乎可以为任何类型的应用程序或后端服务运行代码，并且不必进行任何管理。AWS Lambda 在可用性高的计算基础设施上运行您的代码，执行计算资源的所有管理工作，其中包括服务器和操作系统维护、容量预置和自动扩展、代码监控和记录。您只需要以 [AWS Lambda 支持的一种语言](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)提供您的代码。

您可以使用 AWS Lambda 运行代码以响应事件，例如更改 Amazon S3 存储桶或 Amazon DynamoDB 表中的数据；以及使用 Amazon API Gateway 运行代码以响应 HTTP 请求；或者使用通过 AWS SDK 完成的 API 调用来调用您的代码。借助这些功能，您可以使用 Lambda 轻松地为 Amazon S3 和 Amazon DynamoDB 等 AWS 服务构建数据处理触发程序，处理 Kinesis 中存储的流数据，或创建您自己的按 AWS 规模、性能和安全性运行的后端。

您也可以构建由事件触发的函数组成的[无服务器](https://aws.amazon.com/serverless)应用程序，并使用 CodePipeline 和 AWS CodeBuild 自动部署这些应用程序。有关更多信息，请参阅[AWS Lambda 应用程序](https://docs.amazonaws.cn/lambda/latest/dg/deploying-lambda-apps.html)。

有关 AWS Lambda 执行环境的更多信息，请参阅[AWS Lambda 运行时](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)。有关 AWS Lambda 如何确定执行您的代码所需的计算资源的信息，请参阅[AWS Lambda 函数配置](https://docs.amazonaws.cn/lambda/latest/dg/resource-model.html)。

# 应在何时使用 AWS Lambda？
AWS Lambda 是很多应用程序场景的理想计算平台，只要您可以用 AWS Lambda 支持的语言编写应用程序代码并在 AWS Lambda 标准运行时环境和 Lambda 提供的资源中运行。

在使用 AWS Lambda 时，您只需负责自己的代码。AWS Lambda 管理提供内存、CPU、网络和其他资源均衡的计算机群。这是以灵活性为代价的，这意味着您不能登录计算实例，或自定义操作系统或语言运行时。通过这些约束，AWS Lambda 可以代表您执行操作和管理活动，包括预置容量、监控机群运行状况、应用安全补丁、部署您的代码以及监控和记录您的 Lambda 函数日志。

如果您需要管理自己的计算资源，Amazon Web Services 还提供了其他计算服务以满足您的需求。
- Amazon Elastic Compute Cloud (Amazon EC2) 服务提供灵活性和各种 EC2 实例类型供您选择。它允许您选择自定义操作系统、网络和安全性设置以及整个软件堆栈，但您负责预置容量、监控机群运行状况和性能以及使用可用区来实现容错。
- Elastic Beanstalk 提供易用的服务，您可将应用程序部署和扩展到 Amazon EC2 上，在其中您保留对底层 EC2 实例的所有权和完整控制权。

Lambda 是一项高度可用的服务。有关更多信息，请参阅[AWS Lambda 服务等级协议](http://www.amazonaws.cn/lambda/sla/)。
# 您是 AWS Lambda 的新用户吗？
如果您是首次接触 AWS Lambda 的用户，我们建议您按顺序阅读以下内容：
1. 阅读产品概述并观看宣传视频，以了解示例使用案例。 这些资源可在[AWS Lambda 网页](http://www.amazonaws.cn/lambda/)上找到。
2. 尝试基于控制台的入门练习。 此练习提供了使用控制台创建和测试您的第一个 Lambda 函数的说明。您还将了解编程模型和其他 Lambda 概念。有关更多信息，请参阅[开始使用 AWS Lambda](https://docs.amazonaws.cn/lambda/latest/dg/getting-started.html)。
3. 阅读本指南的[使用 AWS Lambda 部署应用程序](https://docs.amazonaws.cn/lambda/latest/dg/deploying-lambda-apps.html)部分。本部分介绍了您可以用来打造端到端体验的各种 AWS Lambda 组件。

除了入门练习之外，您还可浏览各种使用案例，每个使用案例都随附有指导您完成示例方案的教程。根据您的应用程序需求（例如，无论您需要事件驱动型 Lambda 函数调用还是按需调用），您可按照满足您特定需求的特定教程进行操作。有关更多信息，请参阅[将AWS Lambda 与其他服务结合使用](https://docs.amazonaws.cn/lambda/latest/dg/lambda-services.html)。

# Reference
- [什么是 AWS Lambda](https://docs.amazonaws.cn/lambda/latest/dg/welcome.html)