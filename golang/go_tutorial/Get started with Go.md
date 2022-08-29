# Go 开始入门

## 前提条件

- **一些编程经验**：这里的代码非常简单，但它能够帮助了解函数的一些知识
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。

## 安装 Go

请参见[下载与安装](https://go.dev/doc/install)。

## 编写一些代码

让我们从 `Hello, World` 开始。

1. 打开命令行终端并切换到你的主目录：
   
   在 Linux 或 Mac:
   ```
   cd
   ```
   在 Windows:
   ```
   cd %HOMEPATH%
   ```

2. 为你的第一个 Go 源代码创建一个 hello 目录

   例如，使用下面的命令：
   ```
   mkdir hello
   cd hello
   ```
3. 为你的代码开启依赖追踪
   
   当你的代码从其它模块里导入包时，你通过你代码自身的模块管理这些依赖。模块由一个叫 `go.mod` 的文件定义，它追踪提供这些包的模块。文件 `go.mod` 与你的代码一起位于你的源代码仓库里。

   为了创建 `go.mod` 文件从而为你的代码开启依赖追踪，运行 [go mod init](https://go.dev/ref/mod#go-mod-init) 命令，并传递你的代码所处的模块名。名字是模块的模块路径。

   在实际开发中，模块路径典型的是你的代码保存的仓库地址。例如，模块路径可能是 `github.com/mymodule`。如果你计划发布你的代码给他人使用，模块路径必须是一个 Go 能够从那里下载你的模块的地址。想要了解更多模块命令及模块路径，参阅[管理依赖](https://go.dev/doc/modules/managing-dependencies#naming_module)。

   处于本教程的目的，仅仅使用 `example/hello`：
   ```
   $ go mod init example/hello
   go: creating new go.mod: module example/hello
   ```

4. 在你的文本编辑器中，打开一个文件 `hello.go` 以供编写你的代码
5. 将下面的代码黏贴进 `hello.go` 并保存文件
   ```
   package main

   import "fmt"

    func main() {
       fmt.Println("Hello, World!")
   }
   ```

   这就是你的 Go 代码。在代码中，你：
   + 声明了一个 main 包（包是组织功能的一种方式），它由同一目录下的所有文件组成
   + 导入流行的 [fmt包](https://pkg.go.dev/fmt/)，它包含格式化文本的函数，包括打印到控制台上。这个包是[标准库](https://pkg.go.dev/std)包中的一个，当你安装 Go 时就有了。
   + 实现 `main` 函数以将消息打印到控制台上。当你运行 `main` 包时 `main` 函数会默认执行。

6. 运行你的代码以查看欢迎词。
   
   ```
   $ go run .
   Hello, World!
   ```

   [go run](https://go.dev/cmd/go/#hdr-Compile_and_run_Go_program) 命令是你平时使用 Go 工作的常见命令之一。使用下面的命令以获取更多选项。
   ```
   $ go help
   ```

## 调用外部包里的代码

如果你的代码需要调用由其他人实现的功能时，你可以寻找实现了你所需功能的包。

1. 通过使用外部模块里的函数使得你的输出消息更有趣：

   + 访问 `pkg.go.dev` 并[查找 quote 包](https://pkg.go.dev/search?q=quote)
   + 在查询结果（如果你发现了 `rsc.io/quote/v3`，忽略它）中定位并点击 `rsc.io/quote` 包
   + 在 **Documentation** 节中 **Index** 下面，注意到你可以从你的代码里调用的函数列表。你将使用 `Go` 函数。
   + 在页面的最上部，注意 `quote` 包位于 `rsc.io/quote` 模块里

   你可以使用 `pkg.go.dev` 网站来找到发布的模块，其包含有你期望在你的代码里调用的函数。包在模块里发布--像 `rsc.io/quote`--其他人可以使用它们。随着时间流逝，模块可能被改进，可能有新的版本号，你可以升级你的代码以使用改进版本。

2. 在你的 Go 代码中中，导入 `rsc.io/quote` 包，并增加对其 Go 函数的调用

   在增加高亮行之后， 你的代码应该包含如下内容：
   ```
   package main

   import "fmt"

   import "rsc.io/quote"

   func main() {
      fmt.Println(quote.Go())
   }
   ```

3. 增加新的模块需求和总结

   Go 将增加 `quote` 模块作为一个必须，也将增加一个 `go.sum` 文件以便认证该模块。更多内容，请参见 Go 模块参考中的[认证模块](https://go.dev/ref/mod#authenticating)

   ```
   $ go mod tidy
   go: finding module for package rsc.io/quote
   go: found rsc.io/quote in rsc.io/quote v1.5.2
   ```

4. 运行代码以查看你调用的函数所产生的消息。

   ```
   $ go run .
   Don't communicate by sharing memory, share memory by communicating.
   ```

   注意到你的代码调用了 Go 函数，打印了一条关于通信的更聪明的消息。

当你运行 `go mod tidy` 命令时，它定位并下载包含你的代码中导入包的 `rsc.io/quote` 模块。默认地，它下载最新版本 -- `v1.5.2`。

## 编写更多代码

随着这个快速介绍，你安装了 Go 并学会了一些基础。如果期待随着别的教程编写更多代码，请继续阅读下一节[创建 Go 模块](https://go.dev/doc/tutorial/create-module.html)。

## Reference

- [Get started with Go](https://go.dev/doc/tutorial/getting-started)