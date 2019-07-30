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

## Reference
- [AWS CLI 是什么](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-welcome.html)