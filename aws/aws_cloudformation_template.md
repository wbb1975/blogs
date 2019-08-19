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
## 模板剖析
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
## 什么是 AWS CloudFormation Designer？
## 演练
## 模板代码段
## 自定义资源
## 模板宏
## 使用正则表达式
## 使用 CloudFormer（测试版）创建模板

## 参考
- [与 AWS CloudFormation 模板一起运行](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-guide.html)