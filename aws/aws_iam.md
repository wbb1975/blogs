# AWS Identity and Access Management (IAM)

## 什么是 IAM？
AWS Identity and Access Management (IAM) 是一种 Web 服务，可以帮助您安全地控制对 AWS 资源的访问。您可以使用 IAM 控制对哪个用户进行身份验证 (登录) 和授权 (具有权限) 以使用资源。

当您首次创建 AWS 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 AWS账户根用户（root user），可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。强烈建议您不使用 根用户执行日常任务，即使是管理任务。请遵守仅将用于[创建首个 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html)的最佳实践。然后请妥善保存根用户凭证，仅用它们执行少数账户和服务管理任务。

### 了解 IAM 的工作方式
在创建用户之前，您应该了解 IAM 的工作方式。IAM 提供了控制您的账户的身份验证和授权所需的基础设施。IAM 基础设施包含以下元素：
- 术语
- 委托人(Principals)
- 请求
- 身份验证
- 授权
- 操作
- 资源

![IAM main elements](https://github.com/wbb1975/blogs/blob/master/aws/images/aws_iam_elements.png)
#### 术语
- 资源：存储在 IAM 中的用户、角色、组和策略对象。与其他 AWS 服务一样，您可以在 IAM 中添加、编辑和删除资源。
- 身份(Identities)：用于标识和分组的 IAM 资源对象。其中包括用户、组和角色。
- 实体(Entities)：AWS 用于进行身份验证的 IAM 资源对象。其中包括用户和角色。角色可以由您的账户或其他账户中的 IAM 用户以及通过 Web 身份或 SAML 联合的用户代入。
- 委托人：使用实体登录并向 AWS 发出请求的人员或应用程序。
#### 委托人
委托人 是可请求对 AWS 资源执行操作的人员或应用程序。作为委托人，您首先要以 AWS 账户根用户或 IAM 用户实体身份登录。作为最佳实践，请勿使用您的根用户执行日常工作。而是创建 IAM 实体（用户和角色）。您还可以支持联合身份用户或编程访问以允许应用程序访问您的 AWS 账户。
#### 请求
在委托人尝试使用 AWS 管理控制台、AWS API 或 AWS CLI 时，该委托人将向 AWS 发送请求。请求包含以下信息：
- 操作 – 委托人希望执行的操作。这可以是 AWS 管理控制台中的操作或者 AWS CLI 或 AWS API 中的操作。
- 资源 – 对其执行操作的 AWS 资源对象。
- 委托人 – 已使用实体（用户或角色）发送请求的人员或应用程序。有关委托人的信息包括与委托人用于登录的实体关联的策略。
- 环境数据 – 有关 IP 地址、用户代理、SSL 启用状态或当天时间的信息。
- 资源数据 – 与请求的资源相关的数据。这可能包括 DynamoDB 表名称或 Amazon EC2 实例上的标签等信息。
AWS 将请求信息收集到请求上下文中，后者用于评估和授权请求。
#### 身份验证
作为委托人，您必须使用 IAM 实体进行身份验证（登录到 AWS）才能将请求发送到 AWS。虽然某些服务（如 Amazon S3 和 AWS STS）允许一些来自匿名用户的请求，但它们是规则的例外情况。

要作为用户从控制台中进行身份验证，您必须使用用户名和密码登录。要从 API 或 AWS CLI 中进行身份验证，您必须提供访问密钥和私有密钥。您还可能需要提供额外的安全信息。例如，AWS 建议您使用多重验证 (MFA) 以提高您的账户的安全性。要了解有关 AWS 可验证的 IAM 实体的更多信息，请参阅[IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users.html)和[IAM 角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles.html)。
#### 授权
您还必须获得授权（允许）才能完成您的请求。在授权期间，AWS 使用请求上下文中的值来检查应用于请求的策略。然后，它使用策略来确定是允许还是拒绝请求。大多数策略作为[JSON 文档](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html#access_policies-json)存储在 AWS 中，并指定委托人实体的权限。有[多种类型的策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html)可影响是否对请求进行授权。要向用户提供访问他们自己账户中的 AWS 资源的权限，只需基于身份的策略。基于资源的策略常用于授予[跨账户](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html#UserPermissionsAcrossAccounts)访问。其他策略类型是高级功能，应谨慎使用。

AWS 检查应用于请求上下文的每个策略。如果一个权限策略包含拒绝的操作，AWS 将拒绝整个请求并停止评估。这称为显式拒绝。由于请求是默认被拒绝的，因此，只有在适用的权限策略允许请求的每个部分时，AWS 才会授权请求。单个账户中对于请求的评估逻辑遵循以下一般规则：
- 默认情况下，所有请求都将被拒绝。（通常，始终允许使用 AWS 账户根用户凭证创建的访问该账户资源的请求。）
- 任何权限策略（基于身份(identity-based)或基于资源）中的显式允许将覆盖此默认值。
- 组织 SCP、IAM 权限边界或会话策略的存在将覆盖允许。如果存在其中一个或多个策略类型，它们必须都允许请求。否则，将隐式拒绝它。
- 任何策略中的显式拒绝将覆盖任何允许。
要了解有关如何评估所有类型的策略的更多信息，请参阅[策略评估逻辑](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)。如果您需要在另一个账户中发出请求，此其他账户中的策略必须允许访问资源，并且 您用于发出请求的 IAM 实体必须具有允许该请求的基于身份的策略。
#### 操作
在对您的请求进行身份验证和授权后，AWS 将批准请求中的操作。操作是由服务定义的，包括可以对资源执行的操作，例如，查看、创建、编辑和删除该资源。例如，IAM 为用户资源支持大约 40 个操作，包括以下操作：
CreateUser
DeleteUser
GetUser
UpdateUser
要允许委托人执行操作，您必须在应用于委托人或受影响的资源的策略中包含所需的操作。要查看每个服务支持的操作、资源类型和条件键的列表，请参阅[AWS服务的操作、资源类型和条件键](https://docs.amazonaws.cn/en_us/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)。
#### 资源
在 AWS 批准请求中的操作后，可以对您的账户中的相关资源执行这些操作。资源是位于服务中的对象。示例包括 Amazon EC2 实例、IAM 用户和 Amazon S3 存储桶。服务定义了一组可对每个资源执行的操作。如果创建一个请求以对资源执行不相关的操作，则会拒绝该请求。例如，如果您请求删除一个 IAM 角色，但提供一个 IAM 组资源，请求将失败。要查看确定操作影响哪些资源的 AWS 服务表，请参阅[AWS服务的操作、资源类型和条件键](https://docs.amazonaws.cn/en_us/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)。

## Reference
- [IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)
