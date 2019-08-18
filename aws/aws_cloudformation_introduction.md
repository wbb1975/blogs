# AWS CloudFormation 文档
借助 AWS CloudFormation，您可以有预见性地、重复地创建和预置 AWS 基础设施部署。它可以帮助您利用 AWS 产品 (如 Amazon EC2、Amazon Elastic Block Store、Amazon SNS、Elastic Load Balancing 和 Auto Scaling) 在云中构建高度可靠、高度可扩展且经济高效的应用程序，为您免除创建和配置底层 AWS 基础设施之忧。借助 AWS CloudFormation，您可以使用模板文件，将资源集作为一个单元 (堆栈) 进行创建和删除。
## 什么是 AWS CloudFormation
AWS CloudFormation 是一项服务，可帮助您对 Amazon Web Services 资源进行建模和设置，以便能花较少的时间管理这些资源，而将更多的时间花在运行于 AWS 中的应用程序上。您创建一个描述您所需的所有 AWS 资源（如 Amazon EC2 实例或 Amazon RDS 数据库实例）的模板，并且 AWS CloudFormation 将负责为您设置和配置这些资源。您无需单独创建和配置 AWS 资源并了解 what; AWS CloudFormation 句柄处理所有这些工作时所依赖的内容。以下方案演示 AWS CloudFormation 如何提供帮助。
- 简化基础设施管理
  
  对于还包括后端数据库的可扩展 Web 应用程序，您可使用 Auto Scaling 组、Elastic Load Balancing 负载均衡器和 Amazon Relational Database Service 数据库实例。通常，您可使用每个单独的服务来配置这些资源。在创建资源后，您必须将这些资源配置为结合使用。在您的应用程序启动并正常运行之前，所有这些任务会增加复杂性和时间。

  相反，您可创建或修改现有 AWS CloudFormation 模板。一个描述了您的所有资源及其属性的模板。当您使用该模板创建 AWS CloudFormation 堆栈时，AWS CloudFormation 将为您配置 Auto Scaling 组、负载均衡器和数据库。成功创建堆栈之后，您的 AWS 资源将正常运行。您可以轻松删除堆栈，这将删除堆栈中的所有资源。通过使用 AWS CloudFormation，您可以轻松地将一组资源作为一个单元进行管理。
- 快速复制您的基础设施

  如果您的应用程序需要其他可用性，您可在多个区域中复制它，以便在一个区域变得不可用的情况下，您的用户仍可在其他区域中使用您的应用程序。复制应用程序的难点在于它还需要您复制您的资源。您不仅需要记录您的应用程序所需的所有资源，还必须在每个区域中设置和配置这些资源。

  在您使用 AWS CloudFormation 时，可重复使用您的模板来不断地重复设置您的资源。仅描述您的资源一次，然后在多个区域中反复配置相同的资源。
- 轻松控制和跟踪对您的基础设施所做的更改
  在某些情况下，您可能拥有增量升级所需的基础资源。例如，您可能在 Auto Scaling 启动配置中更改为更高的执行实例类型，以便您能减小 Auto Scaling 组中的最大实例数。如果完成更新后出现问题，您可能需要将基础设施回滚到原始设置。要手动执行此操作，您不仅必须记住已发生更改的资源，还必须知道原始设置是什么。

  当您使用 AWS CloudFormation 配置基础设施时，AWS CloudFormation 模板准确描述了所配置的资源及其设置。由于这些模板是文本文件，因此您只需跟踪模板中的区别即可跟踪对基础设施所做的更改，其方式类似于开发人员控制对源代码所做的修订的方式。例如，您可使用将版本控制系统用于模板，以便准确了解所做的更改、执行更改的人员和时间。如果您在任何时候需要撤消基础设施所做的更改，则可使用模板的上一个版本。
### AWS CloudFormation 概念
在使用 AWS CloudFormation 时，将使用模板和堆栈。您创建模板来描述 AWS 资源及其属性。当您创建堆栈时，AWS CloudFormation 会配置模板中描述的资源。
#### 模板
AWS CloudFormation 模板是 JSON 或 YAML 格式的文本文件。您可以使用任何扩展名（如 .json、.yaml、.template 或 .txt）保存这些文件。AWS CloudFormation 将这些模板作为蓝图以构建 AWS 资源。例如，在模板中，您可描述 Amazon EC2 实例，如实例类型、AMI ID、块储存设备映射和其 Amazon EC2 密钥对名称。当您创建堆栈时，还可以指定 AWS CloudFormation 用来创建模板中描述的任何项的模板。

例如，如果您使用以下模板创建堆栈，AWS CloudFormation 将使用 ami-0ff8a91507f77f867 AMI ID、t2.micro 实例类型、testkey 密钥对名称和 Amazon EBS 卷预置一个实例。

**例 JSON**

```
{
  "AWSTemplateFormatVersion" : "2010-09-09",
  "Description" : "A sample template",
  "Resources" : {
    "MyEC2Instance" : {
      "Type" : "AWS::EC2::Instance",
      "Properties" : {
        "ImageId" : "ami-0ff8a91507f77f867",
        "InstanceType" : "t2.micro",
        "KeyName" : "testkey",
        "BlockDeviceMappings" : [
          {
            "DeviceName" : "/dev/sdm",
            "Ebs" : {
              "VolumeType" : "io1",
              "Iops" : "200",
              "DeleteOnTermination" : "false",
              "VolumeSize" : "20"
            }
          }
        ]
      }
    }
  }
}
```

**例 YAML**
```
AWSTemplateFormatVersion: "2010-09-09"
Description: A sample template
Resources:
  MyEC2Instance:
    Type: "AWS::EC2::Instance"
    Properties: 
      ImageId: "ami-0ff8a91507f77f867"
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
  MyEIP:
    Type: AWS::EC2::EIP
    Properties:
      InstanceId: !Ref MyEC2Instance
```
之前的模板以 Amazon EC2 实例为中心；但 AWS CloudFormation 模板还具有其他功能，可利用这些功能来构建复杂的资源集并在很多环境中重新使用这些模板。例如，您可添加输入参数，其值是在创建 AWS CloudFormation 堆栈时指定的。换句话说，您可在创建堆栈而不是创建模板时指定一个值 (如实例类型)，以便在不同的情况下更轻松地重新使用模板。

有关模板创建和功能的更多信息，请参阅[模板剖析](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-anatomy.html)。

有关声明特定资源的更多信息，请参阅[AWS 资源和属性类型参考](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)。

要开始使用 AWS CloudFormation Designer 设计您自己的模板，请转到 https://console.aws.amazon.com/cloudformation/designer。
#### 堆栈
在您使用 AWS CloudFormation 时，可将相关资源作为一个称为“堆栈”的单元进行管理。您可通过创建、更新和删除堆栈来创建、更新和删除一组资源。堆栈中的所有资源均由堆栈的 AWS CloudFormation 模板定义。假设您创建了一个模板，它包括 Auto Scaling 组、Elastic Load Balancing 负载均衡器和 Amazon Relational Database Service (Amazon RDS) 数据库实例。要创建这些资源，您可通过提交已创建的模板来创建堆栈，AWS CloudFormation 将会为您配置所有这些资源。您可通过使用 AWS CloudFormation [控制台](https://console.aws.amazon.com/cloudformation/)、[API](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/) 或 [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/cloudformation) 来使用堆栈。

有关创建、更新或删除堆栈的更多信息，请参阅[使用堆栈](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/stacks.html)。
#### 更改集
如果您需要更改堆栈中运行的资源，则可更新堆栈。在更改资源之前，您可以生成一个更改集，这是建议进行的更改的摘要。利用更改集，您可以在实施更改之前，了解更改可能会对运行的资源 (特别是关键资源) 造成的影响。

例如，如果您更改 Amazon RDS 数据库实例的名称，AWS CloudFormation 将创建新数据库并删除旧数据库。除非您已经对旧数据库中的数据进行备份，否则您将丢失该数据。如果您生成了更改集，则将了解更改会导致数据库被替换，而您可以先做出相应的计划，然后再更新堆栈。有关更多信息，请参阅[使用更改集更新堆栈](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html)。
### AWS CloudFormation 是如何运行的？
当您创建堆栈时，AWS CloudFormation 对 AWS 进行基础服务调用以配置您的资源。请注意，AWS CloudFormation 只能执行您有权执行的操作。例如，要使用 AWS CloudFormation 创建 EC2 实例，您需要具有创建实例的权限。您在删除带实例的堆栈时，将需要用于终止实例的类似权限。您可以使用 [AWS Identity and Access Management (IAM)](https://docs.aws.amazon.com/IAM/latest/UserGuide/)管理权限。

AWS CloudFormation 进行的调用全部由您的模板声明。例如，假设您有一个描述带 t1.micro 实例类型的 EC2 实例的模板。当您使用该模板创建堆栈时，AWS CloudFormation 将调用 Amazon EC2 创建实例 API 并将该实例类型指定为 t1.micro。以下示意图归纳了用于创建堆栈的 AWS CloudFormation 工作流程。

![Stack Creation Process](https://github.com/wbb1975/blogs/blob/master/aws/images/create-stack-diagram.png)

1. 您可以在 AWS CloudFormation Designer 中设计 AWS CloudFormation 模板（JSON 或 YAML 格式的文档），或者在文本编辑器中编写模板。您还可以选择使用提供的模板。模板描述了您所需的资源及其设置。例如，假设您需要创建一个 EC2 实例。您的模板可声明 EC2 实例并描述其属性，如以下示例所示：
  
    **例 JSON 语法**

    ```
    {
        "AWSTemplateFormatVersion" : "2010-09-09",
        "Description" : "A simple EC2 instance",
        "Resources" : {
            "MyEC2Instance" : {
            "Type" : "AWS::EC2::Instance",
            "Properties" : {
                "ImageId" : "ami-0ff8a91507f77f867",
                "InstanceType" : "t1.micro"
            }
        }
        }
    }
    ```

    **例 YAML 语法**

    ```
    AWSTemplateFormatVersion: '2010-09-09'
    Description: A simple EC2 instance
    Resources:
        MyEC2Instance:
            Type: AWS::EC2::Instance
            Properties:
                ImageId: ami-0ff8a91507f77f867
                InstanceType: t1.micro
    ```
2. 您可在本地或在 S3 存储桶中保存模板。如果创建了一个模板，可使用任何文件扩展名 (如 .json、.yaml 或 .txt) 保存该模板。
3. 指定模板文件位置以创建 AWS CloudFormation 堆栈，例如，本地计算机上的路径或 Amazon S3 URL。如果模板包含参数，则可在创建堆栈时指定输入值。利用参数，您能够将值传入模板，以便能在创建堆栈时自定义资源。
   您可以使用 AWS CloudFormation [控制台](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html)、[API](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html) 或 [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html) 创建堆栈。
   > **注意** 如果指定在本地存储的模板文件，则 AWS CloudFormation 将该文件上传到您的 AWS 账户的 S3 存储桶中。AWS CloudFormation 为每个区域创建一个存储桶以上传模板文件。在您的 AWS 账户中具有 Amazon Simple Storage Service (Amazon S3) 权限的任何人都可以访问存储桶。如果 AWS CloudFormation 创建的存储桶已存在，则将模板添加到该存储桶。
   > 
   > 您可通过手动将模板上传到 Amazon S3 来使用您自己的存储桶并管理其权限。之后，当您创建或更新堆栈时，请指定模板文件的 Amazon S3 URL。

AWS CloudFormation 通过调用您的模板中描述的 AWS 服务来配置资源。

所有资源创建完毕后，AWS CloudFormation 会报告已创建您的堆栈。然后，您可以开始使用堆栈中的资源。如果堆栈创建失败，则 AWS CloudFormation 会通过删除已创建的资源来回滚您的更改。
#### 使用更改集更新堆栈
在需要更新堆栈的资源时，您可以修改堆栈的模板。您不需要创建新堆栈和删除旧堆栈。要更新堆栈，请提交修改的原始堆栈模板版本和/或不同的输入参数值以创建一个更改集。AWS CloudFormation 将修改的模板与原始模板进行比较并生成一个更改集。更改集列出了建议的更改。在审核更改后，您可以执行更改集以更新堆栈，也可以创建新的更改集。以下示意图概述了用于更新堆栈的工作流程

![Stack Update Process](https://github.com/wbb1975/blogs/blob/master/aws/update-stack-diagram.png)!

> **重要**  更新可能会导致中断。根据您所更新的资源和属性，更新可能会中断或者甚至替换现有资源。有关更多信息，请参阅[AWS CloudFormation 堆栈更新](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks.html)。
1. 您可以使用 [AWS CloudFormation Designer](https://console.aws.amazon.com/cloudformation/designer) 或文本编辑器修改 AWS CloudFormation 堆栈模板。例如，如果您需要更改 EC2 实例的实例类型，可更改原始堆栈模板中的 InstanceType 属性的值。

   有关更多信息，请参阅[修改堆栈模板](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-get-template.html)。
2. 在本地或在 S3 存储桶中保存 AWS CloudFormation 模板。
3. 通过指定要更新的堆栈和修改后模板的位置 (例如本地计算机上的路径或 Amazon S3 URL) 来创建更改集。如果模板包含参数，则可在创建更改集时指定值。
   
   有关创建更改集的更多信息，请参阅[使用更改集更新堆栈](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html)。

     > **注意**  如果您指定存储在本地计算机上的模板，则 AWS CloudFormation 自动将模板上传到 AWS 账户中的 S3 存储桶。
4. 查看更改集以检查 AWS CloudFormation 是否将执行预期更改。例如，检查 AWS CloudFormation 是否将替换任何关键堆栈资源。您可以创建所需数量的更改集，直到您包含所需的更改。
     > **重要**  更改集并不指示您的堆栈更新是否将成功。例如，更改集不检查是否将超出账户[限制](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html)、是否将更新不支持更新的[资源](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)或者是否[权限](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/using-iam-template.html)不足而无法修改资源，所有这些都将导致堆栈更新失败。
5. 执行要应用于堆栈的更改集。AWS CloudFormation 仅更新您修改的资源以更新堆栈，并发出已成功更新堆栈的信号。如果堆栈更新失败，则 AWS CloudFormation 将回滚更改以将堆栈还原到上一个已知工作状态。
#### 删除堆栈
在删除堆栈时，您可指定要删除的堆栈，并且 AWS CloudFormation 将删除该堆栈及其包含的所有资源。您可通过使用 AWS CloudFormation [控制台](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/cfn-console-delete-stack.html)、[API](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DeleteStack.html) 或 [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/delete-stack.html) 删除堆栈。

若要删除一个堆栈但保留该堆栈中的一些资源，您可使用[删除策略](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html)来保留那些资源。

在删除所有资源后，AWS CloudFormation 会发出有关您的堆栈已被成功删除的信号。如果 AWS CloudFormation 无法删除资源，则将不会删除堆栈。尚未删除的任何资源都将保留，直到您能成功删除堆栈。
#### 其他资源
  - 有关创建 AWS CloudFormation 模板的更多信息，请参阅[模板剖析](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/template-anatomy.html)。
  - 有关创建、更新或删除堆栈的更多信息，请参阅[使用堆栈](https://docs.aws.amazon.com/zh_cn/AWSCloudFormation/latest/UserGuide/stacks.html)。

## 参考
- [AWS CloudFormation 文档](https://docs.aws.amazon.com/zh_cn/cloudformation/?id=docs_gateway)