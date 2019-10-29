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
您可以将常用的配置设置和凭证保存在由 AWS CLI 维护的文件中。这些文件分为可按名称引用的多个部分。这称为“配置文件”。除非您另行指定，否则 CLI 将使用在名为 default 的配置文件中找到的设置。要使用备用设置，您可以创建和引用其他配置文件。您也可以通过设置某个支持的环境变量或使用命令行参数来覆盖个别设置。
#### 配置设置存储在何处？
AWS CLI 将使用 aws configure 指定的凭证存储在主目录中名为 .aws 的文件夹中名为 credentials 的本地文件中。使用 aws configure 指定的其他配置选项存储在名为 config 的本地文件中，该文件也存储在主目录的 .aws 文件夹中。主目录位置因操作系统而异，但在 Windows 中使用环境变量 %UserProfile% 引用，在基于 Unix 的系统中使用 $HOME 或 ~（波形符）引用。

例如，下面的命令列出 .aws 文件夹的内容。

Linux, OS X, or Unix
```
ls  ~/.aws
```

Windows
```
dir "%UserProfile%\.aws"
```

AWS CLI 使用两个文件将敏感的凭证信息（位于 ~/.aws/credentials 中）与不太敏感的配置选项（位于 ~/.aws/config 中）分开。

通过将 AWS_CONFIG_FILE 环境变量设置为另一个本地路径，可以为 config 文件指定非默认位置。有关更多信息，请参阅[环境变量](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-envvars.html)。
> **在 Config 文件中存储证书**
>
> AWS CLI 也可以从 config 文件读取凭证。您可以将所有配置文件设置保存在一个文件中。如果在一个配置文件的两个位置都有证书（假设您使用 aws configure 更新了配置文件密钥），则credentials文件中的密钥有优先顺序。
> 
> 这些文件也被各种语言软件开发工具包 (SDK) 使用。如果除 AWS CLI 外您还使用一个软件开发工具包，当证书不是存储在它自己的文件中时，您会收到其他警告。

CLI 为上一部分中配置的配置文件生成的文件如下所示。

**~/.aws/credentials**
```
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**~/.aws/config**
```
[default]
region=us-west-2
output=json
```
> **注意**： 上面的示例介绍具有单个默认配置文件的文件。有关具有多个命名配置文件的文件的示例，请参阅[命名配置文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-profiles.html)。

当您使用共享配置文件指定 IAM 角色时，AWS CLI 将调用 AWS STS AssumeRole 操作来检索临时凭证。随后，这些凭证将存储起来（存储在 ~/.aws/cli/cache 中）。后续 AWS CLI 命令将使用缓存的临时凭证，直到它们过期，这时 AWS CLI 将自动刷新这些凭证。
#### 支持的 config 文件设置
config 文件支持以下设置。将使用指定（或默认）配置文件中列出的值，除非它们被具有相同名称的环境变量或具有相同名称的命令行选项覆盖。

您可以通过直接使用文本编辑器编辑配置文件或使用 aws configure set 命令来配置这些设置。使用 --profile 设置指定要修改的配置文件。例如，以下命令设置名为 integ 的配置文件中的 region 设置。
```
aws configure set region us-west-2 --profile integ  
```

您还可以使用 get 子命令检索任何设置的值。
```
$ aws configure get region --profile default
us-west-2
```

如果输出为空，则没有显式设置该设置，并将使用默认值。
##### 全局设置
- api_versions
   
   某些 AWS 服务维护多个 API 版本以支持向后兼容性。默认情况下，CLI 命令使用最新的可用 API 版本。您可以通过在 config 文件中包含 api_versions 设置来指定要用于配置文件的 API 版本。

   这是一个“嵌套”设置，后跟一个或多个缩进行，每行标识一个 AWS 服务和要使用的 API 版本。请参阅每项服务的文档以了解可用的 API 版本。

   以下示例显示如何为两种 AWS 服务指定 API 版本。这些 API 版本仅用于在包含这些设置的配置文件下运行的命令。
   ```
   api_versions =
       ec2 = 2015-03-01
       cloudfront = 2015-09-017
   ```
- [aws_access_key_id](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-creds)

   指定用作凭证一部分的对命令请求进行身份验证的 AWS 访问密钥。虽然它可以存储在 config 文件中，但我们建议您将其存储在 credentials 文件中。

   可以被 AWS_ACCESS_KEY_ID 环境变量覆盖。请注意，您不能将访问密钥 ID 指定为命令行选项。

   ```
   aws_access_key_id = 123456789012
   ```
- [aws_secret_access_key](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-creds)
   指定用作凭证一部分的对命令请求进行身份验证的 AWS 私有密钥。虽然它可以存储在 config 文件中，但我们建议您将其存储在 credentials 文件中。

   可以被 AWS_SECRET_ACCESS_KEY 环境变量覆盖。请注意，您不能将私有访问密钥指定为命令行选项。
   ```
   aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```
- aws_session_token
  
   制定一个AWS 会话令牌。一个会话令牌仅在你手工指定一个临时安全凭证时是必要的。虽然它可以存储在 config 文件中，但我们建议您将其存储在 credentials 文件中。

   可以被 AWS_SESSION_TOKEN 环境变量覆盖。请注意，您不能将私有访问密钥指定为命令行选项。
   ```
   aws_session_token = AQoEXAMPLEH4aoAH0gNCAPyJxz4BlCFFxWNE1OPTgk5TthT+FvwqnKwRcOIfrRh3c/LTo6UDdyJwOOvEVPvLXCrrrUtdnniCEXAMPLE/IvU1dYUg2RVAJBanLiHb4IgRmpRV3zrkuWJOgQs8IZZaIv2BXIa2R4Olgk
   ```
- ca_bundle
   
   指定一个CA证书捆绑包（一个带.pem扩展名的文件），用于验证SSL凭证。

   可以被 AWS_CA_BUNDLE环境变量或--ca-bundle命令行选项覆盖。
   ```
   ca_bundle = dev/apps/ca-certs/cabundle-2019mar05.pem
   ```
- cli_follow_urlparam

   指定 CLI 是否尝试跟踪命令行参数中以 http:// 或 https:// 开头的 URL 链接。启用后，将检索到的内容而不是 URL 用作参数值。
  - true：这是默认值。配置后，将抓取任何以 http:// 或 https:// 开头的字符串参数，并将任何下载的内容用作该命令的参数值。
  - false：CLI 不将以 http:// 或 https:// 开头的参数字符串值与其他字符串区别对待。

   该条目没有等效的环境变量或命令行选项。
   ```
   cli_follow_urlparam = false
   ```
- cli_timestamp_format

   指定输出中包含的时间戳值的格式。可以指定以下任一值：
   - none：这是默认值。按原样显示 HTTP 查询响应中收到的时间戳值。
   - iso8601：按 [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) 指定的格式重新格式化时间戳。

   该条目没有等效的环境变量或命令行选项。
   ```
   cli_timestamp_format = iso8601
   ```
- [credential_process](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-sourcing-external.html)

   指定 CLI 运行的外部命令，以生成或检索用于该命令的身份验证凭证。命令必须以特定格式返回凭证。有关如何使用该设置的更多信息，请参阅[使用外部进程获取凭证](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-sourcing-external.html)。

   该条目没有等效的环境变量或命令行选项。
   ```
   credential_process = /opt/bin/awscreds-retriever --username susan
   ```
- duration_seconds

   指定角色会话的最大持续时间（以秒为单位）。该值的范围在 900 秒（15 分钟）到角色的最大会话持续时间设置之间。此参数为可选参数，默认情况下，该值设置为 3600 秒。
- [external_id](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html#cli-configure-role-xaccount)

   第三方用于在其客户账户中代入角色的唯一标识符。这将映射到 AssumeRole 操作中的 ExternalId 参数。此参数是可选的，除非角色的信任策略指定 ExternalId 必须为特定值。
- [mfa_serial](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html#cli-configure-role-mfa)

   代入角色时要使用的 MFA 设备的标识号。仅当代入角色的信任策略包含需要 MFA 身份验证的条件，此值才是必需的。该值可以是硬件设备（例如 GAHT12345678）的序列号，也可以是虚拟 MFA 设备（例如 arn:aws:iam::123456789012:mfa/user）的 Amazon 资源名称 (ARN)。
- [output](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-format)

   指定使用该配置文件请求的命令的默认输出格式。您可以指定以下任意值：
   + json：这是默认值。输出采用 [JSON](https://json.org/) 字符串的格式。
   + text：输出采用多行制表符分隔的字符串值的格式，如果要将输出传递给文本处理器（如 grep、sed 或 awk），则该格式非常有用。
   + table：输出采用表格形式，使用字符 +|- 以形成单元格边框。它通常以“人性化”格式呈现信息，这种格式比其他格式更容易阅读，但从编程方面来讲不是那么有用。

   可以被 AWS_DEFAULT_OUTPUT 环境变量或 --output 命令行选项覆盖。
   ```
   output = table
   ```
- parameter_validation

   指定 CLI 客户端在将参数发送到 AWS 服务终端节点之前是否尝试验证参数。
   + true：这是默认值。配置后，CLI 将执行命令行参数的本地验证。
   + false：配置后，CLI 在将命令行参数发送到 AWS 服务终端节点前不对其进行验证。

   该条目没有等效的环境变量或命令行选项。
   ```
   parameter_validation = false
   ```
- [region](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-region)

  对于使用该配置文件请求的命令，指定要将请求发送到的默认 AWS 区域。您可以指定可用于所选服务的任何区域代码（有关服务和区域代码的列表，请参阅 Amazon Web Services 一般参考 中的 AWS 区域和终端节点）。

   可以被 AWS_DEFAULT_REGION 环境变量或 --region 命令行选项覆盖。
   ```
   region = us-west-2
   ```
- [role_arn](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-role.html)

   指定要用于运行 AWS CLI 命令的 IAM 角色的 Amazon 资源名称 (ARN)。此外，还必须指定以下参数之一以标识有权代入此角色的凭证：
   + source_profile
   + credential_source

   ```
   role_arn = arn:aws:iam::123456789012:role/role-name
   ```
- [source_profile](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html)

   指定包含长期凭证的命名配置文件，AWS CLI 可使用这些凭证代入通过 role_arn 参数指定的角色。不能在同一配置文件中同时指定 source_profile 和 credential_source。

   ```
   source_profile = production-profile
   ```
- [credential_source](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html)

   在 EC2 实例或 EC2 容器中使用，指定 AWS CLI 在何处可以找到要用于代入通过 role_arn 参数指定的角色的凭证。不能在同一配置文件中同时指定 source_profile 和 credential_source。
   
   此参数具有三个值：
   + Environment：从环境变量检索源凭证
   + Ec2InstanceMetadata：将附加到 [EC2 实例配置文件](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)的 IAM 角色用作源凭证。
   + EcsContainer：将附加到 ECS 容器的 IAM 角色用作源凭证。

   ```
   credential_source = Ec2InstanceMetadata
   ```
- [role_session_name](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html#cli-configure-role-session-name)

   指定要附加到角色会话的名称。此值在 AWS CLI 调用 AssumeRole 操作时将提供给 RoleSessionName 参数，并成为代入角色用户 ARN 的一部分： arn:aws:sts::123456789012:assumed-role/role_name/role_session_name。此参数为可选参数。如果未提供此值，则将自动生成会话名称。此名称显示在与此会话关联的条目的 AWS CloudTrail 日志中。

   ```
   role_session_name = maria_garcia_role
   ```
- sts_regional_endpoints

   指定AWS CLI 客户使用的AWS服务终端端点，以此来与AWS安全令牌服务通讯（AWS STS）。你可以指定两者之一：
   + regional：AWS CLI将使用对应配置区域的AWS STS终端节点。例如，如果客户配置使用us-west-2，那么所有到AWS STS的调用将被导向sts.us-west-2.amazonaws.com区域终端节点而非全局sts.amazonaws.com终端节点。
   + legacy：对以下区域，使用全局sts.amazonaws.com终端节点：ap-northeast-1, ap-south-1, ap-southeast-1, ap-southeast-2, aws-global, ca-central-1, eu-central-1, eu-north-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-1, and us-west-2。所有其他区域使用它们的各自区域终端节点。
- [web_identity_token_file](https://docs.amazonaws.cn/en_us/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc)

   指定一个文件的路径，该文件包含由身份提供商提供的 OAuth 2.0 访问令牌或 OpenID Connect ID 令牌。AWS CLI 加载此文件的内容，并将其作为 WebIdentityToken 参数传递给 AssumeRoleWithWebIdentity 操作。
- tcp_keepalive

  指定 CLI 客户端是否使用 TCP keep-alive 数据包。

  该条目没有等效的环境变量或命令行选项。
  ```
  tcp_keepalive = false
  ``` 
##### S3 自定义命令设置
Amazon S3 支持多项配置 CLI 如何执行 S3 操作的设置。一些设置适用于 s3api 和 s3 命名空间中的所有 S3 命令。其他的则专门用于抽象常见操作的 S3“自定义”命令，而不仅仅是对 API 操作的一对一映射。aws s3 传输命令 cp、sync、mv 和 rm 具有可用于控制 S3 传输的其他设置。

可以通过在 config 文件中指定 s3 嵌套设置来配置所有这些选项。每个设置在其自己的行上缩进。
> **注意**：这些设置完全是可选的。即使不配置这些设置中的任何一个，您也应该能够成功使用 aws s3 传输命令。提供这些设置是为了让您能够调整性能或匹配运行这些 aws s3 命令的特定环境。

以下设置适用于 s3 或 s3api 命名空间中的任何 S3 命令。
- addressing_style

   指定要使用的寻址样式。这将控制存储桶名称位于主机名还是 URL 中。有效值为：path、virtual 和 auto。默认值为 auto。

   构造 S3 终端节点的样式有两种。第一种称为 virtual，它将存储桶名称包含为主机名的一部分。例如：https://bucketname.s3.amazonaws.com。另一种为 path 样式 - 将存储桶名称视为 URI 中的路径。例如：https://s3.amazonaws.com/bucketname。CLI 中的默认值是使用 auto，它尝试尽可能使用 virtual 样式，但在需要时回退到 path 样式。例如，如果您的存储桶名称与 DNS 不兼容，则存储桶名称不能是主机名的一部分，而必须位于路径中。使用 auto 时，CLI 将检测这种情况并自动切换到 path 样式。如果将寻址方式设置为 path，您必须确保在 AWS CLI 中配置的 AWS 区域与存储桶的区域匹配。
- payload_sigining_enabled

   指定是否对 sigv4 负载进行 SHA256 签名。默认情况下，使用 https 时，将对流式上传（UploadPart 和 PutObject）禁用该设置。默认情况下，对于流式上传（UploadPart 和 PutObject），此设置为 false，但仅限存在 ContentMD5（默认生成）并且终端节点使用 HTTPS 时。

   如果设置为 true，则 S3 请求接收 SHA256 校验和形式的额外内容验证（替您计算并包含在请求签名中）。如果设置为 false，则不计算校验和。禁用该设置可减少校验和计算产生的性能开销。
- use_dualstack_endpoint

   为所有 s3 和 s3api 命令使用 Amazon S3 双 IPv4 / IPv6 终端节点。默认值为 False。该设置与 use_accelerate_endpoint 设置互斥。

   如果设置为 true，CLI 会将所有 Amazon S3 请求定向到配置的区域的双 IPv4/IPv6 终端节点。
- use_accelerate_endpoint

   为所有 s3 和 s3api 命令使用 Amazon S3 加速终端节点。默认值为 False。该设置与 use_dualstack_endpoint 设置互斥。

   如果设置为 true，CLI 会将所有 Amazon S3 请求定向到 s3-accelerate.amazonaws.com 的 S3 加速终端节点。要使用该终端节点，您必须让您的存储桶使用 S3 加速。使用存储桶寻址的虚拟样式发送所有请求：my-bucket.s3-accelerate.amazonaws.com。不会将任何 ListBuckets、CreateBucket 和 DeleteBucket 请求发送到加速终端节点，因为该终端节点不支持这些操作。如果将任何 s3 或 s3api 命令的 --endpoint-url 参数设置为 https://s3-accelerate.amazonaws.com 或 http://s3-accelerate.amazonaws.com，也可以设置该行为。

以下设置仅适用于 s3 命名空间命令集中的命令：
- max_bandwidth

   指定向 Amazon S3 上传数据和从其下载数据可使用的最大带宽。默认为无限制。

   这限制了 S3 命令可用于向 S3 传输数据和从 S3 传输数据的最大带宽。该值仅适用于上传和下载；它不适用于复制或删除。值以每秒字节数表示。该值可以指定为：
   - 一个整数。例如，1048576 将最大带宽使用率设置为每秒 1 兆字节。
   - 一个整数，后跟速率后缀。可以使用以下格式指定速率后缀：KB/s、MB/s 或 GB/s。例如，300KB/s 和 10MB/s。

   通常，我们建议您先尝试通过降低 max_concurrent_requests 来降低带宽使用率。如果这样做没有将带宽使用率限制到所需速率，接下来您可以使用 max_bandwidth 设置进一步限制带宽使用率。这是因为 max_concurrent_requests 控制当前运行的线程数。如果您先降低 max_bandwidth 但保持较高的 max_concurrent_requests 设置，则可能导致线程进行不必要的等待，从而造成过多的资源消耗和连接超时。
- max_concurrent_requests

   指定最大并发请求数。默认值是 10。

   aws s3 传输命令是多线程的。在任意给定时间，都可以运行多个 Amazon S3 请求。例如，当您使用命令 aws s3 cp localdir s3://bucket/ --recursive 将文件上传到 S3 存储桶时，AWS CLI 可以并行上传文件 localdir/file1、localdir/file2 和 localdir/file3。设置 max_concurrent_requests 指定可同时运行的最大传输操作数。

   您可能由于以下原因而需要更改该值：
   - 减小该值 – 在某些环境中，默认的 10 个并发请求可能会占用过多的系统资源。这可能导致连接超时或系统响应速度变慢。减小该值可减少 S3 传输命令消耗的资源。但不利后果是 S3 传输可能需要更长时间才能完成。如果使用了限制带宽的工具，则可能需要减小该值。
   - 增大该值 – 在某些情况下，您可能希望 S3 传输根据需要使用尽可能多的网络带宽，以尽可能快地完成任务。在这种情况下，默认的并发请求数可能不足以利用所有可用的网络带宽。增大该值可缩短完成 S3 传输所需的时间。
- max_queue_size

   指定任务队列中的最大任务数。默认值是 1000。

   AWS CLI 在内部使用这样一种模型：将 S3 任务排队，然后由数量受 max_concurrent_requests 限制的使用者执行。任务通常映射到单个 S3 操作。例如，任务可以是 PutObjectTask、GetObjectTask 或 UploadPartTask。任务添加到队列的速度可能比使用者完成任务的速度快得多。为避免无限制增长，任务队列大小设置了特定大小的上限。该设置用于更改该最大数量的值。

   您通常不需要更改该设置。该设置还对应于 CLI 知道需要运行的任务数。这意味着，默认情况下 CLI 只能查看前 1000 个任务。在 S3 命令得知执行的任务总数之前，进度线显示总计 ...。增大该值意味着 CLI 可更快得知所需任务的总数（假设排队速度快于任务完成速度）。但不利后果是更大的最大队列大小需要更多的内存。
- multipart_chunksize

   指定 CLI 用于单个文件的分段传输的块大小。默认值为 8 MB，最小值为 5 MB。

   当文件传输超出 multipart_threshold 时，CLI 将文件分成该大小的块。可以使用与 multipart_threshold 相同的语法指定该值，即整数形式的字节数，或使用大小和后缀。
- multipart_threshold

   指定 CLI 用于单个文件的分段传输的大小阈值。默认值为 8 MB。

   上传、下载或复制文件时，如果文件超出该大小，S3 命令将切换到分段操作。您可以通过以下两种方式之一指定该值：
   - 文件大小（以字节为单位）。例如：1048576。
   - 文件大小及大小后缀。您可以使用 KB、MB、GB 或 TB。例如，10MB、1GB。
   > **注意**： S3 可能会对可用于分段操作的有效值施加约束。有关更多信息，请参阅 Amazon Simple Storage Service 开发人员指南 中的 [S3 分段上传文档](https://docs.amazonaws.cn/AmazonS3/latest/dev/mpuoverview.html)。 

这些设置都在 config 文件中的顶层 s3 关键字下设置，如以下 development 配置文件示例所示：
```
[profile development]
s3 =
  max_concurrent_requests = 20
  max_queue_size = 10000
  multipart_threshold = 64MB
  multipart_chunksize = 16MB
  max_bandwidth = 50MB/s
  use_accelerate_endpoint = true
  addressing_style = path
```
### 命名配置文件（Named Profiles）
#### 命名配置文件
AWS CLI 支持使用存储在 config 和 credentials 文件中的多个命名配置文件中的任何一个。您可以通过在 aws configure 中使用 --profile 选项或通过向 config 和 credentials 文件中添加条目来配置其他配置文件。

下面的示例介绍一个有两个配置文件的 credentials 文件。第一个在运行没有配置文件的 CLI 命令时使用。第二个在运行有 --profile user1 参数的 CLI 命令时使用。

**~/.aws/credentials**（Linux 和 Mac）或 **%USERPROFILE%\.aws\credentials** (Windows)
```
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[user1]
aws_access_key_id=AKIAI44QH8DHBEXAMPLE
aws_secret_access_key=je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

每个配置文件可以指定不同的凭证（可能来自不同的 IAM 用户），还可以指定不同的 AWS 区域和输出格式。

**~/.aws/config**（Linux 和 Mac）或 **%USERPROFILE%\.aws\config** (Windows)
```
[default]
region=us-west-2
output=json

[profile user1]
region=us-east-1
output=text
```
> **重要**：credentials 文件使用的命名格式与 CLI config 文件用于命名配置文件的格式不同。仅当在 config 文件中配置命名配置文件时，才包含前缀单词“profile”。在 credentials 文件中创建条目时，请勿 使用单词 profile。
#### 通过 AWS CLI 使用配置文件（Using Profiles with the AWS CLI）
要使用命名配置文件，请向您的命令添加 --profile profile-name 选项。以下示例列出了使用先前示例文件中 user1 配置文件中定义的凭证和设置的所有 Amazon EC2 实例。
```
aws ec2 describe-instances --profile user1
```

要为多个命令使用一个命名配置文件，通过在命令行设置 AWS_PROFILE 环境变量可以避免在每个命令中指定配置文件。

Linux, OS X, or Unix

```
export AWS_PROFILE=user1
```
设置环境变量会更改默认配置文件，直到 Shell 会话结束或直到您将该变量设置为其他值。通过将环境变量放在 shell 的启动脚本中，可使环境变量在未来的会话中继续有效。有关更多信息，请参阅 [环境变量](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-envvars.html)。

Windows

```
setx AWS_PROFILE user1
```
使用 [set](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1) 设置环境变量会更改使用的值，直到当前命令提示符会话结束，或者直到您将该变量设置为其他值。

使用 [setx](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/setx) 设置环境变量会更改运行命令后创建的所有命令 Shell 中的值。这不会 影响运行命令时已在运行的任何命令 Shell。关闭并重新启动命令 Shell 可查看这一更改的效果。
### 环境变量
环境变量提供了另一种指定配置选项和凭证的方法；若要编写脚本或将一个命名配置文件临时设置为默认配置文件，环境变量会很有用。

**选项的优先顺序：**
- 如果您使用本主题中描述的某个环境变量指定选项，则它将在配置文件中覆盖从配置文件加载的任何值。
- 如果您通过在 CLI 命令行上使用参数指定选项，则它将在配置文件中覆盖相应环境变量或配置文件中的任何值。

**支持的环境变量**
+ AWS_ACCESS_KEY_ID – 指定与 IAM 用户或角色关联的 AWS 访问密钥。
+ AWS_SECRET_ACCESS_KEY – 指定与访问密钥关联的私有密钥。这基本上是访问密钥的“密码”。
+ AWS_SESSION_TOKEN – 指定在使用临时安全凭证时需要的会话令牌值。有关更多信息，请参阅 AWS CLI Command Reference 中的[代入角色命令的输出部分](https://docs.amazonaws.cn/cli/latest/reference/sts/assume-role.html#output)。
+ AWS_DEFAULT_REGION – 指定要将请求发送到的 [AWS 区域](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration-region)。
+ AWS_DEFAULT_OUTPUT – 指定要使用的[输出格式](https://docs.amazonaws.cn/cli/latest/userguide/cli-usage-output.html)。
+ AWS_PROFILE – 指定包含要使用的凭证和选项的 CLI [配置文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-profiles.html)的名称。可以是存储在 credentials 或 config 文件中的配置文件的名称，也可以是值 default，后者使用默认配置文件。如果您指定此环境变量，它将在配置文件中覆盖使用名为 [default] 的配置文件的行为。
+ AWS_ROLE_SESSION_NAME – 指定要与角色会话关联的名称。有关更多信息，请参阅[指定角色会话名称以便于审核](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-role.html#cli-configure-role-session-name)。
+ AWS_CA_BUNDLE – 指定要用于 HTTPS 证书验证的证书捆绑包的路径。
+ AWS_SHARED_CREDENTIALS_FILE – 指定 AWS CLI 用于存储访问密钥的文件的位置。默认路径为 ~/.aws/credentials。
+ AWS_CONFIG_FILE – 指定 AWS CLI 用于存储配置文件的文件的位置。默认路径为 ~/.aws/config。

下面的示例介绍如何为默认用户配置环境变量。这些值将覆盖在命名配置文件中找到的任何值或实例元数据。设置后，您可以通过在 CLI 命令行上指定参数或通过更改/删除环境变量来覆盖这些值。有关优先顺序以及 AWS CLI 如何确定使用哪些凭证的更多信息，请参阅[配置设置和优先顺序](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html#config-settings-and-precedence)。

**Linux, OS X, or Unix**

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```
设置环境变量会更改使用的值，直到 Shell 会话结束或直到您将该变量设置为其他值。通过在 shell 的启动脚本中设置变量，可使变量在未来的会话中继续有效。

**Windows 命令提示符**

```
setx AWS_ACCESS_KEY_ID AKIAIOSFODNN7EXAMPLE
setx AWS_SECRET_ACCESS_KEY wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
setx AWS_DEFAULT_REGION us-west-2
```
使用 [set](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1) 设置环境变量会更改使用的值，直到当前命令提示符会话结束，或者直到您将该变量设置为其他值。使用 [setx](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/setx) 设置环境变量会更改当前命令提示符会话和运行该命令后创建的所有命令提示符会话中使用的值。它不 影响在运行该命令时已经运行的其他命令 shell。

**PowerShell**

```
$Env:AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
$Env:AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
$Env:AWS_DEFAULT_REGION="us-west-2"
```
如果在 PowerShell 提示符下设置环境变量（如前面的示例所示），则仅保存当前会话持续时间的值。要在所有 PowerShell 和命令提示符会话中使环境变量设置保持不变，请使用控制面板中的系统应用程序来存储该变量。或者，您可以通过将其添加到 PowerShell 配置文件来为将来的所有 PowerShell 会话设置该变量。有关存储环境变量或跨会话保存它们的更多信息，请参阅 [PowerShell 文档](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_variables)。
### 命令行选项
您可以使用以下命令行选项来覆盖一条命令的默认配置设置。虽然您可以指定要使用的配置文件，但无法使用命令行选项直接指定凭证（credentials）。
+ **--profile <string>**

   指定用于该命令的命名配置文件。要设置其他命名配置文件，可以在 aws configure 命令中使用 --profile 选项。
   ```
   aws configure --profile <profilename>
   ```
+ **--region <string>**

   指定要将该命令的 AWS 请求发送到的 AWS 区域。有关可以指定的所有区域的列表，请参阅Amazon Web Services 一般参考中的 [AWS 区域和终端节点](https://docs.amazonaws.cn/general/latest/gr/rande.html)。
+ **--output <string>**

   指定用于该命令的输出格式。您可以指定以下任意值：

   - json：输出采用 [JSON](https://json.org/) 字符串的格式。
   - text：输出采用多行制表符分隔的字符串值的格式，如果要将输出传递给文本处理器（如 grep、sed 或 awk），则该格式非常有用。
   - table：输出采用表格形式，使用字符 +|- 以形成单元格边框。它通常以“人性化”格式呈现信息，这种格式比其他格式更容易阅读，但从编程方面来讲不是那么有用。
+ **--endpoint-url <string>**

   指定要将请求发送到的 URL。对于大多数命令，AWS CLI 会根据所选服务和指定的 AWS 区域自动确定 URL。但是，某些命令需要您指定账户专用 URL。您还可以配置一些 AWS 服务[直接在您的私有 VPC 中托管终端节点](https://docs.amazonaws.cn/AmazonVPC/latest/UserGuide/what-is-amazon-vpc.html#what-is-privatelink)（然后可能需要指定该终端节点）。

   有关每个区域可用的标准服务终端节点的列表，请参阅Amazon Web Services 一般参考中的  [AWS 区域和终端节点](https://docs.amazonaws.cn/general/latest/gr/rande.html)。
+ **--debug**

   指定要启用调试日志记录的布尔开关。这包括有关命令操作的额外诊断信息，这些信息在排查命令提供意外结果的原因时非常有用。
+ **--no-paginate**

   禁用输出自动分页的布尔开关。
+ **--query <string>**

   指定用于筛选响应数据的 [JMESPath 查询](http://jmespath.org/)。有关更多信息，请参阅[如何使用 --query 选项筛选输出](https://docs.amazonaws.cn/cli/latest/userguide/cli-usage-output.html#cli-usage-output-filter)。
+ **--version**

   显示正在运行的 AWS CLI 程序的当前版本的布尔开关。
+ **---color <string>**

   指定对彩色输出的支持。有效值包括 on、off 和 auto。默认值为 auto。
+ **--no-sign-request**

   对 AWS 服务终端节点的 HTTP 请求禁用签名的布尔开关。这可避免加载凭证。
+ **--ca-bundle <string>**

   指定验证 SSL 证书时要使用的 CA 证书捆绑包。
+ **--cli-read-timeout <integer>**

   指定最大套接字读取时间（以秒为单位）。如果该值设置为 0，则套接字读取将无限等待（阻塞），不会超时。
+ **--cli-connect-timeout <integer>**

   指定最大套接字连接时间（以秒为单位）。如果该值设置为 0，则套接字连接将无限等待（阻塞），不会超时。

将这些选项中的一个或多个作为命令行参数提供时，它会覆盖该单个命令的默认配置或任何相应的配置文件设置。

每个带参数的选项都需要一个空格或等号 (=) 将参数与选项名称分开。如果参数值为包含空格的字符串，则必须使用引号将参数引起来。

常见的命令行选项用法包括在编写脚本时检查多个 AWS 区域中的资源，以及更改输出格式使其易于阅读或使用。例如，如果您不确定实例运行的区域，可以针对每个区域运行 describe-instances 命令，直到找到该区域，如下所示。
```
$ aws ec2 describe-instances --output table --region us-east-1
-------------------
|DescribeInstances|
+-----------------+
$ aws ec2 describe-instances --output table --region us-west-1
-------------------
|DescribeInstances|
+-----------------+
$ aws ec2 describe-instances --output table --region us-west-2
------------------------------------------------------------------------------
|                              DescribeInstances                             |
+----------------------------------------------------------------------------+
||                               Reservations                               ||
|+-------------------------------------+------------------------------------+|
||  OwnerId                            |  012345678901                      ||
||  ReservationId                      |  r-abcdefgh                        ||
|+-------------------------------------+------------------------------------+|
|||                                Instances                               |||
||+------------------------+-----------------------------------------------+||
|||  AmiLaunchIndex        |  0                                            |||
|||  Architecture          |  x86_64                                       |||
...
```

[指定参数值](https://docs.amazonaws.cn/cli/latest/userguide/cli-usage-parameters.html)中详细描述了每个命令行选项的参数类型（例如，字符串、布尔值）。
### 使用外部进程获取凭证
> **警告**：以下主题讨论从外部进程获取凭证。如果生成凭证的命令可由未经批准的进程或用户访问，则可能存在安全风险。我们建议您使用 CLI 和 AWS 提供的支持的安全替代方案，以降低泄露凭证的风险。请务必保管好 config 文件及任何支持文件和工具，以防泄露。

如果您有 AWS CLI 不直接支持的生成或查找凭证的方法，则可以通过在 config 文件中配置 credential_process 设置来配置 CLI 使用它。

例如，您可以在配置文件中包含类似于以下内容的条目：
```
[profile developer]
credential_process = /opt/bin/awscreds-custom --username helen
```

AWS CLI 完全按照配置文件中指定的方式运行该命令，然后从 STDOUT 读取数据。您指定的命令必须在 STD​​OUT 上生成符合以下语法的 JSON 输出：
```
{
  "Version": 1,
  "AccessKeyId": "an AWS access key",
  "SecretAccessKey": "your AWS secret access key",
  "SessionToken": "the AWS session token for temporary credentials", 
  "Expiration": "ISO8601 timestamp when the credentials expire"
}  
```
截至撰写本文之时，Version 密钥必须设置为 1。随时间推移和该结构的发展，该值可能会增加。

Expiration 密钥是采用 [ISO8601](https://wikipedia.org/wiki/ISO_8601) 格式的时间戳。如果工具的输出中不存在 Expiration 键，则 CLI 假定凭证是不刷新的长期凭证。否则，将其视为临时凭证，并通过在其过期前重新运行 credential_process 命令来自动刷新凭证。

> **注意**：AWS CLI 不 缓存外部进程凭据，这一点不同于代入角色凭证。如果需要缓存，则必须在外部进程中实现。

外部进程可以返回非零返回代码，以指示在检索凭证时发生错误。
### 实例元数据
从 Amazon EC2 实例中运行 AWS CLI 时，可以简化向命令提供凭证的过程。每个 Amazon EC2 实例都包含 AWS CLI 能够直接查询临时凭证的元数据。要提供这些元数据，请创建一个对所需资源有访问权限的 AWS Identity and Access Management (IAM) 角色，然后在 Amazon EC2 实例启动时向其附加该角色。

启动实例并进行检查，看是否已安装了 AWS CLI（在 Amazon Linux 上是预安装的）。如有必要，安装 AWS CLI。您仍必须配置默认区域，以免在每个命令中指定它。

要在命名配置文件中指定要使用托管 Amazon EC2 实例配置文件中可用的凭证，请在配置文件中指定以下行：
```
credential_source = Ec2InstanceMetadata 
```

以下示例说明如何通过在 Amazon EC2 实例配置文件中引用 marketingadminrole 角色来代入该角色：
```
[profile marketingadmin]
role_arn = arn:aws-cn:iam::123456789012:role/marketingadminrole
credential_source = Ec2InstanceMetadata
```

您可以通过运行 aws configure 来设置区域和默认输出格式，而无需通过按两次 Enter 跳过前两条提示来指定凭证。
```
aws configure
AWS Access Key ID [None]: ENTER
AWS Secret Access Key [None]: ENTER
Default region name [None]: us-west-2
Default output format [None]: json
```
向实例附加 IAM 角色后，AWS CLI 可以自动并且安全地从实例元数据检索凭证。有关更多信息，请参阅 IAM 用户指南 中的[向 Amazon EC2 实例中运行的应用程序授予访问 AWS 资源的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/role-usecase-ec2app.html)。
### 使用 HTTP 代理
#### 使用 HTTP 代理
要通过代理服务器访问 AWS，您可以使用代理服务器使用的 DNS 域名或 IP 地址和端口号配置 HTTP_PROXY 和 HTTPS_PROXY 环境变量。

> **注意**：以下示例显示了全部使用大写字母的环境变量名称。但是，如果您指定一个变量两次 - 一次使用大写字母，一次使用小写字母，则以使用小写字母的变量为准。我们建议您只定义变量一次，以避免混淆和意外行为。

以下示例显示如何使用代理的显式 IP 地址或解析为代理 IP 地址的 DNS 名称。两种情况都可以后跟冒号和应将查询发送到的端口号

**Linux, OS X, or Unix**

```
export HTTP_PROXY=http://10.15.20.25:1234
export HTTP_PROXY=http://proxy.example.com:1234
export HTTPS_PROXY=http://10.15.20.25:5678
export HTTPS_PROXY=http://proxy.example.com:5678
```
**Windows**

```
setx HTTP_PROXY http://10.15.20.25:1234
setx HTTP_PROXY=http://proxy.example.com:1234
setx HTTPS_PROXY=http://10.15.20.25:5678
setx HTTPS_PROXY=http://proxy.example.com:5678 
```
#### 代理身份验证
AWS CLI 支持 HTTP 基本身份验证。在代理 URL 中指定用户名和密码，如下所示：

**Linux, OS X, or Unix**

```
export HTTP_PROXY=http://username:password@proxy.example.com:1234
export HTTPS_PROXY=http://username:password@proxy.example.com:5678
```
**Windows**

```
setx HTTP_PROXY http://username:password@proxy.example.com:1234
setx HTTPS_PROXY=http://username:password@proxy.example.com:5678
```
> **注意**：AWS CLI 不支持 NTLM 代理。如果使用 NTLM 或 Kerberos 协议代理，则可以通过身份验证代理（如 [Cntlm](http://cntlm.sourceforge.net/)）进行连接。
#### 对 Amazon EC2 实例使用代理
如果是在使用附加 IAM 角色启动的 Amazon EC2 实例上配置代理，请确保排除用于访问[实例元数据](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)的地址。为此，请将 NO_PROXY 环境变量设置为实例元数据服务的 IP 地址 169.254.169.254。该地址保持不变。

**Linux, OS X, or Unix**

```
export NO_PROXY=169.254.169.254
```
**Windows**

```
setx NO_PROXY 169.254.169.254
```
### 在 AWS CLI 中使用 IAM 角色（Using an IAM Role in the AWS CLI）
[AWS Identity and Access Management (IAM) 角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles.html)是一种授权工具，可让 IAM 用户获得额外（或不同）的权限或者获取使用其他 AWS 账户执行操作的权限。

通过在 ~/.aws/credentials 文件中为 IAM 角色定义配置文件，您可以配置 AWS Command Line Interface (AWS CLI) 以使用该角色。

以下示例显示了一个名为 marketingadmin 的角色配置文件。如果使用 --profile marketingadmin（或使用 AWS_PROFILE 环境变量指定它）运行命令，则 CLI 使用配置文件 user1 中定义的凭证代入 Amazon 资源名称 (ARN) 为 arn:aws-cn:iam::123456789012:role/marketingadminrole 的角色。您可以运行分配给该角色的权限所允许的任何操作。
```
[marketingadmin]
role_arn = arn:aws-cn:iam::123456789012:role/marketingadminrole
source_profile = user1
```
然后，您可以指定一个指向单独的命名配置文件的 source_profile，此配置文件包含 IAM 用户凭证及使用该角色的权限。在上一个示例中，marketingadmin 配置文件使用 user1 配置文件中的凭证。当您指定某个 AWS CLI 命令将使用配置文件 marketingadmin 时，CLI 会自动查找链接的 user1 配置文件的凭证，并使用它们为指定的 IAM 角色请求临时凭证。CLI 在后台使用 sts:AssumeRole 操作来完成该操作。然后，使用这些临时凭证来运行请求的 CLI 命令。指定的角色必须附加有允许运行请求的 CLI 命令的 IAM 权限策略。

如果要在 Amazon EC2 实例或 Amazon ECS 容器中运行 CLI 命令，可以使用附加到实例配置文件或容器的 IAM 角色。如果未指定配置文件或未设置环境变量，则将直接使用该角色。这让您能够避免在实例上存储长时间生存的访问密钥。您也可以使用这些实例或容器角色仅获取其他角色的凭证。为此，请使用 credential_source（而不是 source_profile）指定如何查找凭证。credential_source 属性支持以下值：
- Environment – 从环境变量检索源凭证。
- Ec2InstanceMetadata – 使用附加到 Amazon EC2 实例配置文件的 IAM 角色。
- EcsContainer – 使用附加到 Amazon ECS 容器的 IAM 角色。

以下示例显示通过引用 Amazon EC2 实例配置文件来使用同一个 marketingadminrole 角色：
```
[profile marketingadmin]
role_arn = arn:aws-cn:iam::123456789012:role/marketingadminrole
credential_source = Ec2InstanceMetadata
```
当您调用角色时，您可以要求其他选项，例如使用多重身份验证、外部 ID（供第三方公司用于访问其客户的资源）以及指定可更容易地在 AWS CloudTrail 日志中进行审核的唯一角色会话名称。
#### 配置和使用角色
在使用指定 IAM 角色的配置文件运行命令时，AWS CLI 将使用源配置文件的（source profile's）凭证调用 AWS Security Token Service (AWS STS) 并为指定角色请求临时凭证。源配置文件中的用户必须具有为指定配置文件中的角色调用 sts:assume-role 的权限。该角色必须具有允许源配置文件中的用户使用角色的信任关系。检索角色的临时凭证然后使用临时凭证的过程通常称为代入角色（assuming the role）。

您可以通过执行 AWS Identity and Access Management 用户指南 中的[创建向 IAM 用户委派权限的角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/roles-creatingrole-user.html)下的过程，在 IAM 中创建一个您希望用户代入的具有该权限的新角色。如果该角色和源配置文件的 IAM 用户在同一个账户中，在配置角色的信任关系时，您可以输入自己的账户 ID。

在创建角色后，请修改信任关系以允许 IAM 用户（或 AWS 账户中的用户）代入该角色。

以下示例显示了一个可附加到角色的信任策略。该策略允许账户 123456789012 中的任何 IAM 用户代入该角色，前提 是该账户的管理员向该用户显式授予了 sts:assumerole 权限。
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws-cn:iam::123456789012:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
信任策略不会实际授予权限。账户管理员必须通过附加具有适当权限的策略才能将代入角色的权限委派给各个用户。以下示例显示了一个可附加到 IAM 用户的策略，该策略仅允许用户代入 marketingadminrole 角色。有关授予用户代入角色的访问权限的更多信息，请参阅 IAM 用户指南 中的[向用户授予切换角色的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_permissions-to-switch.html)。
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws-cn:iam::123456789012:role/marketingadminrole"
    }
  ]
}
```
IAM 用户无需拥有任何附加权限即可使用角色配置文件运行 CLI 命令。相反，运行命令的权限来自附加到角色 的权限。您可以将权限策略附加到角色，以指定可以针对哪些 AWS 资源执行哪些操作。有关向角色附加权限（与向 IAM 用户附加权限的操作相同）的更多信息，请参阅 IAM 用户指南 中的[更改 IAM 用户的权限](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_users_change-permissions.html)。

您已正确配置角色配置文件、角色权限、角色信任关系和用户权限，可以通过调用 --profile 选项在命令行中使用该角色了。例如，下面的命令使用附加到 marketingadmin 角色（由本主题开头的示例定义）的权限调用 Amazon S3 ls 命令。
```
aws s3 ls --profile marketingadmin
```
要对多个调用使用角色，您可以从命令行设置当前会话的 AWS_DEFAULT_PROFILE 环境变量。定义该环境变量后，就不必对每个命令都指定 --profile 选项。

**Linux, OS X, or Unix**

```
export AWS_PROFILE=marketingadmin
```
**Windows**

```
setx AWS_PROFILE marketingadmin
```

有关配置 IAM 用户和角色的更多信息，请参阅 IAM 用户指南 中的[用户和组](https://docs.amazonaws.cn/IAM/latest/UserGuide/Using_WorkingWithGroupsAndUsers.html)和[角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/roles-toplevel.html)。
#### 使用多重验证
为了提高安全性，当用户尝试使用角色配置文件进行调用时，您可以要求用户提供从多重验证 (MFA) 设备（一种 U2F 设备）或移动应用程序生成的一次性密钥。

首先，您可以选择将与 IAM 角色有关的信任关系修改为需要 MFA。这可以防止任何人在未首先使用 MFA 进行身份验证的情况下使用该角色。有关示例，请参阅下面示例中的 Condition 行。此策略允许名为 anika 的 IAM 用户代入策略所附加的角色，但前提是她使用 MFA 进行身份验证。
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws-cn:iam::123456789012:user/anika" },
      "Action": "sts:AssumeRole",
      "Condition": { "Bool": { "aws:multifactorAuthPresent": true } }
    }
  ]
}
```

其次，为角色配置文件添加一行，用来指定用户的 MFA 设备的 ARN。以下示例 config 文件条目显示两个角色配置文件，它们都使用访问密钥为 IAM 用户 anika 请求角色 cli-role 的临时凭证。用户 anika 有权代入角色，这是由角色的信任策略授予的。

```
[profile role-without-mfa]
region = us-west-2
role_arn= arn:aws:iam::128716708097:role/cli-role
source_profile=cli-user

[profile role-with-mfa]
region = us-west-2
role_arn= arn:aws:iam::128716708097:role/cli-role
source_profile = cli-user
mfa_serial = arn:aws:iam::128716708097:mfa/cli-user

[profile anika]
region = us-west-2
output = json
```
该 mfa_serial 设置可以采取如图所示的 ARN 或硬件 MFA 令牌的序列号。

第一个配置文件 role-without-mfa 不需要 MFA。但是，由于附加到角色的先前示例信任策略需要 MFA，因此使用此配置文件运行命令的任何尝试都将失败。
```
aws iam list-users --profile role-without-mfa
An error occurred (AccessDenied) when calling the AssumeRole operation: Access denied
```

第二个配置文件条目 role-with-mfa 标识要使用的 MFA 设备。当用户尝试使用此配置文件运行 CLI 命令时，CLI 会提示用户输入 MFA 设备提供的一次性密码 (OTP)。如果 MFA 身份验证成功，则此命令会执行请求的操作。OTP 未显示在屏幕上。
```
$ aws iam list-users --profile role-with-mfa
Enter MFA code for arn:aws:iam::123456789012:mfa/cli-user:
{
    "Users": [
        {
```
#### 跨账户角色和外部 ID
通过将角色配置为跨账户角色，您可以让 IAM 用户使用属于不同账户的角色。在创建角色期间，将角色类型设置为 Another AWS account (其他 AWS 账户)（如[创建向 IAM 用户委派权限的角色](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_create_for-user.html)中所述）。（可选）选择 Require MFA (需要 MFA)。Require MFA (需要 MFA) 选项将按照[使用多重验证](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-role.html#cli-configure-role-mfa)中所述在信任关系中配置相应条件。

如果使用[外部 ID](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html)来加强控制可跨账户使用角色的人员，则还必须将 external_id 参数添加到角色配置文件。通常情况下，仅应在其他账户由公司或组织外部的人员控制时才使用该功能。
```
[profile crossaccountrole]
role_arn = arn:aws-cn:iam::234567890123:role/SomeRole
source_profile = default
mfa_serial = arn:aws-cn:iam::123456789012:mfa/saanvi
external_id = 123456
```
#### 指定角色会话名称以便于审核
当某个角色被许多人共享时，审核会变得比较困难。您希望将调用的每个操作与调用该操作的个人关联。但是，当个人使用角色时，个人代入角色是一项独立于调用操作的行为，您必须手动将这两者关联起来。

通过在用户代入角色时指定唯一的角色会话名称，您可以简化此过程。只需向指定某一角色的 config 文件中的每个命名配置文件添加 role_session_name 参数，即可实现这一点。role_session_name 值将传递给 AssumeRole 操作，并成为角色会话 ARN 的一部分。该值也包含在所有已记录操作的 AWS CloudTrail 日志中。

例如，您可以创建基于角色的配置文件，如下所示：

```
[profile namedsessionrole]
role_arn = arn:aws-cn:iam::234567890123:role/SomeRole
source_profile = default
role_session_name = Session_Maria_Garcia
```
这会导致角色会话具有以下 ARN：

```
arn:aws-cn:iam::234567890123:assumed-role/SomeRole/Session_Maria_Garcia
```

此外，所有 AWS CloudTrail 日志都在为每个操作捕获的信息中包含角色会话名称。
#### 通过 Web 身份代入角色
您可以配置一个配置文件，以指示 AWS CLI 应使用 [Web 联合身份验证和 Open ID Connect (OIDC)](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_providers_oidc.html) 代入角色。当您在配置文件中指定此选项时，AWS CLI 会自动为您发出相应的 AWS STS AssumeRoleWithWebIdentity 调用。
> **注意**：当您指定使用 IAM 角色的配置文件时，AWS CLI 会发出相应的调用来检索临时凭证。随后，这些凭证将存储在 ~/.aws/cli/cache 中。指定同一个配置文件的后续 AWS CLI 命令将使用缓存的临时凭证，直到它们过期。这时，AWS CLI 将自动刷新这些凭证。

要通过 Web 联合身份验证检索和使用临时凭证，您可以在共享配置文件中指定以下配置值：
- [role_arn](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-role.html)
   
   指定要代入的角色的 ARN。
- web_identity_token_file
   
   指定一个文件的路径，该文件包含由身份提供商提供的 OAuth 2.0 访问令牌或 OpenID Connect ID 令牌。AWS CLI 加载此文件，并将其内容作为 AssumeRoleWithWebIdentity 操作的 WebIdentityToken 参数传递。
- [role_session_name](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-role.html#cli-configure-role-session-name)
   
   指定应用于此代入角色会话的可选名称

以下是使用 Web 身份配置文件配置代入角色所需的最少量配置的示例配置：
```
# In ~/.aws/config

[profile web-identity]
role_arn=arn:aws:iam:123456789012:role/RoleNameToAssume
web_identity_token_file=/path/to/a/token
```

您也可以使用[环境变量](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-envvars.html)提供此配置：
- AWS_ROLE_ARN

   要代入的角色的 ARN。
- AWS_WEB_IDENTITY_TOKEN_FILE

   Web 身份令牌文件的路径。
- AWS_ROLE_SESSION_NAME

   应用于此代入角色会话的名称。

> **注意**：这些环境变量当前仅适用于使用 Web 身份提供商的代入角色，而不适用于常规代入角色提供商配置。
#### 清除缓存凭证
当您使用一个角色时，AWS CLI 会在本地缓存临时凭证，直到这些凭证过期。当您下次尝试使用它们时，AWS CLI 会尝试代表您续订这些凭证。

如果您的角色的临时凭证[已吊销](https://docs.amazonaws.cn/IAM/latest/UserGuide/id_roles_use_revoke-sessions.html)，它们不会自动续订，并且使用它们的尝试将失败。但是，您可以删除缓存以强制 AWS CLI 检索新凭证。

**Linux, OS X, or Unix**

```
rm -r ~/.aws/cli/cache
```
**Windows**

```
del /s /q %UserProfile%\.aws\cli\cache
```
### 命令完成（Command Completion）
在类 Unix 系统上，AWS CLI 包含一项命令完成功能，让您可以使用 Tab 键完成部分键入的命令。在大多数系统上，该功能不是自动安装的，需要手动配置。

要配置命令完成，您必须具有两项信息：所使用的 Shell 的名称和 aws_completer 脚本的位置。
> **Amazon Linux** 
> 
>  默认情况下，在运行 Amazon Linux 的 Amazon EC2 实例上自动配置和启用命令完成。
#### 识别 Shell
如果不确定所使用的 Shell，可以使用以下命令之一进行识别：

echo $SHELL – 显示 Shell 的程序文件名称。这通常会与所使用的 Shell 的名称匹配，除非您在登录后启动了不同的 Shell。
```
$ echo $SHELL
/bin/bash
```
ps： 显示为当前用户运行的进程。Shell 将是其中之一。
```
$ ps
  PID TTY          TIME CMD
 2148 pts/1    00:00:00 bash
 8756 pts/1    00:00:00 ps
```
#### 定位 AWS 完成标签
AWS 完成标签的位置可能随所用安装方法而异。

程序包管理器 – pip、yum、brew 和 apt-get 等程序通常在标准路径位置安装 AWS 完成标签（或其符号链接）。在这种情况下，which 命令可以为您定位完成标签。

如果在没有 --user 命令的情况下使用 pip，则可能会看到以下路径。
```
$ which aws_completer
/usr/local/aws/bin/aws_completer
```

如果您在 pip install 命令中使用了 --user 参数，则通常可以在 $HOME 文件夹下的 local/bin 文件夹中找到完成标签。
```
wangbb@wangbb-ThinkPad-T420:~$ which aws_completer
/home/wangbb/.local/bin/aws_completer
```

捆绑安装程序 – 如果根据上一节中的说明使用捆绑安装程序，AWS 完成标签将位于安装目录的 bin 子文件夹中。

```
$ ls /usr/local/aws/bin
activate
activate.csh
activate.fish
activate_this.py
aws
aws.cmd
aws_completer
...
```
如果所有 else 都失败，可以使用 find 在整个文件系统中搜索 AWS 完成标签。

```
$ find / -name aws_completer
/usr/local/aws/bin/aws_completer
```
#### 将补全程序的文件夹添加到您的路径中
要让 AWS 补全程序成功运行，必须先将其添加到计算机的路径中。
1. 在您的用户文件夹中查找 Shell 的配置文件脚本。如果您不能确定所使用的 Shell，请运行 echo $SHELL。
   
    ```
    $ ls -a ~
    .  ..  .bash_logout  .bash_profile  .bashrc  Desktop  Documents  Downloads
    ```

   + Bash– .bash_profile、.profile 或 .bash_login
    + Zsh– .zshrc
    + Tcsh– .tcshrc、.cshrc 或 .login
2. 在配置文件脚本末尾添加与以下示例类似的导出命令。将 /usr/local/aws/bin 替换为您在上一部分中找到的文件夹。
   
   ```
   export PATH=/usr/local/aws/bin:$PATH
   ```
3. 将配置文件重新加载到当前会话中，以使更改生效。将 .bash_profile 替换为您在第一部分中找到的 shell 脚本的名称。
   
   ```
   source ~/.bash_profile
   ```
#### 启用命令完成
运行命令以启用命令完成。用来启用完成功能的命令取决于所使用的 Shell。您可以将命令添加到外壳程序的 RC 文件中，以便在每次打开一个新外壳程序时运行它。在每个命令中，将路径 /usr/local/aws/bin 替换为上一部分中在您的系统上找到的那个。
- **bash** – 使用内置命令 complete。
   
   ```
   complete -C '/usr/local/aws/bin/aws_completer' aws
   ```
   将命令添加到 ~/.bashrc 中，以便在每次打开一个新外壳程序时运行它。您的 ~/.bash_profile 应指定 ~/.bashrc 的来源，以确保该命令也在登录外壳程序中运行。
- **tcsh** – tcsh 的完成采用字类型和样式来定义完成行为。

   ```
   > complete aws 'p/*/`aws_completer`/'
   ```
   将命令添加到 ~/.tschrc 中，以便在每次打开一个新外壳程序时运行它。
- **zsh** – 源 bin/aws_zsh_completer.sh。

   ```
   % source /usr/local/aws/bin/aws_zsh_completer.sh
   ```
   WS CLI 使用 bash 兼容性自动完成 (bashcompinit) 实现 zsh 支持。有关更多详细信息，请参阅aws_zsh_completer.sh 的顶部。

   将命令添加到 ~/.zshrc 中，以便在每次打开一个新外壳程序时运行它。
#### 测试命令完成
启用命令完成后，输入部分命令并按 Tab 查看可用命令。
```
$ aws sTAB
s3              ses             sqs             sts             swf
s3api           sns             storagegateway  support
```

## Reference
- [配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html)
