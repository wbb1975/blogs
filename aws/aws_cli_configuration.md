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
