# 什么是 AWS Lambda？
AWS Lambda 是一项计算服务，可使您无需预配置或管理服务器即可运行代码。AWS Lambda 只在需要时执行您的代码并自动缩放，从每天几个请求到每秒数千个请求。您只需按消耗的计算时间付费 – 代码未运行时不产生费用。借助 AWS Lambda，您几乎可以为任何类型的应用程序或后端服务运行代码，并且不必进行任何管理。AWS Lambda 在可用性高的计算基础设施上运行您的代码，执行计算资源的所有管理工作，其中包括服务器和操作系统维护、容量预置和自动扩展、代码监控和记录。您只需要以 [AWS Lambda 支持的一种语言](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)提供您的代码。

您可以使用 AWS Lambda 运行代码以响应事件，例如更改 Amazon S3 存储桶或 Amazon DynamoDB 表中的数据；以及使用 Amazon API Gateway 运行代码以响应 HTTP 请求；或者使用通过 AWS SDK 完成的 API 调用来调用您的代码。借助这些功能，您可以使用 Lambda 轻松地为 Amazon S3 和 Amazon DynamoDB 等 AWS 服务构建数据处理触发程序，处理 Kinesis 中存储的流数据，或创建您自己的按 AWS 规模、性能和安全性运行的后端。

您也可以构建由事件触发的函数组成的[无服务器](https://aws.amazon.com/serverless)应用程序，并使用 CodePipeline 和 AWS CodeBuild 自动部署这些应用程序。有关更多信息，请参阅[AWS Lambda 应用程序](https://docs.amazonaws.cn/lambda/latest/dg/deploying-lambda-apps.html)。

有关 AWS Lambda 执行环境的更多信息，请参阅[AWS Lambda 运行时](https://docs.amazonaws.cn/lambda/latest/dg/lambda-runtimes.html)。有关 AWS Lambda 如何确定执行您的代码所需的计算资源的信息，请参阅[AWS Lambda 函数配置](https://docs.amazonaws.cn/lambda/latest/dg/resource-model.html)。

# 应在何时使用 AWS Lambda？

## Reference
- [什么是 AWS Lambda](https://docs.amazonaws.cn/lambda/latest/dg/welcome.html)