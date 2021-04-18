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
为了使用 `net/http` 包，它必须被导入：
```
import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)
```
让我们创建一个处理器，`viewHandler` 会允许用户查看一个 `wiki` 页面，它将处理以 "/view/" 为前缀的地址。
```
func viewHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/view/"):]
    p, _ := loadPage(title)
    fmt.Fprintf(w, "<h1>%s</h1><div>%s</div>", p.Title, p.Body)
}
```
再一次，请注意使用 `_` 来忽略来自 `loadPage` 的返回的错误值。这里这样做是为了简化，通常被认为是不好的实践。

首先，这个函数从 `r.URL.Path`，即请求 `URL` 的路径部分里抽取出页面标题。路径被利用 [len("/view/"):] 再次切片从而移除请求路径的前导 "/view/" 部分。这是因为路径将不变地以 "/view/" 开始，它不是页面标题的一部分。

接下来函数加载页面数据，用一个简单的 HTML 字符串格式化页面，并写入 `w`, 即 `http.ResponseWriter`。

为了使用这个处理器，我们重写了 `main` 函数，利用 `viewHandler` 来初始化 `http` 以处理 `/view/` 下的任何请求。
```
func main() {
    http.HandleFunc("/view/", viewHandler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```
[点击这里以查看到目前为止我们所写的代码](https://golang.org/doc/articles/wiki/part2.go)

让我们来差U那个捡一些页面数据（比如 test.txt），编译我们的代码，病史者服务我们的 wiki 页面。
```
$ go build wiki.go
$ ./wiki
```

在你的编辑器中打开 test.txt，将字符串  "Hello world" （不带引号）存入它。

（如果你在使用 Windows 你必须输入不带 the "./" 的 "wiki" 来运行程序。）

当 Web 服务器运行时，访问 `http://localhost:8080/view/test` 将显示一个页面标题为 "test"，内容为 "Hello world"。
## 6. 编辑页面
一个 `wiki` 不能没有任何编辑能力。让我们创建两个新的处理器：一个名为 `editHandler` 用于显示 “编辑页面”表单；另一个名为 `saveHandler` 通过表单保存输入的数据。

首先，我们把它们加入到 main()：
```
func main() {
    http.HandleFunc("/view/", viewHandler)
    http.HandleFunc("/edit/", editHandler)
    http.HandleFunc("/save/", saveHandler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```
函数 `editHandler` 加载页面（或者，如果它不存在，创建一个空的 Page 结构体），并显示一个 `HTML` 表单：
```
func editHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/edit/"):]
    p, err := loadPage(title)
    if err != nil {
        p = &Page{Title: title}
    }
    fmt.Fprintf(w, "<h1>Editing %s</h1>"+
        "<form action=\"/save/%s\" method=\"POST\">"+
        "<textarea name=\"body\">%s</textarea><br>"+
        "<input type=\"submit\" value=\"Save\">"+
        "</form>",
        p.Title, p.Title, p.Body)
}
```
这个函数将工作的得很好，但所有硬编码的 `HTML` 很丑陋。当然，我们有更好的方式。
## 7. html/template 包
`html/template` 包是 Go 标准库的一部分。我们可以使用 `html/template` 来将 `HTML` 保存在一个单独的文件中。允许我们改变我们编辑的文件的布局而无需修改我们的 Go 代码。

首先，我们需要将 `html/template` 加入到我们的导入列表。我们将不再使用 `fmt`，因此我们移除它：
```
import (
	"html/template"
	"io/ioutil"
	"net/http"
)
```
让我们创建一个包含 `HTML` 表单的模板文件。打开一个新的名为 `edit.html` 的文件，并加入下面的行：
```
<h1>Editing {{.Title}}</h1>

<form action="/save/{{.Title}}" method="POST">
<div><textarea name="body" rows="20" cols="80">{{printf "%s" .Body}}</textarea></div>
<div><input type="submit" value="Save"></div>
</form>
```
修改 `editHandler` 使用这个模板来替代硬编码的 `HTML`：
```
func editHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/edit/"):]
    p, err := loadPage(title)
    if err != nil {
        p = &Page{Title: title}
    }
    t, _ := template.ParseFiles("edit.html")
    t.Execute(w, p)
}
```
函数 `template.ParseFiles` 将读入 `edit.html` 的内容并返回一个 `*template.Template`。

方法 `t.Execute` 执行该模板，将产生的页面下写入到 `http.ResponseWriter`。点标识符 `.Title` 和 `.Body` 指 `p.Title` 和 `p.Body`。

模板指令用两个大括号包围，`printf "%s" .Body` 指令是一个函数调用，它将 `.Body` 输出成一个字符串而非一个字节流，`fmt.Printf` 也一样。`html/template` 包帮助确保模板行动产生安全及正确的 HTML。例如，它自动转义任何大些符号（`>`），将其替换为 " &gt;"，以此确保用户数据不会破坏HTML表单。

因为我们现在在用模板工作，让我们再为我们的 `viewHandler` 创建一个模板 `view.html`:
```
<h1>{{.Title}}</h1>

<p>[<a href="/edit/{{.Title}}">edit</a>]</p>

<div>{{printf "%s" .Body}}</div>
```
相应地修改 `viewHandler` ：
```
func viewHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/view/"):]
    p, _ := loadPage(title)
    t, _ := template.ParseFiles("view.html")
    t.Execute(w, p)
}
```
注意我们在两个处理器中使用了几乎一样的模板，让我们通过将模板（处理）代码移到到一个函数来消除重复：
```
func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
    t, _ := template.ParseFiles(tmpl + ".html")
    t.Execute(w, p)
}
```
并修改处理器以利用新的函数：
```
func viewHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/view/"):]
    p, _ := loadPage(title)
    renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/edit/"):]
    p, err := loadPage(title)
    if err != nil {
        p = &Page{Title: title}
    }
    renderTemplate(w, "edit", p)
}
```
如果我们在 main里注掉我们还未实现的 save 处理器的注册，我们可以再一次构建并运行我们的应用。[点击这里以查看到目前为止我们所写的代码](https://golang.org/doc/articles/wiki/part3.go)。
## 8. 处理不存在的页面（Handling non-existent pages）
如果你访问 `/view/APageThatDoesntExist` 会发生什么？你将看到一把包含 HTML 的页面。这是因为它忽略了 `loadPage` 返回的错误值并继续用控数据填充页面。取而代之，如果请求页面不存在，它应该将客户重定向到编辑页面，以此内容可以被创建。
```
func viewHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/view/"):]
    p, err := loadPage(title)
    if err != nil {
        http.Redirect(w, r, "/edit/"+title, http.StatusFound)
        return
    }
    renderTemplate(w, "view", p)
}
```
函数 `http.Redirect` 添加了一个 HTTP 状态码 `http.StatusFound (302)` 和一个 `Location` 头到 HTTP Response。
## 9. 保存页面
函数 `saveHandler` 将处理编辑页面的表单提交。在解除 `main` 中的注释之后，我们来实现这个处理器。
```
func saveHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/save/"):]
    body := r.FormValue("body")
    p := &Page{Title: title, Body: []byte(body)}
    p.save()
    http.Redirect(w, r, "/view/"+title, http.StatusFound)
}
```
页面标题 （在URL中提供）及表单的唯一字段，`Body`，将被保存到一个新的 `Page`。`save()` 方法被调用以把数据写到一个文件，客户呗重定向到 `/view/` 页面。

`FormValue` 返回的类型是 s`tring`，在它被保存到一个 `Page` 前我们必须将其转化为 `[]byte`。我们使用 `[]byte(body)` 来执行此转化。
## 10. 错误处理
我们的程序中还有其它几处错误被忽略了。这是坏的实践，至少当错误发生时，程序可能导致一种不期望的行为。一个更好的方案是处理错误并把错误消息返回给用户。这种方式下如果发生了某些错误，程序仍然按照我们期待的方式工作，用户也可得到通知。

首先，让我们在 `renderTemplate` 中处理错误：
```
func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
    t, err := template.ParseFiles(tmpl + ".html")
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    err = t.Execute(w, p)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}
```
函数 `http.Error` 发送一个特定的 `HTTP` 回复码（本例为 "Internal Server Error"）和错误消息。把它放进一个单独的函数的决定是还债（paying off）。

现在改正 `saveHandler`:
```
func saveHandler(w http.ResponseWriter, r *http.Request) {
    title := r.URL.Path[len("/save/"):]
    body := r.FormValue("body")
    p := &Page{Title: title, Body: []byte(body)}
    err := p.save()
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    http.Redirect(w, r, "/view/"+title, http.StatusFound)
}
```
在 `p.save()` 中发生的任何错误都将报告给用户。
## 11. 模板缓存（Template caching）
在我们的代码中有一处比较低效。每当一个页面要渲染时，`renderTemplate` 都会调用 `parseFiles`。一个更好的方法是在程序初始化时调用 `ParseFiles` 一次，将所有的模板解析进一个单独的 `*Template`。之后我们就可以使用 [ExecuteTemplate](https://golang.org/pkg/html/template/#Template.ExecuteTemplate) 来渲染一个特定的模板。

首先，我们创建一个全局变量 `templates`，并使用 `ParseFiles` 初始化它：
```
var templates = template.Must(template.ParseFiles("edit.html", "view.html"))
```
函数 `template.Must` 是一个方便的包装函数，当传递其一个 `non-nil` 的 `error` 值时它将 `panic`，否则返回一个不可更改的 `*Template`。在这里 `panic` 是合适的，如果模板不能被加载，唯一合理的事情就是退出程序。

函数 `ParseFiles` 可以接收任意数量的字符串以代表不同的模板文件。将这些文件解析成以这些文件 `basename` 命名的模板。如果我们期待为我们的应用添加更多的模板，我们可以将它们加入到 `ParseFiles` 的参数里。

接下来我们修改函数 `renderTemplate` 来调用 `templates.ExecuteTemplate` 方法并传递合适的模板名。
```
func renderTemplate(w http.ResponseWriter, tmpl string, p *Page) {
    err := templates.ExecuteTemplate(w, tmpl+".html", p)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}
```
注意模板名即为模板文件名，因此我们必须添加 ".html" 到 `tmpl` 参数里。
## 12. 验证（Validation）
你可能已经观察到，程序有一个严重的安全缺陷：一个用户可以提供一个服务器的任一路径以供读写。为了减轻这个，我们可以编写一个函数利用正则表达式来验证标题。

首先，添加 "regexp" 到导入列表。然后我们可以创建一个全局变量来存储我们的验证表达式：
```
var validPath = regexp.MustCompile("^/(edit|save|view)/([a-zA-Z0-9]+)$")
```
函数 `regexp.MustCompile` 将解析并编译正则表达式并返回一个 `regexp.Regexp`。`MustCompile` 与 `Compile` 的不同之处在于如果表达式编译失败 `MustCompile` 将 `panic`，而 `Compile` 在第二个返回值里填充 `error` 。

现在，让我们编写一个函数利用 `validPath` 来验证路径并抽取标题。
```
func getTitle(w http.ResponseWriter, r *http.Request) (string, error) {
    m := validPath.FindStringSubmatch(r.URL.Path)
    if m == nil {
        http.NotFound(w, r)
        return "", errors.New("invalid Page Title")
    }
    return m[2], nil // The title is the second subexpression.
}
```
如果标题有效，它将与一个 `nil error` 值一起返回。如果标题无效，函数将向 HTTP 连接写一个 "404 Not Found" error，并向处理器返回一个 error 值。为了创建一个新的 error，我们不得不到入 `errors` 包。

让我们在每个处理器中加入 `getTitle` 调用：
```
func viewHandler(w http.ResponseWriter, r *http.Request) {
    title, err := getTitle(w, r)
    if err != nil {
        return
    }
    p, err := loadPage(title)
    if err != nil {
        http.Redirect(w, r, "/edit/"+title, http.StatusFound)
        return
    }
    renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request) {
    title, err := getTitle(w, r)
    if err != nil {
        return
    }
    p, err := loadPage(title)
    if err != nil {
        p = &Page{Title: title}
    }
    renderTemplate(w, "edit", p)
}

func saveHandler(w http.ResponseWriter, r *http.Request) {
    title, err := getTitle(w, r)
    if err != nil {
        return
    }
    body := r.FormValue("body")
    p := &Page{Title: title, Body: []byte(body)}
    err = p.save()
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    http.Redirect(w, r, "/view/"+title, http.StatusFound)
}
```

## 13. 函数字面量与闭包简介（Introducing Function Literals and Closures）
在每个处理器中捕捉错误情况引入了许多重复代码。如果我们在一个函数里包装所有的处理器，它做所有的验证和错误检查如何？Go 的[函数字面量](https://golang.org/ref/spec#Function_literals)提供了强大的抽象功能，它可以在这里为我们提供帮助。

首先，我们重写每个处理器定义让其接受一个标题参数：
```
func viewHandler(w http.ResponseWriter, r *http.Request, title string)
func editHandler(w http.ResponseWriter, r *http.Request, title string)
func saveHandler(w http.ResponseWriter, r *http.Request, title string)
```
现在让我们定义一个包装函数，它接受如上定义的函数并返回一个 http.HandlerFun 函数类型（适合传递给函数 http.HandleFunc）。
```
func makeHandler(fn func (http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Here we will extract the page title from the Request,
		// and call the provided handler 'fn'
	}
}
```
因为它圈捕获了函数外所有定义的值，返回的函数被称为一个闭包，在本例中，变量 `fn` （`makeHandler` 的单个参数）被闭包捕获。变量 `fn` 将会是 `save`, `edit`, 或 `view` 处理器中的一个。

现在我们从 `getTitle` 拿来代码兵用在这里（有一些小修改）：
```
func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        m := validPath.FindStringSubmatch(r.URL.Path)
        if m == nil {
            http.NotFound(w, r)
            return
        }
        fn(w, r, m[2])
    }
}
```
`makeHandler` 返回的闭包是一个函数，它接受一个 `http.ResponseWriter` 和 `http.Request`（换句话说，`http.HandlerFunc`）闭包从请求路径里抽取标题，并用 `validPath` 正则表达式对象验证。如果标题无效，一个 error 就将会被 `http.NotFound` 函数写到 `ResponseWriter`，如果标题有效，闭包处理函数 `fn` 将会被调用，调用参数为 `ResponseWriter`, `Request`, 和标题。

现在我们可以在 `main` 里在利用 `http` 包注册它们之前用 `makeHandler` 包装处理函数。
```
func main() {
    http.HandleFunc("/view/", makeHandler(viewHandler))
    http.HandleFunc("/edit/", makeHandler(editHandler))
    http.HandleFunc("/save/", makeHandler(saveHandler))

    log.Fatal(http.ListenAndServe(":8080", nil))
}
```
最终，我们参处理器中移除了 `getTitle` 调用，使它们看起来更简单：
```
func viewHandler(w http.ResponseWriter, r *http.Request, title string) {
    p, err := loadPage(title)
    if err != nil {
        http.Redirect(w, r, "/edit/"+title, http.StatusFound)
        return
    }
    renderTemplate(w, "view", p)
}

func editHandler(w http.ResponseWriter, r *http.Request, title string) {
    p, err := loadPage(title)
    if err != nil {
        p = &Page{Title: title}
    }
    renderTemplate(w, "edit", p)
}

func saveHandler(w http.ResponseWriter, r *http.Request, title string) {
    body := r.FormValue("body")
    p := &Page{Title: title, Body: []byte(body)}
    err := p.save()
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    http.Redirect(w, r, "/view/"+title, http.StatusFound)
}
```
## 14. 试一试！（Try it out!）
[点击这里以查看到目前为止我们所写的代码](https://golang.org/doc/articles/wiki/final.go)

重新编译代码，并运行应用：
```
$ go build wiki.go
$ ./wiki
```
访问 http://localhost:8080/view/ANewPage 将呈现给你一个编辑页面，你就可以输入一些文本，点击  'Save'，将会被重定向到新创建的页面。
## 15. 其它任务
以下是一些你可以自己追踪的一些小任务：
- 将模板存储 在 `tmpl/` 页面数据存储在 `data/`
- 创建一个处理器将根页面的请求重定向到 `/view/FrontPage`
- 通过有效的 HTML 并添加 CSS 规则来打扮我们的页面模板
- 通过将 `[PageName]` 转化为 `<a href="/view/PageName">PageName</a>` 来实现页面间链接（提示，你可以使用 `regexp.ReplaceAllFunc` 来实现它）

## Reference
- [Writing Web Applications](https://golang.org/doc/articles/wiki/)
- [Golang标准库文档](https://studygolang.com/pkgdoc)