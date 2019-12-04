# 开始使用 AWS Lambda
要开始使用 AWS Lambda，请使用 Lambda 控制台创建函数。在几分钟的时间内，您可以创建一个函数，调用它，并查看日志、指标（metrics）和跟踪数据（trace data）。
> **注意** 要使用 Lambda 和其他 AWS 服务，您需要 AWS 账户。如果您没有账户，请访问 www.amazonaws.cn，然后选择创建 AWS 账户。有关详细说明，请参阅[创建和激活 AWS 账户](http://www.amazonaws.cn/premiumsupport/knowledge-center/create-and-activate-aws-account/)。
> 
> 作为最佳实践，您还应创建一个具有管理员权限的 AWS Identity and Access Management (IAM) 用户，并在不需要根凭证的所有工作中使用该用户。创建密码以用于访问控制台，并创建访问密钥以使用命令行工具。有关说明，请参阅[ IAM 用户指南 中的创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

您可以在 Lambda 控制台中编写函数，也可以使用 IDE 工具包、命令行工具或软件开发工具包编写函数。Lambda 控制台为非编译语言提供了[代码编辑器](https://docs.amazonaws.cn/lambda/latest/dg/code-editor.html)，使您可以快速修改和测试代码。[AWS CLI](https://docs.amazonaws.cn/lambda/latest/dg/gettingstarted-awscli.html) 使您可以直接访问 Lambda API 以获取高级配置和自动化使用案例。
## 使用控制台创建 Lambda 函数
## 使用 AWS Lambda 控制台编辑器创建函数
## 将 AWS Lambda 与 AWS Command Line Interface 结合使用
## AWS Lambda 概念
## AWS Lambda 功能
## 与 AWS Lambda 一起使用的工具
## AWS Lambda 限制
AWS Lambda 将限制可用来运行和存储函数的计算和存储资源量。以下限制按区域应用，并且可以提高这些限制。要请求提高限制，请使用[支持中心控制台](https://console.amazonaws.cn/support/v1#/case/create?issueType=service-limit-increase)。

资源|默认限制
--|--
并发执行|1,000
函数和层存储|75 GB

有关并发以及 Lambda 如何扩展您的函数并发以响应流量的详细信息，请参阅[AWS Lambda 函数扩展](https://docs.amazonaws.cn/lambda/latest/dg/scaling.html)。

以下限制适用于函数配置、部署和执行。无法对其进行更改。
资源|限制
--|--
函数内存分配|128 MB 到 3,008 MB，以 64 MB 为增量。
函数超时|900 秒（15 分钟）
函数环境变量|4 KB
函数基于资源的策略|20 KB
函数层|5 层
函数突增并发|500 - 3000（每个区域各不相同）
调用频率（每秒请求数）|10 倍并发执行限制（同步 – 所有资源）10 倍并发执行限制（异步 – 非 AWS 资源）无限制（异步 – AWS 服务资源）
调用负载（请求和响应）|6 MB（同步）256 KB（异步）
部署程序包大小|50 MB（已压缩，可直接上传）250 MB（解压缩，包括层）3 MB（控制台编辑器）
每个 VPC 的弹性网络接口数|160
测试事件（控制台编辑器）|10
/tmp 目录存储|512 MB
文件描述符|1,024
执行进程/线程|1,024

其他服务的限制（如 AWS Identity and Access Management、Amazon CloudFront (Lambda@Edge) 和 Amazon Virtual Private Cloud）会影响您的 Lambda 函数。有关更多信息，请参阅 [AWS 服务限制](https://docs.amazonaws.cn/general/latest/gr/aws_service_limits.html)和[将 AWS Lambda 与其他服务结合使用](https://docs.amazonaws.cn/lambda/latest/dg/lambda-services.html)。

## Reference
- [开始使用 AWS Lambda](https://docs.amazonaws.cn/lambda/latest/dg/getting-started.html?shortFooter=true)