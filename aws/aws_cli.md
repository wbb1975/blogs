# AWS Command Line Interface
AWS Command Line Interface (AWS CLI) 是一种开源工具，让您能够在命令行 Shell 中使用命令与 AWS 服务进行交互。仅需最少的配置，您就可以从常用终端程序中的命令提示符开始使用同基于浏览器的 AWS 管理控制台提供的相同功能：
- Linux Shell – 使用常见 Shell 程序（例如 bash、zsh 和 tsch）在 Linux, OS X, or Unix 中运行命令。
- Windows 命令行 – 在 Windows 上，在 PowerShell 或 Windows 命令提示符处运行命令。
- 远程 – 通过远程终端（如 PuTTY 或 SSH）或者使用 AWS Systems Manager 在 Amazon Elastic Compute Cloud (Amazon EC2) 实例上运行命令。

所有 在AWS管理控制台(AWS Management Console )中的IaaS（基础设施即服务），包括AWS 管理和访问 功能都可在AWS API 和 CLI 得到。新的 AWS IaaS 功能和服务在启动时或在 180 天启动期内通过 API 和 CLI 提供全部 AWS 管理控制台 功能。

AWS CLI 提供对 AWS 服务的公共 API 的直接访问。您可以使用 AWS CLI 探索服务的功能，可以开发 Shell 脚本来管理资源。或者，也可以通过 AWS 开发工具包利用所学知识开发其他语言的程序。

除了低级别的 API 等效命令，多项 AWS 服务还为 AWS CLI 提供了自定义项。自定义项可能包括更高级别的命令，可简化具有复杂 API 的服务的使用。例如，aws s3 命令集提供熟悉的语法，用于管理 Amazon Simple Storage Service (Amazon S3) 中的文件。

例 将文件上传到 Amazon S3：aws s3 cp 提供了一个类似于 shell 的复制命令，并自动执行分段上传，以快速、弹性地传输大型文件。
```
aws s3 cp myvideo.mp4 s3://mybucket/
```
使用低级别命令 (在 aws s3api 下提供) 执行同一任务需要更多的工作。

## 安装 AWS CLI 
安装 AWS Command Line Interface (AWS CLI) 的方式
- [Using pip](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#install-tool-pip)
- [使用虚拟环境](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#install-tool-venv)
- [使用捆绑安装程序](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#install-tool-bundled)

先决条件：
- Python 2 版本 2.6.5+ 或 Python 3 版本 3.3+
- Windows、Linux, OS X, or Unix
> 注意
>
> 较早版本的 Python 可能无法兼容所有 AWS 服务。如果在安装或使用 AWS CLI 时看到 InsecurePlatformWarning 或弃用通知，请更新到更高的版本。

您可以查找最新 CLI 的版本号，网址为：https://github.com/aws/aws-cli/blob/master/CHANGELOG.rst。

### 使用 pip 安装 AWS CLI
AWS CLI 在 Linux、Windows 和 macOS 上的主要分发方式为 pip。这是一个用于 Python 的程序包管理器，提供了简单的方式来安装、升级和删除 Python 程序包及其相关组件。

**当前 AWS CLI 版本**

经常更新 AWS CLI 以支持新服务和命令。要确定您是否拥有最新版本，请查看 GitHub 上的版本页面。
如果您已经有 pip 和支持的 Python 版本，则可以使用以下命令安装 AWS CLI：如果您安装了 Python 3+ 版本，我们建议您使用 pip3 命令。
```
pip3 install awscli --upgrade --user
```
--upgrade 选项通知 pip3 升级已安装的任何必要组件。--user 选项通知 pip3 将程序安装到用户目录的子目录中，以避免修改您的操作系统所使用的库。

### 在虚拟环境中安装 AWS CLI
如果您在尝试随 pip3 一起安装 AWS CLI 时遇到问题，可以[在虚拟环境中安装 AWS CLI ](https://docs.amazonaws.cn/cli/latest/userguide/install-virtualenv.html)来隔离工具及其依赖项。或者，您可以使用与通常不同的 Python 版本。

### 使用安装程序安装 AWS CLI
若要在 Linux, OS X, or Unix 上进行离线或自动安装，请尝试[捆绑安装程序](https://docs.amazonaws.cn/cli/latest/userguide/install-bundle.html)。捆绑安装程序包括 AWS CLI 和其依赖项，以及为您执行安装的 Shell 脚本。

在 Windows 上，您也可以使用 [MSI 安装程序](https://docs.amazonaws.cn/cli/latest/userguide/install-windows.html#install-msi-on-windows)。这两种方法都简化了初始安装。但缺点是，当新版本的 AWS CLI 发布时，升级更加困难。

## 安装后需要执行的步骤
- [设置路径以包含 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#post-install-path)
- [使用您的凭证配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#post-install-configure)
- [升级到最新版本的 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#post-install-upgrade)
- [卸载 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html#post-install-uninstall)
### 设置路径以包含 AWS CLI
在安装 AWS CLI 后，您可能需要将可执行文件路径添加到您的 PATH 变量中。有关特定于平台的说明，请参阅以下主题：
+ Linux – [将 AWS CLI 可执行文件添加到命令行路径](https://docs.amazonaws.cn/cli/latest/userguide/install-linux.html#install-linux-path)
+ Windows – [将 AWS CLI 可执行文件添加到命令行路径](https://docs.amazonaws.cn/cli/latest/userguide/install-windows.html#awscli-install-windows-path)
+ macOS – [将 AWS CLI 可执行文件添加到 macOS 命令行路径](https://docs.amazonaws.cn/cli/latest/userguide/install-macos.html#awscli-install-osx-path)

通过运行 aws --version 来验证 AWS CLI 是否已正确安装。
```
aws --version
aws-cli/1.16.116 Python/3.6.8 Linux/4.14.77-81.59-amzn2.x86_64 botocore/1.12.106
```
### 使用您的凭证配置 AWS CLI
在运行 CLI 命令之前，您必须先使用您的凭证配置 AWS CLI。

通过在 [AWS CLI 配置文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-files.html)（默认存储在用户的主目录中）中定义[配置文件](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-profiles.html)，您可以在本地存储凭证信息。有关更多信息，请参阅 [配置 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-configure.html)。

> 注意：如果您在 Amazon EC2 实例上运行，可以从实例元数据中自动检索凭证。有关更多信息，请参阅 [实例元数据](https://docs.amazonaws.cn/cli/latest/userguide/cli-configure-metadata.html)。
### 升级到最新版本的 AWS CLI
定期更新 AWS CLI，以便添加对新服务和命令的支持。要更新到最新版本的 AWS CLI，请再次运行安装命令。有关 AWS CLI 最新版本的详细信息，请参阅 [AWS CLI 发行说明](https://github.com/aws/aws-cli/blob/develop/CHANGELOG.rst)。
```
pip3 install awscli --upgrade --user
```
### 卸载 AWS CLI
如果需要卸载 AWS CLI，请使用 pip uninstall。
```
$ pip3 uninstall awscli
```

如果您没有 Python 和 pip，则使用适合您的环境的过程。

## Reference
- [AWS CLI 是什么](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-welcome.html)