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

   在你创建了这个目录之后，你应该拥有两个平级目录 `hello` 和 `greetings`，如下所示：
    ```
    <home>/
    |-- greetings/
    |-- hello/
    ```

    例如，如果你的命令行提示符在 `greetings` 目录，你应该使用下面的命令：
    ```
    cd ..
    mkdir hello
    cd hello
    ```
2. 为你即将编写的代码开启依赖追踪

   为了给你的代码开启依赖追踪，运行 [go mod init 命令](https://go.dev/ref/mod#go-mod-init)，传递你的代码所在模块名。

   为了本次教程目的，使用 `example.com/hello` 作为模块路径。
   ```
    $ go mod init example.com/hello
    go: creating new go.mod: module example.com/hello
   ```
3. 在你的文本编辑器中，在 `hello` 目录下创建一个文件 `hello.go` 以供编写你的代码
4. 编写你的代码以调用 `Hello` 函数，然后打印函数返回值

   为了实现这个，将下面的代码黏贴进 `hello.go`。
   ```
   package main

   import (
    "fmt"

    "example.com/greetings"
   )

   func main() {
      // Get a greeting message and print it.
      message := greetings.Hello("Gladys")
      fmt.Println(message)
   }
   ```
   在这段代码中，你：

   - 声明了一个 `main` 包。在 Go 中，作为应用运行的代码必须位于一个 `main` 包中。
   - 导入了两个包：`example.com/greetings` 和 [fmt 包](https://pkg.go.dev/fmt/)。这使得你的代码可以访问位于这些包中的函数。导入 `example.com/greetings`（包位于你早先创建的模块里）可以使你得以访问 `Hello` 函数；你也导入了 `fmt`，里面的函数可以处理输入和输出文本（例如打印文本到控制台）。
   - 通过调用 `greetings` 包里的 `Hello` 函数得到一个欢迎词。
5. 编辑 `example.com/hello` 模块以使用本地模块 `example.com/greetings`

   为了产品使用，你将从它的代码仓库（模块路径反映了发布位置）发布 example.com/greetings 模块，这里 Go 工具可以找到并下载它。对当前来说，我们还没有发布模块，你需要调整 example.com/hello 模块，如此它能够从你的本地文件系统上找到 example.com/greetings 代码。

   为了这个，使用[go mod edit 命令](https://go.dev/ref/mod#go-mod-edit)来编辑 example.com/hello 模块以重定向 Go 工具从它的模块路径（这里模块不在此）至本地文件系统（目标模块位于此处）。

   1. 从位于 `hello` 目录下的命令行提示符，运行下面的命令：
      ```
      $ go mod edit -replace example.com/greetings=../greetings
      ```
      基于定位模块目的，命令指定 `example.com/greetings` 应被 `../greetings` 替换。当你运行命令后，`hello` 目录中的 `go.mod` 文件应该包含一个 [replace 指令](https://go.dev/doc/modules/gomod-ref#replace)。

      ```
      module example.com/hello

      go 1.16

      replace example.com/greetings => ../greetings
      ```
   2. 从位于 `hello` 目录下的命令行提示符，运行 [go mod tidy 命令](https://go.dev/ref/mod#go-mod-tidy) 同步 `example.com/hello` 模块的依赖，添加如下代码所需的，但当前却未被模块追踪的。

      ```
      $ go mod tidy
      go: found example.com/greetings in example.com/greetings v0.0.0-00010101000000-000000000000
      ```

      命令结束后，`example.com/hello` 模块的 `go.mod` 文件应该看起来像这样：
      ```
      module example.com/hello

      go 1.16

      replace example.com/greetings => ../greetings

      require example.com/greetings v0.0.0-00010101000000-000000000000
      ```

      命令发现了位于 `greetings` 目录的本地代码，然后添加了一条 [require指令](https://go.dev/doc/modules/gomod-ref#require) 指定 `example.com/hello` 需要 `example.com/greetings`。当你在 `hello.go` 中导入 `greetings` 包时你创建了这个依赖。

      紧随模块路径的数字是虚拟版本号--一个产生的数字用于替代语义版本号（当前模块还没有它）。

      为了引用一个发布的模块，`go.mod` 文件典型地不会有 `replace` 指令，而是在最后使用 `require` 指令指定一个打包版本号。

      ```
      require example.com/greetings v1.1.0
      ```

      更多版本号信息，请参见[模块版本号](https://go.dev/doc/modules/version-numbers)。
6. 在 `hello` 目录下，从命令行提示中运行你的代码已验证它能够工作。
   ```
   $ go run .
   Hi, Gladys. Welcome!
   ```
   
   祝贺你！你已经创建了两个可以工作的模块了。

## 3. 返回及处理错误

1. 在 `greetings/greetings.go`， 添加下面高亮部分代码。

   如果你不知道要欢迎谁，发送一个欢迎词回来没有任何意义。当名字为空时，向调用方返回一个错误。拷贝下面的的代码至 `greetings.go`，并保存文件。

   ```
    package greetings

    import (
        "errors"
        "fmt"
    )

    // Hello returns a greeting for the named person.
    func Hello(name string) (string, error) {
        // If no name was given, return an error with a message.
        if name == "" {
            return "", errors.New("empty name")
        }

        // If a name was received, return a value that embeds the name
        // in a greeting message.
        message := fmt.Sprintf("Hi, %v. Welcome!", name)
        return message, nil
    }
   ```

   在这段代码，你：

   - 改变函数让其返回两个值：一个 `string` 和一个 `error`。你的调用方将检查第二个值以判断是否有错误发生（任何 Go 函数可以返回多个值。跟多信息，请参考[Effective Go](https://go.dev/doc/effective_go.html#multiple-returns)）。
   - 导入 Go 标准库 `errors` 包，如此你可以使用它的 [errors.New 函数](https://pkg.go.dev/errors/#example-New)。
   - 添加一个 `if` 语句来检查请求有效性（名字为空字符串），如果请求无效就返回一个错误。`errors.New` 函数返回一个 `error` 并携带你的错误消息。
   - 当成功返回时，添加一个 `nil`(意思是没有错误) 作为第二个返回值。这种方式下，调用方能够知道函数成功了。


2. 在你的 `hello/hello.go` 中，处理现在由 `Hello` 函数返回的错误，以及非错误值。

   将下面代码粘贴进 `hello.go`：

   ```
    package main

    import (
        "fmt"
        "log"

        "example.com/greetings"
    )

    func main() {
        // Set properties of the predefined Logger, including
        // the log entry prefix and a flag to disable printing
        // the time, source file, and line number.
        log.SetPrefix("greetings: ")
        log.SetFlags(0)

        // Request a greeting message.
        message, err := greetings.Hello("")
        // If an error was returned, print it to the console and
        // exit the program.
        if err != nil {
            log.Fatal(err)
        }

        // If no error was returned, print the returned message
        // to the console.
        fmt.Println(message)
    }
   ```

   在这段代码，你：

   - 配置 [log 包](https://pkg.go.dev/log/) 以在日志消息开头打印命令名（"greetings: "），不打印时间戳和文件信息。
   - 将 `Hello` 返回的两个值都赋值给变量。
   - 将 `Hello` 参数从 `Gladys` 名变成一个空字符串，如此你可以实验你的错误处理代码。
   - 检查一个非 `nil` 错误值，继续这种场景没有任何意义。
   - 使用标准库 `log` 包里的函数输出错误信息。如果你得到一个错误，你使用 `log` 包的 [Fatal 函数](https://pkg.go.dev/log?tab=doc#Fatal) 来打印错误并停止系统。
   
3. 在 `hello` 目录中，从命令行运行 `hello.go` 来确认代码正常工作。

   现在你传递了一个空名字，你见得到一个错误：
   ```
   $ go run .
   greetings: empty name
   exit status 1
   ```

这是 Go 中常见错误处理：返回一个 `error` 值，调用方可以检查它。

## 4. 返回一个随机欢迎值

为了实现这个，你将使用 Go 切片。一个切片像一个数组，除了当你向其添加元素或者移除元素时其大小会动态改变。切片是 Go 最有用的类型之一。

你将加入一个小型切片以容纳三条欢迎词，然后你的代码将随机返回其中一条。关于切片的更多信息，在 Go 博客上参见 [Go slices](https://blog.golang.org/slices-intro)。

1. 在 `greetings/greetings.go` 中，修改你的代码让其看起来像如下这样：

   ```
    package greetings

    import (
        "errors"
        "fmt"
        "math/rand"
        "time"
    )

    // Hello returns a greeting for the named person.
    func Hello(name string) (string, error) {
        // If no name was given, return an error with a message.
        if name == "" {
            return name, errors.New("empty name")
        }
        // Create a message using a random format.
        message := fmt.Sprintf(randomFormat(), name)
        return message, nil
    }

    // init sets initial values for variables used in the function.
    func init() {
        rand.Seed(time.Now().UnixNano())
    }

    // randomFormat returns one of a set of greeting messages. The returned
    // message is selected at random.
    func randomFormat() string {
        // A slice of message formats.
        formats := []string{
            "Hi, %v. Welcome!",
            "Great to see you, %v!",
            "Hail, %v! Well met!",
        }

        // Return a randomly selected message format by specifying
        // a random index for the slice of formats.
        return formats[rand.Intn(len(formats))]
    }
   ```

   在这段代码，你：

   - 添加一个 `randomFormat` 函数为欢迎消息随机选择一个格式。注意 `randomFormat` 以小写字母开头，使它只能从其包所在代码中访问。
   - 在 `randomFormat` 中，声明了一个 `formats` 切片，初始化为三个消息格式。当生命一个切片时，你并不需要在括号中指定其大小，如 `[]string` 所示。它告诉　Go 切片底层数组的大小可被动态改变。
   - 使用 [math/rand 包](https://pkg.go.dev/math/rand/)来为从切片中选择一条格式产生下标。
   - 加入 `init` 函数以当前时间作为 `rand` 包的种子。Go 在应用启动时在全局变量初始化之后自动运行 `init` 函数。关于 `init` 函数的更多信息，请参见 [Effective Go](https://go.dev/doc/effective_go.html#init)。
   - 在 `Hello` 中，使用 `randomFormat` 函数来为返回的消息得到一个格式，然后利用这个格式和 `name` 值一起来创建这条消息。
   - 想你以前做的一样返回这条消息（或者错误）

2. 在 `hello/hello.go` 中，修改代码如下所示：
   
   你添加了 `Glady` 的名字（如果你喜欢，可以添加别的名字）作为 `hello.go` 中 `Hello` 函数调用的参数，

    ```
    package main

    import (
        "fmt"
        "log"

        "example.com/greetings"
    )

    func main() {
        // Set properties of the predefined Logger, including
        // the log entry prefix and a flag to disable printing
        // the time, source file, and line number.
        log.SetPrefix("greetings: ")
        log.SetFlags(0)

        // Request a greeting message.
        message, err := greetings.Hello("Gladys")
        // If an error was returned, print it to the console and
        // exit the program.
        if err != nil {
            log.Fatal(err)
        }

        // If no error was returned, print the returned message
        // to the console.
        fmt.Println(message)
    }
   ```
3. 在 `hello` 目录中，从命令行运行 `hello.go` 来确认代码正常工作。运行它多次，注意到欢迎词改变了。

   ```
   $ go run .
   Great to see you, Gladys!

   $ go run .
   Hi, Gladys. Welcome!

   $ go run .
   Hail, Gladys! Well met!
   ```

下一步，你将使用一个切片来欢迎多个人。

## 5. 为多人返回欢迎值

接下来在对你的模块代码最新修改中，你会添加支持在一个请求中返回多个欢迎词。换句话说，你将处理多个值的输入，然后对输入输出都做成键值对的形式。为了实现这个，你需要把一个名字集传递给函数并为每一个名字返回一个换用词。

但这里有个小问题。将 `Hello` 函数的参数从一个名字赣成一个名字集将改变函数的签名。如果你已经发布了 `example.com/greeting` 模块，并且客户已经编写代码调用了 `Hello`，这种修改将破坏他们的程序。

在这种情况下，一种更好的选择是新写一个不同名的函数。新的函数将接受多个参数，这将保持与就函数的兼容性。

1. 在 `greetings/greetings.go` 中，修改你的代码让其看起来像如下这样：

   ```
    package greetings

    import (
        "errors"
        "fmt"
        "math/rand"
        "time"
    )

    // Hello returns a greeting for the named person.
    func Hello(name string) (string, error) {
        // If no name was given, return an error with a message.
        if name == "" {
            return name, errors.New("empty name")
        }
        // Create a message using a random format.
        message := fmt.Sprintf(randomFormat(), name)
        return message, nil
    }

    // Hellos returns a map that associates each of the named people
    // with a greeting message.
    func Hellos(names []string) (map[string]string, error) {
        // A map to associate names with messages.
        messages := make(map[string]string)
        // Loop through the received slice of names, calling
        // the Hello function to get a message for each name.
        for _, name := range names {
            message, err := Hello(name)
            if err != nil {
                return nil, err
            }
            // In the map, associate the retrieved message with
            // the name.
            messages[name] = message
        }
        return messages, nil
    }

    // Init sets initial values for variables used in the function.
    func init() {
        rand.Seed(time.Now().UnixNano())
    }

    // randomFormat returns one of a set of greeting messages. The returned
    // message is selected at random.
    func randomFormat() string {
        // A slice of message formats.
        formats := []string{
            "Hi, %v. Welcome!",
            "Great to see you, %v!",
            "Hail, %v! Well met!",
        }

        // Return one of the message formats selected at random.
        return formats[rand.Intn(len(formats))]
    }
   ```

   在这段代码，你：

   - 添加一个 `Hellos` 函数，它的参数为一个名字的切片而非一个单一名字。同时，你修改了其返回值从一个字符串到一个映射（map）。如此你可以返回一个名字到欢迎词的映射。
   - 让 `Hellos` 调用已经存在的 `Hello` 函数，这帮助减少了重复，我们还让两个函数各司其职。
   - 创建一个 `messages` 映射，其键为每个收到的名字，值为一条欢迎消息。在 Go 中，你用 `make(map[key-type]value-type)` 初始化一个映射。现在 `Hellos` 可以返回这个映射。关于更多关于映射的知识，请参见 Go 博客中的 [Go maps in action](https://blog.golang.org/maps)。
   - 迭代你的函数收到的 `names`，检查每个是否由非空值，并未欸个名字关联一条消息。在这个 for 循环中，`range` 返回两个值：当前项的索引，以及一个当前值的拷贝。你并不需要这个索引，因此你使用 Go 空标识符（一个下划线）来忽略它。更多信息，请参见 [Effective Go](https://go.dev/doc/effective_go.html) 中的 [The blank identifier](https://go.dev/doc/effective_go.html#blank)

2. 在你的 `hello/hello.go` 调用代码中，传递一个名字切片，打印你得到的名字消息映射。
   
   修改你的 `hello.go` 代码如下所示：

    ```
    package main

    import (
        "fmt"
        "log"

        "example.com/greetings"
    )

    func main() {
        // Set properties of the predefined Logger, including
        // the log entry prefix and a flag to disable printing
        // the time, source file, and line number.
        log.SetPrefix("greetings: ")
        log.SetFlags(0)

        // A slice of names.
        names := []string{"Gladys", "Samantha", "Darrin"}

        // Request greeting messages for the names.
        messages, err := greetings.Hellos(names)
        if err != nil {
            log.Fatal(err)
        }
        // If no error was returned, print the returned map of
        // messages to the console.
        fmt.Println(messages)
    }
   ```

   在这些修改里，你：

   - 创建了一个切片类型的变量 `names` 来容纳三个名字
   - 传递 `names` 变量给 `Hellos` 函数作为参数
3. 在命令行切换到包含 `hello/hello.go` 的目录，然后使用 `go run` 来确认代码能够工作。

   输出包括一个名字与欢迎词的关联的映射的字符串表示，如下所示：

   ```
   $ go run .
   map[Darrin:Hail, Darrin! Well met! Gladys:Hi, Gladys. Welcome! Samantha:Hail, Samantha! Well met!]
   ```

本主题介绍了代表名值队的映射；它还介绍了为一个模块新的或变化的功能实现一个新函数从而保持后向兼容的思想。关于后向兼容的更多内容，请参看[保持你的模块后向兼容](https://blog.golang.org/module-compatibility)。

## 6. 添加测试

现在你的代码已经稳定下来（顺便说一句，做得好），添加一个测试。在开发阶段测试你的代码可以在你修改代码时发现里面的问题。在这个教程，你将为 `Hello` 函数添加测试。

Go 对单元测试的内在支持使得你测试 Go 变得容易。特别是，使用命名规范，基于 Go 的 `testing` 包和 `go test` 命令，你可以快速编写和执行测试。

1. 在 `greetings` 目录，创建名为 `greetings_test.go` 的文件。

   文件名以 `_test.go` 结尾告诉 `go test` 命令这个文件包含测试函数。

2. 在 `greetings_test.go` 中，粘贴下面的内容并保存文件。

   ```
    package greetings

    import (
        "testing"
        "regexp"
    )

    // TestHelloName calls greetings.Hello with a name, checking
    // for a valid return value.
    func TestHelloName(t *testing.T) {
        name := "Gladys"
        want := regexp.MustCompile(`\b`+name+`\b`)
        msg, err := Hello("Gladys")
        if !want.MatchString(msg) || err != nil {
            t.Fatalf(`Hello("Gladys") = %q, %v, want match for %#q, nil`, msg, err, want)
        }
    }

    // TestHelloEmpty calls greetings.Hello with an empty string,
    // checking for an error.
    func TestHelloEmpty(t *testing.T) {
        msg, err := Hello("")
        if msg != "" || err == nil {
            t.Fatalf(`Hello("") = %q, %v, want "", error`, msg, err)
        }
    }
   ```

   在这段代码，你：

   - 在与你的代码的同一个包中，实现了测试功能。
   - 创建了两个测试函数以测试 `greetings.Hello` 函数。测试函数名有下面的形式 `TestName`，这里 `Name` 是指有关特定测试的一些特质。同时，测试函数接受一个 `testing` 包的 [testing.T类型](https://pkg.go.dev/testing/#T指针作为参数)。你是用这个参数的方法从你的测试中汇报及记录。
   - 实现了两个侧式：

     + `TestHelloName` 调用了 `Hello` 函数，传递一个 `name` 值；函数据此应该返回一个有效地回复消息。如果函数返回一个错误或者一条不期待的回复消息（没有包含你传递进去的名字），你就可以使用 `t` 参数的 [Fatalf 方法](https://pkg.go.dev/testing/#T.Fatalf) 来在终端打印消息并终止执行。
     + `TestHelloEmpty` 以一个空值测试 `Hello` 函数，这个测试是为了确认那你的错误处理正常工作。如果调用返回一个非空字符串或者没有错误，你使用 `t` 参数的 `Fatalf` 方法来在终端打印消息并终止执行。

2. 在你的 `hello/hello.go` 调用代码中，传递一个名字切片，打印你得到的名字消息映射。
   
   修改你的 `hello.go` 代码如下所示：

    ```
    package main

    import (
        "fmt"
        "log"

        "example.com/greetings"
    )

    func main() {
        // Set properties of the predefined Logger, including
        // the log entry prefix and a flag to disable printing
        // the time, source file, and line number.
        log.SetPrefix("greetings: ")
        log.SetFlags(0)

        // A slice of names.
        names := []string{"Gladys", "Samantha", "Darrin"}

        // Request greeting messages for the names.
        messages, err := greetings.Hellos(names)
        if err != nil {
            log.Fatal(err)
        }
        // If no error was returned, print the returned map of
        // messages to the console.
        fmt.Println(messages)
    }
   ```

   在这些修改里，你：

   - 创建了一个切片类型的变量 `names` 来容纳三个名字
   - 传递 `names` 变量给 `Hellos` 函数作为参数
3. 在命令行切换到包含 `hello/hello.go` 的目录，然后使用 `go run` 来确认代码能够工作。

   输出包括一个名字与欢迎词的关联的映射的字符串表示，如下所示：

   ```
   $ go run .
   map[Darrin:Hail, Darrin! Well met! Gladys:Hi, Gladys. Welcome! Samantha:Hail, Samantha! Well met!]
   ```

## 7. 编译和安装应用

## Appendix. 结论

在本教程中，你编写函数并打包进两个模块：一个包含发送欢迎词的逻辑；另一个作为第一个的消费者。

关于在你的代码中管理以来的更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。关于更多为他人使用开发模块的信息，请参见[开发及发布模块](https://go.dev/doc/modules/developing)。

关于更多 Go 语言特性，请参见 [Go 教程](https://go.dev/tour/)。

## Reference

- [Create a Go module](https://go.dev/doc/tutorial/create-module)
- [开发及发布模块](https://go.dev/doc/modules/developing)
- [Go Modules Reference](https://go.dev/ref/mod#go-mod-init)
- [管理依赖](https://go.dev/doc/modules/managing-dependencies#naming_module)
- [模块版本号](https://go.dev/doc/modules/version-numbers)
- [Effective Go](https://go.dev/doc/effective_go.html)
- [保持你的模块后向兼容](https://blog.golang.org/module-compatibility)