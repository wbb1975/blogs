# IAM 身份(用户、组和角色)
本节介绍 IAM 身份，创建这些身份的目的是为了向您的 AWS 账户中的人员和过程提供身份验证。本节还介绍 IAM组，这是可以作为一个单位进行管理的 IAM 用户的集合。身份代表用户，可对身份进行验证，然后向其授予在 AWS 中执行操作的权限。每个部分均可与一个或多个策略相关联来决定用户、角色或组成员可在哪些条件下对哪些 AWS 资源执行哪些操作。
- **AWS 账户根用户**
  
    当您首次创建 Amazon Web Services (AWS) 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 AWS 账户根用户，可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。

    > **重要**  强烈建议您不使用 根用户 执行日常任务，即使是管理任务。请遵守[仅将根用户用于创建首个 IAM 用户的最佳实践](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#create-iam-users)。然后请妥善保存 根用户 凭证，仅用它们执行少数账户和服务管理任务。要查看需要您以根用户身份登录的任务，请参阅[需要根用户的 AWS 任务](https://docs.amazonaws.cn/general/latest/gr/aws_tasks-that-require-root.html)。
- **IAM 用户**
  
   IAM 用户 是您在 AWS 中创建的实体。IAM 用户表示使用 IAM 用户与 AWS 互动的人员或服务。IAM 用户的主要用途是使人们能够登录到 AWS 管理控制台以执行交互式任务，并向使用 API 或 CLI 的 AWS 服务发出编程请求。AWS 中的用户由用于登录 AWS 管理控制台的用户名和密码组成，最多可包含用于 API 或 CLI 的两个访问密钥。当您创建 IAM 用户时，通过使该用户成为附加了适当的权限策略的组的成员或者通过直接将策略附加到该用户，从而授予用户权限。您也可以克隆现有 IAM 用户的权限，这将使得新用户自动成为相同组的成员并附加所有相同的策略。
- **IAM 组**
  
   IAM 组是 IAM 用户的集合。您可以使用组为一组用户指定权限，以便更轻松地管理这些用户的权限。例如，您可能有一个名为 Admins 的组，并向该组授予管理员通常需要的权限类型。该组中的任何用户均自动具有分配给该组的权限。如果有新用户加入您的组织，并且应具有管理员权限，则可通过将该用户添加到该组，分配相应的权限。同样，如果您的组织中有人更换工作，则不必编辑该用户的权限，只需从旧组中将其删除，然后将其添加到合适的新组即可。请注意，组并不是真正的身份，因为无法在[基于资源的策略或信任策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_identity-vs-resource.html)中将其标识为 Principal。它只是用于一次性将策略附加到多个用户的方法。
- **IAM 角色**
  
   AM 角色非常类似于用户，因为它是一个实体，该实体具有确定其在 AWS 中可执行和不可执行的操作的权限策略。但是，角色没有任何关联的凭证（密码或访问密钥）。角色旨在让需要它的任何人代入，而不是唯一地与某个人员关联。IAM 用户可担任角色来暂时获得针对特定任务的不同权限。可将角色分配给使用外部身份提供程序而非 IAM 登录的[联合身份用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers.html)。AWS 使用由身份提供程序传递的详细信息来确定映射到联合身份用户的角色。
- **临时证书**
  
   临时凭证主要用于 IAM 角色，但也有其他用途。您可以请求权限集比标准 IAM 用户限制更严格的临时凭证。这可以防止您意外执行限制更严格的凭证不允许执行的任务。临时凭证的一个好处是会在设定的时间段后自动过期。您可以控制这些凭证的有效期。
### **何时创建 IAM 用户 (而不是角色)**
由于 IAM 用户只是您的账户中一个具有特定权限的身份，因此可能不需要为每个需要凭证的场合都创建 IAM 用户。在许多情况下，可利用 IAM 角色及其临时安全凭证来代替使用与 IAM 用户关联的长期凭证。
- **您创建了 AWS 账户，您是唯一使用您的账户的人员。**

  可通过您的 AWS 账户的根用户凭证使用 AWS，但我们建议不要这样做。相反，强烈建议您为自己创建一个 IAM 用户，并通过该用户的凭证使用 AWS。有关更多信息，请参阅IAM 最佳实践。

- **您所在组中的其他人需要在您的 AWS 账户中工作，而您的组不使用其他身份机制。**

  为需要访问您的 AWS 资源的个人创建 IAM 用户，向每个用户分配相应的权限，然后为每个用户提供他们的凭证。强烈建议您不要在多个用户间共享凭证。

- **您需要通过命令行界面 (CLI) 使用 AWS。**

  CLI 需要借助凭证才能调用 AWS。创建一个 IAM 用户，然后向该用户授予相应的权限，用于运行您需要的 CLI 命令。然后，将计算机上的 CLI 配置为使用与 IAM 用户关联的访问密钥凭证。
### **何时创建 IAM 角色 (而不是用户)**
在以下情况下创建 IAM 角色：
- **您要创建一个在 Amazon Elastic Compute Cloud (Amazon EC2) 实例上运行的应用程序，该应用程序向 AWS 提出请求。**
  
   请勿创建 IAM 用户并将该用户的凭证传递给该应用程序，也不要在该应用程序中嵌入凭证。相反，可创建附加到 EC2 实例的 IAM 角色来向实例上运行的应用程序提供临时安全凭证。这些凭证拥有附加到角色的策略中指定的权限。有关详细信息，请参阅[使用 IAM角色向在 Amazon EC2 实例上运行的应用程序授予权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)。
- **您正在创建一个应用程序，该应用程序在手机上运行，并向 AWS 发出请求。**
  
   请勿创建 IAM 用户并用该应用程序分发该用户的访问密钥。相反，请使用身份提供商 (如 Login with Amazon、Amazon Cognito、Facebook 或 Google) 验证用户的身份并将该用户映射到 IAM 角色。应用程序可使用角色获取临时安全凭证，这些凭证拥有附加到该角色的策略中指定的权限。有关更多信息，请参阅下列内容：
    + 适用于 Android 的 AWS 移动软件开发工具包 Developer Guide 中的[Amazon Cognito 概述](https://docs.amazonaws.cn/mobile/sdkforandroid/developerguide/cognito-auth.html#d0e840)
    + AWS Mobile SDK for iOS Developer Guide 中的[Amazon Cognito 概述](https://docs.amazonaws.cn/mobile/sdkforios/developerguide/cognito-auth.html#d0e664)
    + [关于 Web 联合身份验证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_oidc.html)
- **您公司中的用户在企业网络中进行身份验证，需要能够使用 AWS 而不必重新登录 — 即，您需要允许用户向 AWS 进行联合身份验证。**
  不要创建 IAM 用户。在您的企业身份系统和 AWS 之间配置联合关系。您可以通过两种方式执行此操作：
    + 如果您公司的身份系统与 SAML 2.0 兼容，则可在您公司的身份系统与 AWS 之间建立信任。有关更多信息，请参阅[关于基于 SAML 2.0 的联合身份验证](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_saml.html)。
    + 创建并使用将企业中的用户身份转换为 IAM 角色以及提供临时 AWS 安全凭证的自定义代理服务器。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。
## 用户
AWS Identity and Access Management (IAM) 用户 是您在 AWS 中创建的一个实体，该实体代表使用它与 AWS 进行交互的人员或应用程序。AWS 中的用户包括名称和凭证。

具备管理员权限的 IAM 用户与账户 AWS 账户根用户并不是一回事。有关 根用户 的更多信息，请参阅[AWS 账户根用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_root-user.html)。
- **AWS 如何标识 IAM 用户**
- **用户和凭证**
- **用户和权限**
- **用户和账户**
- **作为账户服务的用户**

### 添加用户
## 组
## 角色
## 标记实体
## 临时安全凭证
## 根用户
##  使用 CloudTrail 记录事件

## 参考
- [IAM身份](https://docs.amazonaws.cn/IAM/latest/UserGuide/id.html?shortFooter=true)