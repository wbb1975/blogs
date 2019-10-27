## 配置 AWS CLI
本节介绍如何配置 AWS Command Line Interface (AWS CLI) 在与 AWS 交互时使用的设置，包括您的安全凭证、默认输出格式和默认 AWS 区域。
> 注意:
>
> AWS 要求所有传入的请求都进行加密签名。AWS CLI 为您执行该操作。“签名”包括日期/时间戳。因此，您必须确保正确设置计算机的日期和时间。否则，如果签名中的日期/时间与 AWS 服务认定的日期/时间相差太远，AWS 会拒绝请求。
#### 快速配置 AWS CLI
 对于一般用途，aws configure 命令是设置 AWS CLI 安装的最快方法。
   ```
   $ aws configure
  AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
  AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  Default region name [None]: us-west-2
  Default output format [None]: json
   ```
 键入该命令时，AWS CLI 会提示您输入四条信息（访问密钥、秘密访问密钥，AWS 区域和输出格式），并将它们存储在名为 default 的配置文件（一个设置集合）中。每当您运行的 AWS CLI 命令未明确指定要使用的配置文件时，就会使用该配置文件。
#### 访问密钥ID和秘密访问密钥
AWS Access Key ID 和 AWS Secret Access Key 是您的 AWS 凭证。它们与 AWS Identity and Access Management (IAM) 用户或角色相关联，用于确定您拥有的权限。有关如何使用 IAM 服务创建用户的教程，请参阅 IAM 用户指南 中的[创建您的第一个 IAM 管理员用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/getting-started_create-admin-group.html)。

访问密钥包含访问密钥 ID 和秘密访问密钥，用于签署对 AWS 发出的编程请求。如果没有访问密钥，您可以使用AWS 管理控制台进行创建。 一个最佳实践是，不要让AWS 账户根用户访问密钥用于根本不要要的任务，取而代之，创建一个IAM 管理员帐号。

仅当创建访问密钥时，您才能查看或下载秘密访问密钥。以后您无法恢复它们。不过，您随时可以创建新的访问密钥。您还必须拥有执行所需 IAM 操作的权限。有关更多信息，请参阅 IAM 用户指南 中的[访问 IAM 资源所需的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/access_permissions-required.html)。
1. 打开 [IAM 控制台](https://console.amazonaws.cn/iam/home?#home)。
2. 在控制台的导航窗格中，选择 Users。
3. 选择您的 IAM 用户名称（而不是复选框）。
4. 选择安全证书选项卡，然后选择创建访问秘钥。
5. 要查看新访问秘钥，请选择显示。您的凭证与下面类似：
    - 访问密钥 ID：AKIAIOSFODNN7EXAMPLE
    - 私有访问密钥：wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
6. 要下载密钥对文件，请选择下载 .csv 文件。将密钥存储在安全位置。
    
    请对密钥保密以保护您的 AWS 账户，切勿通过电子邮件发送密钥。请勿对组织外部共享密钥，即使有来自 AWS 或 Amazon.com 的询问。合法代表 Amazon 的任何人永远都不会要求您提供密钥。
#### 相关主题
- [什么是 IAM](https://docs.amazonaws.cn/IAM/latest/UserGuide/introduction.html)？（在 IAM 用户指南 中）
- AWS General Reference 中的 [AWS 安全证书](https://docs.amazonaws.cn/general/latest/gr/aws-security-credentials.html)
####  区域
Default region name 标识默认情况下您要将请求发送到的服务器所在的 AWS 区域。通常是离您最近的区域，但可以是任意区域。例如，您可以键入 us-west-2 以使用美国西部（俄勒冈）。除非在命令中另行指定，否则这是所有后续请求将发送到的区域。

> **注意**：使用 AWS CLI 时，必须明确指定或通过设置默认区域来指定 AWS 区域。有关可用区域的列表，请参阅[区域和终端节点](https://docs.amazonaws.cn/general/latest/gr/rande.html)。AWS CLI 使用的区域指示符与您在 AWS 管理控制台 URL 和服务终端节点中看到的名称相同。
#### 输出格式
Default output format 指定结果的格式。可以是以下列表中的任何值。如果未指定输出格式，则默认使用 json。
- json：输出采用 [JSON](https://json.org/) 字符串的格式。
- text：输出采用多行制表符分隔的字符串值的格式，如果要将输出传递给文本处理器（如 grep、sed 或 awk），则该格式非常有用。
- table：输出采用表格形式，使用字符 +|- 以形成单元格边框。它通常以“人性化”格式呈现信息，这种格式比其他格式更容易阅读，但从编程方面来讲不是那么有用。
#### 创建多个配置文件
如果您使用上一节中显示的命令，则结果是名为 default 的单个配置文件。通过指定 --profile 选项并分配名称，您可以创建可按名称引用的其他配置。以下示例创建一个名为 produser 的配置文件。您指定的凭证所来自的账户和区域可与其他配置文件的完全不同。
```
$ aws configure --profile produser
AWS Access Key ID [None]: AKIAI44QH8DHBEXAMPLE
AWS Secret Access Key [None]: je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: text
```
然后，运行命令时，可以省略 --profile 选项，并使用 default 配置文件中存储的凭证和设置。
```
$ aws s3 ls
```
或者，您也可以指定 --profile profilename 并使用按该名称存储的凭证和设置。
```
$ aws s3 ls --profile produser
```
要更新任何设置，只需再次运行 aws configure（根据要更新的配置文件，使用或不使用 --profile 参数），并根据需要输入新值。下面几节包含有关 aws configure 创建的文件、其他设置和命名配置文件的更多信息。
#### 配置设置和优先顺序
AWS CLI 使用一组凭证提供程序 查找 AWS 凭证。每个凭证提供程序在不同的位置查找凭证，例如系统或用户环境变量、本地 AWS 配置文件，或在命令行上显式声明为参数。AWS CLI 通过按以下顺序调用提供程序来查找凭证和配置设置，在找到要使用的一组凭证时停止：
1. [命令行选项](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-options.html) – 您可以在命令行上指定 --region、--output 和 --profile 作为参数。
2. [环境变量](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-envvars.html) – 您可以在环境变量中存储值：AWS_ACCESS_KEY_ID、AWS_SECRET_ACCESS_KEY 和 AWS_SESSION_TOKEN。如果存在环境变量，则会使用这些变量。
3. [CLI 凭证文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-files.html) – 这是运行命令 aws configure 时更新的文件之一。该文件位于 ~/.aws/credentials（在 Linux, OS X, or Unix 上）或 C:\Users\USERNAME\.aws\credentials（在 Windows 上）。该文件可以包含 default 配置文件和任何命名配置文件的凭证详细信息。
4. [CLI 配置文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-files.html) – 这是运行命令 aws configure 时更新的另一个文件。该文件位于 ~/.aws/config（在 Linux, OS X, or Unix 上）或 C:\Users\USERNAME\.aws\config（在 Windows 上）。该文件包含默认配置文件和任何命名配置文件的配置设置。
5. [容器凭证](https://docs.amazonaws.cn/AmazonECS/latest/developerguide/task-iam-roles.html) – 您可以将 IAM 角色与每个 Amazon Elastic Container Service (Amazon ECS) 任务定义相关联。之后，该任务的容器就可以使用该角色的临时凭证。有关更多信息，请参阅 Amazon Elastic Container Service Developer Guide 中的[适用于任务的 IAM 角色](https://docs.amazonaws.cn/AmazonECS/latest/developerguide/task-iam-roles.html)。
6. [实例配置文件凭证](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) – 您可以将 IAM 角色与每个 Amazon Elastic Compute Cloud (Amazon EC2) 实例相关联。之后，在该实例上运行的代码就可以使用该角色的临时凭证。凭证通过 Amazon EC2 元数据服务提供。有关更多信息，请参阅 Amazon EC2 用户指南（适用于 Linux 实例） 中的[适用于 Amazon EC2 的 IAM 角色](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)和 IAM 用户指南 中的[使用实例配置文件](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)。
### 配置和证书文件
### 命名配置文件
### 环境变量
### 命令行选项
### 使用外部进程获取凭证
### 实例元数据
### 使用 HTTP 代理
### 在 AWS CLI 中使用 IAM 角色
### 命令完成

## Reference
- [配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html)
