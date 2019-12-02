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

  当您创建用户时，IAM 提供以下这些方法来识别该用户：
   + 该用户的“易记名称”，这是您在创建该用户时指定的名称，如 Richard 或 Anaya。您将在 AWS 管理控制台中看到这些名称。
   + 用户的 Amazon 资源名称 (ARN)。当您需要跨所有 AWS 唯一标识用户时，可以使用 ARN。例如，您可以使用 ARN 在 Amazon S3 存储桶的 IAM 策略中将用户指定为 Principal。IAM 用户的 ARN 可能类似于以下内容：arn:aws-cn:iam::account-ID-without-hyphens:user/Richard
   + 用户的唯一标识符。仅在您使用 API、Windows PowerShell 工具 或 AWS CLI 创建用户时返回此 ID；控制台中不会显示此 ID。

  有关这些标识符的更多信息，请参阅[IAM 标识符](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_identifiers.html)。
- **用户和凭证**
  
    您可以通过不同方式访问 AWS，具体取决于用户凭证：
  + 控制台密码：密码，用户可键入密码以登录交互式会话，例如 AWS 管理控制台。
  + 访问密钥：访问密钥 ID 和秘密访问密钥的组合。您可以一次向一个用户分配两个访问密钥。这些可用于对 AWS 进行编程调用。例如，在使用代码的 API 时，或在 AWS CLI 或 AWS PowerShell 工具的命令提示符下，您可能会使用访问密钥。
  + 与 CodeCommit 结合使用的 SSH 密钥：可用于向 CodeCommit 进行身份验证的采用 OpenSSH 格式的 SSH 公有密钥。
  + 服务器证书：您可用于向某些 AWS 服务进行身份验证的 SSL/TLS 证书。我们建议您使用 AWS Certificate Manager (ACM) 来预置、管理和部署您的服务器证书。只有当您必须在 ACM 不支持的区域中支持 HTTPS 连接时，才应使用 IAM。要了解 ACM 支持哪些区域，请参阅 AWS General Reference 中的 [AWS Certificate Manager 区域和终端节点](http://docs.aws.amazon.com/general/latest/gr/rande.html#acm_region)。
  
  您可以选择最适合您的 IAM 用户的凭证。当您使用 AWS 管理控制台来创建用户时，必须选择至少包含一个控制台密码或访问密钥。默认情况下，使用 AWS CLI 或 AWS API 创建的全新 IAM 用户没有任何类型的凭证。您必须根据 IAM 用户需求为该用户创建凭证类型。

  可使用以下选项管理密码、访问密钥和 MFA 设备：
  + 管理 IAM 用户的密码。 创建和更改允许访问 AWS 管理控制台的密码。设置密码策略以强制实施最小密码复杂性。允许用户更改其密码。
  + 管理 IAM 用户的访问密钥。 创建和更新用于通过编程方式访问账户中的资源的访问密钥。
  + 您可以通过为用户启用 Multi-Factor Authentication (MFA)，增强用户证书的安全性。使用 MFA，用户必须提供两种形式的身份证明：首先，他们提供属于用户身份一部分的凭证（密码或访问密钥）。此外，他们提供在硬件设备上或由智能手机或平板电脑上的应用程序生成的或者由 AWS 发送到与 SMS 兼容的移动设备的临时数字代码。
  + 查找未使用的密码和访问密钥。 拥有您账户或您账户中的 IAM 用户的密码或访问密钥的任何人都可以访问您的 AWS 资源。安全最佳实践是，在用户不再需要密码和访问密钥时将其删除。
  + 下载您账户的凭证报告。 您可以生成和下载列出您账户中所有 IAM 用户及其各个凭证状态（包括密码、访问密钥和 MFA 设备）的凭证报告。对于密码和访问密钥，凭证报告将显示多久前使用了密码或访问密钥。
- **用户和权限**

  默认情况下，全新的 IAM 用户没有执行任何操作的权限。该用户无权执行任何 AWS 操作或访问任何 AWS 资源。采用单独 IAM 用户的优势在于可单独向每个用户分配权限。您可以向几个用户分配管理权限，而这些用户随后可管理您的 AWS 资源，甚至创建和管理其他 IAM 用户。但在大多数情况下，您希望限制用户的权限，使其只能访问工作所需的任务（AWS 操作）和资源。

  设想一个名为 Diego 的用户。在创建 IAM 用户 Diego 时，您可以为该用户创建密码。您还可以向 IAM 用户附加权限，以使其能够启动特定 Amazon EC2 实例以及从 Amazon RDS 数据库中的表读取 (GET) 信息。有关如何创建用户并授予用户初始凭证和权限的过程，请参阅[在您的 AWS 账户中创建 IAM 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html)。有关如何更改现有用户的权限的过程，请参阅[更改 IAM 用户的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_change-permissions.html)。有关如何更改用户的密码或访问密钥的过程，请参阅[管理密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords.html)和[管理 IAM 用户的访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html)。

  您还可以向您的用户添加权限边界。权限边界是一项高级功能，可让您使用 AWS 托管策略来限制基于身份的策略可向用户或角色授予的最大权限。有关策略类型和用法的更多信息，请参阅[策略和权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies.html)。
- **用户和账户**
  
  每个 IAM 用户均与一个且仅一个 AWS 账户关联。由于用户是在您的 AWS 账户中定义的，因此不需要向 AWS 报备付款方式。用户在您的账户中执行的任何 AWS 活动产生的费用均计入您的账户。

  您在 AWS 账户中拥有的 IAM 用户数量将存在限制。有关更多信息，请参阅[IAM 实体和对象的限制](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_iam-limits.html)。
- **作为账户服务的用户**
  
  IAM 用户是 IAM 中具有相关凭证和权限的资源。IAM 用户可以表示一个人或使用此人的凭证向 AWS 提出请求的应用程序。这通常被称为服务账户。如果您选择在应用程序中使用 IAM 用户的长期凭证，**请勿直接将访问密钥嵌入您的应用程序代码**。 使用 AWS 开发工具包和 AWS Command Line Interface，可以在已知位置放置访问密钥，这样就不必将其保留在代码中。有关更多信息，请参阅 AWS General Reference 中的[正确管理 IAM 用户访问密钥](https://docs.amazonaws.cn/general/latest/gr/aws-access-keys-best-practices.html#iam-user-access-keys)。另外，作为最佳实践，您可以[使用临时安全凭证（IAM 角色）代替长期访问密钥](https://docs.amazonaws.cn/general/latest/gr/aws-access-keys-best-practices.html#use-roles)。
### 添加用户
可以在您的 AWS 账户中创建一个或多个 IAM 用户。当有人加入您的团队时，或创建需要对 AWS 进行 API 调用的新应用程序时，您可能会创建 IAM 用户。
> **重要**  如果您是从 IAM 控制台到达该页面的，您的账户可能不包含 IAM 用户（即使您已登录）。能够使用角色以 AWS 账户根用户身份登录，也可以使用临时凭证登录。要了解有关这些 IAM 身份的更多信息，请参阅[身份 (用户、组和角色)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id.html)。

创建用户并使该用户能够执行工作任务的过程包含以下步骤：
1. 在 AWS 管理控制台、AWS CLI、Windows PowerShell 工具中或使用 AWS API 操作创建用户。如果您在 AWS 管理控制台中创建用户，则将根据您的选择自动处理步骤 1 到步骤 4。如果您以编程方式创建用户，则必须分别执行上述每个步骤。
2. 根据用户所需的访问类型为用户创建凭证：
  + **编程访问**：IAM 用户可能需要进行 API 调用、使用 AWS CLI 或使用Windows PowerShell 工具。对于这种情况，请为该用户创建访问密钥（访问密钥 ID 和秘密访问密钥）。
  + **AWS 管理控制台访问**：如果用户需要访问 AWS 管理控制台，请为用户[创建密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_admin-change-user.html)。
3. 通过将用户添加到一个或多个组，向用户提供执行所需任务的权限。您还可以通过将权限策略直接附加到用户来授予权限。但是，我们建议您将用户放入组内并通过附加到这些组的策略来管理权限。您还可以使用[权限边界](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_boundaries.html)来限制用户可以具有的权限，但这不常用。
4. （可选）通过附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅[标记 IAM 实体](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html)。
5. 向用户提供必要的登录信息。信息包括密码以及用户在其中提供这些凭证的账户登录页面的控制台 URL。有关更多信息，请参阅[IAM 用户如何登录 AWS](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_sign-in.html)。
6. (可选) 为用户配置[多重验证 (MFA)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa.html)。MFA 要求用户在每次登录 AWS 管理控制台时都提供一次性的代码。
7. (可选) 向用户授予管理其自己的安全凭证所需的权限。(默认状态下，用户没有许可管理自己的证书。) 有关更多信息，请参阅[允许 IAM 用户更改自己的密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_enable-user-change.html)。

有关创建用户时需要的权限的信息，请参阅[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。
#### 创建 IAM 用户（控制台）
1. 登录 AWS 管理控制台 并通过以下网址打开 IAM 控制台 https://console.amazonaws.cn/iam/。
2. 在导航窗格中，选择 Users (用户)，然后选择Add user (添加用户)。
3. 为新用户键入用户名。这是 AWS 的登录名。如果您要同时添加多个用户，请为每个其他用户选择 Add another user 并键入其用户名。您一次最多可以添加 10 个用户。
    > **注意** 
    > 用户名可以是一个最多由 64 个字母、数字和以下字符构成的组合：加号 (+)、等号 (=)、逗号 (,)、句点 (.)、at 符号 (@) 和连字符 (-)。账户中的名称必须唯一。名称不区分大小写。例如，您不能创建名为 TESTUSER 和 testuser 的两个用户。有关 IAM 实体限制条件的更多信息，请参阅 IAM 实体和对象的限制。
4. 选择此组用户将拥有的访问权限类型。您可以选择以编程方式访问、访问 AWS 管理控制台，或者同时选择这二者。
    + 如果用户需要访问 API、AWS CLI 或 Windows PowerShell 工具，请选择 Programmatic access (编程访问)。这会为每个新用户创建访问密钥。您可以在转到 Final 页面后查看或下载访问密钥。
    + 如果用户需要访问 AWS 管理控制台，请选择 AWS 管理控制台 access (AWS 管理控制台访问)。这会为每个新用户创建密码。
    + 对于 Console password (控制台密码)，请选择下列项目之一：
      - **自动生成的密码**。每个用户将获得一个随机生成的密码，该密码符合当前生效的账户密码策略（如果有）。在转到完成页面后，您可以查看或下载密码。
      - **自定义密码**。向每个用户分配您在框内键入的密码。
    + （可选）我们建议您选择 Require password reset (需要密码重置) 以确保用户在首次登录时必须更改其密码。
      > **注意** 如果您尚未启用[整个账户的密码策略设置 Allow users to change their own password (允许用户更改其密码)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords_enable-user-change.html)，则选择 Require password reset (需要密码重置) 会将名为 IAMUserChangePassword 的 AWS 托管策略自动附加到新用户，授予他们更改自己的密码的权限。
5. 选择 Next: Permissions (下一步: 权限)。
6. 在 Set permissions 页面上，指定您要向这组新用户分配权限的方式。选择下列三个选项之一：
    + **将用户添加到组**。如果您希望将用户分配到已具有权限策略的一个或多个组，请选择此选项。IAM 将显示您账户中的组及其附加的策略的列表。您可以选择一个或多个现有组，或者选择 Create group 来创建新组。有关更多信息，请参阅[更改 IAM 用户的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_change-permissions.html)。
    + **从现有用户复制权限**。选择此选项可将现有用户的所有组成员资格、附加的托管策略、嵌入式内联策略以及任何现有的[权限边界](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_boundaries.html)都复制给新用户。IAM 将显示您账户中的用户列表。选择其权限与新用户的需求最为匹配的一个用户。
    + **直接将现有策略附加到用户**。选择此选项可查看您的账户中的 AWS 托管策略和客户托管策略的列表。选择您要附加到新用户的策略或选择创建策略，以打开新的浏览器选项卡并从头开始创建新策略。有关更多信息，请参阅过程[创建 IAM 策略（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_create.html#access_policies_create-start)中的步骤 4。在您创建策略后，关闭该选项卡并返回到您的原始选项卡，以将策略添加到新用户。作为[最佳实践](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html#use-groups-for-permissions)，我们建议您改为将策略附加到组，然后使用户成为相应的组的成员。
7. （可选）设置权限边界。这是一项高级功能。
   
    打开 Set permissions boundary (设置权限边界) 部分，然后选择 Use a permissions boundary to control the maximum user permissions (使用权限边界最大用户权限)。IAM 将显示您的账户中的 AWS 托管和客户托管策略的列表。选择要用于权限边界的策略，或选择创建策略以打开新的浏览器选项卡并从头开始创建新策略。有关更多信息，请参阅过程[创建 IAM 策略（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_create.html#access_policies_create-start)中的步骤 4。在您创建策略后，关闭该选项卡并返回到您的原始选项卡，以选择要用于权限边界的策略。
8. 选择 Next: Tagging (下一步: 标记)。
9.  可选）通过以键值对的形式附加标签来向用户添加元数据。有关在 IAM 中使用标签的更多信息，请参阅标记 IAM 实体。
10. 选择 Next: Review 以查看您此时已做出的所有选择。如果您已准备好继续，请选择 Create user。
11. 要查看用户的访问密钥（访问密钥 ID 和秘密访问密钥），请选择您要查看的每个密码和访问密钥旁边的显示。要保存访问密钥，请选择下载 .csv，然后将文件保存到安全位置。
    > **重要**  这是您查看或下载秘密访问密钥的唯一机会，您必须向用户提供此信息，他们才能使用 AWS API。将用户的新访问密钥 ID 和秘密访问密钥保存在安全的地方。完成此步骤后，您再也无法访问这些私有密钥。
12. 为每个用户提供各自的凭证。在最后的页面上，您可以选择每个用户旁边的 Send email。您的本地邮件客户端将打开并显示一份草稿，您可以对草稿进行自定义并发送。电子邮件模板包括每个用户的以下详细信息：
    + 用户名称
    + 账户登录页面的 URL。使用以下示例，换入正确的账户 ID 号或账户别名：
     ```
     https://AWS-account-ID or alias.signin.www.amazonaws.cn/console
     ```
     有关更多信息，请参阅[IAM 用户如何登录 AWS](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_sign-in.html)。
    > **重要**  用户的密码未 包括在生成的电子邮件中。您必须以符合您组织的安全准则的方式向客户提供密码。
#### 创建 IAM 用户（AWS CLI）
1. 创建用户。
  + aws iam create-user
2. （可选）向用户提供对 AWS 管理控制台的访问权限。这需要密码。您必须还向用户提供[您的账户登录页的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_sign-in.html)。
  + aws iam create-login-profile
3. （可选）向用户提供编程访问。这需要访问密钥。
  - aws iam create-access-key
  - Windows PowerShell 工具：New-IAMAccessKey
  - IAM API：CreateAccessKey
    > **重要**  这是您查看或下载秘密访问密钥的唯一机会，您必须向用户提供此信息，他们才能使用 AWS API。将用户的新访问密钥 ID 和秘密访问密钥保存在安全的地方。完成此步骤后，您再也无法访问这些私有密钥。
4. 将该用户添加到一个或多个组。您指定的组应具有用于向用户授予适当的权限的附加策略。
  - aws iam add-user-to-group
5. 可选）向用户附加策略，此策略用于定义该用户的权限。注意：建议您通过将用户添加到一个组并向该组附加策略（而不是直接向用户附加策略）来管理用户权限。
  - aws iam attach-user-policy
6. （可选）通过附加标签来向用户添加自定义属性。有关更多信息，请参阅[管理 IAM 实体的标签（AWS CLI 或 AWS API）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html#id_tags_procs-cli-api)。
7. （可选）向用户授予用于管理其自身的安全凭证的权限。有关更多信息，请参阅[AWS：允许经过 MFA 身份验证的 IAM 用户在“My Security Credentials (我的安全凭证)”页面上管理自己的凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html)。
#### 创建 IAM 用户 (AWS API)
1. 创建用户。
    - [CreateUser](https://docs.amazonaws.cn/IAM/latest/APIReference/API_CreateUser.html)
2. （可选）向用户提供对 AWS 管理控制台的访问权限。这需要密码。您必须还向用户提供您的账户登录页的 URL。
    - [CreateLoginProfile](https://docs.amazonaws.cn/IAM/latest/APIReference/API_CreateLoginProfile.html)
3. （可选）向用户提供编程访问。这需要访问密钥。
    - [CreateAccessKey](https://docs.amazonaws.cn/IAM/latest/APIReference/API_CreateAccessKey.html)
  
    > **重要**  这是您查看或下载秘密访问密钥的唯一机会，您必须向用户提供此信息，他们才能使用 AWS API。将用户的新访问密钥 ID 和秘密访问密钥保存在安全的地方。**完成此步骤后，您再也无法访问这些私有密钥**。
4. 将该用户添加到一个或多个组。您指定的组应具有用于向用户授予适当的权限的附加策略。
    - [AddUserToGroup](https://docs.amazonaws.cn/IAM/latest/APIReference/API_AddUserToGroup.html)
5. （可选）向用户附加策略，此策略用于定义该用户的权限。注意：建议您通过将用户添加到一个组并向该组附加策略（而不是直接向用户附加策略）来管理用户权限。
    - [AttachUserPolicy](https://docs.amazonaws.cn/IAM/latest/APIReference/API_AttachUserPolicy.html)
6. （可选）通过附加标签来向用户添加自定义属性。有关更多信息，请参阅管理[IAM 实体的标签（AWS CLI 或 AWS API）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_tags.html#id_tags_procs-cli-api)。
7. 可选）向用户授予用于管理其自身的安全凭证的权限。有关更多信息，请参阅[AWS：允许经过 MFA 身份验证的 IAM 用户在“My Security Credentials (我的安全凭证)”页面上管理自己的凭证](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html)。
### IAM 用户如何登录 AWS
要以 IAM 用户身份登录 AWS 管理控制台，除了提供用户名和密码以外，您还必须提供账户 ID 或账户别名。管理员在控制台中创建 IAM 用户时，他们应该已经向您发送登录凭证，包括用户名和指向您的账户登录页面的 URL (其中包括账户 ID 和账户别名)。
```
https://My_AWS_Account_ID.signin.www.amazonaws.cn/console/
```

您还可以在以下通用登录终端节点登录并手动键入账户 ID 或账户别名：
```
https://console.amazonaws.cn/
```

为方便起见，AWS 登录页面将使用浏览器 Cookie 来记住您的 IAM 用户名和账户信息。当用户下次转至 AWS 管理控制台中的任意页面时，控制台使用此 cookie 将用户重定向到账户登录页。

您只能访问管理员在附加到您的 IAM 用户身份的策略中指定的 AWS 资源。要在控制台开展工作，您必须有权限执行控制台执行的操作 (例如列出和创建 AWS 资源)。有关更多信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)和 [IAM 基于身份的策略示例](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_examples.html)。

> **注意**  如果组织现在有一个身份系统，您可能需要创建单一登录 (SSO) 选项。SSO 向用户提供访问您的账户的 AWS 管理控制台的权限，而无需他们具有 IAM 用户身份。SSO 也无需用户单独登录您的组织的网站和 AWS。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。
#### 在 CloudTrail 中记录登录详细信息
如果您允许 CloudTrail 将登录事件记录到您的日志中，您需要了解 CloudTrail 如何选择在何处记录事件。
  - 如果您的用户直接登录到控制台，则系统会根据所选服务控制台是否支持区域，将他们重定向到全局或区域登录终端节点。例如，主控制台主页支持区域，因此，如果您登录以下 URL：
      ```
      https://alias.signin.aws.amazon.com/console
      ```
      您会被重定向到区域登录终端节点，例如 https://us-east-2.signin.aws.amazon.com，导致用户的区域日志中记录一个区域 CloudTrail 日志条目

      另一方面，Amazon S3 控制台不支持区域，因此，如果您登录到以下 URL
      ```
      https://alias.signin.aws.amazon.com/console/s3
      ```
      AWS 会将您重定向到全局登录终端节点 https://signin.aws.amazon.com，从而产生一个全局 CloudTrail 日志条目。
  - 您可以通过使用类似如下的 URL 语法登录到启用区域的主控制台主页，来手动请求特定区域网站终端节点：
      ```
      https://alias.signin.aws.amazon.com/console?region=ap-southeast-1
      ```
      AWS 将您重定向到 ap-southeast-1 区域登录终端节点并导致区域 CloudTrail 日志事件。

有关 CloudTrail 和 IAM 的更多信息，请参阅[使用 AWS CloudTrail 记录 IAM 事件](https://docs.amazonaws.cn/IAM/latest/UserGuide/cloudtrail-integration.html)。

如[管理访问密钥（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)中所述，如果用户需要编程访问来使用您的账户，则可以为所有用户创建访问密钥对（访问密钥 ID 和私有密钥）。
### 管理 IAM 用户
Amazon Web Services 提供了多种工具来管理 AWS 账户中的 IAM 用户。您可以列出您的账户中或组中的 IAM 用户，也可以列出用户所属的所有组。您可以重命名或更改 IAM 用户的路径。您还可以从您的 AWS 账户中删除 IAM 用户。

有关添加、更改或删除 IAM 用户的托管策略的更多信息，请参阅[更改 IAM 用户的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_change-permissions.html)。有关为 IAM 用户管理内联策略的信息，请参阅[添加和删除 IAM 身份权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage-attach-detach.html)、[编辑 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage-edit.html)和[删除 IAM 策略](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_manage-delete.html)。作为最佳实践，请使用托管策略而不是内联策略。
#### 查看用户访问
在删除用户之前，您应查看其最近的服务级别活动。这非常重要，因为您不想删除使用它的委托人（个人或应用程序）的访问权限。有关查看上次访问的服务相关数据的更多信息，请参阅[使用上次访问的服务相关数据减少权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_policies_access-advisor.html)。
#### 列出 IAM 用户
您可以列出 AWS 账户中或特定 IAM 组中的 IAM 用户，也可以列出用户所属的所有组。有关为列出用户而需要的权限的信息，请参阅[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。
##### 列出账户中的所有用户
  - AWS 管理控制台：在导航窗格中，选择 Users (用户)。控制台显示您 AWS 账户中的用户。
  - AWS CLI：[aws iam list-users](https://docs.amazonaws.cn/cli/latest/reference/iam/list-users.html)
  - AWS API：[ListUsers](https://docs.amazonaws.cn/IAM/latest/APIReference/API_ListUsers.html)
##### 列出特定组中的用户
  - AWS 管理控制台：在导航窗格中，选择 Groups，选择组的名称，然后选择 Users 选项卡。
  - AWS CLI：[aws iam get-group](https://docs.amazonaws.cn/cli/latest/reference/iam/get-group.html)
  - AWS API：[GetGroup](https://docs.amazonaws.cn/IAM/latest/APIReference/API_GetGroup.html)
##### 列出用户所属的所有组
  - AWS 管理控制台：在导航窗格中，选择 Users，选择用户名称，然后选择 Groups 选项卡。
  - AWS CLI：[aws iam list-groups-for-user](https://docs.amazonaws.cn/cli/latest/reference/iam/list-groups-for-user.html)
  - AWS API：[ListGroupsForUser](https://docs.amazonaws.cn/IAM/latest/APIReference/API_ListGroupsForUser.html)
#### 重命名 IAM 用户
  要更改用户的名称或路径，必须使用 AWS CLI、Windows PowerShell 工具 或 AWS API。控制台中没有用于重命名用户的选项。有关为将用户重命名而需要的权限的信息，请参阅[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。

  当您更改用户名或路径时，发生以下情况：
  - 应用于用户的所有策略采用新用户名继续生效.
  - 采用新用户名的用户保留在原来的群组.
  - 用户的唯一 ID 保持不变。有关唯一 ID 的更多信息，请参阅[唯一 ID](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_identifiers.html#identifiers-unique-ids)。
  - 任何将该用户视为委托人（向该用户授予访问权限）的资源或角色策略均自动更新以使用新用户名或路径。例如，Amazon SQS 中任何基于队列的策略或 Amazon S3 中任何基于资源的策略都会自动更新，以使用新名称和路径。

  IAM 不自动更新将该用户视为资源 的策略以使用新用户名或路径；必须由您手动更新。例如，假设向用户 Richard 附加了一个策略，该策略使该用户可管理其自己的安全凭证。如果管理员将 Richard 重命名为 Rich，则管理员还需要更新该策略以将资源从：

   ```
    arn:aws-cn:iam::111122223333:user/division_abc/subdivision_xyz/Richard
   ```

  改为：

   ```
    arn:aws-cn:iam::111122223333:user/division_abc/subdivision_xyz/Rich
   ```

  如果管理员更改路径，则也会发生这种情况；管理员需要更新策略以反映该用户使用新路径。
##### 重命名用户
  - AWS CLI：[aws iam update-user](https://docs.amazonaws.cn/cli/latest/reference/iam/update-user.html)
  - AWS API：[UpdateUser](https://docs.amazonaws.cn/IAM/latest/APIReference/API_UpdateUser.html)
#### 删除 IAM 用户
如果贵公司有人离职，则可从您的账户中删除 IAM 用户。如果用户只是暂时离开公司，则可禁用该用户的凭证，而不必从 AWS 账户中完全删除该用户。这样可防止该用户在离开期间访问 AWS 账户的资源，但以后可重新启用该用户。

有关禁用证书的更多信息，请参阅[管理 IAM 用户的访问密钥](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_access-keys.html)。有关为删除用户而需要的权限的信息，请参阅[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。
##### 删除 IAM 用户（控制台）
  使用 AWS 管理控制台删除 IAM 用户时，IAM 将自动删除以下信息：
  - 用户
  - 任何组成员关系，即从该用户所属的任何 IAM 组中删除该用户
  - 任何与该用户关联的密码
  - 属于该用户的任何访问密钥
  - 嵌入到该用户中的所有内联策略 (通过组权限应用于用户的策略不受影响)
    > **注意**  删除用户时，所有附加到该用户的托管策略都将与该用户分离。删除用户时不会删除托管策略。
  - 任何关联的 MFA 设备
##### 删除 IAM 用户（控制台）的步骤
  1. 登录 AWS 管理控制台 并通过以下网址打开 IAM 控制台 https://console.amazonaws.cn/iam/。
  2. 在导航窗格中，选择 Users，然后选择要删除的用户名称旁的复选框，而不是名称或行本身。
  3. 在页面的顶部，选择 Delete user。
  4. 在确认对话框中，先等待上次访问的服务数据加载，然后审核数据。该对话框会显示所选每个用户上次访问 AWS 服务的时间。如果您尝试删除在最近 30 天内处于活动状态的用户，则必须选中另一个复选框以确认要删除该活动用户。如果要继续，请选择 Yes, Delete。
##### 删除 IAM 用户 (AWS CLI)
  与 AWS 管理控制台不同，当您使用 AWS CLI 删除用户时，必须手动删除附加到该用户的项目。此过程演示了这个流程。
  1. 删除用户的密钥和证书。这有助于确保用户再也无法访问您的 AWS 账户资源。注意，当您删除安全证书时，证书永远消失，无法恢复。
    [aws iam delete-access-key](https://docs.amazonaws.cn/cli/latest/reference/iam/delete-access-key.html) 和 [aws iam delete-signing-certificate](https://docs.amazonaws.cn/cli/latest/reference/iam/delete-signing-certificate.html)
  2. 如果用户有密码，删除该用户的密码。
    [aws iam delete-login-profile](https://docs.amazonaws.cn/cli/latest/reference/iam/delete-login-profile.html)
  3. 如果用户有 MFA 设备，请禁用该设备。
    [aws iam deactivate-mfa-device](https://docs.amazonaws.cn/cli/latest/reference/iam/deactivate-mfa-device.html)
  4. 分离附加到该用户的任何策略。
    [aws iam list-attached-user-policies](https://docs.amazonaws.cn/cli/latest/reference/iam/list-attached-user-policies.html)（用于列出附加到该用户的策略）和 [aws iam detach-user-policy](https://docs.amazonaws.cn/cli/latest/reference/iam/detach-user-policy.html)（用于分离策略）
  5. 获取该用户所属的任何组的列表，然后从这些组中删除该用户。
    [aws iam list-groups-for-user](https://docs.amazonaws.cn/cli/latest/reference/iam/list-groups-for-user.html) 和 [aws iam remove-user-from-group](https://docs.amazonaws.cn/cli/latest/reference/iam/remove-user-from-group.html)
  6. 删除该用户。
    [aws iam delete-user](https://docs.amazonaws.cn/cli/latest/reference/iam/delete-user.html)
### 更改 IAM 用户的权限
### 管理密码
### 管理 IAM 用户的访问密钥
### 检索丢失的密码或访问密钥
### 多重验证 (MFA)
### 查找未使用的凭证
### 获取凭证报告
### 将 IAM 与 CodeCommit 结合使用：Git 凭证、SSH 密钥和 AWS 访问密钥
### 使用服务器证书
## 组
## 角色
## 标记实体
## 临时安全凭证
## 根用户
##  使用 CloudTrail 记录事件

## 参考
- [IAM身份](https://docs.amazonaws.cn/IAM/latest/UserGuide/id.html?shortFooter=true)