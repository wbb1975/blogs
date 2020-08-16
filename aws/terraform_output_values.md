## 输出值（Output Values）
> **注意**：本页面主要面向Terraform 0.12及其更新版本，对Terraform 0.11及其之前版本，请参阅[0.11配置语言输出值](https://www.terraform.io/docs/configuration-0-11/outputs.html)。

输出值就像一个Terraform 模块的返回值，它拥有以下几个用例：
- 子模块能够利用输出值来暴露父模块资源属性的一个子集
- 根模块在运行`terraform apply`后可以利用输出值在命令行输出中打印一些值
- 当使用[远程状态](https://www.terraform.io/docs/state/remote.html)，根模块输出可以被其它配置项通过[terraform_remote_state data source](https://www.terraform.io/docs/providers/terraform/d/remote_state.html)访问到。

Terraform 管理的资源实例每个都暴露出一些属性，其值可在配置文件中其它地方访问。输出值也是对你的模块用户暴露信息的一种方式。
> **注意**：为了简化，当在上下文中意思清晰的时候，“输出值”也常被引用为“输出”。
### 声明一个输出值
### 访问子模块输出


## Reference
- [Output Values](https://www.terraform.io/docs/configuration/outputs.html)