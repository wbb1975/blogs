## IAM 最佳实践
要帮助保护 AWS 资源，请遵循针对 AWS Identity and Access Management (IAM) 服务的这些建议。
### 隐藏您的 AWS 账户根用户 访问密钥
使用访问密钥 (访问密钥 ID 和私有访问密钥) 以编程方式向 AWS 提出请求。但是，请勿使用您的 AWS 账户根用户访问密钥。您的 AWS 账户根用户的访问密钥提供对所有 AWS 服务的所有资源（包括您的账单信息）的完全访问权限。您无法减少与您的 AWS 账户根用户访问密钥关联的权限。

因此，在保护根用户访问密钥时应像对待您的信用卡号或任何其他敏感机密信息一样。以下是执行该操作的一些方式：
- 如果您的 AWS 账户根用户尚无访问密钥，除非绝对需要，否则请勿创建它。而应使用您的账户电子邮件地址和密码登录 AWS 管理控制台，并[为自己创建具有管理权限的 IAM 用户 ](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。
- 如果您的 AWS 账户根用户具有访问密钥，请删除它。如果您一定要保留它，请定期轮换（更改）访问密钥。要删除或轮换 根用户 访问密钥，请转至 AWS 管理控制台中的“[我的安全凭证](https://console.amazonaws.cn/iam/home?#security_credential)”页并使用您账户的电子邮件地址和密码登录。您可以在 Access keys 部分中管理您的访问密钥。有关轮换访问密钥的更多信息，请参阅[轮换访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey)。
- 切勿与任何人共享您的 AWS 账户根用户密码或访问密钥。本文档的其余部分讨论了避免与其他用户分享您的 AWS 账户根用户凭证，以及避免将凭证嵌入应用程序中的几种方法。
- 使用强密码有助于保护对 AWS 管理控制台 进行账户级别的访问。有关管理 AWS 账户根用户 密码的信息，请参阅[更改 AWS 账户根用户密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_change-root.html)。
- 对您的 AWS 账户启用 AWS 账户根用户 Multi-Factor Authentication (MFA)。有关更多信息，请参阅[在AWS 中使用多重身份验证 (MFA)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa.html)。
### 创建单独的 IAM 用户
请勿使用 AWS 账户根用户 凭证访问 AWS，也不要将凭证授予任何其他人。您应为需要访问您 AWS 账户的任何人创建单独的用户。同时，您也要为自己创建一个 IAM 用户，并授予该用户管理权限，以使用该 IAM 用户执行您的所有工作。有关如何执行此操作的信息，请参阅[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

在为访问您的账户的人员创建单独的 IAM 用户时，您可授予每个 IAM 用户一组独特的安全证书。您还可向每个 IAM 用户授予不同的权限。如有必要，您可随时更改或撤销 IAM 用户的权限。(如果您公布了根用户凭证，则很难将其撤消，且不可能限制它们的权限。)
> **注意： 在针对单独的 IAM 用户设置权限之前，请参阅下一个关于组的要点。**
### 使用组向 IAM 用户分配权限
而不是为各个 IAM 用户定义权限，这样做通常可以更方便地创建与工作职能 (管理员、开发人员、会计人员等) 相关的组。接下来，定义与每个组相关的权限。最后，将 IAM 用户分配到这些组。一个 IAM 组中的所有用户将继承分配到该组的权限。这样，您在一个位置即可更改群组内的所有人。公司人员发生调动时，您只需更改 IAM 用户所属的 IAM 组。

有关更多信息，请参阅下列内容：
- [创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)
- [管理 IAM 组](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_groups_manage.html)
### 授予最低权限
创建 IAM 策略时，请遵循授予最小权限 这一标准安全建议，或仅授予执行任务所需的权限。首先，确定用户需要执行的任务，然后，拟定仅限用户执行这些任务的策略。

最开始只授予最低权限，然后根据需要授予其他权限。这样做比起一开始就授予过于宽松的权限而后再尝试收紧权限来说更为安全。

您可以使用访问级别分组来了解策略授予的访问级别。[策略操作](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_elements_action.html)被归类为 List、Read、Write、Permissions management 或 Tagging。例如，您可以从 List 和 Read 访问级别中选择操作，以向您的用户授予只读访问权限。要了解如何使用策略摘要来了解访问级别权限，请参阅[使用访问权限级别查看 IAM 权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#use-access-levels-to-review-permissions)。

对此有帮助的一项功能是上次访问的服务相关数据。在 IAM 控制台详细信息页面上的 Access Advisor (访问顾问) 选项卡上查看用户、组、角色或策略的此类数据。您还可以使用 AWS CLI 或 AWS API 检索上次访问的服务相关数据。此数据包括有关用户、组、角色或使用策略的任何人尝试访问哪些服务以及何时访问的信息。您可以使用此信息确定不必要的权限，从而优化 IAM 策略以更好地遵循最小特权原则。有关更多信息，请参阅[使用上次访问的服务相关数据减少权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_access-advisor.html)。

要进一步减少权限，您可以在 CloudTrail Event history (事件历史记录) 中查看您账户的事件。CloudTrail 事件日志包含您可用于减少策略权限的详细事件信息且仅包含您的 IAM 实体所需的操作和资源。有关更多信息，请参阅 AWS CloudTrail 用户指南 中的[在 CloudTrail 控制台中查看 CloudTrail 事件](https://docs.amazonaws.cn/awscloudtrail/latest/userguide/view-cloudtrail-events-console.html)。

有关更多信息，请参阅下列内容：
- [访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)
- 在单个产品的策略主题中，提供了如何针对特定产品的资源编写策略的示例。示例
   + Amazon DynamoDB 开发人员指南 中的[Amazon DynamoDB 身份验证和访问控制](https://docs.amazonaws.cn/amazondynamodb/latest/developerguide/UsingIAMWithDDB.html)
   + Amazon Simple Storage Service 开发人员指南中的[使用存储桶策略和用户策略](https://docs.amazonaws.cn/AmazonS3/latest/dev/using-iam-policies.html)。
   + Amazon Simple Storage Service 开发人员指南 中的[访问控制列表 (ACL) 概述](https://docs.amazonaws.cn/AmazonS3/latest/dev/acl-overview.html)
### 利用 AWS 托管策略开始使用权限 (Get Started Using Permissions with AWS Managed Policies)
仅为您的员工提供其所需的权限需要时间和详细的 IAM 策略知识。员工需要时间来了解他们希望或需要使用哪些 AWS 服务。管理员需要时间来了解和测试 IAM。

要快速入门，您可以使用 AWS 托管策略为您的员工提供其入门所需的权限。这些策略已在您的账户中提供，并由 AWS 维护和更新。有关 AWS 托管策略的更多信息，请参阅[AWS 托管策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#aws-managed-policies)。

AWS 托管策略可用于为很多常用案例提供权限。完全访问 AWS 托管策略（如 [AmazonDynamoDBFullAccess](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess) 和 [IAMFullAccess](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/IAMFullAccess)）通过授予对服务的完全访问权限来定义服务管理员的权限。高级用户 AWS 托管策略（如 [AWSCodeCommitPowerUser](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AWSCodeCommitPowerUser) 和 [AWSKeyManagementServicePowerUser](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser)）提供对 AWS 服务的多个级别的访问权限，但未授予管理权限。部分访问 AWS 托管策略（如 [AmazonMobileAnalyticsWriteOnlyAccess](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AmazonMobileAnalyticsWriteOnlyAccess) 和 [AmazonEC2ReadOnlyAccess](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess)）提供对 AWS 服务的特定级别的访问权限。利用 AWS 托管策略，您可更轻松地为用户、组和角色分配相应权限，而不必自己编写策略。

AWS 工作职能托管策略可以跨越多项服务，并与 IT 行业的常见工作职能紧密贴合。有关工作职能策略的列表和说明，请参阅[工作职能的 AWS 托管策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_job-functions.html)。
### 使用客户托管策略而不是内联策略 (Use Customer Managed Policies Instead of Inline Policies)
对于自定义策略，建议您使用托管策略而不是内联策略。使用这些策略的一个重要优势是，您可以在控制台中的一个位置查看所有托管策略。您还可以使用单个 AWS CLI 或 AWS API 操作查看此信息。内联策略是仅 IAM 身份（用户、组或角色）具有的策略。托管策略是可附加到多个身份的独立的 IAM 资源。有关更多信息，请参阅[托管策略与内联策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)。

如果您的账户中具有内联策略，则可将其转换为托管策略。为此，请将策略复制到新的托管策略，将新策略附加到具有内联策略的身份，然后删除内联策略。您可使用以下说明执行此操作。

将内联策略转换为托管策略：
1. 登录 AWS 管理控制台 并通过以下网址打开 IAM 控制台 https://console.amazonaws.cn/iam/。
2. 在导航窗格中，选择 Groups、Users 或 Roles。
3. 在列表中，选择具有要修改的策略的组、用户或角色的名称。
4. 选择 Permissions 选项卡。如果您选择 Groups，请根据需要展开 Inline Policies 部分。
5. 对于组，选择要删除的内联策略旁边的 Show Policy (显示策略)。对于用户和角色，选择 Show n more (再显示 n 个)（如有必要），然后选择要删除的内联策略旁边的箭头。
6. 复制策略的 JSON 策略文档。
7. 在导航窗格中，选择 Policies。
8. 选择 Create policy (创建策略)，然后选择 JSON 选项卡。
9. 将现有文本替换为您的 JSON 策略文本，然后选择 Review policy (查看策略)。
10. 为您的策略输入名称，然后选择 Create policy (创建策略)。
11. 在导航窗格中，选择 Groups (组)、Users (用户) 或 Roles (角色)，然后再次选择具有要删除的策略的组、用户或角色的名称。
12. 对于组，选择 Attach Policy (附加策略)。对于用户和角色，选择 Add permissions (添加权限)。
13. 对于组，选中新策略名称旁的复选框，然后选择 Attach Policy (附加策略)。对于用户或角色，选择 Add permissions (添加权限)。在下一页上，选择 Attach existing policies directly (直接附加现有策略)，选中您的新策略名称旁的复选框，选择 Next: Review (下一步: 查看)，然后选择 Add permissions (添加权限)。

您将返回您的组、用户或角色的 Summary (摘要) 页面。
14. 对于组，选择要删除的内联策略旁边的 Remove Policy (删除策略)。对于用户或角色，选择要删除的内联策略旁边的 X。

在某些情况下，我们建议您选择内联策略而不是托管策略。有关详细信息，请参阅[在托管策略与内联策略之间进行选择](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_managed-vs-inline.html#choosing-managed-or-inline)。
### 使用访问权限级别查看 IAM 权限 (Use Access Levels to Review IAM Permissions)
要增强您的 AWS 账户的安全性，您应该定期查看和监控每个 IAM 策略。请确保您的策略仅授予执行必需的操作所需要的[最低特权](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#grant-least-privilege)。

当您查看一个策略时，您可以查看[策略摘要](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand.html)，其中包括该策略中每个服务的访问权限级别的摘要。AWS 基于每个服务操作的用途将其分类为四个访问权限级别 之一：List、Read、Write 或 Permissions management。您可以使用这些访问权限级别确定将哪些操作包含在您的策略中。

例如，在 Amazon S3 服务中，您可能想允许一大组用户访问 List 和 Read 操作。此类操作允许这些用户列出存储桶和获取存储在 Amazon S3 中的对象。但是，您应当只允许一小组用户访问 Amazon S3 Write 操作以删除存储桶或将对象放入 S3 存储桶。此外，您还应减少权限以仅允许管理员访问 Amazon S3 Permissions management 操作。这可确保只有有限数量的人员可以在 Amazon S3 中管理存储桶策略。这对于 IAM 和 AWS Organizations 服务中的 Permissions management 操作特别重要。

要查看分配给服务中的每个操作的访问级别分类，请参阅[AWS服务的操作，资源和条件密钥](https://docs.amazonaws.cn/en_us/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)。

要查看一个策略的访问权限级别，必须先找到该策略的摘要。在托管策略的 Policies 页面中以及附加到用户的策略的 Users 页面中，都包含此策略摘要。有关更多信息，请参阅[策略摘要 (服务列表)](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand-policy-summary.html)。

在策略摘要中，Access level (访问级别) 列显示出策略提供对服务的四个 AWS 访问权限级别中的一个或多个级别的 Full (完全) 或 Limited (受限) 访问权限。此外，它还可能显示该策略提供对服务中的所有操作的 Full access 访问权限。您可以使用此 Access level 列中的信息来了解策略提供的访问权限级别。然后可以采取措施加强您的 AWS 账户安全。有关访问权限级别摘要的详细信息和示例，请参阅了解[策略摘要内的访问级别摘要](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_understand-policy-summary-access-level-summaries.html)。
### 为您的用户配置强密码策略
如果允许用户更改其密码，则需要他们创建强密码并且定期轮换其密码。在 IAM 控制台的[Account Settings (账户设置)](https://console.amazonaws.cn/iam/home?#account_settings) 页面中，可以为账户创建密码策略。您可以使用策略密码定义密码要求，如最短长度、是否需要非字母字符、必须进行轮换的频率等。

有关更多信息，请参阅 为[IAM 用户设置账户密码策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html)。
### 为特权用户启用 MFA
为增强安全性，应为持有特权的 IAM 用户 (获准访问敏感资源或 API 操作的用户) 启用多重验证 (MFA)。启用 MFA 后，用户便拥有了一部可生成身份验证质询响应的设备。用户的凭证和设备生成的响应是完成登录过程所必需的。通过以下方式之一生成响应：

- 虚拟和硬件 MFA 设备生成代码，您可以在应用程序或设备上进行查看，然后在登录屏幕上输入代码。
- 点击设备时 U2F 安全密钥生成响应。用户不能手动在登录屏幕上输入代码。

有关更多信息，请参阅在[AWS 中使用多重身份验证 (MFA](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa.html)。
### 针对在 Amazon EC2 实例上运行的应用程序使用角色
在 Amazon EC2 实例上运行的应用程序需要证书才能访问其他 AWS 服务。若要以安全的方式提供应用程序所需的证书，可使用 IAM 角色。角色是指自身拥有一组许可的实体，但不是指用户或群组。角色没有自己的一组永久凭证，这也与 IAM 用户不一样。对于 Amazon EC2，IAM 将向 EC2 实例动态提供临时证书，这些证书将为您自动轮换。

当您启动 EC2 实例时，您可指定实例的角色，以作为启动参数。在 EC2 实例上运行的应用程序在访问 AWS 资源时可使用角色的凭证。角色的许可将确定允许访问资源的应用程序。

有关更多信息，请参阅[使用 IAM角色向在 Amazon EC2 实例上运行的应用程序授予权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)。
### 使用角色委托权限 (Use Roles to Delegate Permissions)
请勿在不同账户之间共享安全凭证，防止另一个 AWS 账户的用户访问您 AWS 账户中的资源。而应使用 IAM 角色。您可以定义角色来指定允许其他账户中的 IAM 用户拥有哪些权限。您还可以指定哪些 AWS 账户拥有允许代入该角色的 IAM 用户。

有关更多信息，请参阅[角色术语和概念](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_terms-and-concepts.html)。
### 不共享访问密钥
访问密钥提供对 AWS 的编程访问。不要在未加密代码中嵌入访问密钥，也不要在您的 AWS 账户中的用户之间共享这些安全凭证。对于需要访问 AWS 的应用程序，将程序配置为使用 IAM 角色检索临时安全凭证。要允许您的用户单独以编程方式访问，请创建具有个人访问密钥的 IAM 用户。

有关更多信息，请参阅[切换至 IAM 角色 (AWS API)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-api.html) 和[管理 IAM 用户的访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html)。
### 定期轮换凭证
定期更改您自己的密码和访问密钥，并确保账户中的所有 IAM 用户也这么做。这样，若在您不知情的情况下密码或访问密钥外泄，则您可限制证书在多长时间之内可用于访问资源。您的账户可以使用密码策略，以要求您的所有 IAM 用户轮换他们的密码，并且您可以选择他们必须多久执行一次该操作。

有关在您的账户中设置密码策略的更多信息，请参阅为[IAM 用户设置账户密码策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html)。

有关轮换 IAM 用户的访问密钥的更多信息，请参阅[轮换访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey)。
### 删除不需要的凭证
删除不需要的 IAM 用户凭证（密码和访问密钥）。例如，如果您为应用程序创建了一个不使用控制台的 IAM 用户，则该 IAM 用户无需密码。同样，如果用户仅使用控制台，请删除其访问密钥。最近未使用的密码和访问密钥可能适合做删除处理。您可以使用控制台、CLI 或 API 或者通过下载凭证报告来查找未使用的密码或访问密钥。

有关查找最近未用过的 IAM 用户凭证的更多信息，请参阅[查找未使用的凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_finding-unused.html)。

有关删除 IAM 用户密码的更多信息，请参阅[管理 IAM 用户的密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_admin-change-user.html)。

有关停用或删除 IAM 用户访问密钥的更多信息，请参阅[管理 IAM 用户的访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html)。

有关 IAM 证书报告的更多信息，请参见[获取您 AWS 账户的凭证报告](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_getting-report.html)。
### 使用策略条件来增强安全性
在切实可行的范围内，定义在哪些情况下您的 IAM 策略将允许访问资源。例如，您可编写条件来指定请求必须来自允许的 IP 地址范围。您还可以指定只允许在指定日期或时间范围内的请求。您还可设置一些条件，如要求使用 SSL 或 MFA (Multi-Factor Authentication)。例如，您可要求用户使用 MFA 设备进行身份验证，这样才允许其终止某一 Amazon EC2 实例。

有关更多信息，请参阅 IAM 策略元素参考中的[IAM JSON 策略元素：Condition](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_elements_condition.html)。
### 监控 AWS 账户中的活动
您可以使用 AWS 中的日志记录功能来确定用户在您的账户中进行了哪些操作，以及使用了哪些资源。日志文件会显示操作的时间和日期、操作的源 IP、哪些操作因权限不足而失败等。

日志记录功能在以下 AWS 服务中可用：
+ [Amazon CloudFront](http://www.amazonaws.cn/cloudfront/) – 记录 CloudFront 收到的用户请求。有关更多信息，请参阅 Amazon CloudFront 开发人员指南 中的[访问日志](https://docs.amazonaws.cn/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)。
+ [AWS CloudTrail](http://www.amazonaws.cn/cloudtrail/) – 记录由某个 AWS 账户发出或代表该账户发出的 AWS API 调用和相关事件。有关更多信息，请参阅[AWS CloudTrail User Guide](https://docs.amazonaws.cn/awscloudtrail/latest/userguide/)。
+ [Amazon CloudWatch](http://www.amazonaws.cn/cloudwatch/) – 监控您的 AWS 云资源以及您在 AWS 上运行的应用程序。您可以在 CloudWatch 中基于您定义的指标设置警报。有关更多信息，请参见[Amazon CloudWatch 用户指南](https://docs.amazonaws.cn/AmazonCloudWatch/latest/DeveloperGuide/)。
+ [AWS Config](http://www.amazonaws.cn/config/) – 提供有关您的 AWS 资源（包括您的 IAM 用户、组、角色和策略）的配置的详细历史信息。例如，您可以使用 AWS Config 确定在某个特定时间属于某个用户或组的权限。有关更多信息，请参见[AWS Config Developer Guide](https://docs.amazonaws.cn/config/latest/developerguide/)。
+ [Amazon Simple Storage Service (Amazon S3)](http://www.amazonaws.cn/s3/) – 记录发送到您的 Amazon S3 存储桶的访问请求。有关更多信息，请参阅Amazon Simple Storage Service 开发人员指南中的[服务器访问日志记录](https://docs.amazonaws.cn/AmazonS3/latest/dev/ServerLogs.html)。
### 关于 IAM 最佳实践的视频演示
下列视频中包含一份会议报告，其中涵盖了这些最佳实践，并介绍了如何使用上述功能的更多详细信息。

[IAW Vedio](https://www.youtube.com/embed/_wiGpBQGCjU)
## 商用案例
IAM 的简单商用案例可帮助您了解使用该服务来控制您的用户所拥有的 AWS 访问权限的基本方法。此使用案例只是粗略介绍，并未涵盖您使用 IAM API 来实现所需结果的技术性细节。

此使用案例将探讨一家名为 Example Corp 的虚构公司可能使用 IAM 的两种典型方式。第一个场景考虑 Amazon Elastic Compute Cloud (Amazon EC2)。第二个场景考虑 Amazon Simple Storage Service (Amazon S3)。

有关通过 AWS 的其他服务使用 IAM 的更多信息，请参阅使用[IAM 的 AWS 服务](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_aws-services-that-work-with-iam.html)。
### Example Corp 的初始设置
John 是 Example Corp 创始人。在公司成立之初，他创建了自己的 AWS 账户，他本人使用 AWS 产品。之后，他雇佣了员工，担任开发人员、管理员、测试人员、经理及系统管理员。

John 通过 AWS 账户根用户 凭证使用 AWS 管理控制台，为自己创建了名为 John 的用户以及名为 Admins 的组。他使用 AWS 托管策略 [AdministratorAccess](https://console.amazonaws.cn/iam/home#policies/arn:aws:iam::aws:policy/AdministratorAccess) 向 Admins 组授予了对所有 AWS 账户的资源执行所有操作的权限。然后，他将 John 用户添加到了 Admins 组中。有关为您自己创建管理员组和 IAM 用户，然后将用户添加至管理员组的分步指南，请参阅[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

此时，John 可以停止使用 根用户 的凭证与 AWS 交互，他开始只使用自己的用户凭证。

John 还创建了一个名为 AllUsers 的组，这样他就可以将任何账户范围内的权限轻松应用于 AWS 账户内的所有用户。他将本人添加至该群组。随后，他又创建了名为 Developers、Testers、Managers 及 SysAdmins 的群组。他为每位员工创建了用户，并将这些用户归入各自的群组。他还将所有用户添加至 AllUsers 群组。有关创建组的信息，请参阅[创建 IAM 组](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_groups_create.html)。有关创建用户的信息，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。有关向组中添加用户的信息，请参阅[管理 IAM 组](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_groups_manage.html)。
### IAM 与 Amazon EC2 结合使用的使用案例
类似 Example Corp 的公司通常使用 IAM 与类似 Amazon EC2 的服务互动。如要理解使用案例的这一部分，您需要对 Amazon EC2 有基本的了解。有关 Amazon EC2 的更多信息，请访问[Amazon EC2 用户指南（适用于 Linux 实例）](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/)。
#### 用于组的 Amazon EC2 许可
为提供“周边(perimeter)”控制，John 对 AllUsers 组附加了一个策略。如果来源 IP 地址位于 Example Corp 企业网络外部，则该策略拒绝用户的任何 AWS 请求。

在 Example Corp.，不同的组需要不同的权限：
- **System administrators** – 需要创建和管理 AMI、实例、快照、卷、安全组等的权限。John 向 SysAdmins 组附加了一个策略，以为该组成员授予使用所有 Amazon EC2 操作的权限。
- **Developers** – 只需能够使用实例即可。因此，John 向 Developers 组附加了策略，以允许开发人员调用 DescribeInstances、RunInstances、StopInstances、StartInstances 及 TerminateInstances。
  > Amazon EC2 使用 SSH 密钥、Windows 密码及安全组来控制哪些人能够访问特定 Amazon EC2 实例的操作系统。在 IAM 系统中，无法允许或拒绝访问特定实例的操作系统。
- **Managers** – 无法执行任何 Amazon EC2 操作，但可列出当前可用的 Amazon EC2 资源。因此，John 向 Managers 组附加了一个策略，以便仅允许该组成员调用 Amazon EC2 "Describe" API 操作。

如需有关上述策略具体形式的示例，请参阅Amazon EC2 用户指南（适用于 Linux 实例）中的[IAM 基于身份的策略示例](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)和[使用 AWS Identity and Access Management](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)。
#### 用户的角色转换
此时，其中一位开发人员 Paulo 的角色发生转变，成为一名管理人员。John 将 Paulo 从 Developers 组移至 Managers 组。现在，Paulo 位于 Managers 组，因此他与 Amazon EC2 实例交互的能力受到限制。他无法启动或启用实例。即使他是启动或启用实例的用户，也无法停止或终止现有实例。他只能列出 Example Corp 用户已启动的实例。
### IAM 与 Amazon S3 结合使用的使用案例
类似 Example Corp 的公司通常还通过 Amazon S3 使用 IAM。John 已为公司创建了 Amazon S3 存储桶，并将其命名为 example_bucket。
#### 创建其他用户和群组
作为员工，Zhang 和 Mary 都需要能够在公司的存储桶中创建自己的数据。他们还需要读取和写入所有开发人员都要处理的共享数据。为做到这一点，John 采用 Amazon S3 密钥前缀方案，在 example_bucket 中按照逻辑方式排列数据，如下图所示。
```
/example_bucket
    /home
        /zhang
        /mary
    /share
        /developers
        /managers
```
John 针对每位员工将主 /example_bucket 分隔成一系列主目录，并为开发人员和管理人员组留出一个共享区域。

现在，John 创建一组策略，以便向用户和组分配权限：
+ **Zhang 的主目录访问** – John 向 Zhang 附加的策略允许后者读取、写入和列出带 Amazon S3 密钥前缀 /example_bucket/home/Zhang/ 的任何对象
+ **Mary 的主目录访问** – John 向 Mary 附加的策略允许后者读取、写入和列出带 Amazon S3 键前缀 /example_bucket/home/mary/ 的任何对象
+ **Developers 组的共享目录访问** – John 向该组附加的策略允许开发人员读取、写入和列出 /example_bucket/share/developers/ 中的任何对象
+ **Managers 组的共享目录访问** – John 向该组附加的策略允许管理人员读取、写入和列出 /example_bucket/share/managers/ 中的对象
> **注意**：对于创建存储段或对象的用户，Amazon S3 不会自动授予其对存储段或对象执行其他操作的许可。因此，在您的 IAM 策略中，您必须显式授予用户使用他们所创建的 Amazon S3 资源的许可。

如需有关上述策略具体形式的示例，请参见 Amazon Simple Storage Service 开发人员指南 中的[Access Control](https://docs.amazonaws.cn/AmazonS3/latest/dev/UsingAuthAccess.html)。有关如何在运行时对策略进行评估的信息，请参阅[策略评估逻辑](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)。
#### 用户的角色转换
此时，其中一位开发人员 Zhang 的角色发生转变，成为一名管理人员。我们假设他不再需要访问 share/developers 目录中的文档。作为管理员，John 将 Zhang 从 Managers 组移至 Developers 组。通过简单的重新分配，Zhang 将自动获得所有授予给 Managers 组的权限，但将无法再访问 share/developers 目录中的数据。
#### 与第三方企业集成
组织经常与合作公司、顾问及承包商合作。Example Corp 是 Widget Company 的合作伙伴，而 Widget Company 的员工 Shirley 需要将数据放入存储桶中，以供 Example Corp 使用。John 创建了一个名为 WidgetCo 的组和名为 Shirley 的用户，并将 Shirley 添加至 WidgetCo 组。John 还创建了一个名为 example_partner_bucket 的专用存储桶，以供 Shirley 使用。

John 更新现有策略或添加新的策略来满足合作伙伴 Widget Company 的需求。例如，John 可新建用于拒绝 WidgetCo 组成员使用任何操作 (写入操作除外) 的策略。除非有一个广泛的策略，授予所有用户访问大量 Amazon S3 操作的许可，否则此策略将非常必要。

## 参考
- [IAM 最佳实践和使用案例](https://docs.amazonaws.cn/IAM/latest/UserGuide/IAMBestPracticesAndUseCases.html)