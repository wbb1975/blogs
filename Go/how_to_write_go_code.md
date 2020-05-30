# 怎样写Go代码
## 介绍
本文档演示了在一个模块中一个简单的Go模块的开发，也介绍了[Go工具](https://golang.google.cn/cmd/go/)，这是获取，构建，安装Go模块，包以及命令的标准方式。

> **注意**：本文档假设你正在使用Go 1.13及以后版本，并且GO111MODULE环境变量未设置。如果你在寻找本文档老的，模块引入之前的版本，它被归档在[这里](https://golang.google.cn/doc/gopath_code.html)。
## 代码组织
Go应用按包组织。一个包是同一目录下的源代码的集合，它们并编译在一起。在一个源文件中定义的函数，类型，变量，常量等对同一包中的所有源代码文件可见。

一个存储库（repository）包含一个或多个模块。一个模块是一起发布的相关Go包的集合。一个Go存储库典型地仅含一个模块，存在于存储库的根目录下。一个名为go.mod的文件指明了模块路径：该模块内所有包的导入路径前缀。该模块包含拥有go.mod的目录下的所有包，也包含该目录的下级目录，直到含有别的go.mod（如果有）的下级目录。

注意在你的代码可以构建之前你并不需要把你的代码发布到远程存储库。一个模块可以在本地定义，且不属于一个存储库。但是，将你的代码以方便你日后发布是一个好习惯。

每个模块路径不仅服务于它的包的导入路径前缀，同时也指明了go命令应该从哪里寻找并下载它。例如，为了下载模块 golang.org/x/tools，Go命令将查询由https://golang.org/x/tools 指定的存储库（[这里](https://golang.org/cmd/go/#hdr-Relative_import_paths)描述了这一行为）。

导入路径是一个用于导入包的字符串，一个包的导入路径是其模块路径和该模块下的子目录的连接（串）。例如，模块 github.com/google/go-cmp在目录cmp/下有一个包，该包的导入路径即为github.com/google/go-cmp/cmp。标准库中的包没有模块路径前缀。
## 你的第一个程序
为了编译和运行一个简单程序，首先选择一个模块路径（我们将使用example.com/user/hello）并创建一个go.mod文件来声明它。
```
$ mkdir hello # Alternatively, clone it if it already exists in version control.
$ cd hello
$ go mod init example.com/user/hello
go: creating new go.mod: module example.com/user/hello
$ cat go.mod
module example.com/user/hello

go 1.14
$
```
Go源代码的第一条语句必须是`package name`。可执行命令必须总是使用包main。

下一步，在该目录下创建一个文件hello.go包含下面的Go代码：
```
package main

import "fmt"

func main() {
	fmt.Println("Hello, world.")
}
```
现在你可以使用go工具来构建并安装该程序了：
```
$ go install example.com/user/hello
$
```
这个命令将构建hello命令并产生一个可执行二进制文件。接下来它将该二进制文件安装为$HOME/go/bin/hello（或者在Windows下为%USERPROFILE%\go\bin\hello.exe）。

安装目录由GOPATH和GOBIN[环境变量](https://golang.google.cn/cmd/go/#hdr-Environment_variables)控制。如果GOBIN已经设置，二进制文件将安装到该目录。如果GOPATH已经设置，二进制文件将被安装到GOPATH列表的第一个目录的bin子目录中。否则，二进制文件被安装到缺省GOPATH（$HOME/go 或 %USERPROFILE%\go）的bin子目录中。

你可以为将来的go命令使用`go env`工具可移植地设置一个环境变量的缺省值：
```
$ go env -w GOBIN=/somewhere/else/bin
$
```
使用 go env -u可以取消之前由go env -w设置的变量值：
```
$ go env -u GOBIN
$
```
像go install这样的命令仅仅在包含当前工作目录的模块上下文中适用。如果工作目录不在example.com/user/hello模块内，go install 可能会失败。

为了方便，go命令接受针对当前工作目录的相对目录，如果没有其它的路径指定，则缺省指向当前工作目录的包。因此在你的工作目录，下面的命令实际上是一样的：
```
$ go install example.com/user/hello
$ go install .
$ go install
```
接下来，让我们运行程序来确保它工作。为增加便利性，我们把安装目录增加到我们的PATH中来时的运行程序更容易：
```
# Windows users should consult https://github.com/golang/go/wiki/SettingGOPATH
# for setting %PATH%.
$ export PATH=$PATH:$(dirname $(go list -f '{{.Target}}' .))
$ hello
Hello, world.
$
```

如果你在使用源代码控制系统，现在是一个很好的时机来初始化一个存储库，添加文件，并提交你的首次修改。再一次：这一步是可选的，你并不需要选代码控制就可以写Go代码。
```
$ git init
Initialized empty Git repository in /home/user/hello/.git/
$ git add go.mod hello.go
$ git commit -m "initial commit"
[master (root-commit) 0b4507d] initial commit
 1 file changed, 7 insertion(+)
 create mode 100644 go.mod hello.go
$
```
Go命令定位包含给定模块路径的存储库时，它会请求对应的HTTPS路径并读取嵌入到HTML 回复中的元数据（参见[go help importpath](https://golang.google.cn/cmd/go/#hdr-Remote_import_paths)）。许多托管服务已经提供对Go代码存储库的元信息，因此使你的模块对其他人可用的最容易的方法就是使你的模块路径匹配存储库的URL。
## 从你的模块中导入包
让我们来写一个模块morestrings并在hello应用中使用它。首先，为包创建一个目录$HOME/hello/morestrings，然后，在该目录下创建一个名为reverse.go 的文件，并填充以下内容：
```
// Package morestrings implements additional functions to manipulate UTF-8
// encoded strings, beyond what is provided in the standard "strings" package.
package morestrings

// ReverseRunes returns its argument string reversed rune-wise left to right.
func ReverseRunes(s string) string {
	r := []rune(s)
	for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
		r[i], r[j] = r[j], r[i]
	}
	return string(r)
}
```
因为ReverseRunes以大写字母开头，它是[导出](https://golang.google.cn/ref/spec#Exported_identifiers)的，可在导入我们的morestrings包 的包中使用。

让我们使用go build来测试包编译：
```
$ cd $HOME/hello/morestrings
$ go build
$
```

这将不会产生一个输出文件，作为替代，它将编译好的包存放到本地构建缓存中。

确认了morestrings包的构建之后，让我们从hello应用中使用它。为了实现这个，修改你原先的$HOME/hello/hello.go以使用morestrings包：
```
package main

import (
	"fmt"

	"example.com/user/hello/morestrings"
)

func main() {
	fmt.Println(morestrings.ReverseRunes("!oG ,olleH"))
}
```
安装hello应用：
```
$ go install example.com/user/hello
```

运行新版本程序，你应该看到反转后的消息：
```
$ hello
Hello, Go!
```
## 从远程模块中导入包
## 测试
## 下一步
## 获得帮助

## Reference
- [How to Write Go Code](https://golang.google.cn/doc/code.html)