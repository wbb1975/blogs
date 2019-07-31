# 配置 AWS CLI
本节介绍如何配置 AWS Command Line Interface (AWS CLI) 在与 AWS 交互时使用的设置，包括您的安全凭证、默认输出格式和默认 AWS 区域。
> 注意:
>
> AWS 要求所有传入的请求都进行加密签名。AWS CLI 为您执行该操作。“签名”包括日期/时间戳。因此，您必须确保正确设置计算机的日期和时间。否则，如果签名中的日期/时间与 AWS 服务认定的日期/时间相差太远，AWS 会拒绝请求。

## 快速配置 AWS CLI
 对于一般用途，aws configure 命令是设置 AWS CLI 安装的最快方法。
   ```
   $ aws configure
  AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
  AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  Default region name [None]: us-west-2
  Default output format [None]: json
   ```
 键入该命令时，AWS CLI 会提示您输入四条信息（访问密钥、秘密访问密钥，AWS 区域和输出格式），并将它们存储在名为 default 的配置文件（一个设置集合）中。每当您运行的 AWS CLI 命令未明确指定要使用的配置文件时，就会使用该配置文件。

### 访问密钥和秘密访问密钥
AWS Access Key ID 和 AWS Secret Access Key 是您的 AWS 凭证。它们与 AWS Identity and Access Management (IAM) 用户或角色相关联，用于确定您拥有的权限。有关如何使用 IAM 服务创建用户的教程，请参阅 IAM 用户指南 中的[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

访问密钥包含访问密钥 ID 和秘密访问密钥，用于签署对 AWS 发出的编程请求。如果没有访问密钥，您可以使用AWS 管理控制台进行创建。 一个最佳实践是，不要让AWS 账户根用户访问密钥用于根本不要要的任务，取而代之，创建一个IAM 管理员帐号。

仅当创建访问密钥时，您才能查看或下载秘密访问密钥。以后您无法恢复它们。不过，您随时可以创建新的访问密钥。您还必须拥有执行所需 IAM 操作的权限。有关更多信息，请参阅 IAM 用户指南 中的[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。
  
## 配置设置和优先顺序
## 

## Reference
- [配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html)

