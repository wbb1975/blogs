# 与 AWS CloudFormation 模板一起运行 （Working with AWS CloudFormation Templates）
要调配和配置堆栈资源，您必须了解 AWS CloudFormation 模板 (JSON 或 YAML 格式的文本文件)。这些模板描述要在 AWS CloudFormation 堆栈中调配的资源。您可以使用 AWS CloudFormation Designer 或任意文本编辑器创建和保存模板。有关模板结构和语法的信息，请参阅[模板剖析](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-anatomy.html)。

如果您不熟悉 JSON 或 YAML，可以使用 AWS CloudFormation Designer 帮助您开始使用 AWS CloudFormation 模板。AWS CloudFormation Designer 是一种以可视化方式创建和修改模板的工具。有关更多信息，请参阅[什么是 AWS CloudFormation Designer？](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/working-with-templates-cfn-designer.html)。

[模板代码段](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/CHAP_TemplateQuickRef.html) 提供一些示例以说明如何为特定资源编写模板。例如，您可以查看 Amazon EC2 实例、Amazon S3 域、AWS CloudFormation 映射等的代码段。代码段按资源分组，在[通用模板代码段](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/quickref-general.html)中提供了通用的 AWS CloudFormation 代码段。

有关您可以在模板中使用的支持的资源、类型名称、内部函数和伪参数的详细信息，请参阅[模板参考](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-reference.html)。
## 模板格式
可使用 JSON 或 YAML 格式创作 AWS CloudFormation 模板。我们支持适用于这两种格式的所有 AWS CloudFormation 特性和功能（包含在 AWS CloudFormation Designer 中）。

在决定要使用哪种格式时，选择最方便使用的格式。另外，考虑到 YAML 本身提供了一些不适用于 JSON 的功能，例如注释。

> **重要**  我们建议您不要在 Designer 中向模板添加 # YAML 注释。如果您的 YAML 模板包含 # 注释，则 Designer 在将模板转换为 JSON 时不保留这些注释。此外，在 Designer 中修改模板 (例如，在画布上移动资源) 时，注释将丢失。

您可以向在 Designer 以外创建的 AWS CloudFormation 模板中添加注释。以下示例介绍一个包含内联注释的 YAML 模板。
```

AWSTemplateFormatVersion: "2010-09-09"
Description: A sample template
Resources:
  MyEC2Instance: #An inline comment
    Type: "AWS::EC2::Instance"
    Properties: 
      ImageId: "ami-0ff8a91507f77f867" #Another comment -- This is a Linux AMI
      InstanceType: t2.micro
      KeyName: testkey
      BlockDeviceMappings:
        -
          DeviceName: /dev/sdm
          Ebs:
            VolumeType: io1
            Iops: 200
            DeleteOnTermination: false
            VolumeSize: 20
```
AWS CloudFormation 支持以下 JSON 和 YAML 规范：

**JSON**

   AWS CloudFormation 遵循 ECMA-404 JSON 标准。有关 JSON 格式的更多信息，请访问 http://www.json.org。

**YAML**

  AWS CloudFormation 支持 YAML 版本 1.1 规范，但有一些例外。AWS CloudFormation 不支持以下功能：

     - binary、omap、pairs、set 和 timestamp 标签
     - 别名
     - 哈希合并

   有关 YAML 的更多信息，请访问 http://www.yaml.org。
## 模板剖析 (Template Anatomy)
模板是一个 JSON 或 YAML 格式的文本文件，该文件描述您的 AWS 基础设施。以下示例显示 AWS CloudFormation 模板结构和各个部分。
### JSON
以下示例显示 JSON 格式的模板片段：
```
{
  "AWSTemplateFormatVersion" : "version date",

  "Description" : "JSON string",

  "Metadata" : {
    template metadata
  },

  "Parameters" : {
    set of parameters
  },

  "Mappings" : {
    set of mappings
  },

  "Conditions" : {
    set of conditions
  },

  "Transform" : {
    set of transforms
  },

  "Resources" : {
    set of resources
  },

  "Outputs" : {
    set of outputs
  }
}
```
### YAML
以下示例显示 YAML 格式的模板片段：
```
---
AWSTemplateFormatVersion: "version date"

Description:
  String

Metadata:
  template metadata

Parameters:
  set of parameters

Mappings:
  set of mappings

Conditions:
  set of conditions

Transform:
  set of transforms

Resources:
  set of resources

Outputs:
  set of outputs
```
### 模板部分
模板包含几个主要部分。Resources 部分是唯一的必需部分。模板中的某些部分可以任何顺序显示。但是，在您构建模板时，使用以下列表中显示的逻辑顺序可能会很有用，因为一个部分中的值可能会引用上一个部分中的值。
- [Format Version（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/format-version-structure.html)

    模板符合的 AWS CloudFormation 模板版本。模板格式版本与 API 或 WSDL 版本不同。模板格式版本可独立于 API 和 WSDL 版本，进行独立更改。
- [Description (可选)](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-description-structure.html)

    一个描述模板的文本字符串。此部分必须始终紧随模板格式版本部分之后。
- [元数据（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/metadata-section-structure.html)

    提供有关模板的其他信息的对象。
- [Parameters（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)

    要在运行时 (创建或更新堆栈时) 传递到模板的值。您可引用模板的 Resources 和 Outputs 部分中的参数。
-[Mappings（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/mappings-section-structure.html)

    可用来指定条件参数值的密钥和关键值的映射，与查找表类似。可以通过使用 Resources 和 Outputs 部分中的 Fn::FindInMap 内部函数将键与相应的值匹配。
- [条件（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/conditions-section-structure.html)
  
    用于控制是否创建某些资源或者是否在堆栈创建或更新过程中为某些资源属性分配值的条件。例如，您可以根据堆栈是用于生产环境还是用于测试环境来按照条件创建资源。
- [转换 (可选)](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/transform-section-structure.html)
  
    对于[无服务器应用程序](https://docs.aws.amazon.com/lambda/latest/dg/deploying-lambda-apps.html) （也称为“基于 Lambda 的应用程序”），指定要使用的 [AWS Serverless Application Model (AWS SAM)](https://github.com/awslabs/serverless-application-specification) 的版本。当您指定转换时，可以使用 AWS SAM 语法声明您的模板中的资源。此模型定义您可使用的语法及其处理方式。

    您也可以使用 AWS::Include 转换来处理与主 AWS CloudFormation 模板分开存储的模板代码段。您可以将代码段文件存储在 Amazon S3 存储桶中，然后在多个模板中重用这些函数。
- [Resources（必需）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/resources-section-structure.html)

    指定堆栈资源及其属性，如 Amazon Elastic Compute Cloud 实例或 Amazon Simple Storage Service 存储桶。您可引用模板的 Resources 和 Outputs 部分中的资源。
- [Outputs（可选）](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html)
  
    描述在您查看堆栈的属性时返回的值。例如，您可以声明 S3 存储桶名称的输出，然后调用 aws cloudformation describe-stacks AWS CLI 命令来查看该名称。
### 格式版本
AWSTemplateFormatVersion 部分 (可选) 标识模板的功能。最新的模板格式版本是 2010-09-09，并且它是目前唯一的有效值。

> **注意**  模板格式版本与 API 或 WSDL 版本不同。模板格式版本可独立于 API 和 WSDL 版本，进行独立更改。

模板格式版本声明的值必须是文字字符串。您无法使用参数或函数来指定模板格式版本。如果您没有指定值，则 AWS CloudFormation 将接受最新的模板格式版本。以下代码段是有效的模板格式版本声明的示例：

**JSON**

```
"AWSTemplateFormatVersion" : "2010-09-09"
```

**YAML**

```
AWSTemplateFormatVersion: "2010-09-09"
```
### Description
Description 部分（可选）使您能够包含有关您的模板的评论。Description 必须紧随 AWSTemplateFormatVersion 部分之后。

描述声明的值必须是长度介于 0 和 1024 个字节之间的文字字符串。您无法使用参数或函数来指定描述。以下代码段是描述声明的示例：

**JSON**

```
"Description" : "Here are some details about the template."
```

**YAML**

```
Description: >
  Here are some
  details about
  the template.
```
### 元数据
您可以使用可选的 Metadata 部分包括任意 JSON 或 YAML 对象，用于提供模板详细信息。例如，可以包括有关特定资源的模板实现详细信息，如以下代码段所示：
> **重要**  堆栈更新期间，您无法更新 Metadata 部分本身。您只能在包括添加、修改或删除资源的更改时更新它。

**JSON**

```
"Metadata" : {
  "Instances" : {"Description" : "Information about the instances"},
  "Databases" : {"Description" : "Information about the databases"}
```

**YAML**

```
Metadata:
  Instances:
    Description: "Information about the instances"
  Databases: 
    Description: "Information about the databases"
```

#### 元数据键
某些 AWS CloudFormation 功能可在 Metadata 部分中检索您定义的设置或配置信息。您可在以下特定于 AWS CloudFormation 的元数据键中定义此信息：
##### AWS::CloudFormation::Init
为 cfn-init 帮助程序脚本定义配置任务。要在 EC2 实例上配置和安装应用程序，此脚本很有用。有关更多信息，请参阅 [AWS::CloudFormation::Init](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-resource-init.html)。
##### AWS::CloudFormation::Interface
定义在 AWS CloudFormation 控制台中显示输入参数时的分组和排序。默认情况下，AWS CloudFormation 控制台根据参数的逻辑 ID 按照字母顺序排序。有关更多信息，请参阅[AWS::CloudFormation::Interface](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)。
##### AWS::CloudFormation::Designer
描述您的资源在 AWS CloudFormation Designer (Designer) 中如何排列。当您使用它创建和更新模板时，Designer 会自动添加此信息。有关更多信息，请参阅 [什么是 AWS CloudFormation Designer？](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/working-with-templates-cfn-designer.html)
### 参数
使用可选的 Parameters 部分来自定义模板。利用参数，您能够在每次创建或更新堆栈时将自定义值输入模板。
#### 在模板中定义参数
以下示例声明名为 InstanceTypeParameter 的参数。利用此参数，您可以为堆栈指定 Amazon EC2 实例类型以在创建或更新堆栈时使用。

请注意，InstanceTypeParameter 具有默认值 t2.micro。除非提供有其他值，否则这是 AWS CloudFormation 用于预置堆栈的值。

**JSON**
```
"Parameters" : {
  "InstanceTypeParameter" : {
    "Type" : "String",
    "Default" : "t2.micro",
    "AllowedValues" : ["t2.micro", "m1.small", "m1.large"],
    "Description" : "Enter t2.micro, m1.small, or m1.large. Default is t2.micro."
  }
}
```

**YAML**

```
Parameters: 
  InstanceTypeParameter: 
    Type: String
    Default: t2.micro
    AllowedValues: 
      - t2.micro
      - m1.small
      - m1.large
    Description: Enter t2.micro, m1.small, or m1.large. Default is t2.micro.
```
#### 在模板中引用参数
您使用 Ref 内部函数来引用某个参数，AWS CloudFormation 使用该参数的值来预置堆栈。您可以引用同一模板的 Resources 和 Outputs 部分中的参数。

在以下示例中，EC2 实例资源的 InstanceType 属性引用了 InstanceTypeParameter 参数值：

**JSON**
```
"Ec2Instance" : {
  "Type" : "AWS::EC2::Instance",
  "Properties" : {
    "InstanceType" : { "Ref" : "InstanceTypeParameter" },
    "ImageId" : "ami-0ff8a91507f77f867"
  }
}"Ec2Instance" : {
  "Type" : "AWS::EC2::Instance",
  "Properties" : {
    "InstanceType" : { "Ref" : "InstanceTypeParameter" },
    "ImageId" : "ami-0ff8a91507f77f867"
  }
}
```

**YAML**

```
Ec2Instance:
  Type: AWS::EC2::Instance
  Properties:
    InstanceType:
      Ref: InstanceTypeParameter
    ImageId: ami-0ff8a91507f77f867
```
#### 参数的一般要求
- 一个 AWS CloudFormation 模板中最多可包含 60 个参数。
- 必须为每个参数提供一个逻辑名称 (也称为逻辑 ID)，该名称必须是字母数字，并且在模板内的所有逻辑名称中必须是唯一的。
- 必须向每个参数分配一个受 AWS CloudFormation 支持的参数类型。有关更多信息，请参阅[类型](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#parameters-section-structure-properties-type)。
- 必须向每个参数分配一个运行时的值，使 AWS CloudFormation 能够成功预置堆栈。您可以选择为要使用的 AWS CloudFormation 指定默认值，除非提供有其他值。
- 必须在同一模板内声明和引用参数。您可以引用模板的 Resources 和 Outputs 部分中的参数。

**JSON**

```
"Parameters" : {
  "ParameterLogicalID" : {
    "Type" : "DataType",
    "ParameterProperty" : "value"
  }
}
```

**YAML**

```
Parameters:
  ParameterLogicalID:
    Type: DataType
    ParameterProperty: value
```
#### 属性
- AllowedPattern
  
   一个正则表达式，表示要允许 String 类型使用的模式。

   Required: No
- AllowedValues
  
   包含参数允许值列表的阵列。

   Required: No
- ConstraintDescription

   用于在违反约束时说明该约束的字符串。例如，在没有约束条件描述的情况下，具有允许的 [A-Za-z0-9]+ 模式的参数会在用户指定无效值时显示以下错误消息：

   Malformed input-Parameter MyParameter must match pattern [A-Za-z0-9]+

   通过添加约束描述（如 must only contain letters (uppercase and lowercase) and numbers），您可以显示以下自定义的错误消息：

   Malformed input-Parameter MyParameter must only contain uppercase and lowercase letters and numbers

   Required: No
- Default
  
   模板适当类型的值，用于在创建堆栈时未指定值的情况下。如果您定义参数的约束，则必须指定一个符合这些约束的值。

   Required: No
- Description
  
   用于描述参数的长度最多为 4000 个字符的字符串。

   Required: No
- MaxLength
  
   一个整数值，确定要允许 String 类型使用的字符的最大数目。

   Required: No
- MaxValue
  
   一个数字值，确定要允许 Number 类型使用的最大数字值。

   Required: No
- MinLength

   一个整数值，确定要允许 String 类型使用的字符的最小数目。

   Required: No
- MinValue
   
   一个数字值，确定要允许 Number 类型使用的最小数字值。

   Required: No
- NoEcho

   在发出描述堆栈的调用时是否掩蔽参数值。如果将值设置为 true，则使用星号 (*****) 掩蔽参数值。

   Required: No
- Type

   参数 (DataType) 的数据类型。

   Required: Yes

   AWS CloudFormation 支持以下参数类型：

   String

      一个文字字符串。

      例如，用户可指定 "MyUserName"。

   Number

      整数或浮点数。AWS CloudFormation 将参数值验证为数字；但当您在模板中的其他位置使用该参数时（例如，通过使用 Ref 内部函数），该参数值将变成字符串。

      例如，用户可指定 "8888"。

   List<Number>
  
      一组用逗号分隔的整数或浮点数。AWS CloudFormation 将参数值验证为数字，但当您在模板中的其他位置使用该参数时（例如，通过使用 Ref 内部函数），该参数值将变成字符串列表。

      例如，用户可指定 "80,20"，并且 Ref 将生成 ["80","20"]。

   CommaDelimitedList

      一组用逗号分隔的文本字符串。字符串的总数应比逗号总数多 1。此外，会对每个成员字符串进行空间修剪。

      例如，用户可指定 "test,dev,prod"，并且 Ref 将生成 ["test","dev","prod"]。

   AWS 特定的参数类型

      AWS 值，例如 Amazon EC2 密钥对名称和 VPC ID。有关更多信息，请参阅[AWS 特定的参数类型](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-specific-parameter-types)。

   SSM 参数类型

      与 Systems Manager Parameter Store 中的现有参数对应的参数。您指定 Systems Manager 参数键作为 SSM 参数的值，并且 AWS CloudFormation 从 Parameter Store 提取最新值来用于堆栈。有关更多信息，请参阅 [SSM 参数类型](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-ssm-parameter-types。)

      > **注意**  AWS CloudFormation 目前不支持 SecureString Systems Manager 参数类型。
#### AWS 特定的参数类型
要在开始创建或更新堆栈时捕获无效值，特定于 AWS 的参数类型很有帮助。要使用特定于 AWS 的类型指定参数，模板用户必须输入其 AWS 账户中的现有 AWS 值。AWS CloudFormation 针对该账户中的现有值来验证这些输入值。例如，对于 AWS::EC2::VPC::Id 参数类型，用户必须[输入在其中创建堆栈的账户和区域中的现有 VPC ID](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-parameters.html)。

如果要允许模板用户输入来自不同 AWS 账户的输入值，请不要使用特定于 AWS 的类型来定义参数；相反，定义类型为 String（或 CommaDelimitedList）的参数。

支持的特定于 AWS 的参数类型：
- AWS::EC2::AvailabilityZone::Name

   可用区，如 us-west-2a。
- AWS::EC2::Image::Id

   Amazon EC2 映像 ID，如 ami-0ff8a91507f77f867。请注意，AWS CloudFormation 控制台不会显示此参数类型的值的下拉列表。
- AWS::EC2::Instance::Id

   Amazon EC2 实例 ID，如 i-1e731a32。
- AWS::EC2::KeyPair::KeyName
   
   Amazon EC2 密钥对名称。
- AWS::EC2::SecurityGroup::GroupName

   EC2-Classic 或默认 VPC 安全组名称，如 my-sg-abc。
- AWS::EC2::SecurityGroup::Id

   安全组 ID，如 sg-a123fd85。
- AWS::EC2::Subnet::Id

   子网 ID，如 subnet-123a351e。
- AWS::EC2::Volume::Id

   Amazon EBS 卷 ID，如 vol-3cdd3f56。
- AWS::EC2::VPC::Id

   VPC ID，如 vpc-a123baa3。
- AWS::Route53::HostedZone::Id

   Amazon Route 53 托管区域 ID，如 Z23YXV4OVPL04A。
- List<<AWS::EC2::AvailabilityZone::Name>>

   针对某个区域的一组可用区，如 us-west-2a, us-west-2b。
- List<<AWS::EC2::Image::Id>>

   一组 Amazon EC2 映像 ID，如 ami-0ff8a91507f77f867, ami-0a584ac55a7631c0c。请注意，AWS CloudFormation 控制台不会显示此参数类型的值的下拉列表。
- List<<AWS::EC2::Instance::Id>>

   一组 Amazon EC2 实例 ID，如 i-1e731a32, i-1e731a34。
- List<<AWS::EC2::SecurityGroup::GroupName>>

   一组 EC2-Classic 或默认 VPC 安全组名称，如 my-sg-abc, my-sg-def。
- List<<AWS::EC2::SecurityGroup::Id>>

   一组安全组 ID，如 sg-a123fd85, sg-b456fd85。
- List<<AWS::EC2::Subnet::Id>>

   一组子网 ID，如 subnet-123a351e, subnet-456b351e。
- List<<AWS::EC2::Volume::Id>>

   一组 Amazon EBS 卷 ID，如 vol-3cdd3f56, vol-4cdd3f56。
- List<<AWS::EC2::VPC::Id>>

   一组 VPC ID，如 vpc-a123baa3, vpc-b456baa3。
- List<<AWS::Route53::HostedZone::Id>>

   一组 Amazon Route 53 托管区域 ID，如 Z23YXV4OVPL04A, Z23YXV4OVPL04B。
#### SSM 参数类型
SSM 参数类型与 Systems Manager Parameter Store 中的现有参数对应。您指定 Systems Manager 参数键作为 SSM 参数的值，并且 AWS CloudFormation 从 Parameter Store 提取最新值来用于堆栈。有关 Systems Manager 参数的更多信息，请参阅AWS Systems Manager 用户指南中的 [Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)。

您也可以使用 ssm 或 ssm-secure 动态参数模式在模板中指定参数值。有关更多信息，请参阅[使用动态引用以指定模板值](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/dynamic-references.html)。

当您创建或更新堆栈并创建更改集时，AWS CloudFormation 会在此操作运行时使用 Parameter Store 中存在的任何值。如果某个指定的参数在调用方的 AWS 账户下的 Parameter Store 中不存在，AWS CloudFormation 会返回验证错误。

当您执行更改集时，AWS CloudFormation 将使用在更改集中指定的值。您应在执行更改集前检查这些值，因为在您创建更改集和运行更改集之间的时间内，它们可能会在 Parameter Store 中发生更改。
   > **提示**  您可以在控制台中或通过运行 describe-stacks 或 describe-change-set 来查看堆栈的 Parameters 选项卡上 SSM 参数的解析值。这些是目前在堆栈定义中用于相应的 Systems Manager 参数键的值。请注意，这些值是在创建或更新堆栈时设置的，因此它们可能与 Parameter Store 中的最新值不同。
   > 
   > 如果您使用 ssm-secure 模式指定参数值作为安全字符串，AWS CloudFormation 不会存储安全字符串值或将其显示在控制台中或 API 调用的结果中。

由于 SSM 参数的值是 Systems Manager 参数键，因此您应了解以下行为：
   - 对于堆栈更新，控制台中的 Use existing value (使用现有值) 选项和[update-stack](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/update-stack.html) 的 UsePreviousValue 属性告诉 AWS CloudFormation 使用现有 Systems Manager 参数键，而不是其值。AWS CloudFormation 在更新堆栈时始终从 Parameter Store 中提取最新值。

     但是，如果您使用 ssm 或 ssm-secure 动态参数模式来指定参数值，您必须指定 Systems Manager 参数的版本以便 AWS CloudFormation 使用。
   - AWS CloudFormation 可以对 Systems Manager 参数键执行验证，但不能对其对应的值执行验证。为了进行验证，您可以将参数键视为字符串。您应为 Parameter Store 中的 Systems Manager 参数值执行任何验证。

有关使用 SSM 参数类型的示例，请参阅[SSM 参数类型](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#parameters-section-ssm-examples)。

AWS CloudFormation 支持以下 SSM 参数类型：
+ AWS::SSM::Parameter::Name
 
    Systems Manager 参数键的名称。

   请在您要传递参数键时使用此参数。例如，您可以使用此类型验证此参数是否存在。
+ AWS::SSM::Parameter::Value<String>

   其值是字符串的 Systems Manager 参数。这与 Parameter Store 中的 String 参数对应。
+ AWS::SSM::Parameter::Value<List<String>> 或者 AWS::SSM::Parameter::Value<CommaDelimitedList>

   其值是字符串列表的 Systems Manager 参数。这与 Parameter Store 中的 StringList 参数对应。
+ AWS::SSM::Parameter::Value<AWS-specific parameter type>
  
   其值是[特定于 AWS 的参数类型](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-specific-parameter-types)的 Systems Manager 参数。例如，下面指定了 AWS::EC2::KeyPair::KeyName 类型：

   AWS::SSM::Parameter::Value<AWS::EC2::KeyPair::KeyPairName>
+ AWS::SSM::Parameter::Value<List<AWS-specific parameter type>>

   其值是特定于 AWS 的参数类型的列表的 Systems Manager 参数。例如，下面指定了 AWS::EC2::KeyPair::KeyName 类型的列表：

   AWS::SSM::Parameter::Value<List<AWS::EC2::KeyPair::KeyPairName>>

不支持的 SSM 参数类型：
  - SSM 参数类型的列表，例如：List<AWS::SSM::Parameter::Value<String>>

此外，AWS CloudFormation 不支持将模板参数定义为 SecureString Systems Manager 参数类型。但是，您可以使用动态参数模式为某些资源指定安全字符串作为参数值。有关更多信息，请参阅[使用动态引用以指定模板值](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/dynamic-references.html)。
#### 在 AWS CloudFormation 控制台中对参数进行分组和排序
使用 AWS CloudFormation 控制台创建或更新堆栈时，控制台根据输入参数的逻辑 ID 按照字母顺序列出输入参数。要覆盖默认排序方式，您可以使用 AWS::CloudFormation::Interface 元数据键。通过对参数进行分组和排序，用户可更轻松地指定参数值。例如，您可以将所有 VPC 相关参数放到一个组中，免得它们散落在按字母排序的列表中而难以查找。

在元数据键中，您可以指定要创建的组、每个组包含的参数以及控制台在其分组中显示各个参数时的顺序。此外，您还可以定义易记参数名称，以便控制台显示描述性名称而不是逻辑 ID。在元数据键中引用的所有参数都必须在模板的 Parameters 部分中声明。

有关更多信息和 AWS::CloudFormation::Interface 元数据键的示例，请参阅[AWS::CloudFormation::Interface](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)。
#### 示例
##### 基本输入参数
以下示例 Parameters 部分声明有两个参数。DBPort 参数属于 Number 类型，默认值为 3306。可指定的最小值为 1150，可指定的最大值为 65535。DBPwd 参数属于 String 类型，无默认值。NoEcho 属性设置为 true，以阻止描述堆栈调用（如 aws cloudformation describe-stacks AWS CLI 命令）返回参数值。可指定的最小长度为 1，可指定的最大长度为 41。该模式允许小写和大写字母字符和数字。

**JSON**
```
"Parameters" : {
  "DBPort" : {
    "Default" : "3306",
    "Description" : "TCP/IP port for the database",
    "Type" : "Number",
    "MinValue" : "1150",
    "MaxValue" : "65535"
  },
  "DBPwd" : {
    "NoEcho" : "true",
    "Description" : "The database admin account password",
    "Type" : "String",
    "MinLength" : "1",
    "MaxLength" : "41",
    "AllowedPattern" : "^[a-zA-Z0-9]*$"
  }
}
```

**YAML**
```
Parameters: 
  DBPort: 
    Default: 3306
    Description: TCP/IP port for the database
    Type: Number
    MinValue: 1150
    MaxValue: 65535
  DBPwd: 
    NoEcho: true
    Description: The database admin account password
    Type: String
    MinLength: 1
    MaxLength: 41
    AllowedPattern: ^[a-zA-Z0-9]*$
```
##### AWS 特定的参数类型
当您使用 AWS 特定的参数类型时，使用您的模板创建或更新堆栈的用户必须指定其账户中和当前堆栈所在的区域中的现有 AWS 值。AWS 特定的参数类型可帮助确保在 AWS CloudFormation 创建或更新任何资源之前，这些类型的输入值存在且正确。例如，如果使用 AWS::EC2::KeyPair::KeyName 参数类型，AWS CloudFormation 在创建任何资源（如 Amazon EC2 实例）之前，将针对用户的现有密钥对名称验证输入值。

如果用户使用 AWS 管理控制台，则 AWS CloudFormation [向 AWS 特定的参数类型预填充有效值](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-parameters.html)。这样一来，用户便无需记住和正确输入特定的名称或 ID，而只需从下拉列表中选择一个或多个值。此外，根据参数类型，用户还可以按 ID、名称或名称标签值来搜索值。有关更多信息，请参阅[指定堆栈名称和参数](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-parameters.html)。

以下示例声明类型 AWS::EC2::KeyPair::KeyName 和 AWS::EC2::Subnet::Id 的两个参数。这些类型限制现有密钥对名称和子网 ID 的有效值。因为将 mySubnetIDs 参数指定为列表，所以用户可指定一个或多个子网 ID。

**JSON**
```
"Parameters" : {
  "myKeyPair" : {
    "Description" : "Amazon EC2 Key Pair",
    "Type" : "AWS::EC2::KeyPair::KeyName"
  },
  "mySubnetIDs" : {
    "Description" : "Subnet IDs",
    "Type" : "List<AWS::EC2::Subnet::Id>"
  }
}
```

**YAML**
```
Parameters: 
  myKeyPair: 
    Description: Amazon EC2 Key Pair
    Type: "AWS::EC2::KeyPair::KeyName"
  mySubnetIDs: 
    Description: Subnet IDs
    Type: "List<AWS::EC2::Subnet::Id>"
```

***AWS CLI 和 API 支持***
目前，用户无法使用 AWS CLI 或 AWS CloudFormation API 查看 AWS 特定的参数的有效值列表。但用户可通过使用 [aws cloudformation get-template-summary](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/get-template-summary.html) 命令或 [GetTemplateSummary API](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_GetTemplateSummary.html) 来查看有关每个参数的信息，如参数类型。
##### 逗号分隔列表参数类型
您可使用 CommaDelimitedList 参数类型在一个参数中指定多个字符串值。这样一来，您可使用一个参数而不是许多不同的参数来指定多个值。例如，如果您使用各自不同的 CIDR 块分别创建三个不同子网，则可以使用三个不同参数指定三个不同 CIDR 块。不过更简单的方法是使用包括三个 CIDR 块的列表的单个参数，如以下代码段所示：

**JSON**
```
"Parameters" : {
  "DbSubnetIpBlocks": {
    "Description": "Comma-delimited list of three CIDR blocks",
    "Type": "CommaDelimitedList",
    "Default": "10.0.48.0/24, 10.0.112.0/24, 10.0.176.0/24"
  }
}
```

**YMAL**
```
Parameters: 
  DbSubnetIpBlocks: 
    Description: "Comma-delimited list of three CIDR blocks"
    Type: CommaDelimitedList
    Default: "10.0.48.0/24, 10.0.112.0/24, 10.0.176.0/24"
```
##### *从逗号分隔列表参数返回值*
要引用列表中的特定值，请在模板的 Fn::Select 部分中使用 Resources 内部函数。可传递所需对象的索引值和对象列表，如以下代码段所示：

**JSON**
```
"DbSubnet1" : {
  "Type" : "AWS::EC2::Subnet",
  "Properties" : {
    "AvailabilityZone" : {"Fn::Join" : ["",[ { "Ref" : "AWS::Region" }, { "Fn::Select" : [ "0", {"Ref" : "VpcAzs"} ] } ] ]} ,
    "VpcId" :  { "Ref" : "VPC" },
    "CidrBlock" : { "Fn::Select" : [ "0", {"Ref" : "DbSubnetIpBlocks"} ] }
  }
},
"DbSubnet2" : {
  "Type" : "AWS::EC2::Subnet",
  "Properties" : {
    "AvailabilityZone" : {"Fn::Join" : ["",[ { "Ref" : "AWS::Region" }, { "Fn::Select" : [ "1", {"Ref" : "VpcAzs"} ] } ] ]} ,
    "VpcId" : { "Ref" : "VPC" },
    "CidrBlock" : { "Fn::Select" : [ "1", {"Ref" : "DbSubnetIpBlocks"} ] }
  }
},
"DbSubnet3" : {
  "Type" : "AWS::EC2::Subnet",
  "Properties" : {
    "AvailabilityZone" : {"Fn::Join" : ["",[ { "Ref" : "AWS::Region" }, { "Fn::Select" : [ "2", {"Ref" : "VpcAzs"} ] } ] ]} ,
    "VpcId" : { "Ref" : "VPC" },
    "CidrBlock" : { "Fn::Select" : [ "2", {"Ref" : "DbSubnetIpBlocks"} ] }
  }
}
```

**YAML**
```
DbSubnet1:
  Type: AWS::EC2::Subnet
  Properties:
    AvailabilityZone: !Sub
      - "${AWS::Region}${AZ}"
      - AZ: !Select [0, !Ref VpcAzs]
    VpcId: !Ref VPC
    CidrBlock: !Select [0, !Ref DbSubnetIpBlocks]
DbSubnet2: 
  Type: AWS::EC2::Subnet
  Properties:
    AvailabilityZone: !Sub
      - "${AWS::Region}${AZ}"
      - AZ: !Select [1, !Ref VpcAzs]
    VpcId: !Ref VPC
    CidrBlock: !Select [1, !Ref DbSubnetIpBlocks]
DbSubnet3: 
  Type: AWS::EC2::Subnet
  Properties:
    AvailabilityZone: !Sub
      - "${AWS::Region}${AZ}"
      - AZ: !Select [2, !Ref VpcAzs]
    VpcId: !Ref VPC
    CidrBlock: !Select [2, !Ref DbSubnetIpBlocks]
```
##### SSM 参数类型
###### AWS::SSM::Parameter::Value<String> 类型
以下模板声明 AWS::SSM::Parameter::Value<String> 参数类型。

**JSON**
```
{
  "Parameters": {
    "InstanceType": {
      "Type": "AWS::SSM::Parameter::Value<String>"
    }
  },
  "Resources": {
    "Instance": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "InstanceType": {
          "Ref": "InstanceType"
        }
      }
    }
  }
}
```

**YAML**
```
Parameters: 
  InstanceType: 
    Type: 'AWS::SSM::Parameter::Value<String>'
Resources: 
  Instance: 
    Type: 'AWS::EC2::Instance'
    Properties: 
      InstanceType: !Ref InstanceType
```

以下命令基于示例模板创建堆栈。它提供 Systems Manager 参数键 (myInstanceType) 作为 InstanceType 模板参数的值。这假定 myInstanceType 参数在调用方的 AWS 账户下的 Parameter Store 中存在。
```
aws cloudformation create-stack --stack-name S1 --template-body example template --parameters ParameterKey=InstanceType,ParameterValue=myInstanceType
```
###### AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 类型
以下模板声明 AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 参数类型。

**JSON**
```
{
  "Parameters": {
    "ImageId": {
      "Type": "AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>"
    }
  },
  "Resources": {
    "Instance": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": {
          "Ref": "ImageId"
        }
      }
    }
  }
}
```

**YAML**
```
Parameters: 
  ImageId: 
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
Resources: 
  Instance: 
    Type: 'AWS::EC2::Instance'
    Properties:
      ImageId: !Ref ImageId
```

以下命令基于示例模板创建堆栈。它提供 Systems Manager 参数键 (myLatestAMI) 作为 ImageId 模板参数的值。这假定 myLatestAMI 参数在调用方的 AWS 账户下的 Parameter Store 中存在。
```
aws cloudformation create-stack --stack-name S2 --template-body example template --parameters ParameterKey=ImageId,ParameterValue=myLatestAMI
```
## 什么是 AWS CloudFormation Designer？
## 演练
## 模板代码段
## 自定义资源
## 模板宏
## 使用正则表达式
## 使用 CloudFormer（测试版）创建模板

## 参考
- [与 AWS CloudFormation 模板一起运行](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-guide.html)