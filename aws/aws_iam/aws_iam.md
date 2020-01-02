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
#### 联合身份用户和角色(Federated Users and Roles)
联合身份用户无法通过与 IAM 用户相同的方式在您的 AWS 账户中获得永久身份。要向联合身份用户分配权限，可以创建称为角色 的实体，并为角色定义权限。当联合用户登录 AWS 时，该用户会与角色关联，被授予角色中定义的权限。有关更多信息，请参阅[针对第三方身份提供商创建角色 (联合)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_create_for-idp.html)。
#### 基于身份和基于资源的策略(Identity-based and Resource-based Policies)
基于身份的策略是附加到 IAM 身份（如 IAM 用户、组或角色）的权限策略。基于资源的策略是附加到资源（如 Amazon S3 存储桶或 IAM 角色信任策略）的权限策略。

基于身份的策略控制身份可以在哪些条件下对哪些资源执行哪些操作。基于身份的策略可以进一步分类：
- 托管策略 – 基于身份的独立策略，可附加到您的 AWS 账户中的多个用户、组和角色。您可以使用两个类型的托管策略：
   + AWS 托管策略 – 由 AWS 创建和管理的托管策略。如果您刚开始使用策略，建议先使用 AWS 托管策略。
   + 客户托管策略 – 您在 AWS 账户中创建和管理的托管策略。与 AWS 托管策略相比，客户托管策略可以更精确地控制策略。您可以在可视化编辑器中创建和编辑 IAM 策略，也可以直接创建 JSON 策略文档以创建和编辑该策略。有关更多信息，请参阅[创建 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_create.html)和[编辑 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage-edit.html)。
- 内联策略 – 由您创建和管理的策略，直接嵌入在单个用户、组或角色中。大多数情况下，我们不建议使用内联策略。

基于资源的策略控制指定的委托人可以在何种条件下对该资源执行哪些操作。基于资源的策略是内联策略，没有基于资源的托管策略。要启用跨账户访问，您可以将整个账户或其他账户中的 IAM 实体指定为基于资源的策略中的委托人。

IAM 服务仅支持一种类型的基于资源的策略（称为角色信任策略），这种策略附加到 IAM 角色。由于 IAM 角色同时是支持基于资源的策略的身份和资源，因此，您必须同时将信任策略和基于身份的策略附加到 IAM 角色。信任策略定义哪些委托人实体（账户、用户、角色和联合身份用户）可以代入该角色。要了解 IAM 角色如何与其他基于资源的策略不同，请参阅[IAM 角色与基于资源的策略有何不同](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_compare-resource-policies.html)。

要了解哪些服务支持基于资源的策略，请参阅[使用IAM 的 AWS 服务](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。要了解基于资源的策略的更多信息，请参阅[基于身份的策略和基于资源的策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_identity-vs-resource.html)。
### IAM 外部的安全功能
通过 IAM 可以控制对使用 AWS 管理控制台、AWS 命令行工具或服务 API 操作（通过使用 AWS 开发工具包）执行的任务的访问。某些 AWS 产品还有其他方法来保护其资源。以下列表提供了一些示例，不过并不详尽。
- Amazon EC2
   在 Amazon Elastic Compute Cloud 中，需要使用密钥对 (对于 Linux 实例) 或使用用户名称和密码 (对于 Windows 实例) 来登录实例。
- Amazon RDS
   在 Amazon Relational Database Service 中，需要使用与数据库关联的用户名称和密码来登录数据库引擎。
- Amazon EC2 和 Amazon RDS
   在 Amazon EC2 和 Amazon RDS 中，需要使用安全组来控制发送到实例或数据库的流量。
- Amazon WorkSpaces
   在 Amazon WorkSpaces 中，用户使用用户名称和密码登录桌面。
- Amazon WorkDocs
在 Amazon WorkDocs 中，用户通过使用用户名称和密码进行登录来访问共享文档。
这些访问控制方法不属于 IAM。通过 IAM 可以控制如何管理这些 AWS 产品 — 创建或终止 Amazon EC2 实例、设置新 Amazon WorkSpaces 桌面等。也就是说，IAM 可帮助您控制通过向 Amazon Web Services 进行请求来执行的任务，并且可帮助您控制对 AWS 管理控制台的访问。但是，IAM 不会帮助您管理诸如登录操作系统 (Amazon EC2)、数据库 (Amazon RDS)、桌面 (Amazon WorkSpaces) 或协作站点 (Amazon WorkDocs) 等任务的安全性。

当您使用特定 AWS 产品时，请务必阅读相应文档，了解属于该产品的所有资源的安全选项。
## 入门
本主题向您介绍如何在您的 AWS 账户下创建 AWS Identity and Access Management (IAM) 用户，以允许访问您的 AWS 资源。首先，您将学习在创建组和用户之前应了解的 IAM 概念；然后，您将详细了解如何使用 AWS 管理控制台 执行必要的任务。第一个任务是设置 AWS 账户的管理员组。AWS 账户中，管理员组不是必需的，但我们强烈建议您创建它。

在下图所示的简单示例中，AWS 账户有三个组。一个群组由一系列具有相似责任的用户组成。在此示例中，一个群组为管理员群组（名为 Admins）。另外还有一个 Developers 群组和一个 Test 群组。每个群组均包含多个用户。尽管图中并未列明，但每个用户可处于多个群组中。您不得将群组置于其他群组中。您可使用策略向群组授予许可。

![IAM Users And Groups](https://github.com/wbb1975/blogs/blob/master/aws/images/iam-intro-users-and-groups.diagram.png)

在随后的流程中，您需要执行下列任务：
- 创建管理员组并向该组提供访问您 AWS 账户的所有资源的权限。
- 为您自己创建一个用户并将该用户添加到管理员组。
- 为您的用户创建密码，以便可以登录 AWS 管理控制台。
您需要授予管理员组权限，以访问 AWS 账户内所有可用的源。可用的资源是指您使用或注册的任何 AWS 产品。管理员组中的用户也可以访问您的 AWS 账户信息，AWS 账户的安全证书除外。
### 建您的第一个 IAM 管理员用户和组
作为[最佳实践](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#lock-away-credentials)，请勿在不必要时使用 AWS 账户根用户 执行任务。而是应为需要管理员访问权限的每个人创建新的 IAM 用户。然后，通过将这些用户放入到一个您附加了 AdministratorAccess 托管策略的“管理员”组中，使这些用户成为管理员。

#### 创建管理员 IAM 用户和组（控制台）：
此过程将介绍如何使用 AWS 管理控制台 自行创建 IAM 用户，并将该用户添加到具有已附加托管策略中的管理权限的组。

自行创建管理员用户并将该用户添加到管理员组（控制台）
1. 使用 AWS 账户电子邮件地址和密码，以 AWS 账户根用户 身份登录到[IAM 控制台](https://console.aws.amazon.com/iam/) 
    > 注意：强烈建议您遵守以下使用 Administrator IAM 用户的最佳实践，妥善保存根用户凭证。只在执行少数[账户和服务管理任务](https://docs.amazonaws.cn/general/latest/gr/aws_tasks-that-require-root.html)时才作为根用户登录。
2. 启用对你创建的IAM管理员账号的账单数据的访问权限
   + 在导航窗格中，选中你的账号名，然后选择My Account（我的账号）
   + 接下来“IAM 用户和角色访问账单信息的权限”，选中Edit（编辑）
   + 选中“激活 IAM 访问权限”的单选框，然后点击Update（更新）
   + 在导航窗格中，选择服务，然后IAM回到IAM控制页面。
3. 在导航窗格中，选择 Users (用户)，然后选择Add user (添加用户)。
4. 对于 User name，键入 Administrator。
5. 选中 AWS 管理控制台 access (AWS 管理控制台访问) 旁边的复选框，选择 Custom password (自定义密码)，然后在文本框中键入新密码。默认情况下，AWS 将强制新用户在首次登录时创建新密码。您可以选择清除 User must create a new password at next sign-in (用户必须在下次登录时创建新密码) 旁边的复选框，以允许新用户在登录后重置其密码。
6. 选择 Next: Permissions (下一步: 权限)。
7. 在设置权限页面上，选择将用户添加到组。
8. 选择 Create group。
9.  在 Create group (创建组) 对话框中，对于 Group name (组名称)，键入 Administrators。
10. 选择 Policy Type (策略类型)，然后选择 AWS托管以筛选表内容。
11. 在策略列表中，选中 AdministratorAccess 的复选框。然后选择 Create group。
12. 返回到组列表中，选中您的新组所对应的复选框。如有必要，选择 Refresh 以在列表中查看该组。
13. 选择 Next: Tagging (下一步: 标记)。
14. （可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅[标记 IAM 实体](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。
15. 选择 Next: Review 以查看要添加到新用户的组成员资格的列表。如果您已准备好继续，请选择 Create user。

您可使用此相同的流程创建更多的组和用户，并允许您的用户访问 AWS 账户资源。要了解有关使用限制用户对特定 AWS 资源的权限的策略的信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)和[IAM 基于身份的策略示例](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)。要在创建组之后向其中添加其他用户，请参阅[在IAM 组中添加和删除用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_groups_manage_add-remove-users.html)。

#### 创建 IAM 用户和组 (AWS CLI)
如果执行了上一节中的步骤，则您已使用 AWS 管理控制台 设置了一个管理员组，同时在您的 AWS 账户中创建了 IAM 用户。此过程显示创建组的替代方法。

概述：设置管理员组
1. 创建一个组并为其提供名称 (例如 Admins)。有关更多信息，请参阅创建组 (AWS CLI)。
2. 附加一个策略以便为组提供管理权限（对所有 AWS 操作和资源的访问权限）。有关更多信息，请参阅将策略附加到组 (AWS CLI)。
3. 向组至少添加一个用户。有关更多信息，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。
##### 创建组 (AWS CLI)
1. 键入 [aws iam create-group](https://docs.amazonaws.cn/cli/latest/reference/iam/create-group.html)命令，并使用您为组选择的名称。（可选）您可以包含路径作为该群组名的一部分。有关路径的更多信息，请参阅 易记名称和路径。名称可包含字母、数字以及以下字符：加号 (+)、等号 (=)、逗号 (,)、句点 (.)、at 符号 (@)、下划线 (_) 和连字符 (-)。名称不区分大小写，且最大长度可为 128 个字符。

在此示例中，您将创建名为 Admins 的组。
```
aws iam create-group --group-name Admins
{
    "Group": {
        "Path": "/", 
        "CreateDate": "2014-06-05T20:29:53.622Z", 
        "GroupId":"ABCDEFGHABCDEFGHABCDE",
        "Arn": "arn:aws-cn:iam::123456789012:group/Admins", 
        "GroupName": "Admins"
    }
}
```
2. 键入[aws iam list-groups](https://docs.amazonaws.cn/cli/latest/reference/iam/list-groups.html) 命令以列出您的 AWS 账户中的组并确认该组已创建。
```
aws iam list-groups
{
    "Groups": [
        {
            "Path": "/", 
            "CreateDate": "2014-06-05T20:29:53.622Z", 
            "GroupId":"ABCDEFGHABCDEFGHABCDE", 
            "Arn": "arn:aws-cn:iam::123456789012:group/Admins", 
            "GroupName": "Admins"
        }
    ]
}
```
响应中包括您的新群组的 Amazon 资源名称 (ARN)。ARN 是 AWS 用于识别资源的标准格式。ARN 中的 12 位数字是您的 AWS 账户 ID。您分配至组 (Admins) 的易记名称将在组 ARN 的末尾显示。
##### 将策略附加到组 (AWS CLI)
添加提供了完整管理员权限的策略 (AWS CLI)
1. 键入 aws iam attach-group-policy 命令以将名为 AdministratorAccess 的策略附加到 Admins 组。该命令使用名为 AdministratorAccess 的 AWS 托管策略的 ARN。
   ```
   aws iam attach-group-policy --group-name Admins --policy-arn arn:aws-cn:iam::aws:policy/AdministratorAccess
   ```
   如果命令执行成功，则没有应答。
2. 键入 aws iam list-attached-group-policies 命令以确认该策略已附加到 Admins 组。
```
aws iam list-attached-group-policies --group-name Admins
```
在响应中列出附加到 Admins 组的策略名称。类似如下的响应告诉您名为 AdministratorAccess 的策略已附加到 Admins 组：
```
{
    "AttachedPolicies": [
        {
            "PolicyName": "AdministratorAccess",
            "PolicyArn": "arn:aws-cn:iam::aws:policy/AdministratorAccess"
        }
    ],
    "IsTruncated": false
}
```
您可使用 [aws iam get-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/get-policy.html) 命令来确认特定策略的内容。
> 重要：在您完成管理员群组的设置后，您必须在该群组中至少添加一位用户。有关向组中添加用户的更多信息，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。
##### 创建 IAM 用户（AWS CLI）
1. 创建用户：[aws iam create-user](https://docs.amazonaws.cn/cli/latest/reference/iam/create-user.html)
    ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-user --user-name "admin"
    {
        "User": {
            "UserName": "admin", 
            "Path": "/", 
            "CreateDate": "2019-08-03T01:32:54Z", 
            "UserId": "AIDAQCVPU47ABPOFBEDIN", 
            "Arn": "arn:aws:iam::005737080768:user/admin"
        }
    }
    ```
2. （可选）向用户提供对 AWS 管理控制台的访问权限。这需要密码。您必须还向用户提供您的账户登录页的 URL：
     [aws iam create-login-profile](https://docs.amazonaws.cn/cli/latest/reference/iam/create-login-profile.html)
    ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-login-profile --user-name "admin" --password "XXXX"
    {
        "LoginProfile": {
            "UserName": "admin", 
            "CreateDate": "2019-08-03T01:34:09Z", 
            "PasswordResetRequired": false
        }
    }
    ```
3. （可选）向用户提供编程访问。这需要访问密钥：[aws iam create-access-key](https://docs.amazonaws.cn/cli/latest/reference/iam/create-access-key.html)
   ```
    wangbb@wangbb-ThinkPad-T420:~/git/blogs$ aws iam create-access-key --user-name "admin"
    {
        "AccessKey": {
            "UserName": "admin", 
            "Status": "Active", 
            "CreateDate": "2019-08-03T01:37:14Z", 
            "SecretAccessKey": "I4EKl9sZfk29uTa6PbWtZY+XBSdJ0qFP7ZzNnUHy", 
            "AccessKeyId": "AKIAQCVPU47AIQNHHJFQ"
        }
    }
   ```
4. 将该用户添加到一个或多个组。您指定的组应具有用于向用户授予适当的权限的附加策略：[aws iam add-user-to-group](https://docs.amazonaws.cn/cli/latest/reference/iam/add-user-to-group.html)
5. （可选）向用户附加策略，此策略用于定义该用户的权限。注意：建议您通过将用户添加到一个组并向该组附加策略（而不是直接向用户附加策略）来管理用户权限：[aws iam attach-user-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/attach-user-policy.html)
6. （可选）通过附加标签来向用户添加自定义属性。有关更多信息，请参阅[管理 IAM 实体的标签（AWS CLI 或 AWS API）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html#id_tags_procs-cli-api)。
7. （可选）向用户授予用于管理其自身的安全凭证的权限。有关更多信息，请参阅AWS：[允许经过 MFA 身份验证的 IAM 用户在“My Security Credentials (我的安全凭证)”页面上管理自己的凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html)。
### 创建委派用户(Creating a Delegated User)
要支持您的 AWS 账户中的多个用户，您必须委派权限以允许其他人仅执行您要允许的操作。为此，请创建一个 IAM 组（其中具有这些用户所需的权限），然后在创建必要的组时将 IAM 用户添加到这些组。您可以使用此过程为您的整个 AWS 账户设置组、用户和权限。

此解决方案最适合中小型组织，其中 AWS 管理员可以手动管理用户和组。对于大型组织，您可以使用[自定义 IAM 角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)、[联合身份验证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers.html)或[单一登录](https://docs.amazonaws.cn/singlesignon/latest/userguide/what-is.html)。
#### 创建委派的 IAM 用户和组（控制台）
您可以使用 AWS 管理控制台创建具有委派权限的 IAM 组，然后为其他人创建 IAM 用户并将此用户添加到该组。
1. 登录 AWS 管理控制台 并通过以下网址打开[IAM 控制台](https://console.amazonaws.cn/iam/)
2. 在左侧的导航窗格中，选择策略。
3. 选择 Create policy。
4. 选择 JSON 选项卡，然后在窗口右侧，选择 Import managed policies (导入托管策略)。
5. 在 Import managed policies (导入托管策略) 窗口中，键入 power 以缩小策略列表。然后，选择 PowerUserAccess AWS 托管策略旁的按钮。
6. 选择 Import：导入策略将添加到您的 JSON 策略中。
7. 选择查看策略。
8. 在 Review (审核) 页面上，为 Name (名称) 键入 PowerUserExampleCorp。对于 Description (描述)，键入 Allows full access to all services except those for user management。然后，选择创建策略以保存您的工作。
9. 在导航窗格中，选择 Groups (组)，然后选择 Create New Group (创建新组)。
10. 在 Group Name (组名称) 框中，键入 PowerUsers。
11. 在策略列表中，选中 PowerUserExampleCorp 旁边的复选框。然后选择 Next Step。
12. 选择 Create Group。
13. 在导航窗格中，选择 Users (用户)，然后选择Add user (添加用户)。
14. 对于 User name，键入 mary.major@examplecorp.com。
15. 选择 Add another user (添加其他用户) 并键入 diego.ramirez@examplecorp.com 作为第二个用户。
16. 选中 AWS 管理控制台 access (AWS 管理控制台访问) 旁边的复选框，然后选择 Autogenerated password (自动生成的密码)。默认情况下，AWS 将强制新用户在首次登录时创建新密码。清除 User must create a new password at next sign-in (用户必须在下次登录时创建新密码) 旁边的复选框以允许新用户在登录后重置其密码
17. 选择 Next: Permissions (下一步: 权限)。
18. 在 Set permissions (设置权限) 页面上，选择 Add user to group (将用户添加到组) 并选中 PowerUsers 旁边的复选框。
19. 选择 Next: Tagging (下一步: 标记)。
20. （可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅[标记 IAM 实体](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。
21. 选择 Next: Review 以查看要添加到新用户的组成员资格的列表。如果您准备好继续，请选择 Create users (创建用户)。
22. 下载或复制新用户的密码并安全地将其提供给用户。单独为您的用户提供指向您的 IAM 用户控制台页面的链接以及您刚刚创建的用户名。
#### 减少组权限
PowerUser 组的成员可以完全访问除提供用户管理操作（如 IAM 和 组织）的少数服务之外的所有服务。经过预定义的不活动时段（如 90 天）后，您可以查看组成员已访问的服务。然后，您可以减少 PowerUserExampleCorp 策略的权限以仅包含您的团队所需的服务。
##### 查看上次访问的服务相关数据
等待预定义的不活动时段（如 90 天）经过。然后，您可以查看您的用户或组上次访问的服务相关数据，以了解您的用户上次尝试访问您的 PowerUserExampleCorp 策略允许的服务的时间。
1. 登录 AWS 管理控制台 并通过以下网址打开 [IAM 控制台](https://console.amazonaws.cn/iam/)。
2. 在导航窗格中，选择 Groups (组)，然后选择 PowerUser 组名称。
3. 在组摘要页面上，选择 Access Advisor (访问顾问) 选项卡。

  上次访问的服务相关数据表显示组成员上次尝试访问每个服务的时间（按时间顺序，从最近的尝试开始）。该表仅包含策略允许的服务。在此情况下，PowerUserExampleCorp 策略允许访问所有 AWS 服务。
4. 查看此表并生成您的组成员最近访问过的服务的列表。
##### 编辑策略以减少权限
在查看上次访问的服务相关数据后，可以编辑策略以仅允许访问您的用户所需的服务。
1. 在导航窗格中，选择 Policies (策略)，然后选择 PowerUserExampleCorp 策略名称。
2. 选择 Edit policy (编辑策略)，然后选择 JSON 选项卡。
3. 编辑 JSON 策略文档以仅允许所需的服务。
   例如，编辑第一个包括 Allow 效果和 NotAction 元素的语句以仅允许 Amazon EC2 和 Amazon S3 操作。为此，请将其替换为具有 FullAccessToSomeServices ID 的语句。您的新策略将类似于以下示例策略。
   ```
   {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "FullAccessToSomeServices",
                "Effect": "Allow",
                "Action": [
                    "ec2:*",
                    "s3:*"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:CreateServiceLinkedRole",
                    "iam:DeleteServiceLinkedRole",
                    "iam:ListRoles",
                    "organizations:DescribeOrganization"
                ],
                "Resource": "*"
            }
        ]
    }
   ```
4. 要进一步减少策略对特定操作和资源的权限，请在 CloudTrail Event history (事件历史记录) 中查看您的事件。在此处，您可以查看有关用户已访问的特定操作和资源的详细信息。有关更多信息，请参阅 AWS CloudTrail 用户指南 中的[在 CloudTrail 控制台中查看 CloudTrail 事件](https://docs.amazonaws.cn/awscloudtrail/latest/userguide/view-cloudtrail-events-console.html)。
### 用户如何登录您的账户
在您创建 IAM 用户（带有密码）后，这些用户可使用您的账户 ID 或别名登录到 AWS 管理控制台，或从一个包含您的账户 ID 的自定义 URL 进行登录。

> 注意：如果贵公司现在有一个身份系统，您可能需要创建单一登录 (SSO) 选项。SSO 向用户提供对 AWS 管理控制台 的访问权限，而不要求他们具有 IAM 用户身份。SSO 也无需用户单独登录您的组织的网站和 AWS。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。

## Reference
- [IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)
