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

假设目录要上传到一个 GitHub 仓库 `github.com/someuser/modname`，`go.mod` 文件中的 `module` 行应该记为 

```
module github.com/someuser/modname
```

`modname.go` 中的代码生命包如下：

```
package modname

// ... package code here
```

依赖这个包的用户可以如下导入这个包：

```
import "github.com/someuser/modname"
```

一个 Go 包可被细分成多个文件，单所有文件都驻留于同一目录，如下所示：

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

这里 **main.go** 文件包含 **func main**，但这渐进式一个习惯。“main” 文件也可以是 **modname.go**（`modname`` 的合适名字）或其它任何名字。

假设目录要上传到一个 GitHub 仓库 `github.com/someuser/modname`，`go.mod` 文件中的 `module` 行应该记为 

```
module github.com/someuser/modname
```

一个用户应该能在他们的机器上以如下方式安装它：

```
$ go install github.com/someuser/modname@latest
```

### Package or command with supporting packages

大的包和命令可能从将功能切分到支持包中受益。最初，推荐将支持包放在一个名为 internal 的目录下。这防止了https://pkg.go.dev/cmd/go#hdr-Internal_Directories

### Multiple packages


### Multiple commands


### Packages and commands in the same repository


### Server project


### Reference

- [Organizing a Go module](https://go.dev/doc/modules/layout)