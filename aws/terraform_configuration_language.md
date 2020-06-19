# Configuration Language
Terraform使用自己的配置语言，设计用于基础架构的简洁描述。Terraform语言是声明式的，它描述其意向目标而非达成目标的步骤。
## 资源和模块（Resources and Modules）
Terraform语言的主要目的是声明[资源](https://www.terraform.io/docs/configuration/resources.html)。其它语言特性仅仅是为了使资源的定义更弹性更方便。

一组资源可被聚集成[模块](https://www.terraform.io/docs/configuration/modules.html)，模块创建了一个更大的配置单元。一个资源描述一个简单的基础架构目标，而模块为了创建更高层级的系统可以描述一套对象以及对象间的关系。

一个Terraform配置包括一个根模块，在那里求值开始，当一个模块调用其它模块时，对应子模块将被创建并形成一个模块树。
## 变量，块及表达式（Arguments, Blocks, and Expressions）
Terraform语言的语法仅仅包括一些基本元素：
```
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}

<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```
- 块是其它内容的容器，通常代表某种类型对象如资源的配置。块具有块类型，可以拥有零个或多个标签（labels），其块体拥有任意数量的参数和嵌套块。Terraform的大部分特性由配置文件中的顶级块来控制。
- 参数给一个名字指定一个值，它们在块内出现
- 表达式代表一个值，无论是字面地，还是引用或绑定其它值。它们常以参数的值的形式出现，或在其它表达式里。
关于Terraform的详细语法，请参见：
- [Configuration Syntax](https://www.terraform.io/docs/configuration/syntax.html)
- [Expressions](https://www.terraform.io/docs/configuration/expressions.html)
## 代码组织
Terraform语言使用以`.tf`为扩展名的配置文件，也有基于一种JSON变体的语言以`.tf.json`为扩展名的配置文件。

配置文件必须总是使用UTF-8编码，为了方便通常使用UNIX风格行结束符(LF)而非Windows风格 (CRLF)，虽然两者都可接受。

一个模块是保存在一个目录下的.tf 或 .tf.json 文件的集合，根模块在Terraform运行时从当前工作目录的配置文件动态构建，并且这个模块还将引用其它目录下的子模块，这些子模块有可能顺序引用其它模块。

最简单的Terraform配置文件是一个简单的根模块仅含一个简单的.tf文件。当更多模块被加入时配置文件将会增长，或者通过在根模块创建新的配置文件，或者将资源组织到子模块。
## 配置顺序
由于Terraform语言的声明式特性，块之间的顺序通常不重要（一个资源里provisioner块的顺序是唯一块顺序有影响的特性）。

依据配置文件里资源的相互关系Terraform可以自动以正确顺序处理资源，因此你可以以方便你的基础设施的任意方法组织你的资源，让其位于不同的文件中。
## Terraform CLI与提供者（Providers）
Terraform命令行接口是评估和应用Terraform配置的通用引擎，它定义了Terraform语言语法和总体结构，协调必须变化的顺序以使得远程基础设施符合配置。

通用引擎并没有特定类型的基础设施对象的知识，作为替代，Terraform使用被称为[提供者](https://www.terraform.io/docs/configuration/providers.html)的插件，每个插件可以管理一套特定的资源类型。大多数提供者关联一种特殊的云或on-premises基础设施服务，允许Terraform在该服务内管理基础设施对象。

Terraform并不拥有平台中立的资源类型的概念--资源通常与提供者绑定，因为相似资源的特性在不同提供者差别巨大。但Terraform命令行接口共享配置引擎确保相同的语言结构和语法可跨服务可用，不同服务的资源类型可按需绑定。
## 示例
下面的简单示例描述了AWS上的一个简单网络拓扑，仅仅给与了Terraform语言的一个总体结构和语法概貌。使用其它提供者定义的资源类型，同样的配置可用于创建虚拟网络服务，一个实际的网络配置通常含有其它一些元素，但这里并未给出：
```
variable "aws_region" {}

variable "base_cidr_block" {
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type = list(string)
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  # Referencing the base_cidr_block variable allows the network address
  # to be changed without modifying the configuration.
  cidr_block = var.base_cidr_block
}

resource "aws_subnet" "az" {
  # Create one subnet for each given availability zone.
  count = length(var.availability_zones)

  # For each subnet, use one of the specified availability zones.
  availability_zone = var.availability_zones[count.index]

  # By referencing the aws_vpc.main object, Terraform knows that the subnet
  # must be created only after the VPC is created.
  vpc_id = aws_vpc.main.id

  # Built-in functions and operators can be used for simple transformations of
  # values, such as computing a subnet address. Here we create a /20 prefix for
  # each subnet, using consecutive addresses for each availability zone,
  # such as 10.1.16.0/20 .
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index+1)
}
```
对这里的配置元素的更多信息，使用站点导航去查阅Terraform语言文档的哥哥子章节。可以从[资源配置](https://www.terraform.io/docs/configuration/resources.html)开始。

## Reference
- [Configuration Language](https://www.terraform.io/docs/configuration/index.html)
- [Terraform Recommended Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)