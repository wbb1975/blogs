# SNS (Amazon Simple Notification Service)
## 第一章 什么是 Amazon Simple Notification Service？
Amazon Simple Notification Service (Amazon SNS) 是一项 Web 服务，用于协调和管理向订阅终端节点或客户端交付或发送消息的过程。在 Amazon SNS 中，有两类客户端—发布者和订阅者—也称为创建者和用户。发布者通过创建消息并将消息发送至主题与订阅者进行异步交流，主题是一个逻辑访问点和通信渠道。订阅者（即 Web 服务器、电子邮件地址、Amazon SQS 队列、AWS Lambda 函数）在其订阅主题后通过受支持协议（即 Amazon SQS、HTTP/S、电子邮件、SMS、Lambda）之一使用或接收消息或通知。

![How SNS Works](https://github.com/wbb1975/blogs/blob/master/aws/images/sns-how-works.png)

使用 Amazon SNS 时，您（作为所有者）可通过定义确定哪些发布者和订阅者能就主题进行交流的策略来创建主题和控制对主题的访问权。发布者会发送消息至他们创建的主题或他们有权发布的主题。除了在每个消息中包括特定目标地址之外，发布者还要将消息发送至主题。Amazon SNS 将主题与订阅了该主题的用户列表对应，并将消息发送给这些订阅者中的每一个。每个主题都有一个独特的名称，用户为发布者识别 Amazon SNS 终端节点，从而发布消息和订阅者以注册通知（Each topic has a unique name that identifies the Amazon SNS endpoint for publishers to post messages and subscribers to register for notifications.）。订阅者接收所有发布至他们所订阅主题的消息，并且一个主题的所有订阅者收到的消息都相同。
## 第二章 设置 Amazon SNS 的访问权限
必须先完成以下步骤，然后才能使用 Amazon SNS。
### 步骤 1：创建 AWS 账户和 IAM 管理员用户
要访问任何 AWS 服务，您必须首先创建一个 AWS 账户。这是一个可以使用 AWS 产品的 Amazon 账户。您可以使用 AWS 账户查看您的活动和使用率报告并管理身份验证和访问。
1. 导航到 [AWS 主页](https://aws.amazon.com/)，然后选择 Create an AWS Account (创建 AWS 账户)。
2. 按照说明进行操作。

   作为注册流程的一部分，您会收到一个电话，需要您使用电话键盘输入一个 PIN 码。
3. 创建完 AWS 账户后，按照 IAM 用户指南 中的说明[创建您的第一个 IAM 管理员用户和组](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)。
### 步骤 2：创建 IAM 用户并获取您的 AWS 凭证
为了避免使用您的 IAM 管理员用户执行 Amazon SNS 操作，最佳实践是为需要 Amazon SNS 的管理权限的每个人创建一个 IAM 用户。

要使用 Amazon SNS，您需要与您的 IAM 用户关联的 AmazonSNSFullAccess 策略和 AWS 凭证。这些凭证由访问密钥 ID 和秘密访问密钥组成。有关更多信息，请参阅 IAM 用户指南 中的[什么是 IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/IAM_Introduction.html)？以及 AWS General Reference 中的 [AWS 安全凭证](https://docs.aws.amazon.com/general/latest/gr/aws-security-credentials.html)。
1. 登录 [AWS Identity and Access Management 控制台](https://console.aws.amazon.com/iam/)。
2. 依次选择 Users (用户) 和 Add user (添加用户)。
3. 键入 User name (用户名)，例如 AmazonSNSAdmin。
4. 选择 Programmatic access (编程访问) 和 AWS 管理控制台 access (AWS 管理控制台访问)。
5. 设置 Console password (控制台密码)，然后选择 Next: Permissions (下一步: 权限)。
6. 在 Set permissions (设置权限) 页面上，选择 Attach existing policies directly (直接附加现有策略)。
7. 在筛选条件中键入 AmazonSNS，选择 AmazonSNSFullAccess，然后选择 Next: Tags (下一步: 标签)。
8. 在 Add tags (optional) (添加标签(可选)) 页面上，选择 Next: Review (下一步: 审核)。
9. 在 Review (审核) 页面上，选择 Create user (创建用户)。
   
    将创建 IAM 用户并显示 Access key ID (访问密钥 ID)，例如：

    AKIAIOSFODNN7EXAMPLE
10. 要显示您的 Secret access key (秘密访问密钥)，请选择 Show (显示)，例如：

      wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

      > **重要** 您只能 在创建凭证时查看或下载秘密访问密钥（但是，您随时可以创建新的凭证）。
11. 要下载凭证，请选择 Download .csv (下载 .csv)。将此文件保存在安全位置。
### 后续步骤
现在您已准备好使用 Amazon SNS，通过创建主题、为主题创建订阅、向主题发布消息以及删除订阅和主题来开始。
## 第三章 Amazon SNS 入门
## 第四章 Amazon SNS 教程
## 第五章 Amazon SNS 的工作原理
## 第六章 使用 Amazon SNS 进行系统到系统消息收发
本节提供有关使用 Amazon SNS 进行系统到系统消息收发的信息，以及订阅者（如 Lambda 函数、Amazon SQS 队列、HTTP/S 终端节点和 AWS Event Fork Pipelines）的相关信息。
## 第七章 使用 Amazon SNS 发送用户通知
本节提供有关使用 Amazon SNS 向订阅者（如移动应用程序、手机号码和电子邮件地址）发送用户通知的信息。
### 将移动应用程序作为订阅者（移动推送）
### 将手机号码作为订阅者（发送 SMS）
## 第八章 Amazon SNS 主题的监控、日志记录和问题排查
## 第九章 Amazon SNS 安全性
## 第十章 Amazon SNS 发行说明

# 参考
- [Amazon Simple Notification Service文档](https://docs.aws.amazon.com/zh_cn/sns/?id=docs_gateway)