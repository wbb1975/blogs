# 编写 Web 应用
## 1. 介绍
本教程包括：
- 创建一个包含加载与保存方法的数据结构
- 使用 `net/http` 包来构建 Web 应用
- 使用 `html/template` 包来处理 HTML 模板
- 使用 `regexp` 来验证用户输入
- 使用闭包

假定（你拥有）的知识：
- 编程经验
- 理解基本 Web 技术（HTTP, HTML）
- 一些 UNIX/DOS 命令行知识
## 2. 开始
现在，你需要一台运行 Go 的 FreeBSD, Linux, OS X, 或 Windows机器。我们将使用 `$` 作为命令行提示符。

安装 Go（参见[安装指令](https://golang.org/doc/install)）

在你的 `GOPATH` 下为本教程创建一个新的目录并 `cd` 到里面：
```
$ mkdir gowiki
$ cd gowiki
```
创建一个文件 `wiki.go`， 用你喜欢的编辑器打开它，并加入下面的行：
```
package main

import (
	"fmt"
	"io/ioutil"
)
```
我们从 Go 标准库导入了 `fmt` 和 `ioutil` 包。稍后，随着我们实现额外的功能，我们将会在这个导入声明中添加更多包。
## 3. 数据结构
让我们从定义数据结构开始。一个 wiki 包含一系列相互链接的页面，每一个都拥有标题和躯体（页面内容）。这里，我们将 `Page` 定义为包含两个字段的结构体，一个代表标题，一个代表躯体。
```
type Page struct {
    Title string
    Body  []byte
}
```
类型 `[]byte` 意味着 “字节分片”（参见[分片：用法及内部实现](https://golang.org/doc/articles/slices_usage_and_internals.html)来获取更多分片细节）。`Body` 元素是 `[]byte` 而不是 `string`，原因在一它是我们后面将使用的 io 库所期望的，你稍后将看到这个。

`Page` 结构体描述了页面数据如何在内存里存储，但持久存储又如何呢？我们可以通过在 `Page` 上创建一个 `save` 方法来解决这个问题。
```
func (p *Page) save() error {
    filename := p.Title + ".txt"
    return ioutil.WriteFile(filename, p.Body, 0600)
}
```
这个方法的签名如下：该方法被命名为 `save`，其接收者为 一个指向 `Page` 的指针 `p`。它不接收任何参数，返回一个 `error` 值。

这个方法将会把 `Page` 的 `body` 存到一个文本文件，为了简化，我们将使用 `Page` 的 `Title` 作为文件名。

因为 `WriteFile`（一个标准库函数将字节分片写进一个文件） 返回一个 `error`， 因此 `save` 方法也返回一个 `error` 值。`save` 方法返回一个 `error` 值，可以让应用以任何方式处理写文件过程出现的错误。如果一切顺利，`Page.save()` 将返回 `nil`（指针，接口以及其它一些类型的零值）。

传递给 `WriteFile` 的第三个参数，八进制整型字面量 `0600`，指示该文件以只有当前用户可读写的权限创建（查阅Unix 手册页 open(2）以获取更多细节）。

除了保存页面，我们也期待加载页面：
```
func loadPage(title string) *Page {
    filename := title + ".txt"
    body, _ := ioutil.ReadFile(filename)
    return &Page{Title: title, Body: body}
}
```
函数 `loadPage` 从 `title` 参数构建文件名，将文件的内容读入到一个新的变量 `body`，然后返回一个指向用合适的 `title` 和 `body` 值构造的 Page字面量的指针。

函数可以返回多个值。标准库函数 `io.ReadFile` 返回 `[]byte` 和 `error`。在 `loadPage` 中，错误未被处理；用下划线（_）代表的 “空指示符”用于扨掉 `error` 返回值（本质上，即不把值付赋给任何变量）。

但如果 `ReadFile` 发生错误会发生什么？例如，如果文件不存在。我们不应该忽略这类错误，让我们修改函数返回 `*Page` 和 `error`.
```
func loadPage(title string) (*Page, error) {
    filename := title + ".txt"
    body, err := ioutil.ReadFile(filename)
    if err != nil {
        return nil, err
    }
    return &Page{Title: title, Body: body}, nil
}`
```
现在函数调用方可以检查第二个参数；如果它是 `nil`，则它已经成功地加载了一个页面。如果不是，它将是一个调用方可以处理的 `error`（参阅[语言规范](https://golang.org/ref/spec#Errors)以获取更多细节）。

到现在为止，我们拥有了一个简单的数据结构，也有能力保存文件和从一个文件加载。让我们编写一个 `main` 函数来测试我们到目前所写的代码：
```
func main() {
    p1 := &Page{Title: "TestPage", Body: []byte("This is a sample Page.")}
    p1.save()
    p2, _ := loadPage("TestPage")
    fmt.Println(string(p2.Body))
}
```
在编译并执行这段代码后，一个名为 `TestPage.txt` 包含 `p1` 的内容的的文件将会被创建。然后该文件被读进到结构体 `p2` 中，它的 `Body` 元素被打印到频幕上.

你可以像下面那样编译并运行程序：
```
$ go build wiki.go
$ ./wiki
This is a sample Page.
```
> **注意**：如果你在使用 Windows 你必须输入不带 "./" 的 "wiki" 来运行程序。

[点击这里以查看到目前为止我们所写的代码](https://golang.org/doc/articles/wiki/part1.go)
## 4. net/http 包介绍 (an interlude)
这里是一个简单 Web 服务器的完整工作实例：
```
// +build ignore

package main

import (
    "fmt"
    "log"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
}

func main() {
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```
`main` 函数以调用 `http.HandleFunc` 开始，它告诉 `http` 包使用 `handler` 来处理来自 Web 根资源("/") 的所有请求。

它然后调用 http.ListenAndServe，指定它应该在任一网络接口(":8080")的8080端口上监听。（现在不要担心它的第二个参数，nil）。这个函数将阻塞直至程序停止。

`ListenAndServe` 总是返回一个 `error`，因为只有当一个无法预料的错误发生时它才会返回。为了记录那个错误我们把调用包装在 `log.Fatal` 里。

函数 `handler` 类型为 `http.HandlerFunc`，它需要两个参数 `http.ResponseWriter` 和 `http.Request`。

一个 `http.ResponseWriter` 值装配了 `HTTP` 服务器的回复（`response`），我们通过向它写入来向 `HTTP` 客户发送数据。

`http.Request` 是一个代表客户 `HTTP` 请求的数据结构，`r.URL.Path` 是 请求 URL 的路径部分。尾部 `[1:]` 意味着 “从第二个字符直至结尾创建子切片”，这从路径名中删除了前导 "/" 。

如果你运行这个程序并访问这个地址：
```
http://localhost:8080/monkeys
```
应用将会呈现一个包含下面内容的页面：
```
Hi there, I love monkeys!
```
## 5. 利用 net/http 来服务 wiki 页面

## 6. 编辑页面
## 7. html/template 包
## 8. 处理不存在的页面（Handling non-existent pages）
## 9. 保存页面
## 10. 错误处理
## 11. 模板缓存（Template caching）
## 12. 验证（Validation）
## 13. 函数字面量与闭包简介（Introducing Function Literals and Closures）
## 14. 试一试！（Try it out!）
## 15. 其它任务

## Reference
- [Writing Web Applications](https://golang.org/doc/articles/wiki/)
- [Golang标准库文档](https://studygolang.com/pkgdoc)