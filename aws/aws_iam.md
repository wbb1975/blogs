# AWS Identity and Access Management (IAM)

## 什么是 IAM？
AWS Identity and Access Management (IAM) 是一种 Web 服务，可以帮助您安全地控制对 AWS 资源的访问。您可以使用 IAM 控制对哪个用户进行身份验证 (登录) 和授权 (具有权限) 以使用资源。

当您首次创建 AWS 账户时，最初使用的是一个对账户中所有 AWS 服务和资源有完全访问权限的单点登录身份。此身份称为 AWS账户根用户（root user），可使用您创建账户时所用的电子邮件地址和密码登录来获得此身份。强烈建议您不使用 根用户执行日常任务，即使是管理任务。请遵守仅将用于[创建首个 用户](https://docs.amazonaws.cn/IAM/latest/UserGuide/best-practices.html)的最佳实践。然后请妥善保存根用户凭证，仅用它们执行少数账户和服务管理任务。

## Reference
- [IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)
