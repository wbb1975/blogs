# 多模块工作空间入门

这篇教程介绍了 Go 中多模块工作空间的基础知识。通过多模块工作空间，你可以告诉 Go 命令你在同时于多个模块中编写代码，便于在这些模块中构建于运行代码。

在这个教程中，你将创建两个共享多工作空间的模块，在两个模块间修改代码，并在一次构建里看到这些修改的结果。

## 0. 前提条件

- **一个包含 1.18 或更新版本的 Go 安装**
- **一个编写你的代码的工具**：任何文本编辑器都可以工作得很好。
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。

这按教程需要 `go1.18` 或更新版本，确保你从 [go.dev/dl](https://go.dev/dl) 安装了 Go 的 `Go 1.18` 或更新版本。

## 1. 为你的代码创建一个模块

作为开始，为你即将编写的代码创建一个模块。

1. 打开命令行终端并切换到你的主目录：

   在 Linux 或 Mac:
   ```
   cd
   ```

   在 Windows:
   ```
   cd %HOMEPATH%
   ```

   教程剩余部分的提示符将显示为 `$`，你使用的命令也可作用于 `Windows`。

2. 从命令行提示符，为你的代码创建一个 `workspace` 目录

   ```
   $ mkdir workspace
   $ cd workspace
   ```

3. 初始化模块

   我们的示例将创建一个新模块 `hello`，它依赖 `golang.org/x/example` 模块。

   创建 `hello` 模块：

   ```
   $ mkdir hello
   $ cd hello
   $ go mod init example.com/hello
   go: creating new go.mod: module example.com/hello
   ```

   通过使用 `go get` 添加对 `golang.org/x/example` 模块的依赖。

   ```
   $ go get golang.org/x/example
   ```

   在 `hello` 目录创建一个名为 `hello.go` 的文件，并粘贴如下代码：

   ```
    package main

    import (
        "fmt"

        "golang.org/x/example/stringutil"
    )

    func main() {
        fmt.Println(stringutil.Reverse("Hello"))
    }
   ```

   现在，运行 `hello` 应用：

   ```
   $ go run example.com/hello
   olleH
   ```

## 2. 创建工作空间

在这一步，我们将创建 `go.work` 文件来指定模块的工作空间。

### 2.1 初始化工作空间

在 `workspace 目录`，运行：

```
$ go work init ./hello
```

`go work init` 命令为包含在 `./hello` 目录内的模块的工作空间创建一个 `go.work` 文件。

go 命令创建了一个内容如下的 `go.work` 文件：

```
go 1.18

use ./hello
```

`go.work` 文件拥有与 `go.mod` 类似的语法。

go 指令告诉 Go 什么版本的 Go 可被用于解释该文件。这和 `go.mod` 中的 go 指令相似。

`use` 指令告诉 Go `hello` 目录中的模块应该是构建时的主模块。

因此在 `workspace` 任意子目录内的模块都是活跃的。

### 2.2 在工作空间目录里运行应用

在 `workspace` 目录，运行：

```
$ go run example.com/hello
olleH
```

Go 命令包含了工作空间内的所有模块作为主模块。这允许我们引用模块内的一个包，即使在模块之外。在模块或工作空间之外运行 `go run` 命令将会导致一个错误，原因在于 go 命令并不知道使用哪一个模块。

接下来，我们将添加一个 `golang.org/x/example` 模块的拷贝到工作空间，我们将在 `stringutil` 包里添加一个新函数而不再使用 `Reverse`。

## 3. 下载并修改 `golang.org/x/example` 模块

在这一步，我们将下载一份 Git 仓库的拷贝，它包含 `golang.org/x/example` 模块，将其添加到工作空间，然后添加一个新函数，我们稍后将在 `hello` 程序中用到它。

1. 克隆仓库

   从 `workspace` 目录，运行 `git` 命令以克隆仓库：

   ```
   $ git clone https://go.googlesource.com/example
   Cloning into 'example'...
   remote: Total 165 (delta 27), reused 165 (delta 27)
   Receiving objects: 100% (165/165), 434.18 KiB | 1022.00 KiB/s, done.
   Resolving deltas: 100% (27/27), done.
   ```

2. 将模块添加进工作空间

   ```
   $ go work use ./example
   ```

   `go work use` 命令将一个新的模块添加进 `go.work` 文件。它现在看起来像这样：

   ```
   go 1.18

   use (
       ./hello
       ./example
   )
   ```

   现在我们包含了两模块：`example.com/hello` 和 `golang.org/x/example`。

   这允许我们使用新的代码，它将实现我们期望的 `stringutil` 的一个拷贝，而不是我们通过 `go get` 命令下载并保存在缓存里的版本。

3. 添加新的函数

   我们将在 `golang.org/x/example/stringutil` 包里添加一个函数将一个字符串变成大写。

   在 `workspace/example/stringutil` 目录里创建一个新的文件 `toupper.go`，并添加以下内容：

   ```
   package stringutil

   import "unicode"

   // ToUpper uppercases all the runes in its argument string.
   func ToUpper(s string) string {
       r := []rune(s)
       for i := range r {
           r[i] = unicode.ToUpper(r[i])
       }
       return string(r)
   }
   ```

4. 修改 `hello` 应用以利用这个函数

   修改 `workspace/hello/hello.go` 的内容如下：

   ```
   package main

   import (
       "fmt"
       "golang.org/x/example/stringutil"
   )

   func main() {
       fmt.Println(stringutil.ToUpper("Hello"))
   }
   ```

### 3.1 在工作空间运行代码

从 workspace 目录运行：

```
$ go run example.com/hello
HELLO
```

Go 命令在由 `go.work` 文件指定的 `hello` 目录里找到了命令行指定的 `example.com/hello` 模块，同样的使用 `go.work` 解析了 `golang.org/x/example` 的导入。

`go.work` 能够替代 [replace](https://go.dev/ref/mod#go-mod-file-replace) 指令以跨越多个模块工作。

由于两个模块在一个 `workspace` 目录下，在一个模块里修改代码，在另一个模块里使用它就变得非常容易。

### 3.2 特性设置

现在，为了合适地发布这些模块我们需要对 `golang.org/x/example` 模块做一次发布，例如 `v0.1.0`。这通常是通过版本控制仓库里对提交打标签来实现的。更多细节请参见[模块发布工作流文档](https://go.dev/doc/modules/release-workflow)。一旦发布制作好了，我们可以在 `hello/go.mod` 里增加对 `golang.org/x/example` 的需求。

```
cd hello
go get golang.org/x/example@v0.1.0
```

通过这种方式，Go 命令可以适当地解析工作空间之外的模块。

## 4. 学习更多关于工作空间的知识

除了我们已经先前在教程里看到的 `go work init`，go 命令还有一些子命令工作于工作空间。

- `go work use [-r] [dir]` 在 `go.work` 文件里为 `dir` 添加了一条用户指令，如果它存在；如果参数目录不存在，则删除 `use` 指令；`-r` 标记迭代检查子目录 dir。
- `go work edit` 就像 `go mod edit` 一样修改 `go.work` 文件。
- `go work sync` 从工作空间的构建列表同步依赖进入每一个工作空间模块里。

可以在 Go 模块参考（Go Modules Reference）里查看[工作空间](https://go.dev/ref/mod#workspaces)以了关于工作空间和 `go.work` 文件的更多信息。

## Reference

- [多模块工作空间入门](https://go.dev/doc/tutorial/workspaces)