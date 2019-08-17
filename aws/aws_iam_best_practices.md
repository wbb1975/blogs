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
### 使用组向 IAM 用户分配权限
### 授予最低权限
### 利用 AWS 托管策略开始使用权限
### 使用客户托管策略而不是内联策略
### 使用访问权限级别查看 IAM 权限
### 为您的用户配置强密码策略
### 为特权用户启用 MFA
### 针对在 Amazon EC2 实例上运行的应用程序使用角色
### 使用角色委托权限
### 不共享访问密钥
### 定期轮换凭证
### 删除不需要的凭证
### 使用策略条件来增强安全性
### 监控 AWS 账户中的活动
### 关于 IAM 最佳实践的视频演示

### 创建单独的 IAM 用户

## 商用案例

## 参考
- [IAM 最佳实践和使用案例](https://docs.amazonaws.cn/IAM/latest/UserGuide/IAMBestPracticesAndUseCases.html)