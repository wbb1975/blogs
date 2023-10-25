## 组织 Go 模块

Go 新手的一个常见问题是按照文件和目录布局“我如何组织 Go 项目？”。这篇文章的目标就是提供一些指南以回答这些问题。为了理解这里的内容，请确保阅读过[创建模块教程](https://go.dev/doc/tutorial/create-module)和[管理模块代码](https://go.dev/doc/modules/managing-source)以熟悉模块基本概念。

Go 项目包括包，命令行程序以及两者的组合。本指南依项目类型组织。

### Basic package

一个基本 Go 包其所有代码都在项目根目录下。项目包含一个单一模块， 其包含一个包。包名匹配模块路径的最后一部分。对一个只需一个 Go 文件的简单 Go 包，项目结构为：

```
project-root-directory/
  go.mod
  modname.go
  modname_test.go
```

(纵览本文，文件/包名是完全随意的)

假设目录要上传到一个 GitHub 仓库 **github.com/someuser/modname**，**go.mod** 文件中的 **module** 行应该记为 

```
module github.com/someuser/modname
```

`modname.go` 中的代码声明包如下：

```
package modname

// ... package code here
```

依赖这个包的用户可以如下导入这个包：

```
import "github.com/someuser/modname"
```

一个 Go 包可被细分成多个文件，但所有文件都驻留于同一目录，如下所示：

```
project-root-directory/
  go.mod
  modname.go
  modname_test.go
  auth.go
  auth_test.go
  hash.go
  hash_test.go
```

该目录下的所有文件都声明为 `package modname`。

### Basic command

一个基本可执行程序（命令行工具）按其复杂性和代码大小来组织。最简单的程序可仅仅包含一个 Go 文件，其中 **func main** 被定义。稍大点的程序代码可被细分为多个文件，所有文件都声明 **package main**：

```
project-root-directory/
  go.mod
  auth.go
  auth_test.go
  client.go
  main.go
```

这里 **main.go** 文件包含 **func main**，但这仅仅是一个惯例。**main** 文件也可以是 **modname.go**（`modname` 的合适名字）或其它任何名字。

假设目录要上传到一个 GitHub 仓库 **github.com/someuser/modname**，**go.mod** 文件中的 **module** 行应该记为 

```
module github.com/someuser/modname
```

一个用户应该能在他们的机器上以如下方式安装它：

```
$ go install github.com/someuser/modname@latest
```

### Package or command with supporting packages

大的包和命令行程序可能从将功能切分到支持包中受益。最初，推荐将支持包放在一个名为 **internal** 的目录下。这[防止](https://pkg.go.dev/cmd/go#hdr-Internal_Directories)了其它模块引用我们不期望暴露给外部用户并支持的包，因为其它项目不能从我们的 internal 目录导入代码，我们可以自由地重构代码，通常可以移动代码而无需担心破坏外部用户（程序）。一个包的项目结构如下：

```
project-root-directory/
  internal/
    auth/
      auth.go
      auth_test.go
    hash/
      hash.go
      hash_test.go
  go.mod
  modname.go
  modname_test.go
```

**modname.go** 文件声明 **package modname**, **auth.go** 声明 **package auth**，如此类推。**modname.go** 可以如下导入 **auth** 包：

```
import "github.com/someuser/modname/internal/auth"
```

在 **internal** 目录下存放支持包的命令行项目布局与此类似，除了根目录下的文件声明为 **package main**。

### Multiple packages

一个模块可以包含多个可导入的包；每个包有自己的目录，而且可以形成分层结构。这是一个示例项目结构：

```
project-root-directory/
  go.mod
  modname.go
  modname_test.go
  auth/
    auth.go
    auth_test.go
    token/
      token.go
      token_test.go
  hash/
    hash.go
  internal/
    trace/
      trace.go
```

提醒：我们假设 **go.mod** 中的 **module** 行记录如下：

```
import "github.com/someuser/modname/internal/auth"
```

**modname** 包驻留于根目录，声明 **package modname**，用户可以如下导入它：

```
import "github.com/someuser/modname"
```

用户可以如下导入其它子包：

```
import "github.com/someuser/modname/auth"
import "github.com/someuser/modname/auth/token"
import "github.com/someuser/modname/hash"
```

**trace** 包位于 **internal/trace**，不能从模块外导入。推荐尽量把包放置于 **internal** 内。

### Multiple commands

一个仓库的多个程序典型地拥有单独的目录：

```
project-root-directory/
  go.mod
  internal/
    ... shared internal packages
  prog1/
    main.go
  prog2/
    main.go
```

在每个目录，程序的 Go 文件都声明 **package main**。顶层 **internal** 目录可能包含被同一仓库的所有应用使用的共享包。

用户可以如下安装这些程序：

```
$ go install github.com/someuser/modname/prog1@latest
$ go install github.com/someuser/modname/prog2@latest
```

一个常见惯例是将仓库内的所有命令行程序放置在 **cmd** 目录，在仅仅包含一个命令的仓库中这并非严格必须，但在一个包含命令和导入包的混合仓库中它是很有用的，我们接下来将讨论它。

### Packages and commands in the same repository

有时候一个仓库可能会同时提供可导出的包以及实现了相关功能的应用。这里是此类仓库的示例项目结构：

```
project-root-directory/
  go.mod
  modname.go
  modname_test.go
  auth/
    auth.go
    auth_test.go
  internal/
    ... internal packages
  cmd/
    prog1/
      main.go
    prog2/
      main.go
```

假设这个模块被命名为 **github.com/someuser/modname**，那么用户可以从这导入包：

```
import "github.com/someuser/modname"
import "github.com/someuser/modname/auth"
```

也可以从它安装应用：

```
$ go install github.com/someuser/modname/cmd/prog1@latest
$ go install github.com/someuser/modname/cmd/prog2@latest
```

### Server project

Go 是实现服务的一个常见语言选择。此类项目结构变化较大，涉及服务开发的许多方面：协议（REST？gRPC），部署，前端文件，容器化，脚本等。这里我们将仅聚焦于 Go 项目开发部分。

服务项目通常不会有导出包，原因在于服务通常是一个自包含二进制程序（或一组二进制程序）。因此，推荐在 **internal** 目录下存放实现业务逻辑的包。另外，由于项目可能包含目录以容纳非 Go 语言的文件，将 Go 命令行程序放置于 **cmd** 目录是个好主意。

```
project-root-directory/
  go.mod
  internal/
    auth/
      ...
    metrics/
      ...
    model/
      ...
  cmd/
    api-server/
      main.go
    metrics-analyzer/
      main.go
    ...
  ... the project's other directories with non-Go code
```

当服务仓库增长时，包变得成熟从而可以与其它项目共享，最好将它们切分为多个模块。

### Reference

- [Organizing a Go module](https://go.dev/doc/modules/layout)