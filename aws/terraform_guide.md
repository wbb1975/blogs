# 使用 Terraform 在 AWS 中国区域实现自动化部署指南系列
## 第1章 Terraform概述
### 1.1 Terraform介绍
Terraform是HashiCorp公司旗下的Provision Infrastructure产品, 是AWS APN Technology Partner与AWS DevOps Competency Partner。Terraform是一个IT基础架构自动化编排工具，它的口号是“Write, Plan, and Create Infrastructure as Code”, 是一个“基础设施即代码”工具，类似于[AWS CloudFormation](https://amazonaws-china.com/cloudformation/)，允许您创建、更新和版本控制的AWS基础设施。

Terraform基于AWS Go SDK进行构建，采用HashiCorp配置语言（HCL）对资源进行编排，具体的说就是可以用代码来管理维护IT资源，比如针对AWS，我们可以用它创建、修改或删除 S3 Bucket、Lambda,、EC2、Kinesis、VPC等各种资源。并且在真正运行之前可以看到执行计划(即干运行-dryrun)。由于状态保存到文件中，因此能够离线方式查看资源情况（前提是不要在 Terraform 之外对资源进行修改）。Terraform 配置的状态除了能够保存在本地文件中，也可以保存到 Consul, S3等处。

Terraform是一个高度可扩展的工具，通过Provider来扩展对新的基础架构的支持，几乎支持所有的云服务平台，AWS只是Terraform内建 Providers 中的一种。

在Terraform诞生之前，我们对AWS资源的操作主要依赖Console、AWS CLI、SDK或Serverless。AWS CLI什么都能做，但它是无状态的，必须明确用不同的命令来创建、修改和删除。Serverless不是用来管理基础架构的，用Lambda创建资源是很麻烦的事。AWS提供的CloudFormation，虽然功能非常强大，但是大量的JSON代码阅读困难。
### 1.2 与CloudFormation的区别
AWS CloudFormation允许将基础设施的细节写入配置文件中，配置文件允许基础设施弹性创建、修改和销毁。Terraform类似地使用配置文件来详细描述基础架构设置，并且可以进一步组合多个Providers和服务。它提供统一HCL语法，为使用不同的平台，运维人员无需去学习每一种平台， Terraform还通过使用执行计划的概念将计划阶段与执行阶段分开。

通过运行terraform plan，刷新当前状态并查询配置以生成动作计划。该计划包括将采取的所有行动：将创建，销毁或修改哪些资源。可以对其进行检查，以确保运行正常。运用terraform graph，该计划可以被可视化显示依赖的顺序。一旦捕获了计划，执行阶段只能限于计划中的操作。

Terraform的主要特点如下：
- 基础架构代码（Infrastructure as Code）：使用HCL高级配置语法描述基础架构。这样可以让数据中心的蓝图进行版本控制，像其他代码一样对待，基础设施可以共享和重用。
- 执行计划（Execution Plans）：Terraform有一个“planning”步骤，它生成一个执行计划。当调用时，执行计划显示所有的操作，能有效避免操作人口山水对基础设施的误操作。
- 资源图表（Resource Graph）：Terraform构建了所有资源的图形，并且并行化了任何非依赖资源的创建和修改。因此，Terraform尽可能高效地构建基础架构，操作人员可以深入了解其基础架构中的依赖关系。
- 更改自动化（Change Automation）：复杂的变更集可以通过很少的人工交互应用到基础设施中，使用前面提到的执行计划和资源图表, 将清楚的知道Terraform发生的变化及顺序, 避免了许多可能的人为错误。
## 第2章 Terraform 入门
本章将主要介绍Terraform的安装及初始环境配置。
### 2.1 Terraform安装
可以到如下网站进行下载，选择所需要的二进制版本，支持Linux、Windows、macOS及BSD，目前最新版本为v0.10.8。
https://www.terraform.io/downloads.html
需要基于源码编译安装的可以到github下载。
https://github.com/hashicorp/terraform
将安装包解压后，会得到名为terraform的可执行文件，直接更新PATH环境变量即可运行。
### 2.2 配置介绍
Terraform使用文本文件来描述基础设施和设置变量。这些文件称为Terraform 配置，并以 .tf结尾。本节介绍这些文件的格式以及它们的加载方式。

配置文件的格式可以有两种格式：Terraform格式和JSON。Terraform格式更加人性化，支持注释，并且是大多数Terraform文件通常推荐的格式。JSON格式适用于机器创建，修改和更新，也可以由Terraform操作员完成。Terraform格式后缀名以.tf结尾，JSON格式后缀名以.tf.json结尾。详细说明请参考如下链接：https://www.terraform.io/docs/configuration/index.html
#### 2.2.1 加载顺序与语义
在调用加载Terraform配置的任何命令时，Terraform将按字母顺序加载指定目录中的所有配置文件。

加载文件的后缀名必须是.tf或.json。否则，文件将被忽略。多个文件可位于同一目录中。Terraform配置文件可以一个是Terraform语法，另一个是JSON格式。

覆盖文件是一个例外，因为它们在所有非覆盖文件之后按字母顺序加载。加载文件中的配置将相互附加。这具有相同名称的两个资源不会合并，而是会导致验证错误。

配置中定义的变量，资源等的顺序并不重要。Terraform配置是声明式的，因此对其他资源和变量的引用不依赖于它们定义的顺序。
#### 2.2.2 配置语法
Terraform配置的语法称为HashiCorp配置语言（HCL）。Terraform还可以读取JSON配置。但是，对于一般的Terraform配置，我们建议使用HCL Terraform语法。语法说明可以参考如下：https://www.terraform.io/docs/configuration/syntax.html。以下是Terraform HCL语法的示例：
```
# An AMI
variable "ami" {
  description = "the AMI to use"
}

/* A multi
   line comment. */
resource "aws_instance" "web" {
  ami               = "${var.ami}"
  count             = 2
  source_dest_check = false

  connection {
    user = "root"
  }
}
```
Terraform配置的语法是HashiCorp 独创的 HCL(HashiCorp configuration language), 它可以兼容 JSON 格式，可以采用任何文本编辑器进行配置文件的更新。http://hashivim.github.io/vim-terraform/。可以安装 hashivim/vim-terraform 插件，在Vim中实现HCL语法加亮。写好的 *.tf 文件后可以调用 terraform fmt 对配置文件进行格式化。
### 2.3 AWS Provider配置
AWS Provider被用来与AWS支持的许多资源进行交互。在使用该提供程序之前, 需要使用适当的Credentials进行配置。https://www.terraform.io/docs/providers/aws/index.html。AWS Provider提供了一种提供身份验证凭据的灵活方法,主要支持如下四种方式:
+ 静态凭据
   ![]()
+ 环境变量

## Reference
- [使用 Terraform 在 AWS 中国区域实现自动化部署指南系列（一） TERRAFORM 入门](https://amazonaws-china.com/cn/blogs/china/aws-china-region-guide-series-terraform1/)
- [使用 Terraform 在 AWS 中国区域实现自动化部署指南系列（二） TERRAFORM 进阶](https://amazonaws-china.com/cn/blogs/china/aws-china-region-guide-series-terraform2/)