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
## AWS 账户 ID 及其别名
## 使用 MFA 设备访问您的 IAM 登录页面
## IAM 控制台搜索

## 参考
- [IAM 控制台和登录页面](https://docs.amazonaws.cn/IAM/latest/UserGuide/console.html)