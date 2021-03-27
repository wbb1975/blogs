# Hello World
学习一门新的语言，没有比下手编代码更好的方式了、让我们开始便一我们的第一个 Go 代码。
## 设置开发环境
让我们创建一个目录，我们将在它下面编写我们的 `hello world` 程序。打开终端并输入以下命令：
```
mkdir ~/Documents/learngo/  
```
上述命令将在当前用户的 `Documents` 目录下创建一个名为 `learngo` 的目录，你可以随意选择你保存代码的地方创建目录。
## Hello World
在 `learngo` 目录下选择你喜爱的编辑器创建一个名为 `main.go` 的文件并输入以下内容：
```
package main

import "fmt"

func main() {  
    fmt.Println("Hello World")
} 
```
Go 语言的一个惯例是对包含 `main` 函数的文件命名为 `main.go`，但其它名字也可以工作。
## 运行一个程序
有许多不同的方式来运行 Go 程序，接下来让我们看一看。
### 1. go install
运行 Go 程序的第一个方法是 `go install` 命令。让我们进入我们刚创建的 `learngo` 目录：
```
cd ~/Documents/learngo/  
```
加下来运行下面的命令：
```
go install
```
上面的命令将编译命令并安装（拷贝）可执行程序到 `~/go/bin`。可执行程序的名字是包含 `main.go` 的目录名。在我们的自离中，它将为 `learngo`。

当你试着安装程序时你可能遇见下面的错误：
```
go install: no install location for directory /home/naveen/Documents/learngo outside GOPATH  
For more details see: 'go help gopath'  
```
上面的错误实际意思是 `go install` 不能找到一个安装编译出来的程序的地方。因此让我们给它一个地方让其继续。这个地址由 `GOBIN` 环境变量指定。
```
export GOBIN=~/go/bin/ 
```
上面的命令指定 `go install` 将编译得来的可执行文件拷贝到路径 `~/go/bin/` 下。这是传统 Go 可执行文件安装的地方，但你也可修改它为你喜欢的地方。现在试着再次运行 `go install`，程序应该能够正常编译并正常运行。

你可以在终端输入 `ls -al ~/go/bin/learngo`，你将发现 `go install` 已经将可执行文件拷贝到 `~/go/bin`。

现在让我们运行编译好的程序：
```
~/go/bin/learngo
```
上面的命令将运行 `learngo` 而兼治程序并打印下面的输出：
```
Hello World
```
祝贺你，你已经成功运行了你的第一个 Go 应用。

如果你想避免每次运行程序时输入完整的路径 `~/go/bin/learngo`，你可以将 `~/go/bin/` 加入到 `PATH` 环境变量里。
```
export PATH=$PATH:~/go/bin  
```
现在你可以在终端里仅仅输入 `learngo` 来运行程序了。

你可能会考虑当 `learngo` 目录下包含多个 Go 文件而不仅仅一个 `main.g`o 时会发生什么？`go install` 在这种情况下将如何工作？稍等，我们将在学习过 Go 包和模块后再讨论它们。
### 2. go build
运行 Go 程序的第二种方式是 `go build`。`go build` 与 `go install`很像，除了它不把编译生成的可执行文件安装（拷贝）到 `~/go/bin/`。取而代之，它在 `go build` 命令发出的目录下生成二进制文件。

在终端里输入下面的命令来切换当前目录至 `learngo`：
```
cd ~/Documents/learngo/  
```
之后，输入下面的命令：
```
go build
```
上面的命令将在当前的目录下产生可执行文件 `learngo`，`ls -al` 将验证 `learngo` 确实产生了。

输入 `./learngo` 来运行这个程序，它将输出：
```
Hello World  
```
我们已经使用 go build 也成功运行了我们的第一个 Go 程序。
### 3. go run
运行 Go 程序的第三种方式是 `go run`。

在终端里输入下面的命令来切换当前目录至 `learngo`：
```
cd ~/Documents/learngo/  
```
之后，输入下面的命令：
```
go run main.go
```
当输入上面的命令后，我们将看到下面的输出：
```
Hello World  
```
`go run` 与 `go build/go install` 命令的一个比较微妙的差异在于，`go run` 需要 `.go` 文件名作为参数。

实际上，`go run` 运行的更像 `go build`。它并不编译并将可执行文件安装至当前目录，取而代之，它将文件编译输出至一个临时目录，并从该临时目录运行它。如果你对 `go run` 编译源文件输出可执行程序的路径感兴趣，你可以带 `--work` 参数运行 `go run`。
```
go run --work main.go  
```
在我的例子中运行上面的命令输出：
```
WORK=/var/folders/23/vdjz4kt972g5nzr86wzrj9740000gq/T/go-build698353814  
Hello World  
```
WORK 键的值指定了程序将会在此编译得临时目录地址，

在我的例子中，程序被编译到路径 `/var/folders/23/vdjz4kt972g5nzr86wzrj9740000gq/T/go-build698353814/b001/exe`，但你的例子可能会有所不同。
### 4. Go Playground
运行 Go 程序的最后一种方式是 `go playgroun`。虽然这种方式有限制，但当我们向运行简单的程序时，这种方式很方便，因为它是用浏览器因此并不需要在你本地安装 Go。我已经为 `hello world` 程序创建了 `playground`。[点击这里](https://play.golang.org/p/oXGayDtoLPh)可以在线运行它。

你也可以利用 `go playground` 与其他人分享代码。

现在我们知道了运行程序的4种不同方式，你可能会疑惑到底该采用哪种方式。答案是取决于实际情况。当我想要快速检查逻辑或者找到标准库是如何工作的时候，我通常会使用 [playground](https://play.golang.org/)。在其它情况下，我偏向于使用 `go install`，原因在于它把程序编译安装到标准路径 `~/go/bin/` 下，从而可以从人胡目录下运行程序。
## 对 Hello World 程序的简单解释
这是我们刚刚编写的 hello world程序：
```
package main 

import "fmt" 

func main() {  
    fmt.Println("Hello World") 
}
```
我们将简单讨论程序的每一行做了些什么。我们将在后面的教程中深入了解程序的每一段。

**package main - 每一个 Go 文件必须以 package name 语句开头**。包用于代码组织和重用。这里我们使用包名 `main`。`main` 函数应该总是位于 `main` 包里。

**import "fmt"** - `import` 语句用于导入其它的包。在我们的例子中，`fmt` 被导入，它被用在 `main` 函数里将文本输出到标准输出上。

**func main()** - `func` 关键字表示了一个函数的开始。`main` 是一个特殊的函数。程序的执行从 `main` 函数开始。`{` 和 `}` 指示函数的开始和结束。

**fmt.Println("Hello World")** - `fmt` 包里的 `Println` 函数用于将文本写出到标准输出。`package.function()` 是调用一个包里的函数的语法。

代码可以从 [GitHub](https://github.com/golangbot/hello) 上下载。

## Reference
- [Hello World](https://golangbot.com/hello-world-gomod/)