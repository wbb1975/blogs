# IAM 控制台和登录页面
AWS 管理控制台提供一个基于 Web 的方法以管理 AWS 服务。您可以登录该控制台并使用 AWS 服务为您的账户创建、列出和执行其他任务。这些任务可能包括启动和停止 Amazon EC2 实例和 Amazon RDS 数据库、创建 Amazon DynamoDB 表、创建 IAM 用户等。

此部分提供有关 AWS 管理控制台登录页面的信息。它介绍了如何在您的账户中为 IAM 用户创建唯一登录 URL，以及如何以 根用户 身份登录。

> **注意**：如果组织现在有一个身份系统，您可能需要创建单一登录 (SSO) 选项。SSO 向用户提供访问您的账户的 AWS 管理控制台的权限，而无需他们具有 IAM 用户身份。SSO 也无需用户单独登录您的组织的网站和 AWS。有关更多信息，请参阅[创建一个使联合用户能够访问 AWS 管理控制台（自定义联合代理）的 URL](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html)。
## IAM 用户登录页面
要使用 AWS 管理控制台，除了提供用户名和密码以外，IAM 用户还必须提供账户 ID 或账户别名。当您以管理员身份[在控制台中创建 IAM 用户时](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)，您必须向该用户发送登录凭证，包括用户名和指向账户登录页面的 URL。

> **重要** 根据您设置 IAM 用户的方式不同，向所有用户提供用于首次登录的临时密码。有关密码的详细信息，请参阅管理密码。

当您开始使用 IAM 时，将会自动创建您的唯一账户登录页面 URL。您无需执行任何操作即可使用此登录页面。
```
https://My_AWS_Account_ID.signin.www.amazonaws.cn/console/
```
此外，如果您希望您账户的账户登录 URL 包含自己的公司名称 (或其他友好标识)，而不是您的 AWS 账户 ID 号，您可以自定义自己账户的账户登录 URL。有关创建账户别名的更多信息，请参阅[AWS 账户 ID 及其别名](https://docs.amazonaws.cn/IAM/latest/UserGuide/console_account-alias.html)。

> **提示** 要在 Web 浏览器中为您的账户登录页面创建书签，您应在标签条目中手动键入您的账户的登录 URL。不要使用 Web 浏览器的书签功能，因为重定向会掩盖登录 URL。

通过查看 IAM 控制台的控制面板，您随时可以找到您的账户登录页面的 URL。

![IAW Alias Console](https://github.com/wbb1975/blogs/blob/master/aws/images/AccountAlias.console.png)

IAM 用户还可以在以下通用登录终端节点登录并手动键入账户 ID 或账户别名：
```
https://console.amazonaws.cn/
```

> **注意**  要在 AWS 管理控制台上查找 AWS 账户 ID 号，请在右上角的导航栏上选择 Support (支持)，然后选择 Support Center (支持中心)。您当前的登录账号 (ID) 将显示在 Support Center (支持中心) 标题栏中。
> ![IAW Account Support Center](https://github.com/wbb1975/blogs/blob/master/aws/images/account-id-support-center.console.png)

为方便起见，AWS 登录页面将使用浏览器 Cookie 来记住您的 IAM 用户名和账户信息。当用户下次转至 AWS 管理控制台中的任意页面时，控制台使用此 cookie 将用户重定向到账户登录页。
## AWS 账户根用户登录页面
使用您的 AWS 账户电子邮件地址和密码以根用户身份登录[AWS 管理控制台](https://console.amazonaws.cn/)。

> **注意**  如果您之前已使用[IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users.html) 用户 凭证登录控制台，则您的浏览器可能会记住此首选项，并打开您的账户特定的登录页。您不能在 IAM 用户登录页面上使用您的 AWS 账户根用户凭证进行登录。如果您看到 IAM 用户登录页面，请选择页面底部附近的 Sign in using root account credentials 以返回到主登录页面。在此处，您可以键入您的 AWS 账户电子邮件地址和密码。
## 控制用户访问 AWS 管理控制台
通过登录页面登录到您的AWS 账户的用户可以通过 AWS 管理控制台 访问您的 AWS 资源，但仅限于您授权他们访问的资源。以下列表显示了您授权用户通过 AWS 管理控制台访问您的 AWS 账户资源的几种方式。同时，还列出了用户通过 AWS 网站访问其他 AWS 账户功能的方式。
> **注意** IAM 不收费
- **AWS 管理控制台**
  
   您为需要访问 AWS 管理控制台的每位用户创建一个密码。用户通过启用了 IAM 的 AWS 账户登录页面访问控制台。有关访问登录页面的信息，请参阅[IAM 控制台和登录页面](https://docs.amazonaws.cn/IAM/latest/UserGuide/console.html)。有关创建密码的信息，请参阅[管理密码](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_passwords.html)。
- **您的 AWS 资源（如 Amazon EC2 实例、Amazon S3 存储桶等）**
  
   即使您的用户持有密码，也仍需拥有访问您的 AWS 资源的许可。当您创建一位用户时，在默认情况下，该用户并无许可。若要为授予用户所需的许可，您需要为其附加策略。如果您有许多使用相同资源来执行相同任务的用户，则可将这些用户归为一组，然后将许可分配至该组。有关创建用户和组的信息，请参阅[身份 (用户、组和角色)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id.html)。有关使用策略来设置许可的信息，请参阅[访问控制](https://docs.amazonaws.cn/IAM/latest/UserGuide/access.html)。
- **AWS 开发论坛**
   
   任何人均可阅读[AWS 开发论坛](https://forums.aws.csdn.net/)上的帖子。希望在 AWS 开发论坛上发布问题或评论的用户可使用他们的用户名进行操作。当用户初次在 AWS 开发论坛上发帖时，将提示该用户输入昵称和电子邮件地址，这些信息将仅供该用户在 AWS 开发论坛上使用。
- **您的 AWS 账户账单和使用率信息**
   
   您可授权用户访问您的 AWS 账户账单和使用率信息。有关更多信息，请参阅 AWS Billing and Cost Management 用户指南中的[控制对账单信息的访问权限](https://docs.amazonaws.cn/awsaccountbilling/latest/aboutv2/control-access-billing.html)。
- **您的 AWS 账户资料信息**
    
    用户无法访问您的 AWS 账户资料信息。
- **您的 AWS 账户安全凭证**
   
   用户无法访问您的 AWS 账户安全凭证。
   > **注意**：IAM 策略控制访问不受接口限制。例如，您可为用户提供访问 AWS 管理控制台 的密码，同时，适用于该用户（或该用户所属的任何组）的策略将控制其在 AWS 管理控制台 上可以执行的操作。您也可以为用户提供对 AWS 进行 API 调用的 AWS 访问密钥，同时，相关策略将通过使用这些访问密钥进行身份验证的数据库或客户端来控制用户可以调用的操作。
## AWS 账户 ID 及其别名
账户别名用于替代账户 Web 地址中的账户 ID。您可以从 AWS 管理控制台、AWS CLI 或 AWS API 创建和管理账户别名。
### 查找 AWS 账户 ID
要在 AWS 管理控制台上查找 AWS 账户 ID 号，请在右上角的导航栏上选择 Support (支持)，然后选择 Support Center (支持中心)。您当前的登录账号 (ID) 将显示在 Support Center (支持中心) 标题栏中。

![IAW Alias Console](https://github.com/wbb1975/blogs/blob/master/aws/images/AccountAlias.console.png)
### 关于账户别名
如果您希望在登录页面的 URL 用贵公司名称（或其他友好标识）取代您的 AWS 账户 ID，可以创建一个账户别名。这一节介绍关于 AWS 账户别名的信息，并列出用于创建别名的 API 操作。

您的登录页面 URL 地址默认格式如下：
```
https://Your_AWS_Account_ID.signin.www.amazonaws.cn/console/
```
如果为您的 AWS 账户 ID 创建一个 AWS 账户别名，您的登录页面 URL 地址格式如以下示例。
```
https://Your_Alias.signin.www.amazonaws.cn/console/
```

> **注意**  创建 AWS 账户别名后，包含 AWS 账户 ID 的原始 URL 地址依然有效，可以使用。
> **提示**  要在 Web 浏览器中为您的账户登录页面创建书签，应在书签条目中手动键入登录 URL。请勿使用 Web 浏览器的“将此页标记为书签”功能。
### 创建、删除、列举 AWS 账户别名
您可以使用 AWS 管理控制台、IAM、API 或命令行接口创建或删除您的 AWS 账户别名。
> **重要**
>   - 您的 AWS 账户只能有一个别名。如果为您的 AWS 账户创建新的别名，新别名将覆盖原有别名，包含原有别名的 URL 将失效。
 >  - 账户别名必须在所有 Amazon Web Services 产品中唯一。它必须仅包含数字、小写字母和连字符。有关 AWS 账户实体限制条件的更多信息，请参阅 [IAM 实体和对象的限制](https://docs.amazonaws.cn/IAM/latest/UserGuide/reference_iam-limits.html)。
#### 创建和删除别名（控制台）
1. 登录 AWS 管理控制台 并通过以下网址打开 IAM 控制台 https://console.amazonaws.cn/iam/。
2. 在导航窗格中，选择 Dashboard。
3. 找到 IAM users sign-in link (IAM 用户登录链接)，然后选择该链接右侧的 Customize (自定义)。
4. 键入要用于别名的名称，然后选择 Yes, Create (是，创建)。
5. 要删除别名，请选择 Customize，然后选择 Yes, Delete。登录 URL 会恢复使用 AWS 账户 ID。
#### 创建、删除和列出别名 (AWS CLI)
- 要为 AWS 管理控制台 登录页面 URL 创建别名，请运行以下命令：
  
  [aws iam create-account-alias](https://docs.amazonaws.cn/cli/latest/reference/iam/create-account-alias.html)
- 要删除 AWS 账户 ID 别名，请运行以下命令：
  
  [aws iam delete-account-alias](https://docs.amazonaws.cn/cli/latest/reference/iam/delete-account-alias.html)
- 要显示您的 AWS 账户 ID 别名，请运行以下命令：

  [aws iam list-account-aliases](https://docs.amazonaws.cn/cli/latest/reference/iam/list-account-aliases.html)
#### 创建、删除和列出别名 (AWS API)
- 要为 AWS 管理控制台 登录页面 URL 创建别名，请调用以下操作：

  [CreateAccountAlias](https://docs.amazonaws.cn/IAM/latest/APIReference/API_CreateAccountAlias.html)
- 要删除 AWS 账户 ID 别名，请调用以下操作：

  [DeleteAccountAlias](https://docs.amazonaws.cn/IAM/latest/APIReference/API_DeleteAccountAlias.html)
- 要显示您的 AWS 账户 ID 别名，请调用以下操作：

  [ListAccountAliases](https://docs.amazonaws.cn/IAM/latest/APIReference/API_ListAccountAliases.html)
## 使用 MFA 设备访问您的 IAM 登录页面
配置了[多重身份验证 (MFA)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa.html) 设备的 IAM 用户必须使用其 MFA 设备登录 AWS 管理控制台。在用户输入用户名和密码后，AWS 将检查用户的账户以查看该用户是否需要 MFA。以下各节提供了有关必须使用 MFA 时用户如何完成登录的信息。
### 使用虚拟 MFA 设备登录
如果 MFA 是用户必须使用的，则会显示另一个登录页面。在 MFA code (MFA 代码) 框中，用户必须输入 MFA 应用程序提供的数字代码。

如果 MFA 代码正确，则用户可以访问 AWS 管理控制台。如果代码不正确，则用户可以使用其他代码重试。

虚拟 MFA 设备可能会不同步。如果用户尝试多次后都无法登录 AWS 管理控制台，系统将提示用户同步虚拟 MFA 设备。用户可以按照屏幕上的提示同步虚拟 MFA 设备。有关如何在您的 AWS 账户中同步代表用户的设备的信息，请参阅[重新同步虚拟和硬件 MFA 设备](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_sync.html)。
### 使用 U2F 安全密钥登录
如果 MFA 是用户必须使用的，则会显示另一个登录页面。用户需要点击 U2F 安全密钥。

与其他 MFA 设备不同，U2F 安全密钥不同步。如果 U2F 安全密钥丢失或损坏，管理员可以停用它。有关更多信息，请参阅[停用 MFA 设备（控制台）](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_disable.html#deactive-mfa-console)。

有关支持 AWS 所支持的 U2F 和 U2F 设备的浏览器的信息，请参阅[使用 U2F 安全密钥的受支持配置](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_u2f_supported_configurations.html)。
### 使用硬件 MFA 设备登录
如果 MFA 是用户必须使用的，则会显示另一个登录页面。在 MFA code (MFA 代码) 框中，用户必须输入硬件 MFA 设备提供的数字代码。

如果 MFA 代码正确，则用户可以访问 AWS 管理控制台。如果代码不正确，则用户可以使用其他代码重试。

硬件 MFA 设备可能会不同步。如果用户尝试多次后都无法登录 AWS 管理控制台，系统将提示用户同步 MFA 令牌设备。用户可以根据屏幕上的提示同步 MFA 令牌设备。有关如何在您的 AWS 账户中同步代表用户的设备的信息，请参阅[重新同步虚拟和硬件 MFA 设备](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_credentials_mfa_sync.html)。
## IAM 控制台搜索
当您通过 IAM 管理控制台进行导航以管理各种 IAM 资源时，通常需要查找访问密钥，或浏览深度嵌套的 IAM 资源以找到您需要处理的项目。另一种更快的办法是使用 IAM 控制台搜索页面查找与您的账户、IAM 实体 (如用户、组、角色、身份提供商)、策略 (按名称) 等相关的访问密钥。

IAM 控制台搜索功能可查找以下所有项目：
- 与您的搜索关键字 (用户、组、角色、身份提供商和策略) 匹配的 IAM 实体名称
- 与搜索关键字匹配的 AWS 文档主题名称
- 与搜索关键字匹配的任务

搜索结果中的每一行都是一个有效链接。例如，您可以在搜索结果中选择用户名称，这样，您将转到该用户的详细信息页面。或者您也可以选择操作链接，例如 Create user，从而进入 Create User 页面。

> **注意**  访问密钥搜索要求您在搜索框中输入完整的访问密钥 ID。搜索结果显示与该键关联的用户。您可在此处直接导航到该用户的页面，并且可以在该页面中管理其访问密钥。
### 使用 IAM 控制台搜索功能
1. 登录 AWS 管理控制台 并通过以下网址打开 IAM 控制台 https://console.amazonaws.cn/iam/。
2. 在导航窗格中，选择 Search。
3. 在 Search 框中，键入您的搜索关键字。
4. 在搜索结果列表中选择一个链接以导航到控制台或文档相应的部分。
### IAM 控制台搜索结果中的图标
下面的图标指出了通过搜索找到的项目的类型：

图标|描述
--|--
![IAM 用户](https://github.com/wbb1975/blogs/blob/master/aws/images/search_user.png)|IAM 用户
![IAM 组](https://github.com/wbb1975/blogs/blob/master/aws/images/search_group.png)|IAM 组
![IAM 角色](https://github.com/wbb1975/blogs/blob/master/aws/images/search_role.png)|IAM 角色
![IAM 策略](https://github.com/wbb1975/blogs/blob/master/aws/images/search_policy.png)|IAM 策略
![“创建任务”或“附加策略”等任务](https://github.com/wbb1975/blogs/blob/master/aws/images/search_action.png)|创建任务”或“附加策略”等任务
![使用关键字 delete 搜索到的结果](https://github.com/wbb1975/blogs/blob/master/aws/images/search_delete.png)|使用关键字 delete 搜索到的结果
![IAM 文档](https://github.com/wbb1975/blogs/blob/master/aws/images/search_help.png)|IAM 文档
### 搜索短语示例
您可以在 IAM 搜索中使用以下短语。将各个斜体词分别替换为您要查找的实际 IAM 用户、组、角色、访问密钥、策略或标识提供程序的名称。
- ***user_name*** 或 ***group_name*** 或 ***role_name*** 或 ***policy_name*** 或 ***identity_provider_name***
- ***access_key***
- add user ***user_name*** to groups 或者 add users to group ***group_name***
- remove user ***user_name*** from groups
- delete ***user_name*** or delete ***group_name*** or delete ***role_name***, or delete ***policy_name***, or delete ***identity_provider_name***
- manage access keys ***user_name***
- manage signing certificates ***user_name***
- users
- manage MFA for ***user_name***
- manage password for ***user_name***
- create role
- password policy
- edit trust policy for role ***role_name***
- show policy document for ***role role_name***
- attach policy to ***role_name***
- create managed policy
- create user
- create group
- attach policy to ***group_name***
- attach entities to ***policy_name***
- detach entities to ***policy_name***
- what is IAM
- how do I create an IAM user
- how do I use IAM console
- what is a user、what is a group、what is a policy、what is a role 或 what is an identity provider
## 参考
- [IAM 控制台和登录页面](https://docs.amazonaws.cn/IAM/latest/UserGuide/console.html)