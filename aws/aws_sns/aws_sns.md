# 什么是 Amazon Simple Notification Service？
Amazon Simple Notification Service (Amazon SNS) 是一项 Web 服务，用于协调和管理向订阅终端节点或客户端交付或发送消息的过程。在 Amazon SNS 中，有两类客户端—发布者和订阅者—也称为创建者和用户。发布者通过创建消息并将消息发送至主题与订阅者进行异步交流，主题是一个逻辑访问点和通信渠道。订阅者（即 Web 服务器、电子邮件地址、Amazon SQS 队列、AWS Lambda 函数）在其订阅主题后通过受支持协议（即 Amazon SQS、HTTP/S、电子邮件、SMS、Lambda）之一使用或接收消息或通知。

![How SNS Works](https://github.com/wbb1975/blogs/blob/master/aws/images/sns-how-works.png)

使用 Amazon SNS 时，您（作为所有者）可通过定义确定哪些发布者和订阅者能就主题进行交流的策略来创建主题和控制对主题的访问权。发布者会发送消息至他们创建的主题或他们有权发布的主题。除了在每个消息中包括特定目标地址之外，发布者还要将消息发送至主题。Amazon SNS 将主题与订阅了该主题的用户列表对应，并将消息发送给这些订阅者中的每一个。每个主题都有一个独特的名称用于识别Amazon SNS 终端节点，发布者向它投递消息 ，订阅者于此注册通知。订阅者接收所有发布至他们所订阅主题的消息，并且一个主题的所有订阅者收到的消息都相同。
# 设置 Amazon SNS 的访问权限
## 步骤 1：创建 AWS 账户和 IAM 管理员用户
## 步骤 2：创建 IAM 用户并获取您的 AWS 凭证
## 后续步骤
# Amazon SNS 入门
## 步骤 1：创建主题
## 步骤 2：为终端节点创建主题订阅
## 步骤 3：向主题发布消息
## 步骤 4：删除订阅和主题
## 后续步骤

# Reference
- [什么是 AWS SNS](https://docs.amazonaws.cn/sns/latest/dg/welcome.html?shortFooter=true)