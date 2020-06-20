# Configuration Language
Terraform使用自己的配置语言，设计用于基础架构的简洁描述。Terraform语言是声明式的，它描述其意向目标而非达成目标的步骤。
## 资源和模块（Resources and Modules）
Terraform语言的主要目的是声明[资源](https://www.terraform.io/docs/configuration/resources.html)。其它语言特性仅仅是为了使资源的定义更弹性更方便。

一组资源可被聚集成[模块](https://www.terraform.io/docs/configuration/modules.html)，模块创建了一个更大的配置单元。一个资源描述一个简单的基础架构目标，而模块为了创建更高层级的系统可以描述一套对象以及对象间的关系。

一个Terraform配置包括一个根模块，在那里求值开始，当一个模块调用其它模块时，对应子模块将被创建并形成一个模块树。
## 参数，块及表达式（Arguments, Blocks, and Expressions）
Terraform语言的语法仅仅包括一些基本元素：
```
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}

<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # 参数
}
```
- 块是其它内容的容器，通常代表某种类型对象如资源的配置。块具有块类型，可以拥有零个或多个标签（labels），其块体拥有任意数量的参数和嵌套块。**Terraform的大部分特性由配置文件中的顶级块来控制**。
- 参数给一个名字指定一个值，它们在块内出现
- 表达式代表一个值，无论是字面地，还是引用或绑定其它值。它们常以参数的值的形式出现，或在其它表达式里。

关于Terraform语法A的全部语法，请参见：
- [Configuration Syntax](https://www.terraform.io/docs/configuration/syntax.html)
- [Expressions](https://www.terraform.io/docs/configuration/expressions.html)
## 代码组织
Terraform语言使用以`.tf`为扩展名的配置文件，也有基于一种JSON变体的语言以`.tf.json`为扩展名的配置文件。

配置文件必须总是使用UTF-8编码，为了方便通常使用UNIX风格行结束符(LF)而非Windows风格 行结束符(CRLF)，虽然两者都可接受。

一个模块是保存在一个目录下的.tf 或 .tf.json 文件的集合，根模块在Terraform运行时从当前工作目录的配置文件动态构建，并且这个模块还将引用其它目录下的子模块，这些子模块有可能顺序引用其它模块。

最简单的Terraform配置文件是一个简单的根模块仅含一个简单的.tf文件。当更多模块被加入时配置文件将会增长，或者通过在根模块创建新的配置文件，或者将资源组织到子模块。
## 配置顺序
由于Terraform语言的声明式特性，块之间的顺序通常不重要（一个资源里provisioner块的顺序是唯一块顺序有影响的特性）。

依据配置文件里资源的相互关系Terraform可以自动以正确顺序处理资源，因此你可以以方便你的基础设施的任意方法组织你的资源，让其位于不同的文件中。
## Terraform CLI与提供者（Providers）
Terraform命令行接口是评估和应用Terraform配置的通用引擎，它定义了Terraform语言语法和总体结构，协调必须变化的顺序以使得远程基础设施符合配置。

通用引擎并没有特定类型的基础设施对象的知识，作为替代，Terraform使用被称为[提供者](https://www.terraform.io/docs/configuration/providers.html)的插件，每个插件可以管理一套特定的资源类型。大多数提供者关联一种特殊的云或on-premises基础设施服务，允许Terraform在该服务内管理基础设施对象。

Terraform并不拥有平台中立的资源类型的概念--资源通常与提供者绑定，因为相似资源的特性在不同提供者间差别巨大。但Terraform命令行接口共享配置引擎确保相同的语言结构和语法可跨服务可用，不同服务的资源类型可按需绑定。
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
## 1. 资源（Resources）
资源是Terraform语言中最重要的元素，每个资源块描述了一个或多个基础设施对象如虚拟网络，计算实例，更高级别的组件如DNS记录等。
### 1.1 资源语法
资源声明可包括许多高级特性，但初始使用时仅仅一小部分是必须的。更高级的语法特性，例如单个资源的声明产生多个相似的远程对象，将在本页面稍后描述：
```
resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}
```
一个资源块声明了一个给定类型（"aws_instance"）及给定本地名（"web"）的资源。名字用于从同一Terraform模块中的任意位置引用该资源，但在模块外没有什么重要性。

资源类型和名字合起来是一个给定资源的标识符，因此在模块范围内必须是唯一的。

在一个块体内（在{和}之间）是资源本身的配置参数。该节内大多数参数依赖于资源类型，确实本例中ami 和 instance_type是特定于[aws实例资源类型](https://www.terraform.io/docs/providers/aws/r/instance.html)的参数。
> 资源名必须以一个字母和下划线开始，可以仅仅包含字母，数字，下划线和连字符。
### 1.2 资源类型和参数
每个资源与一个简单资源类型关联，资源类型决定了资源管理的基础设施对象的种类，以及该资源支持的参数及其它属性。

每种资源类型从属于[提供者](https://www.terraform.io/docs/configuration/providers.html)，它是一种Terraform插件并提供了一个资源类型集合。一个提供者通常提供资源来管理单一云或 on-premises 基础设施平台。

一个资源块体内的大多数元素是特定于选定的资源类型的。这些参数会充分利用[表达式](https://www.terraform.io/docs/configuration/expressions.html)和其它动态Terraform语言特性。

也有一些Terraform自身定义的元参数适用于所有的参数类型（参见下方的[元参数](https://www.terraform.io/docs/configuration/resources.html#meta-arguments)）。
### 1.3 资源类型文档
[Terraform提供者文档](https://www.terraform.io/docs/providers/index.html)是学习什么资源类型可用以及该资源支持那些参数的主要场所。一旦你理解了Terraform的基础语法，提供者文档将会是你在本网站花费大部分时间之所在，

顶级导航侧边栏的[提供者](https://www.terraform.io/docs/providers/index.html)页面将呈现给你一个由HashiCorp贡献的按字母序排列的所有提供者列表。你可以在主列表中查询特定提供者，或者从导航侧边栏选择一个“类别”来浏览一个更特定的提供者列表。

你也可搜寻GitHub或其它源来发现第三方提供者，它们可被安装位插件以允许更广阔的资源类型选择。
### 1.4 资源行为
一个资源块描述了你的意图：一个特定基础设施对象应以给定的设置存在。如果你在第一时间写一个新的配置，它所定义的配置仅存在于配置中，并不代表真实目标平台的基础设施对象。

应用Terraform配置是创建，更新，销毁真实基础设施对象以使其设置匹配配置的过程。

当Terraform创建由一个资源块代表的一个新的基础设施对象时，那个对象的标识符被存储在Terraform的[状态文件](https://www.terraform.io/docs/state/index.html)中，允许它在后面的变化中被更新或销毁。对于已经在状态文件中有对象基础设施对象的资源块，Terraform比较对象的实际配置和新的配置的给定参数，如果必要，更新对象以匹配配置。

这个通用的行为（模式）适用于所有的资源--无论其类型。对每种资源类型，其实际创建，更新，销毁一个资源的实际细节是不同的，但这个标准动作的组合本身却是跨资源类型的。

资源块内的元参数将会在下面的章节描述，允许标准资源行为的某些字节可在特定资源基础上定制。
### 1.5 资源依赖
一个配置中的大部分资源并没有任何特殊的关系，Terraform可以对几个不相关的资源并行改变。

但是，某些资源必须在其它特定资源之后处理，有时候是由于资源运行的方式，有时候仅仅因为某些资源的配置需要其它资源产生的信息。

大多数资源依赖被自动处理，Terraform分析资源块内的[表达式](https://www.terraform.io/docs/configuration/expressions.html)以找到对其它对象的引用，当创建，更新或销毁资源时将这些引用作为隐式顺序需求。因为大部分资源如果表现出对其它资源的行为依赖，那么它们也将访问其它资源的数据
，因此通常没有必要手动指定资源间的依赖。

但是，某些依赖在配置中不能隐式识别，例如，如果Terraform必须管理某些访问控制策略，并采取行动，则要求这些策略必须存在。这就在访问策略以及依赖它以创建的资源之间引入了一个隐藏依赖。在这些罕见的例子中，[元参数依赖](https://www.terraform.io/docs/configuration/resources.html#depends_on-explicit-resource-dependencies)可以显式指定一个依赖。
### 1.6 元参数
### 1.7 本地资源（Local-only Resources）
大多数资源类型对应于通过远程网络API管理的一个基础设施对象类型，有几种特定资源类型仅仅在Terraform自身内部运作，计算某些结果并将这些结果存到状态文件中以供将来使用。

例如，本地资源类型有[产生私钥](https://www.terraform.io/docs/providers/tls/r/private_key.html)，[发布自签名TLS证书](https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html)，甚至[产生随机ids](https://www.terraform.io/docs/providers/random/r/id.html)。虽然这些资源类型通常比那些实际管理基础设施对象的资源有更边缘用途，它们可被用作连接其它资源类型的胶水。

本地资源的行为模式与其它资源无异，但它们的结果数据仅仅存在于Terraform状态文件本身，销毁一个这样的资源仅仅意味着从状态文件中移除它并丢弃其数据。
### 1.8 操作超时（Operation Timeouts）

## Reference
- [Configuration Language](https://www.terraform.io/docs/configuration/index.html)
- [Terraform Recommended Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)