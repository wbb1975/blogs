# AWS Identity and Access Management (IAM)

## 第一章 什么是 IAM？
AWS Identity and Access Management (IAM) 是一种 Web 服务，可以帮助您安全地控制对 AWS 资源的访问。您可以使用 IAM 控制对哪个用户进行身份验证 (登录) 和授权 (具有权限) 以使用资源。

当您首次创建 AWS 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 AWS账户根用户（root user），可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。强烈建议您不使用根用户执行日常任务，即使是管理任务。请遵守仅将用于[创建首个 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html)的最佳实践。然后请妥善保存根用户凭证，仅用它们执行少数账户和服务管理任务。

**IAM 功能**
IAM 为您提供以下功能：
- **共享您 AWS 账户的访问权限**
   
   您可以向其他人员授予管理和使用您 AWS 账户中的资源的权限，而不必共享您的密码或访问密钥。
- **精细权限**

   您可以针对不同资源向不同人员授予不同权限。例如，您可以允许某些用户完全访问 Amazon Elastic Compute Cloud (Amazon EC2)、Amazon Simple Storage Service (Amazon S3)、Amazon DynamoDB、Amazon Redshift 和其他 AWS 服务。对于另一些用户，您可以允许仅针对某些 S3 存储桶的只读访问权限，或是仅管理某些 EC2 实例的权限，或是访问您的账单信息但无法访问任何其他内容的权限。
- **在 Amazon EC2 上运行的应用程序针对 AWS 资源的安全访问权限**

   您可以使用 IAM 功能安全地为 EC2 实例上运行的应用程序提供凭证。这些凭证为您的应用程序提供权限以访问其他 AWS 资源。示例包括 S3 存储桶和 DynamoDB 表。
- **多重验证 (MFA)**

   您可以向您的账户和各个用户添加双重身份验证以实现更高安全性。借助 MFA，您或您的用户不仅必须提供使用账户所需的密码或访问密钥，还必须提供来自经过特殊配置的设备的代码。
- **联合身份**

   您可以允许已在其他位置（例如，在您的企业网络中或通过 Internet 身份提供商）获得密码的用户获取对您 AWS 账户的临时访问权限。
- **实现保证的身份信息**

   如果您使用 [AWS CloudTrail](http://www.amazonaws.cn/cloudtrail/)，则会收到日志记录，其中包括有关对您账户中的资源进行请求的人员的信息。这些信息基于 IAM 身份。
- **PCI DSS 合规性**

   IAM 支持由商家或服务提供商处理、存储和传输信用卡数据，而且已经验证符合支付卡行业 (PCI) 数据安全标准 (DSS)。有关 PCI DSS 的更多信息，包括如何请求 AWS PCI Compliance Package 的副本，请参阅 [PCI DSS 第 1 级](http://www.amazonaws.cn/compliance/pci-dss-level-1-faqs/)。
- **已与很多 AWS 服务集成**

   有关使用 IAM 的 AWS 服务的列表，请参阅[使用 IAM 的 AWS 服务](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。
- **最终一致性**

   与许多其他 AWS 服务一样，IAM 具有最终一致性。IAM 通过在 Amazon 的全球数据中心中的多个服务器之间复制数据来实现高可用性。如果成功请求更改某些数据，则更改会提交并安全存储。不过，更改必须跨 IAM 复制，这需要时间。此类更改包括创建或更新用户、组、角色或策略。在应用程序的关键、高可用性代码路径中，我们不建议进行此类 IAM 更改。而应在不常运行的、单独的初始化或设置例程中进行 IAM 更改。另外，在生产工作流程依赖这些更改之前，请务必验证更改已传播。有关更多信息，请参阅[我所做的更改并非始终立即可见](https://docs.amazonaws.cn/IAM/latest/UserGuide/troubleshoot_general.html#troubleshoot_general_eventual-consistency)。
- **免费使用**

   AWS Identity and Access Management (IAM) 和 AWS Security Token Service (AWS STS) 是为您的 AWS 账户提供的功能，不另行收费。仅当您使用 IAM 用户或 AWS STS 临时安全凭证访问其他 AWS 服务时，才会向您收取费用。有关其他 AWS 产品的定价信息，请参阅 [Amazon Web Services 定价页面](http://www.amazonaws.cn/pricing/)。

**访问 IAM**

您可以通过以下任何方式使用 AWS Identity and Access Management。
- **AWS 管理控制台**

   控制台是用于管理 IAM 和 AWS 资源的基于浏览器的界面。有关通过控制台访问 IAM 的更多信息，请参阅 [IAM 控制台和登录页面](https://docs.amazonaws.cn/IAM/latest/UserGuide/console.html)。有关指导您使用控制台的教程，请参阅[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。
- **AWS 命令行工具**

   您可以使用 AWS 命令行工具，在系统的命令行中发出命令以执行 IAM 和 AWS 任务。与控制台相比，使用命令行更快、更方便。如果要构建执行 AWS 任务的脚本，命令行工具也会十分有用。

   AWS 提供两组命令行工具：[AWS Command Line Interface](http://www.amazonaws.cn/cli/) (AWS CLI) 和 [适用于 Windows PowerShell 的 AWS 工具](http://www.amazonaws.cn/powershell/)。有关安装和使用 AWS CLI 的更多信息，请参阅 [AWS Command Line Interface 用户指南](https://docs.amazonaws.cn/cli/latest/userguide/)。有关安装和使用Windows PowerShell 工具的更多信息，请参阅[适用于 Windows PowerShell 的 AWS 工具 用户指南](https://docs.amazonaws.cn/powershell/latest/userguide/)。
- **AWS 开发工具包**

   AWS 提供的 SDK (开发工具包) 包含各种编程语言和平台 (Java、Python、Ruby、.NET、iOS、Android 等) 的库和示例代码。开发工具包提供便捷的方式来创建对 IAM 和 AWS 的编程访问。例如，开发工具包执行以下类似任务：加密签署请求、管理错误以及自动重试请求。有关 AWS 开发工具包的信息（包括如何下载及安装），请参阅[适用于 Amazon Web Services 的工具](http://www.amazonaws.cn/tools/)页面。
- **IAM HTTPS API**

   您可以使用 IAM HTTPS API（可让您直接向服务发布 HTTPS 请求）以编程方式访问 IAM 和 AWS。使用 HTTPS API 时，必须添加代码，才能使用您的凭证对请求进行数字化签名。有关更多信息，请参见[通过提出 HTTP 查询请求来调用 API](https://docs.amazonaws.cn/IAM/latest/UserGuide/programming.html)和 [IAM API 参考](https://docs.amazonaws.cn/IAM/latest/APIReference/)。
### 1. 了解 IAM 的工作方式
在创建用户之前，您应该了解 IAM 的工作方式。**IAM 提供了控制您的账户的身份验证和授权所需的基础设施**。IAM 基础设施包含以下元素：
- 术语
- 委托人(Principals)
- 请求
- 身份验证
- 授权
- 操作
- 资源

![IAM main elements](https://github.com/wbb1975/blogs/blob/master/aws/images/aws_iam_elements.png)
#### 1.1 术语
- 资源：存储在 IAM 中的用户、角色、组和策略对象。与其他 AWS 服务一样，您可以在 IAM 中添加、编辑和删除资源。
- 身份(Identities)：用于标识和分组的 IAM 资源对象。您可以将策略附加到 IAM 身份。其中包括用户、组和角色。
- 实体(Entities)：AWS 用于进行身份验证的 IAM 资源对象。其中包括用户和角色。角色可以由您的账户或其他账户中的 IAM 用户以及通过 Web 身份或 SAML 联合的用户代入。
- 委托人：使用 AWS 账户根用户、IAM 用户或 IAM 角色登录并向 AWS 发出请求的人员或应用程序。
#### 1.2 委托人
委托人 是可请求对 AWS 资源执行操作的人员或应用程序。委托人将作为 AWS 账户根用户 或 IAM 实体进行身份验证以向 AWS 发出请求。作为最佳实践，请勿使用您的根用户凭证完成日常工作。而是创建 IAM 实体（用户和角色）。您还可以支持联合身份用户或编程访问以允许应用程序访问您的 AWS 账户。
#### 1.3 请求
在委托人尝试使用 AWS 管理控制台、AWS API 或 AWS CLI 时，该委托人将向 AWS 发送请求。请求包含以下信息：
   - 操作 – 委托人希望执行的操作。这可以是 AWS 管理控制台中的操作或者 AWS CLI 或 AWS API 中的操作。
   - 资源 – 对其执行操作的 AWS 资源对象。
   - 委托人 – 已使用实体（用户或角色）发送请求的人员或应用程序。有关委托人的信息包括与委托人用于登录的实体关联的策略。
   - 环境数据 – 有关 IP 地址、用户代理、SSL 启用状态或当天时间的信息。
   - 资源数据 – 与请求的资源相关的数据。这可能包括 DynamoDB 表名称或 Amazon EC2 实例上的标签等信息。
AWS 将请求信息收集到请求上下文中，后者用于评估和授权请求。
#### 1.4 身份验证
委托人必须使用其凭证进行身份验证（登录到 AWS）以向 AWS 发送请求。某些服务（如 Amazon S3 和 AWS STS）允许一些来自匿名用户的请求。不过，它们是该规则的例外情况。

要以 根用户 身份从控制台中进行身份验证，必须使用您的电子邮件地址和密码登录。作为 IAM 用户，请提供您的账户 ID 或别名，然后提供您的用户名和密码。要从 API 或 AWS CLI 中进行身份验证，您必须提供访问密钥和私有密钥。您还可能需要提供额外的安全信息。例如，AWS 建议您使用多重身份验证 (MFA) 来提高账户的安全性。要了解有关 AWS 可验证的 IAM 实体的更多信息，请参阅[IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users.html)和[IAM 角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles.html)。
#### 1.5 授权
您还必须获得授权（允许）才能完成您的请求。在授权期间，AWS 使用请求上下文中的值来检查应用于请求的策略。然后，它使用策略来确定是允许还是拒绝请求。大多数策略作为[JSON 文档](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html#access_policies-json)存储在 AWS 中，并指定委托人实体的权限。有[多种类型的策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html)可影响是否对请求进行授权。要向用户提供访问他们自己账户中的 AWS 资源的权限，只需基于身份的策略。基于资源的策略常用于授予[跨账户](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html#UserPermissionsAcrossAccounts)访问。其他策略类型是高级功能，应谨慎使用。

AWS 检查应用于请求上下文的每个策略。如果一个权限策略包含拒绝的操作，AWS 将拒绝整个请求并停止评估。这称为显式拒绝。由于请求是默认被拒绝的，因此，只有在适用的权限策略允许请求的每个部分时，AWS 才会授权请求。单个账户中对于请求的评估逻辑遵循以下一般规则：
   - 默认情况下，所有请求都将被拒绝。（通常，始终允许使用 AWS 账户根用户凭证创建的访问该账户资源的请求。）
   - 任何权限策略（基于身份(identity-based)或基于资源）中的显式允许将覆盖此默认值。
   - 组织 SCP、IAM 权限边界或会话策略的存在将覆盖允许。如果存在其中一个或多个策略类型，它们必须都允许请求。否则，将隐式拒绝它。
   - 任何策略中的显式拒绝将覆盖任何允许。
要了解有关如何评估所有类型的策略的更多信息，请参阅[策略评估逻辑](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)。如果您需要在另一个账户中发出请求，此其他账户中的策略必须允许访问资源，并且 您用于发出请求的 IAM 实体必须具有允许该请求的基于身份的策略。
#### 1.6 操作
在对您的请求进行身份验证和授权后，AWS 将批准请求中的操作。操作是由服务定义的，包括可以对资源执行的操作，例如，查看、创建、编辑和删除该资源。例如，IAM 为用户资源支持大约 40 个操作，包括以下操作：
   + CreateUser
   + DeleteUser
   + GetUser
   + UpdateUser
要允许委托人执行操作，您必须在应用于委托人或受影响的资源的策略中包含所需的操作。要查看每个服务支持的操作、资源类型和条件键的列表，请参阅[AWS服务的操作、资源类型和条件键](https://docs.amazonaws.cn/en_us/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)。
#### 1.7 资源
在 AWS 批准请求中的操作后，可以对您的账户中的相关资源执行这些操作。资源是位于服务中的对象。示例包括 Amazon EC2 实例、IAM 用户和 Amazon S3 存储桶。服务定义了一组可对每个资源执行的操作。如果创建一个请求以对资源执行不相关的操作，则会拒绝该请求。例如，如果您请求删除一个 IAM 角色，但提供一个 IAM 组资源，请求将失败。要查看确定操作影响哪些资源的 AWS 服务表，请参阅[AWS服务的操作、资源类型和条件键](https://docs.amazonaws.cn/en_us/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)。
### 2. 身份管理概述：用户
为实现更好的安全性和组织，您可以向特定用户（使用自定义权限创建的身份）授予对您的 AWS 账户的访问权限。通过将现有身份联合到 AWS 中，可以进一步简化这些用户的访问。
#### 2.1 仅限首次访问：您的根用户凭证
创建 AWS 账户时，会创建一个用于登录 AWS 的 AWS 账户根用户身份。您可以使用此根用户身份（即，创建账户时提供的电子邮件地址和密码）登录 AWS 管理控制台。您的电子邮件地址和密码的组合也称为您的根用户凭证。

使用根用户凭证时，您可以对 AWS 账户中的所有资源进行完全、无限制的访问，包括访问您的账单信息，您还能更改自己的密码。当您首次设置账户时，需要此访问级别。但是，我们**不建议**使用根用户凭证进行日常访问。我们特别建议您不要与任何人共享您的根用户凭证，因为如果这样做，他们可对您的账户进行无限制的访问。无法限制向根用户授予的权限。

以下几节说明如何使用 IAM 创建和管理用户身份和权限以提供对您 AWS 资源的安全、有限访问，适用于您自己以及需要使用您 AWS 资源的其他人员。
#### 2.2 IAM 用户
AWS Identity and Access Management (IAM) 的“身份”方面可帮助您解决问题“该用户是谁？”（通常称为身份验证）。您可以在账户中创建与组织中的用户对应的各 IAM 用户，而不是与他人共享您的根用户凭证。IAM 用户不是单独的账户；它们是您账户中的用户。每个用户都可以有自己的密码以用于访问 AWS 管理控制台。您还可以为每个用户创建单独的访问密钥，以便用户可以发出编程请求以使用账户中的资源。在下图中，用户 Li、Mateo、DevApp1、DevApp2、TestApp1 和 TestApp2 已添加到单个 AWS 账户。每个用户都有自己的凭证。

![IAM Account With Users](https://github.com/wbb1975/blogs/blob/master/aws/images/iam-intro-account-with-users.diagram.png)

请注意，某些用户实际上是应用程序（例如 DevApp1）。IAM 用户不必表示实际人员；您可以创建 IAM 用户以便为在公司网络中运行并需要 AWS 访问权限的应用程序生成访问密钥。

我们建议您为自己创建 IAM 用户，然后向自己分配账户的管理权限。您随后可以作为该用户登录以根据需要添加更多用户。
#### 2.3 联合现有用户
如果您的组织中的用户已通过某种方法进行身份验证 (例如，通过登录到您的公司网络)，则不必为他们创建单独的 IAM 用户。相反，您可以在 AWS 中对这些用户身份进行联合身份验证。

下图介绍用户如何使用 IAM 获取临时 AWS 安全凭证以访问您 AWS 账户中的资源。
![IAM Federation](https://github.com/wbb1975/blogs/blob/master/aws/images/iam-intro-federation.diagram.png)

联合在这些情况下尤其有用：
- **您的用户已在公司目录中拥有身份**
  
   如果您的公司目录与安全断言标记语言 2.0 (SAML 2.0) 兼容，则可以配置公司目录以便为用户提供对 AWS 管理控制台的单一登录 (SSO) 访问。有关更多信息，请参阅[临时凭证的常见情形](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_temp.html#sts-introduction)。

   如果您的公司目录不与 SAML 2.0 兼容，则可以创建身份代理应用程序以便为用户提供对 AWS 管理控制台的单一登录 (SSO) 访问。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。

   如果您的公司目录是 Microsoft Active Directory，则可以使用 [AWS Directory Service](http://www.amazonaws.cn/directoryservice/)在公司目录与您的 AWS 账户之间建立信任。
- **您的用户已有 Internet 身份**

    如果您创建的移动应用程序或基于 Web 的应用程序可以允许用户通过 Internet 身份提供商 (如 Login with Amazon、Facebook、Google 或任何与 OpenID Connect (OIDC) 兼容的身份提供商) 标识自己，则应用程序可以使用联合访问 AWS。有关更多信息，请参阅关于 [Web 联合身份验证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_oidc.html)。

   > 提示：要使用与 Internet 身份提供商的联合身份，我们建议使用 [Amazon Cognito](https://docs.amazonaws.cn/cognito/devguide/)。
### 3. 访问管理概述：权限和策略(Permissions and Policies)
AWS Identity and Access Management (IAM) 的访问管理部分帮助定义委托人实体可在账户内执行的操作。委托人实体是指使用 IAM 实体（用户或角色）进行身份验证的人员或应用程序。访问管理通常称为授权。您在 AWS 中通过创建策略并将其附加到 IAM 身份（用户、用户组或角色）或 AWS 资源来管理访问权限。策略是 AWS 中的对象；在与身份或资源相关联时，策略定义它们的权限。在委托人使用 IAM 实体（如用户或角色）发出请求时，AWS 将评估这些策略。策略中的权限确定是允许还是拒绝请求。大多数策略在 AWS 中存储为 JSON 文档。有关策略类型和用法的更多信息，请参阅[策略和权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html)。
#### 3.1 策略和账户
如果您管理 AWS 中的单个账户，则使用策略定义该账户中的权限。如果您管理跨多个账户的权限，则管理用户的权限会比较困难。您可以将 IAM 角色、基于资源的策略或访问控制列表 (ACL) 用于跨账户权限。但是，如果您拥有多个账户，那我们建议您改用该 AWS Organizations 服务来帮助您管理这些权限。有关更多信息，请参阅[组织用户指南 中的什么是AWS Organizations](https://docs.amazonaws.cn/organizations/latest/userguide/orgs_introduction.html)？。
#### 3.2 策略和用户
IAM 用户是服务中的身份。当您创建 IAM 用户时，他们无法访问您账户中的任何内容，直到您向他们授予权限。向用户授予权限的方法是创建基于身份的策略，这是附加到用户或用户所属组的策略。下面的示例演示一个 JSON 策略，该策略允许用户对 us-west-2 区域内的 123456789012 账户中的 Books 表执行所有 Amazon DynamoDB 操作 (dynamodb:*)。
```
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "dynamodb:*",
    "Resource": "arn:aws-cn:dynamodb:us-west-2:123456789012:table/Books"
  }
```
在将此策略附加到您的 IAM 用户后，该用户将仅具有这些 DynamoDB 权限。大多数用户有多个策略共同代表该用户的权限。

默认情况下会拒绝未显式允许的操作或资源。例如，如果上述策略是附加到用户的唯一策略，则该用户只能对 Books 表执行 DynamoDB 操作。禁止对其他任何表执行操作。同样，不允许用户在 Amazon EC2、Amazon S3 或任何其他 AWS 服务中执行任何操作。原因是策略中未包含使用这些服务的权限。

IAM 控制台中提供了策略摘要 表，这些表总结了策略中对每个服务允许或拒绝的访问级别、资源和条件。策略在三个表中概括：[策略摘要](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand-policy-summary.html)、[服务摘要](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand-service-summary.html)和[操作摘要](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand-action-summary.html)。策略摘要表包含服务列表。选择其中的服务可查看服务摘要。该摘要表包含所选服务的操作和关联权限的列表。您可以选择该表中的操作以查看操作摘要。该表包含所选操作的资源和条件列表。

![Policy DSummary](https://github.com/wbb1975/blogs/blob/master/aws/images/policy_summaries-diagram.png)

您可以在 Users 页面上查看附加到该用户的所有策略 (托管和内联) 的策略摘要。可在 Policies 页面上查看所有托管策略的摘要。
![Policies Summary DynamoDB Example](https://github.com/wbb1975/blogs/blob/master/aws/images/policies-summary-dynamodbexample.png)

您还可以查看策略的 JSON 文档。有关查看摘要或 JSON 文档的信息，请参阅[了解策略授予的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand.html)。
#### 3.3 策略和组
可以将 IAM 用户组织为 IAM 组，然后将策略附加到组。这种情况下，各用户仍有自己的凭证，但是组中的所有用户都具有附加到组的权限。使用组可更轻松地管理权限，并遵循我们的[IAM 最佳实践](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html)。

![IAM Users And Groups](https://github.com/wbb1975/blogs/blob/master/aws/images/iam-intro-users-and-groups.diagram.png)

用户或组可以附加授予不同权限的多个策略。这种情况下，用户的权限基于策略组合进行计算。不过基本原则仍然适用：如果未向用户授予针对操作和资源的显式权限，则用户没有这些权限。
#### 3.4 联合身份用户和角色(Federated Users and Roles)
联合身份用户无法通过与 IAM 用户相同的方式在您的 AWS 账户中获得永久身份。要向联合身份用户分配权限，可以创建称为角色 的实体，并为角色定义权限。当联合用户登录 AWS 时，该用户会与角色关联，被授予角色中定义的权限。有关更多信息，请参阅[针对第三方身份提供商创建角色 (联合)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_create_for-idp.html)。
#### 3.5 基于身份和基于资源的策略(Identity-based and Resource-based Policies)
基于身份的策略是附加到 IAM 身份（如 IAM 用户、组或角色）的权限策略。基于资源的策略是附加到资源（如 Amazon S3 存储桶或 IAM 角色信任策略）的权限策略。

**基于身份的策略**控制身份可以在哪些条件下对哪些资源执行哪些操作。基于身份的策略可以进一步分类：
- **托管策略** – 基于身份的独立策略，可附加到您的 AWS 账户中的多个用户、组和角色。您可以使用两个类型的托管策略：
   + **AWS 托管策略** – 由 AWS 创建和管理的托管策略。如果您刚开始使用策略，建议先使用 AWS 托管策略。
   + **客户托管策略** – 您在 AWS 账户中创建和管理的托管策略。与 AWS 托管策略相比，客户托管策略可以更精确地控制策略。您可以在可视化编辑器中创建和编辑 IAM 策略，也可以直接创建 JSON 策略文档以创建和编辑该策略。有关更多信息，请参阅[创建 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_create.html)和[编辑 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage-edit.html)。
- **内联策略** – 由您创建和管理的策略，直接嵌入在单个用户、组或角色中。**大多数情况下，我们不建议使用内联策略**。

**基于资源的策略**控制指定的委托人可以在何种条件下对该资源执行哪些操作。基于资源的策略是内联策略，没有基于资源的托管策略。要启用跨账户访问，您可以将整个账户或其他账户中的 IAM 实体指定为基于资源的策略中的委托人。

IAM 服务仅支持一种类型的基于资源的策略（称为角色信任策略），这种策略附加到 IAM 角色。由于 IAM 角色同时是支持基于资源的策略的身份和资源，因此，您必须同时将信任策略和基于身份的策略附加到 IAM 角色。信任策略定义哪些委托人实体（账户、用户、角色和联合身份用户）可以代入该角色。要了解 IAM 角色如何与其他基于资源的策略不同，请参阅[IAM 角色与基于资源的策略有何不同](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_compare-resource-policies.html)。

要了解哪些服务支持基于资源的策略，请参阅[使用IAM 的 AWS 服务](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。要了解基于资源的策略的更多信息，请参阅[基于身份的策略和基于资源的策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_identity-vs-resource.html)。
### 4. 什么是适用于 AWS 的 ABAC（Attribute-based access control (ABAC)）？
基于属性的访问控制（ABAC）是一种授权策略，基于属性来定义权限。在 AWS 中，这些属性称为标签。标签可以附加到 IAM 委托人（用户或角色）以及 AWS 资源。您可以为 IAM 委托人创建单个 ABAC 策略或者一小组策略。这些 ABAC 策略可设计为在委托人的标签与资源标签匹配时允许操作。ABAC 在快速增长的环境中非常有用，并在策略管理变得繁琐的情况下可以提供帮助。

例如，您可以创建具有 access-project 标签键的三个角色。将第一个角色的标签值设置为 Heart，第二个为 Sun，第三个为 Lightning。然后，您可以使用单个策略，在角色和资源标记了 access-project 的相同值时允许访问。有关演示如何在 AWS 中使用 ABAC 的详细教程，请参阅教程：[将标签用于 AWS 中的基于属性的访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/tutorial_attribute-based-access-control.html)。

![tutorial-abac-concept](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-abac-concept.png)
#### 4.1 ABAC 与传统 RBAC 模型的对比
IAM 中使用的传统授权模型称为基于角色的访问控制 (RBAC)。RBAC 根据用户的工作职能定义权限，在 AWS 之外称为角色。在 AWS 中，角色通常指 IAM 角色，这是您可以代入的 IAM 中的身份。IAM 包括[适用于工作职能的托管策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_job-functions.html)，将权限与 RBAC 模型中的工作职能相匹配。

在 IAM 中，您通过为不同工作职能创建不同策略来实施 RBAC。然后，您可将策略附加到身份（IAM 用户、用户组或 IAM 角色）。作为最佳实践，您向工作职能授予所需的最小权限。这称为[授予最小权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#grant-least-privilege)。通过列出工作职能可以访问的特定资源来完成此操作。使用传统 RBAC 模型的缺点在于，当员工添加新资源时，您必须更新策略以允许访问这些资源。

例如，假设您的员工在处理三个项目，名为 Heart、Sun 和 Lightning。您可以为每个项目创建一个 IAM 角色。然后，您将策略附加到各个 IAM 角色，定义允许代入该角色的任何用户可以访问的资源。如果员工更换了公司中的工作，您可向其分配不同的 IAM 角色。用户或计划可以分配到多个角色。但是，Sun 项目可能需要额外的资源，例如新的 Amazon S3 存储桶。在这种情况下，您必须更新附加到 Sun 角色的策略来指定新存储桶资源。否则，Sun 项目成员不允许访问新的存储桶。

![tutorial-abac-rbac-concept](https://github.com/wbb1975/blogs/blob/master/aws/images/tutorial-abac-rbac-concept.png)

**相比传统 RBAC 模型，ABAC 具备以下优势**：
- **ABAC 权限随着创新扩展**。它不再需要管理员更新现有策略以允许对新资源的访问。例如，假设您使用 access-project 标签指定了 ABAC 策略。开发人员使用 access-project = Heart 标签的角色。当 Heart 项目中的员工需要额外的 Amazon EC2 资源时，开发人员可以使用 access-project = Heart 标签创建新 Amazon EC2 实例。这样，Heart 项目中的任何员工可以启动和停止这些实例，因为其标签值匹配。
- **ABAC 需要较少的策略**。由于您无需为不同工作职能创建不同策略，需要创建的策略数量减少。这些策略更易于管理。
- **使用 ABAC，团队可以进行更改和扩展**。 这是因为新资源的权限根据属性自动授予。例如，如果您的公司已经使用 ABAC 支持 Heart 和 Sun 项目，则可以轻松地添加新 Lightning 项目。IAM 管理员创建具有 access-project = Lightning 标签的新角色。无需更改策略以支持新项目。有权代入该角色的任何用户可以创建和查看使用 access-project = Lightning 标记的实例。此外，团队成员可以从 Heart 项目转向 Lightning 项目。IAM 管理员将用户分配到不同 IAM 角色。无需更改权限策略。
- **使用 ABAC 可以实现精细权限**。 在您创建策略时，最佳实践是[授予最小权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#grant-least-privilege)。使用传统 RBAC，您必须编写一个策略，仅允许访问特定资源。但是，如果使用 ABAC，您可以允许在所有资源上的操作，但仅在资源标签与委托人标签匹配时。
- **通过 ABAC 使用来自您公司目录的员工属性**。 您可以对基于 SAML 的身份提供商或 Web 身份提供商进行配置，将会话标签传递给 AWS。当您的员工希望联合身份到 AWS 中时，其属性将应用到 AWS 中所得到的委托人。然后，您可以使用 ABAC 来允许或拒绝基于这些属性的权限。

有关演示如何在 AWS 中使用 ABAC 的详细教程，请参阅教程：[将标签用于 AWS 中的基于属性的访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/tutorial_attribute-based-access-control.html)。
### 5. IAM 外部的安全功能
通过 IAM 可以控制对使用 AWS 管理控制台、[AWS 命令行工具](http://www.amazonaws.cn/tools/#Command_Line_Tools)或服务 API 操作（通过使用 [AWS 开发工具包](http://www.amazonaws.cn/tools/)）执行的任务的访问。某些 AWS 产品还有其他方法来保护其资源。以下列表提供了一些示例，不过并不详尽。
- Amazon EC2
   在 Amazon Elastic Compute Cloud 中，需要使用密钥对 (对于 Linux 实例) 或使用用户名称和密码 (对于 Windows 实例) 来登录实例。

   有关更多信息，请参阅以下文档：
   + Amazon EC2 用户指南（适用于 Linux 实例） 中的 [Amazon EC2 Linux 实例入门](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/EC2_GetStarted.html)
   + Amazon EC2 用户指南（适用于 Windows 实例） 中的 -Amazon EC2 Windows 实例入门](https://docs.amazonaws.cn/AWSEC2/latest/WindowsGuide/EC2Win_GetStarted.html)
- Amazon RDS
   在 Amazon Relational Database Service 中，需要使用与数据库关联的用户名称和密码来登录数据库引擎。

   有关更多信息，请参阅 Amazon RDS 用户指南 中的 [入门Amazon RDS](https://docs.amazonaws.cn/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.html)。
- Amazon EC2 和 Amazon RDS
   在 Amazon EC2 和 Amazon RDS 中，需要使用安全组来控制发送到实例或数据库的流量。

   有关更多信息，请参阅以下文档：
   + Amazon EC2 用户指南（适用于 Linux 实例） 中的[适用于 Linux 实例的 Amazon EC2 安全组](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/using-network-security.html)
   + Amazon EC2 用户指南（适用于 Windows 实例） 中的[适用于 Windows 实例的 Amazon EC2 安全组](https://docs.amazonaws.cn/AWSEC2/latest/WindowsGuide/using-network-security.html)
   + Amazon RDS 用户指南 中的[Amazon RDS安全组](https://docs.amazonaws.cn/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html)。
- Amazon WorkSpaces
   在 Amazon WorkSpaces 中，用户使用用户名称和密码登录桌面。

   有关更多信息，请参阅 Amazon WorkSpaces Administration Guide 中的 [入门Amazon WorkSpaces](https://docs.amazonaws.cn/workspaces/latest/adminguide/getting_started.html)。
- Amazon WorkDocs
   在 Amazon WorkDocs 中，用户通过使用用户名称和密码进行登录来访问共享文档。

   有关更多信息，请参阅 Amazon WorkDocs 管理指南 中的 [入门Amazon WorkDocs](https://docs.amazonaws.cn/workdocs/latest/adminguide/getting_started.html)。

这些访问控制方法不属于 IAM。通过 IAM 可以控制如何管理这些 AWS 产品 — 创建或终止 Amazon EC2 实例、设置新 Amazon WorkSpaces 桌面等。也就是说，IAM 可帮助您控制通过向 Amazon Web Services 进行请求来执行的任务，并且可帮助您控制对 AWS 管理控制台的访问。但是，IAM 不会帮助您管理诸如登录操作系统 (Amazon EC2)、数据库 (Amazon RDS)、桌面 (Amazon WorkSpaces) 或协作站点 (Amazon WorkDocs) 等任务的安全性。

当您使用特定 AWS 产品时，请务必阅读相应文档，了解属于该产品的所有资源的安全选项。
### 6. 常见任务的快速链接
使用以下链接可获得与 IAM 关联的常见任务的帮助。
- **作为 IAM 用户登录**

   请参阅[IAM 用户如何登录 AWS](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_sign-in.html)。
- **管理 IAM 用户的密码**

   您需要密码才能访问 AWS 管理控制台（包括对账单信息的访问）。

   对于您的 AWS 账户根用户，请参阅[更改 AWS 账户根用户密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_change-root.html)。

   对于 IAM 用户，请参阅[管理 IAM 用户的密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_admin-change-user.html)。
- **管理 IAM 用户的权限**

   您可以使用策略向您 AWS 账户中的 IAM 用户授予权限。IAM 用户在创建时没有任何权限，因此您必须添加权限才能允许他们使用 AWS 资源。

   有关更多信息，请参阅[管理 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage.html)。
- **列出您 AWS 账户中的用户并获取有关其凭证的信息**

   请参阅[获取您 AWS 账户的凭证报告](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_getting-report.html)。
- **添加 Multi-Factor Authentication (MFA)**
   -要添加虚拟 MFA 设备，请参阅以下内容之一：
      + [为您的 AWS 账户根用户启用虚拟 MFA 设备（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html#enable-virt-mfa-for-root)
      + [为 IAM 用户启用虚拟 MFA 设备（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html#enable-virt-mfa-for-iam-user)
   -要添加 U2F 安全密钥，请参阅以下内容之一：
      + [为 AWS 账户根用户启用 U2F 安全密钥（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_u2f.html#enable-u2f-mfa-for-root)
      + [为其他 IAM 用户启用 U2F 安全密钥（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_u2f.html#enable-u2f-mfa-for-iam-user)
   -要添加硬件 MFA 设备，请参阅以下内容之一：
      + [为 AWS 账户根用户启用硬件 MFA 设备（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_physical.html#enable-hw-mfa-for-root)
      + [为其他 IAM 用户启用硬件 MFA 设备（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_enable_physical.html#enable-hw-mfa-for-iam-user)
- **获取访问密钥**

   如果要使用 AWS 开发工具包、AWS 命令行工具或 API 操作发出 AWS 请求，则需要访问密钥。
   > **重要** 仅当创建访问密钥时，才能查看和下载秘密访问密钥。以后您将无法查看或找回秘密访问密钥。但是，如果您丢失了秘密访问密钥，可以创建新的访问密钥。

   对于您的 AWS 账户，请参阅[管理 AWS 账户的访问密钥](https://docs.amazonaws.cn/general/latest/gr/managing-aws-access-keys.html)。

   对于 IAM 用户，请参阅[管理 IAM 用户的访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html)。
- **为用户或角色添加标签**

   您可以使用 IAM 控制台、AWS CLI 或 API 通过 AWS 开发工具包之一来为 IAM 用户或角色添加标签。

   要了解有关 IAM 中的标签的更多信息，请参阅[标记 IAM 用户和角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。

   有关如何在 IAM 中管理标签的详细信息，请参阅[管理 IAM 实体的标签（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html#id_tags_procs-console)。

   要了解有关使用 IAM 标签控制对 AWS 的访问的更多信息，请参阅[使用 IAM 资源标签控制对 IAM 用户和角色的访问以及他们进行的访问](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_iam-tags.html)。
- **开始使用 AWS 的各项功能**

   这套文档主要介绍 IAM 服务。要了解如何使用 AWS 以及使用多种服务来解决构建和启动您的第一个项目等问题，请参阅[入门资源中心](http://www.amazonaws.cn/getting-started/)。

##  第二章 开始设置
AWS Identity and Access Management (IAM) 可帮助您安全地控制对 Amazon Web Services (AWS) 和您的 AWS 资源的访问。此外，IAM 还可使账户凭证保持私密。利用 IAM，您可以在您的 AWS 账户的伞形结构下创建多个 IAM 用户，或通过与企业目录的联合身份实现临时访问。在某些情况下，您也可以实现跨 AWS 账户访问资源。

但是，如果不使用 IAM，则只有两种方法：一种是您必须创建多个 AWS 账户（即，每个账户都有自己针对 AWS 产品的计费和订阅），另一种是您的员工必须共享一个 AWS 账户的安全凭证。此外，如果不使用 IAM，您无法控制特定用户或系统可以完成的任务以及他们可能使用哪些 AWS 资源。

本指南提供了关于 IAM 的概念综述、描述了商用案例并说明了 AWS 权限和策略。
### 1. 使用 IAM 为用户授予对您的 AWS 资源的访问权限
以下是您可以使用 IAM 控制您的 AWS 资源访问权限的几种方式：

访问权限类型|我为什么使用这种方式？|怎样获取更多信息？
--|--|--
您的 AWS 账户中的用户访问权限|您想要在您的 AWS 账户的伞形结构下添加用户，并希望使用 IAM 创建用户并管理他们的权限|要了解如何使用 AWS 管理控制台 在您的 AWS 账户下创建用户和管理其权限，请参阅 [入门](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started.html)。要了解如何使用 IAM API 或 AWS Command Line Interface 在您的 AWS 账户下创建用户，请参阅[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。有关使用 IAM 用户的更多信息，请参阅[身份 (用户、组和角色)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id.html)。
通过您的认证系统和 AWS 之间的联合身份验证实现非 AWS 用户访问|您的身份和认证系统中有非 AWS 用户，他们需要访问您的 AWS 资源|要了解如何使用安全令牌通过与您的公司目录之间的联合身份验证赋予用户访问您的 AWS 账户资源的权限，请转至[临时安全凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_temp.html)。有关 AWS Security Token Service API 的信息，请转到[AWS 安全令牌服务 API 参考](https://docs.amazonaws.cn/STS/latest/APIReference/)
AWS 账户间的跨账户访问权限|您想要与其他 AWS 账户下的用户共享对特定 AWS 资源的访问权限|要了解如何使用 IAM 向其他 AWS 账户授权，请参阅[角色术语和概念](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_terms-and-concepts.html)
### 2. 我是否需要注册 IAM？
如果您目前没有 AWS 账户，则需要创建一个账户才能使用 IAM。您无需专门注册使用 IAM。IAM 不收费。
> **注意** IAM 仅适用于与 IAM 集成的 AWS 产品。有关支持 IAM 的服务的列表，请参阅[使用 IAM 的 AWS 服务](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。

**注册 AWS**
1. 打开 http://www.amazonaws.cn/，然后选择 Create an AWS Account (创建 AWS 账户)。
   > **注意** 如果您之前曾使用 AWS 账户根用户 凭证登录 AWS 管理控制台，请选择 Sign in to a different account (登录其他账户)。如果您之前曾使用 IAM 凭证登录控制台，请选择 Sign-in using root account credentials (使用根账户凭证登录)。然后选择 Create a new AWS account (创建新的 AWS 账户)。
2. 按照联机说明操作。
   
   在注册时，您将接到一通电话，要求您使用电话键盘输入一个验证码。
### 3. 其他资源
以下资源可以帮助您使用 IAM 完成任务。
- 管理 AWS 账户凭证：AWS General Reference 中的 [AWS 安全凭证](https://docs.amazonaws.cn/general/latest/gr/aws-security-credentials.html)
- 开始并详细了解有关[什么是 IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)？ 的信息
- 设置命令行接口 (CLI) 以与 IAM 一起使用。有关跨平台 AWS CLI，请参阅[AWS 命令行接口文档](http://www.amazonaws.cn/documentation/cli/)和 [IAM CLI 参考](https://docs.amazonaws.cn/cli/latest/reference/iam/index.html)。您还可以使用 Windows PowerShell 管理 IAM；请参阅[适用于 Windows PowerShell 的 AWS 工具文档](http://www.amazonaws.cn/documentation/powershell/)和[IAM Windows PowerShell 参考](https://docs.amazonaws.cn/powershell/latest/reference/items/AWS_Identity_and_Access_Management_cmdlets.html)。
- 下载 AWS 开发工具包以便以编程方式访问 IAM：[用于 Amazon Web Services 的工具](http://www.amazonaws.cn/tools/)
- 获取常见问题解答：[AWS Identity and Access Management 常见问题解答](http://www.amazonaws.cn/iam/faqs/)
- 获取技术支持：[AWS Support 中心](https://console.amazonaws.cn/support/home#/)
- 获取高级技术支持：[AWS Premium Support 中心](http://www.amazonaws.cn/support-plans/)
- 查找 AWS 术语的定义：[Amazon Web Services 术语表](https://docs.amazonaws.cn/general/latest/gr/glos-chap.html)
- 获取社群支持：[IAM 开发论坛](https://forums.aws.csdn.net/forum.jspa?forumID=76)
- 联系 AWS：[联系我们](http://www.amazonaws.cn/contact-us/)

## Reference
- [IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)
