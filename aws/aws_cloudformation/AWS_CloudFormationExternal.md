## AWS CloudFormation介绍
AWS CloudFormation是一个受控的AWS服务，它允许你定义服务和资源从而实现基础设施即代码，它是除AWS控制台（console），CLI,以及各种SDK等各种部署你的基础设施方案之外的另一选择。虽然掌握CloudFormation有一定学习曲线，但你一旦掌握了使用CloudFormation的基础，它将成为你部署AWS基础设施的一个强力工具，尤其当你开始在复杂环境下部署时。

使用CloudFormation时，你使用CloudFormation模版定义一个或多个资源（resource）--模版是集中组织相关资源的一个方便设施。当你部署你的模版，CloudFormation将会创建一个栈，其包含你在模版中定义的所有物理资源。CloudFormation将会部署每个资源，并会解决资源间的任何依赖，并优化部署--如果可行资源将会被并行部署，如果依赖存在，资源将会按照正确顺序部署。好消息是这些强大的功能可以免费获得--你紧紧需要为通过CloudFormation部署的资源本身的消费付费。

需要重点关注的是现在有许多CloudFormation的第三方替代方案--例如，Terraform非常流行，传统的资源管理工具比如Ansible和Puppet也包括了对部署AWS资源的支持。我本人还是喜欢CloudFormation，因为它是AWS原生支持的，对各种各样的AWS资源和服务由很好的支持，并且原生地和AWS CLI以及服务CodePipeline（我们将在本书后面的第13章--持续发布ECS应用中解释这种集成）集成。
### 定义CloudFormation模版
最简单的开始学习CloudFormation的方式是创建一个CloudFormation模版。这个模版可以以JSON或YAML格式定义，后者是我极力推荐的格式，因为对人来讲YMAL比JSON更易于工作。

[CloudFormation用户指南](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)详细描述了模版结构，但居于本书的目的，我们只需担心基本的模版结构，我们以一个真实的例子来演示它。你可以将这个文件命名为stack.yml，并存储在你的电脑上。
```
AWSTemplateFormatVersion: "2010-09-09"

Description: Cloud9 Management Station

Parameters:
 EC2InstanceType:
   Type: String
   Description: EC2 instance type
   Default: t2.micro
 SubnetId:
   Type: AWS::EC2::Subnet::Id
   Description: Target subnet for instance

Resources:
  ManagementStation:
    Type: AWS::Cloud9::EnvironmentEC2
    Properties:
      Name: !Sub ${AWS::StackName}-station
      Description:
        Fn::Sub: ${AWS::StackName} Station
      AutomaticStopTimeMinutes: 15

    InstanceType: !Ref EC2InstanceType
      SubnetId:
        Ref: SubnetId
```
在前面的代码中，CloudFormation定义了一个Cloud9管理站--CLoud9提供了一个基于云的集成开发环境和终端，它事实上是运行在AWS的一个EC2实例上。让我们剖析这个例子来讨论模版的结构和特性。

AWSTemplateFormatVersion属性是必须的，它指定了CloudFormation模版格式版本，它通常以一个日期的格式呈现。参数（Parameters）属性定义了应用于你的模版一套输入参数，这是应对多个环境的一个好方式--对于不同的环境你可以有不同的输入值。例如，EC2InstanceType参数指定了管理站的EC2实例类型，SubnetId参数指定了EC2实例应该附上的子网。这两个值可能在产品环境和非产品环境中不一样，因此将它们定义为输入参数可当随目标环境不同时更改更容易。注意到SubnetId指定了AWS::EC2::Subnet::Id的类型值，这意味着CloudFormation可以使用它来查询并验证输入值。对于支持的参数列表，请参阅https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html。 你也可看到EC2InstanceType为这个参数定义了一个缺省值，如果这个输入参数未被提供，缺省值将会被使用。

Resources属性定义了你的栈中的所有资源--这是模版的主体，至多可包含200个资源。在前面的代码中，我们只定义了一个资源ManagementStation，它通过Type值为AWS::Cloud9::EnvironmentEC2来创建一个 Cloud9 EC2环境。所有资源必须制定一个Type属性，它定义了资源的类型，并决定了每种资源可用的各种配置属性。CloudFormation用户指南专门有一章定义了支持的各种资源类型，最新已有多达300项资源类型在列。

每种资源必须包含“Properties”属性，它用于容纳该资源各种可用的配置属性。在前面的代码中，你可以看到我们定义了5种不同的属性--可用的属性随资源类型而不同，其在CloudFormation用户指南上有详细描述。
- name：
- Description：
- AutomaticStopTime：
- InstanceType：
- SubnetId：
### 部署一个CloudFormation栈
### 更新一个CloudFormation栈
### 删除一个CloudFormation栈

## Rererence
- [Introduction to AWS CloudFormation](https://learning.oreilly.com/library/view/docker-on-amazon/9781788626507/76331243-6e32-4705-8eda-75d47b4e310a.xhtml)