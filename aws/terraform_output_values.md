## 输出值（Output Values）
> **注意**：本页面主要面向Terraform 0.12及其更新版本，对Terraform 0.11及其之前版本，请参阅[0.11配置语言输出值](https://www.terraform.io/docs/configuration-0-11/outputs.html)。

输出值就像一个Terraform 模块的返回值，它拥有以下几个用例：
- 子模块能够利用输出值来暴露父模块资源属性的一个子集
- 根模块在运行`terraform apply`后可以利用输出值在命令行输出中打印一些值
- 当使用[远程状态](https://www.terraform.io/docs/state/remote.html)，根模块输出可以被其它配置项通过[terraform_remote_state data source](https://www.terraform.io/docs/providers/terraform/d/remote_state.html)访问到。

Terraform 管理的资源实例每个都暴露出一些属性，其值可在配置文件中其它地方访问。输出值也是对你的模块用户暴露信息的一种方式。
> **注意**：为了简化，当在上下文中意思清晰的时候，“输出值”也常被引用为“输出”。
### 声明一个输出值
每个模块导出的输出值必须用 `output` 块声明：
```
output "instance_ip_addr" {
  value = aws_instance.server.private_ip
}
```
紧挨着`output`关键字的是名字，其必须是一个有效的[标识符](https://www.terraform.io/docs/configuration/syntax.html#identifiers)。在一个根模块中，这个名字显示给用户；在子模块中，它被用于访问输出值。

`value` 参数带有一个[表达式](https://www.terraform.io/docs/configuration/expressions.html)，它的结果将被返回给用户。在这个例子中，表达式引用`private_ip`属性，它由该模块（未显示）其它地方定义的`aws_instance`资源定义。 一个有效的表达式允许做为输出值。
> **注意**：只有当`Terraform` 应用你的计划时，输出才会被提供。运行`terraform plan`并不会提供输出。
### 访问子模块输出
在父模块中，子模块输出依旧可用，其表达式为：`module.<MODULE NAME>.<OUTPUT NAME>`。例如，如果子模块名为 `web_server`，其定义了一个输出值名为 `instance_ip_addr`，你可以用`module.web_server.instance_ip_addr`访问那个输出值。
#### 可选参数
`output` 块可以可选地包含`description`, `sensitive`, 和 `depends_on`参数，它们在下面的章节描述。
##### description - 输出值文档
由于模块输出值是用户接口的一部分，你可以使用可选地`description`参数简要描述每个值的目的：
```
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."
}
```
描述应该简要介绍该输出值的目的和他期待的值类型。该描述字符串可能会包含在模块文档里，因此它应该从模块用户的视觉撰写而不是模块维护者。对于维护者，请使用注释。
##### sensitive - 拟制CLI输出
一个输出值可被可选`sensitive`参数标记为包含敏感信息。
```
output "db_password" {
  value       = aws_db_instance.db.password
  description = "The password for logging in to the database."
  sensitive   = true
}
```
在一个根模块在将一个输出值标记为`sensitive`将阻止`Terraform` 在`terraform apply`末尾显示的一系列输出值中包含它。由于其它一些原因它也可能在CLI输出值被显示，例如如果该值在一个资源参数的表达式中被引用。

`sensitive`值仍被就在[state](https://www.terraform.io/docs/state/index.html)中，因此对于可访问state数据的任何人依旧可见。更多信息，请参见[Satte中的敏感数据](https://www.terraform.io/docs/state/sensitive-data.html)。
##### depends_on - 显式输出依赖
因为输出值仅仅是一种向模块外传递值的方式，因此通常是不需要担心其同依赖图上其它节点的关系。

但是，当一个父模块访问其一个子模块导出的输出值时，输出值的依赖允许Terraform 正确决定在不同模块定义的资源之间的依赖。

就像[资源依赖](https://www.terraform.io/docs/configuration/resources.html#resource-dependencies)，Terraform 分析输出值的 `value` 表达式并idong决定一系列依赖。但在极少数情况下，一些依赖不能被隐式识别。在这些罕见的情景下， `depends_on`参数用于创建额外的显式依赖：
```
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."

  depends_on = [
    # Security group rule must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    aws_security_group_rule.local_access,
  ]
}
```
 `depends_on`参数应该被选择为最后的方法。当使用它时，总是包含一个注释来解释为什么使用它，以此来帮助未来的维护者理解附加依赖的目的。

## Reference
- [Output Values](https://www.terraform.io/docs/configuration/outputs.html)