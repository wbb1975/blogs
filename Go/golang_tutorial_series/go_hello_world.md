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
### 2. go buil
## 对 Hello World 程序的简单解释

## Reference
- [Hello World](https://golangbot.com/hello-world-gomod/)