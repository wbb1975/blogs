# Terraform入门
## 0. Terraform 核心功能
- 基础架构即代码（Infrastructure as Code）：使用高级配置语法来描述基础架构，这样就可以对数据中心的蓝图进行版本控制，就像对待其它代码一样对待它。
- 执行计划（Execution Plans）：Terraform 有一个 plan 步骤，它生成一个执行计划。执行计划显示了当执行 apply 命令时 Terraform 将做什么。通过 plan 进行提前检查，可以使 Terraform 操作真正的基础结构时避免意外。
- 资源图（Resource Graph）：Terraform 构建的所有资源的图表，它能够并行地创建和修改任何没有相互依赖的资源。因此，Terraform 可以高效地构建基础设施，操作人员也可以通过图表深入地解其基础设施中的依赖关系。
- 自动化变更（Change Automation）：把复杂的变更集应用到基础设施中，而无需人工交互。通过前面提到的执行计划和资源图，我们可以确切地知道 Terraform 将会改变什么，以什么顺序改变，从而避免许多可能的人为错误。
## 1. 安装Terraform
安装Terraform，找到与你系统[匹配的软件包](https://www.terraform.io/downloads.html)然后下载。Terraform被打包为一个zip归档文件。

下载完zip文件以后，解压这个包。Terraform是一个名为terraform的独立文件。包里其他所有的文件都可以安全删掉，Terraform依然可以正常工作。

最后一步确保terraform二进制文件在PATH上可用。在Linux和Mac上设置PATH请查看[此页面](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux)。Windows设置PATH的命令在[此页面](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)。
## 2. 配置
我们在AWS上创建一些基础设施来开始入门指南，因为它最流行且通常可以被理解，但是Terraform可以管理[许多provider](https://www.terraform.io/docs/providers/index.html)，包含在单个配置文件中管理多个provider。在[使用案例](https://www.terraform.io/intro/use-cases.html)中有一些例子。

Terraform中用来描述基础设施的的文件被叫做Terraform配置文件。现在我们将写下我们第一个配置文件来启动一个AWS的EC2实例。

配置文件的文档在[这里](https://www.terraform.io/docs/configuration/index.html)。配置文件也可以是一个[json文件](https://www.terraform.io/docs/configuration/syntax.html)，但是我们建议只在机器生成配置文件时使用json格式。

整个配置文件内容如下所示。我们将在随后的每一步逐步讲解。将下面内容保存到一个名为example.tf的文件中。确认在你的目录中没有其他*.tf文件，因为Terraform将加载所有的*.tf文件。
```
provider "aws" {
  access_key = "AKIAJ7CSMTNB2A76EJRQ"
  secret_key = "YnKclNExx8A/8jz/J0TrqZ3WRK00RmsQRKxZzn03"
  region     = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0e84e211558a022c0"
  instance_type = "t2.micro"
}
```
> 注意：上面的配置工作于大部分AWS账户，将访问默认VPC。EC2经典网络用户请为instance_type指定t1.micro，并为ami指定ami-408c7f28。如果你使用一个非us-east-1的region你将需要指定该region的ami因为每个region的ami都是特定的。

用你的access key和secret key替换ACCESS_KEY_HERE和SECRET_KEY_HERE，可从[此页面](https://console.aws.amazon.com/iam/home?#security_credential)获取。我们现在将他们硬编码，但是在入门指南后面的将会将他们提取到变量里。

> 注意：如果你仅仅遗漏了AWS凭证，Terraform将自动从已保存的API凭证中搜索（如：在~/.aws/credentials中）。或者IAM实例配置文件凭据。对于将文件签入源代码管理或者有多个管理员的情况，该选择要干净很多。到[这里](https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/)查看细节。将凭据信息遗留到配置文件以外，使你可以将凭据信息放在源代码管理之外，并且也可以为不同的用户使用不同的IAM凭据而不需要修改配置文件。

provider块用于指定provider名称，在我们的实例中叫"aws"。provider负责创建和管理资源。如果一个Terraform配置文件由多个provider组成，可以有多个provider块，这是常见的情况。

resource块指定一个基础设施中存在的资源。一个资源可能是物理组件，如：EC2实例，或也可以是一个逻辑资源比如Heroku应用。

resource块开始前有两个字符串：资源类型和资源名称。在我们的实例中资源类型是"aws_instance"，资源名为"example"。资源类型的前缀映射到provider。在我们的实例中，"aws_instance"自动告知你Terraform被"aws"provider管理。

resource块内部是该资源的配置。它独立于每个资源provider并且在[provider参考](https://www.terraform.io/docs/providers/index.html)完全列出来。对于我们的EC2实例，我们为ubuntu指定一个AMI，然后请求一个"t2.micro"的实例因为我们有免费资格。
## 3. 安装
为一个新配置文件或从版本控制工具中检出的已存在的配置执行的第一个命令是terraform init，它将初始化各种本地配置和数据为后面的命令使用。

Terraform使用基于插件的结构来支持众多的基础设施和服务提供商。从Terraform"0.10.0"起，每个提供商有他们自己封装和发型的二进制文件，从Terraform分离出来。terraform init将自动为配置文件中包含provider下载插件。在该实例中只包含"aws"插件。
```
$ terraform init
Initializing the backend...
Initializing provider plugins...
- downloading plugin for provider "aws"...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your environment. If you forget, other
commands will detect it and remind you to do so if necessary.
```
aws provider插件与其他薄记文件一起被下载安装到当前目录子目录。

输出信息会显示所安装插件的版本，以及建议在配置文件中指定版本以确保terraform init在未来安装一个兼容的版本。对于后面步骤来说这一步不是必须的，因为该配置文件后面将会被废弃。

该操作会把文件中指定的驱动程序安装到当前目录下的 .terraform 目录中：
```
wangbb@wangbb-ThinkPad-T420:~/practices/aws/terraform$ ls -la .terraform/plugins/linux_amd64/
总用量 151436
drwxr-xr-x 2 wangbb wangbb        64 6月  15 07:36 .
drwxr-xr-x 3 wangbb wangbb        25 6月  15 07:36 ..
-rwxr-xr-x 1 wangbb wangbb        79 6月  15 07:36 lock.json
-rwxr-xr-x 1 wangbb wangbb 155066368 6月  15 07:36 terraform-provider-aws_v2.66.0_x4
```
## 4. 应用变更
> 注意：本指南中列出的命令适用于terraform0.11及以上版本。更早版本需要在应用前使用terraform plan命令查看执行计划。使用terraform version命令确认你当前terraform版本。

在当前目录中你创建的example.tf为例，执行terraform apply。你将看到以下类似输出，我们删节了部分输出以节省空间：
```
$ terraform apply
# ...

+ aws_instance.example
    ami:                      "ami-2757f631"
    availability_zone:        "<computed>"
    ebs_block_device.#:       "<computed>"
    ephemeral_block_device.#: "<computed>"
    instance_state:           "<computed>"
    instance_type:            "t2.micro"
    key_name:                 "<computed>"
    placement_group:          "<computed>"
    private_dns:              "<computed>"
    private_ip:               "<computed>"
    public_dns:               "<computed>"
    public_ip:                "<computed>"
    root_block_device.#:      "<computed>"
    security_groups.#:        "<computed>"
    source_dest_check:        "true"
    subnet_id:                "<computed>"
    tenancy:                  "<computed>"
    vpc_security_group_ids.#: "<computed>"
```
该输出显示执行计划，描述terraform将根据配置文件执行那些动作来改变基础设施。输出格式与工具输出的diff产生的格式类似，比如git。输出内容在 aws_instance.example 有个 + 意味着Terraform将会创建该资源。在那些之下，显示将会被设置的属性。当值为<computed>时，意味着资源被创建后才能知道。

terraform apply执行失败报错时，读取错误信息并修复所报错误。在这一步，它可能是配置文件中的语法错误。

如果计划被成功创建，Terraform将在执行前暂停并等待确认。如果计划中有任何不对或危险信息，在这里终止很安全，它不会对你的基础设施做任何改变。这是如果计划看起来可接受，在确认终端输入yes执行。

执行该计划会花几分钟时间，直到EC2实例可用：
```
# ...
aws_instance.example: Creating...
  ami:                      "" => "ami-2757f631"
  instance_type:            "" => "t2.micro"
  [...]

aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Creation complete

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# ...
```
在此之后Terraform执行完成，你可以到EC2终端查看创建号的EC2实例。(确保你在查看与配置文件中相同的可用区！)Terraform也会写一些数据到**terraform.tfstate**。该状态文件极其重要；它追踪创建的资源ID，所以Terraform知道它管理的是什么资源。该文件必须被保存并分发给可能使用terraform的任何人。通常建议在使用Terraform时[设置远程状态](https://www.terraform.io/docs/state/remote.html)，来自动分享状态，但是针对像入门指南这样简单的环境这不是必须的。

你可以使用terraform show检查当前状态：
```
$ terraform show
aws_instance.example:
  id = i-32cf65a8
  ami = ami-2757f631
  availability_zone = us-east-1a
  instance_state = running
  instance_type = t2.micro
  private_ip = 172.31.30.244
  public_dns = ec2-52-90-212-55.compute-1.amazonaws.com
  public_ip = 52.90.212.55
  subnet_id = subnet-1497024d
  vpc_security_group_ids.# = 1
  vpc_security_group_ids.3348721628 = sg-67652003
```
你可以看到，通过创建资源，我们收集了很多信息。这些值可以被引用以配置其他资源和输出，这些将会在入门指南后面的部分讲到。
## 5. 输入变量
### 5.0 使用 Provisioners 进行环境配置
Provisioners 可以在资源创建/销毁时在本地/远程执行脚本。
Provisioners 通常用来引导一个资源，在销毁资源前完成清理工作，进行配置管理等。

Provisioners拥有多种类型可以满足多种需求，如：文件传输（file），本地执行（local-exec），远程执行（remote-exec）等 Provisioners可以添加在任何的resource当中：
```
# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {

<...snip...>

    provisioner "file" {
        connection {
            type        = "ssh"
            user        = "royzeng"
            private_key = "${file("~/.ssh/id_rsa")}"
        }

        source      = "newfile.txt"
        destination = "newfile.txt"
    }

    provisioner "remote-exec" {
        connection {
            type        = "ssh"
            user        = "royzeng"
            private_key = "${file("~/.ssh/id_rsa")}"
        }

        inline = [
        "ls -a",
        "cat newfile.txt"
        ]
    }
```
#### 5.0.1 使用 null resource 和 trigger 来解耦
为了让ansible 脚本单独运行，而不需要创建或销毁资源，可以用 null_resource 调用 provisioner 来实现。
```
resource "null_resource" "datanode" {
  count = "${var.count.datanode}"

  triggers {
    instance_ids = "${element(aws_instance.datanode.*.id, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      ...
    ]

    connection {
      type = "ssh"
      user = "centos"
      host = "${element(aws_instance.datanode.*.private_ip, count.index)}"
    }
  }
}
```
### 5.1 新建一个文件定义变量
```
# file variables.tf
---
variable "prefix" {
  default = "royTF"
}

variable "location" { }

variable "tags" {
  type    = "map"
  default = {
     Environment = "royDemo"
     Dept = "Engineering"
  }
}
```
文件中 location 部分没有定义，运行terraform的时候，会提示输入：
```
$ terraform plan -out royplan
var.location
  Enter a value: eastasia
  
  <...snip...>
  
  This plan was saved to: royplan

To perform exactly these actions, run the following command to apply:
    terraform apply "royplan"
```
### 5.2 其它输入变量的方式
命令行输入：
```
$ terraform apply \
>> -var 'prefix=tf' \
>> -var 'location=eastasia'
```

文件输入：
```
$ terraform apply \
  -var-file='secret.tfvars'
```
默认读取文件 terraform.tfvars，这个文件不需要单独指定。

环境变量输入：TF_VAR_name ，比如 TF_VAR_location。
### 5.3 变量类型
- list
- map

对于 list 变量：
```
# 定义 list 变量
variable "image-RHEL" {
  type = "list"
  default = ["RedHat", "RHEL", "7.5", "latest"]
}

# 调用 list 变量

    storage_image_reference {
        publisher = "${var.image-RHEL[0]}"
        offer     = "${var.image-RHEL[1]}"
        sku       = "${var.image-RHEL[2]}"
        version   = "${var.image-RHEL[3]}"
    }
```

map 是一个可以被查询的表。
```
variable "sku" {
    type = "map"
    default = {
        westus = "16.04-LTS"
        eastus = "18.04-LTS"
    }
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "${lookup(var.sku, var.location)}"
    version   = "latest"
}
```
### 5.4 输出变量
定义输出：
```
output "ip" {
    value = "${azurerm_public_ip.publicip.ip_address}"
}
```
测试：
```
$ terraform apply
...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

  ip = 52.184.97.1
$ terraform output ip
52.184.97.1
```
### 5.5 Data Source
DataSource 的作用可以通过输入一个资源的变量名，然后获得这个变量的其他属性字段。
```
data "azurerm_virtual_network" "test" {
  name                = "production"
  resource_group_name = "networking"
}

output "virtual_network_id" {
  value = "${data.azurerm_virtual_network.test.id}"
}

output "virtual_network_subnet" {
  value = "${data.azurerm_virtual_network.test.subnets[0]}"
}
```
## 6. 使用module进行代码的组织管理
Module 是 Terraform 为了管理单元化资源而设计的，是子节点，子资源，子架构模板的整合和抽象。将多种可以复用的资源定义为一个module，通过对 module 的管理简化模板的架构，降低模板管理的复杂度，这就是module的作用。

Terraform中的模块是以组的形式管理不同的Terraform配置。模块用于在Terraform中创建可重用组件，以及用于基本代码组织。每一个module都可以定义自己的input与output，方便代码进行模块化组织。

用模块，可以写更少的代码。比如用下面的代码，调用已有的module 创建vm。
### 6.1 调用官方module
```
# declare variables and defaults
variable "location" {}
variable "environment" {
    default = "dev"
}
variable "vm_size" {
    default = {
        "dev"   = "Standard_B2s"
        "prod"  = "Standard_D2s_v3"
    }
}

# Use the network module to create a resource group, vnet and subnet
module "network" {
    source              = "Azure/network/azurerm"
    version             = "2.0.0"
    location            = "${var.location}"
    resource_group_name = "roytest-rg"
    address_space       = "10.0.0.0/16"
    subnet_names        = ["mySubnet"]
    subnet_prefixes     = ["10.0.1.0/24"]
}

# Use the compute module to create the VM
module "compute" {
    source            = "Azure/compute/azurerm"
    version           = "1.2.0"
    location          = "${var.location}"
    resource_group_name = "roytest-rg"
    vnet_subnet_id    = "${element(module.network.vnet_subnets, 0)}"
    admin_username    = "royzeng"
    admin_password    = "Password1234!"
    remote_port       = "22"
    vm_os_simple      = "UbuntuServer"
    vm_size           = "${lookup(var.vm_size, var.environment)}"
    public_ip_dns     = ["roydns"]
}
```
### 6.2 调用自己写的module
```
## file main.cf

module "roy-azure" {
  source = "./test"
}

## file test/resource.tf

variable "cluster_prefix" {
  type        = "string"
}
variable "cluster_location" {
    type        = "string"
}

resource "azurerm_resource_group" "core" {
    name     = "${var.cluster_prefix}-rg"
    location = "${var.cluster_location}"
}
```

## Reference
- [安装Terraform](https://segmentfault.com/a/1190000018145614)
- [构建基础设施](https://segmentfault.com/a/1190000018145618)
- [Terraform Homepage](https://www.terraform.io/)
- [Terraform Recommended Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform 学习笔记](https://www.jianshu.com/p/e0dd50f7ee98)
- [使用 Terraform 在 AWS 中国区域实现自动化部署指南系列（一） TERRAFORM 入门](https://amazonaws-china.com/cn/blogs/china/aws-china-region-guide-series-terraform1/)
- [使用 Terraform 在 AWS 中国区域实现自动化部署指南系列（二） TERRAFORM 进阶](https://amazonaws-china.com/cn/blogs/china/aws-china-region-guide-series-terraform2/)