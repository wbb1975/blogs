# Create a Go module

这是介绍 Go 语言一些基本特性的教程的第一部分。如果你是刚开始学习 Go 语言，请首先看看 [Tutorial: Get started with Go](https://go.dev/doc/tutorial/getting-started.html)，它介绍了 go 命令, Go 模块, 以及非常简单的 Go 代码。

在这个教程里，你将创建两个模块。第一个模块时倾向于被其它模块或应用导入的库，第二个是一个导入第一个模块的应用。

教程序列包含了七个简单的主题，每一个都展示了语言的不同部分。

1. 创建模块 -- 创建一个包含函数的模块，你可以从另一个模块调用它们
2. [从另一个模块调用你的代码](https://go.dev/doc/tutorial/call-module-code.html) -- 导入并使用你的新模块
3. [返回及处理错误](https://go.dev/doc/tutorial/handle-errors.html) -- 加入简单的错误处理
4. [返回一个随机欢迎值](https://go.dev/doc/tutorial/random-greeting.html) -- 处理切片数据（Go 的动态数组）
5. [为多人返回欢迎值](https://go.dev/doc/tutorial/greetings-multiple-people.html) -- 在映射中存储键值对
6. [添加测试](https://go.dev/doc/tutorial/add-a-test.html) -- 使用 Go 的内建单元测试特性来测试你的代码
7. [编译和安装应用](https://go.dev/doc/tutorial/compile-install.html) -- 本地编译和安装你的代码

> 注意：其它的模块，请参见[教程主页](https://go.dev/doc/tutorial/index.html)

## 0. 前提条件

- **一些编程经验**：这里的代码非常简单，但它能够帮助了解函数的一些知识
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。

## 1. 开始一个其他人可以使用的模块

让我们开始创建一个 Go 模块。在一个模块中，你为一个分散的有用的函数集创建一个或多个相关的包。例如，你可能编写一个包含包的模块，里面含有金融分析相关的函数，如此编写金融应用的开发者可以使用你的工作成果。关于开发模块的更多知识，请参见[开发和发布模块](https://go.dev/doc/modules/developing)。

Go 代码组织成包；包组织成模块。你的模块指定了你的代码运行所需依赖，Go 版本，以及它需要的其他模块。

当你为你的模块添加功能或改进时，你发布了新版模块。调用了你的模块代码的开发者可以导入你的模块里更新过的包，在投入产品环境前测试新版本。

1. 打开命令行终端并切换到你的主目录：
   
   在 Linux 或 Mac:
   ```
   cd
   ```
   在 Windows:
   ```
   cd %HOMEPATH%
   ```

2. 为你的 Go 模块代码创建一个 greetings 目录

   例如，在你的主目录使用下面的命令：

   ```
   mkdir greetings
   cd greetings
   ```

3. 使用 `go mod init` [命令](https://go.dev/ref/mod#go-mod-init) 来开启你的模块之旅

   运行 go mod init 命令，传递你的模块路径--这里使用 example.com/greetings。如果你要发布一个模块，这就必须是一个 Go 工具能从此下载你的模块的路径。那应该是你的代码仓库。

   想要了解更多模块命令及模块路径，参阅[管理依赖](https://go.dev/doc/modules/managing-dependencies#naming_module)。

   ```
   $ go mod init example.com/greetings
   go: creating new go.mod: module example.com/greetings
   ```

   go mod init 命令创建了一个 go.mod 文件来追踪你的代码依赖。到现在为止，这个文件仅仅包括你的模块名以及你的代码支持的 Go 版本号。但随着你加入依赖，go.mod 将列出你的代码依赖的版本。这将保持构建可重复，也给了你对你所使用模块版本的直接控制。

4. 在你的文本编辑器中，打开一个文件 `greetings.go` 以供编写你的代码
5. 将下面的代码黏贴进 `greetings.go` 并保存文件

    ```
   package greetings

   import "fmt"

   // Hello returns a greeting for the named person.
   func Hello(name string) string {
      // Return a greeting that embeds the name in a message.
      message := fmt.Sprintf("Hi, %v. Welcome!", name)
      return message
   }
   ```

   这是你的模块的第一份代码，它对没有调用它的客户返回一句欢迎词。下一步你将编写代码来调用这个函数。

   在这段代码中，你：

   - 声明了一个 `greetings` 包
   - 实现了一个函数 `Hello` 函数返回一句欢迎词

     函数接受一个 `name` 参数，其类型为字符串。函数也返回一个字符串。在 Go 中，以大写字符开头的函数可被同一包之外函数调用。这在 Go 中称为导出名字。更多关于导出名字的信息，请参看 Go 教程中的[导出名字](https://go.dev/tour/basics/3)。

     ![function syntax](function-syntax.png)
   - 声明了一个 message 变量以持有你的欢迎词

     在 Go 中，`:=` 是在同一行声明并初始化一个变量的快捷方式（Go 使用右边的值决定变量类型）。采用长格式，你可能撰写代码如下：

     ```
     var message string
     message = fmt.Sprintf("Hi, %v. Welcome!", name)
     ```
   - 使用  fmt 包的 [Sprintf 函数](https://pkg.go.dev/fmt/#Sprintf) 来创建一个欢迎消息。第一个参数是格式化字符串，`Sprintf` 将会用 `name` 的值替换掉 `%v` 格式化动词。插入 `name` 参数的值就完成了欢迎文本。
   - 将格式化后的欢迎文本返回给调用方。

在下一步，你将从另一个模块调用这个函数。

## 2. 从另一个模块调用你的代码

1. 为你的 Go 模块源代码创建一个 `hello` 目录。这是你编写你的调用方的地方。
2. 为你即将编写的代码开启依赖追踪
3. 在你的文本编辑器中，在 `hello` 目录下创建一个文件 `hello.go` 以供编写你的代码
4. 编写你的代码以调用 Hello 函数，然后打印函数返回值
5. 编辑 `example.com/hello` 模块以使用本地模块 `example.com/greetings`
6. 在 `hello` 目录下，从命令行提示中运行你的代码已验证它能够工作。

## 3. 返回及处理错误


## 4. 返回一个随机欢迎值

## 5. 为多人返回欢迎值


## 6. 添加测试


## 7. 编译和安装应用

## Reference

- [Create a Go module](https://go.dev/doc/tutorial/create-module)
- [Developing and publishing modules](https://go.dev/doc/modules/developing)
- [Go Modules Reference](https://go.dev/ref/mod#go-mod-init)
- [Managing dependencies](https://go.dev/doc/modules/managing-dependencies#naming_module)