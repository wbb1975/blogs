## 第6章 函数
### 什么是函数
函数是执行特定任务的代码块。一个函数接受输入，在输入上执行某些计算，并产生输出。
### 函数声明
Go 中生命一个函数的语法为：
```
func functionname(parametername type) returntype {  
 //function body
}
```
函数中输入参数和返回值是可选的，因此下面的于法也是有效的函数声明：
```
func functionname() {  
}
```
### 多返回值
从一个函数返回多个值是可能的。
```
package main

import (  
    "fmt"
)

func rectProps(length, width float64)(float64, float64) {  
    var area = length * width
    var perimeter = (length + width) * 2
    return area, perimeter
}

func main() {  
     area, perimeter := rectProps(10.8, 5.6)
    fmt.Printf("Area %f Perimeter %f", area, perimeter) 
}
```
如果一个函数返回多个返回值，它们必须在 `(` 和 `)` 之中指定。`func rectProps(length, width float64)(float64, float64)` 拥有两个 `float64` 类型参数 `length` 和 `width` 并返回两个 `float64` 值。上面的程序输出：
```
Area 60.480000 Perimeter 32.800000  
```
### 命名返回值
也可以从一个函数返回命名值。如果一个返回值是命名的，它可被视为在函数的第一行被声明为变量。

上面的 rectProps 可以利用命名返回值重写如下：
```
func rectProps(length, width float64)(area, perimeter float64) {  
    area = length * width
    perimeter = (length + width) * 2
    return //no explicit return value
}
```
在上面的函数中 `area` 和 `perimeter` 是命名返回值。注意上面的返回语句明友显式返回任何值。因为 `area` 和 `perimeter` 在函数声明中被指定为返回值，当遇到一个返回语句时，它们被自动从函数返回。
### 空标识符（Blank Identifier）
Go 语言中 `_` 以空标识符为大家所知。它可以用于替换任何类型的任何值。让我们来看看空标识符的使用。

`rectProps` 函数返回一个矩形的面积和周长。如果我们仅仅想要 `面积area` 而丢弃 `周长perimeter`，这就是 `_` 发挥作用的地方。

下面的程序仅仅使用了从 `rectProps` 函数返回的 `area` 值：
```
package main

import (  
    "fmt"
)

func rectProps(length, width float64) (float64, float64) {  
    var area = length * width
    var perimeter = (length + width) * 2
    return area, perimeter
}
func main() {  
    area, _ := rectProps(10.8, 5.6) // perimeter is discarded
    fmt.Printf("Area %f ", area)
}
```
在第 13 行我们仅仅利用了 `area`，`_` 标识符用于丢弃 `perimeter`。
## 第7章 包
### 什么是包，为什么要用到它们
到目前为止，我们看到的 Go 程序仅仅为带有main[函数](https://golangbot.com/functions/)以及一些其它函数的的单一文件。在现实世界的场景中，将所有代码写在一个单一文件中是不可扩展的。这种方式下的代码不可复用，页很难维护。这就是包可以提供帮助的地方。

**包用于组织代码使其更具可重用性和可读性。包是驻留于一个目录下的所有 Go 源代码的集合。包提供代码隔离机制，因此使得维护 Go 项目更容易**。

例如，假如我们正在用 Go 编写一个金融应用，某些功能是单利利率计算，复利计算以及借贷计算。组织应用的一个简单方法是按照功能。我么可以创建包 simpleinterest，ompoundinterest 和 loan。如果 loan 需要计算单利，它可以仅仅简单地导入 simpleinterest 包。这种方式下代码容易复用。

我们将通过常见简单的应用来学习模块，该应用基于本金（principal），利率以及以年计的时期来计算单利。
### main 函数和 main 包
每个可执行的 Go 应用必须包含主函数，这个函数是执行入口点。主函数应该驻留于 `main` 包内。

**`package packagename` 指定了一个源代码文件术语包 `packagename`。这应该是每个 Go 源代码文件的第一行**。

让我们开始为我们的应用创建主函数和 `main` 包。

在当前用户的 `Documents` 目录下以下面的命令创建 `learnpackage` 目录：
```
mkdir ~/Documents/learnpackage/  
```
在我们的 learnpackage 目录下创建一个文件名为 main.go 并输入下面的内容：
```
package main 

import "fmt"

func main() {  
    fmt.Println("Simple interest calculation")
}
```
`package main` 所在行代码指定了该文件术语 `main` 包。`import "packagename"` 语句用于导入已经存在的包。`packagename.FunctionName()` 是调用一个包里的函数的语法。

在第3行，我们倒入了 `fmt` 包以使用 `Println` 函数。`fmt` 是一个标准库，它作为 Go 标准库的一部分总是可用。接下来是主函数打印 `Simple interest calculation`。

进入 `learnpackage` 目录并编译上面的程序：
```
cd ~/Documents/learnpackage/  
```
并输入下买你的命令：
```
go install    
```
如果一切正常，我们的可执行程序将被编译出来并可执行。在终端上输入命令 `learnpackage` 你将看到下面的输出：
```
Simple interest calculation
```
如果你不能理解 `go install` 如何工作或者你看到下面的错误：
```
go install: no install location for directory /home/naveen/Documents/learnpackage outside GOPATH  
For more details see: 'go help gopath' 
```
请访问https://golangbot.com/hello-world-gomod/以了解更多。
### Go 模块（Module）
我们将以这样的方式结构化代码：所有与单利相关的功能放置在 `simpleinterest` 包里。为了实现这个我们需要创建一个自定义包 `simpleinterest`，里面包含计算单利所需功能。在创建自定义包之前，我们需要首先理解 [Go 模块](https://golangbot.com/books/)，因为 Go 模块是创建自定义模块所需要的。

 **一个 Go 模块就是一个 Go 包的集合**。现在你可能会问，为什么我们需要模块以创建自定义包？答案是我们创建的自定义包的导入路径来自于包模块的名字。除此之外，我们的应用会用的所有其它第三方包（比如从github来的源代码）及其版本都会记录在 `go.mod` 文件里。当我们创建一个新的模块时 `go.mod` 就会被创建。在后面的章节里你将体会到更多。

在我们的脑海中可能会浮现另一个问题。到现在为止我们未创建[Go 模块](https://golangbot.com/books/)我们是怎样开始的？答案是在我们的教程系列直到现在我们从未自定义包，因此并不需要 Go 模块。

理论已经讲够了。让我们进入行动，创建我们自己的 Go 模块和自定义包。
### 创建一个 Go 模块
确保你在 `learnpackage` 目录下，`cd ~/Documents/learnpackage/`。在该目录下运行下面的命令以创建名为 `learnpackage` 的 Go 模块。
```
go mod init learnpackage
```
上面的命令将创建一个名为 `go.mod` 的文件，文件内容如下：
```
module learnpackage

go 1.13
```
行 `module learnpackage` 指定了模块的名字为 `learnpackage`。正如我们之前提到的，`learnpackage` 是导入该模块内任意包的基础路径。行 `go 1.13` 指示模块中的文件使用 Go 版本 `1.13`。
### 创建单利自定义包
**属于一个包的源文件应该放在它们自己的单独的目录里。Go 里的一个管理即为包名与目录名相同。**

让我们在 `learnpackage` 目录里创建 `simpleinterest` 目录，`mkdir simpleinterest` 可为我们创建它。

在 `simpleinterest` 里的所有文件都应该以 `package simpleinterest` 开始，原因在于它们都属于 `simpleinterest` 包。

在 `simpleinterest` 目录下创建文件 `simpleinterest.go`。

下面是我们的应用的目录结构：
```
├── learnpackage
│   ├── go.mod
│   ├── main.go
│   └── simpleinterest
│       └── simpleinterest.go
```
加入下面的代码到 simpleinterest.go：
```
package simpleinterest

//Calculate calculates and returns the simple interest for a principal p, rate of interest r for time duration t years
func Calculate(p float64, r float64, t float64) float64 {  
    interest := p * (r / 100) * t
    return interest
}
```
在上面的代码中，我们已经创建了函数 `Calculate`，它计算并返回单利。函数不解自明。

注意函数 `Calculate` 以大写字母开头。这是很关键的，我们稍后将简单解释为什么需要这样。
### 导入自定义包
为了使用自定义包，我们必须首先导入它。导入路径是模块名加上包的子目录名以及包名。在我们的例子中，模块名为 `learnpackage`，包 `simpleinterest` 在 `learnpackage` 目录下的 simpleinterest 子目录里：
```
├── learnpackage
│   └── simpleinterest
```
因此行 `import "learnpackage/simpleinterest"` 将导入 `simpleinterest` 包。

如果我们拥有目录结构如下：
```
learnpackage  
│   └── finance
│       └── simpleinterest 
```
那么导入语句应该是:
```
import "learnpackage/finance/simpleinterest"
```
将下面的代码加入到 `main.go`：
```
package main

import (  
    "fmt"
    "learnpackage/simpleinterest"
)

func main() {  
    fmt.Println("Simple interest calculation")
    p := 5000.0
    r := 10.0
    t := 1.0
    si := simpleinterest.Calculate(p, r, t)
    fmt.Println("Simple interest is", si)
}
```
上面的代码导入 `simpleinterest` 包，并使用 `Calculate` 计算了单利。标准库中的包并不需要模块名前缀，因此 “fmt” 没有模块名前缀也能工作。当程序运行时，输出如下：
```
Simple interest calculation  
Simple interest is 500  
```
### 关于 go install 更多信息
现在我们理解了包如何工作的，现在是时候讲讲多一点关于 `go install` 的知识了。Go 工具如 `go install` 在当前目录的上下文中工作。让我们来理解这意味着什么。到现在为止我们从目录 `~/Documents/learnpackage/` 下运行 `go install`，如果我们试着从其它目录下运行它，它将会失败。

试着进入 `cd ~/Documents/`，并运行 `go install learnpackage`，它将失败并报告以下错误：
```
can't load package: package learnpackage: cannot find package "learnpackage" in any of:  
    /usr/local/Cellar/go/1.13.7/libexec/src/learnpackage (from $GOROOT)
    /Users/nramanathan/go/src/learnpackage (from $GOPATH)
```
让我们来理解错误背后的原因。`go install` 可以接受一个可选的包名作为参数（在我们的例子中包名为 `learnpackage`）。如果包在当前目录存在，或者在当前目录的父目录，甚至父目录的父目录里存在等等，它将努力编译主函数。

我们在 `Documents` 目录，那里没有 `go.mod` 文件，因此 `go install` 抱怨它不能找到 `learnpackage` 包。

当我们换到 `~/Documents/learnpackage/`，那里有一个 go.mod 文件，我们的模块名 `learnpackage` 就在 `go.mod` 里。

因此 `go install learnpackage` 可以在 `~/Documents/learnpackage/` 目录里工作。

到现在为止我们一直在使用 `go install`，我们也未指定包名。如果包名未指定，`go install` 默认将会使用当前目录的模块名。这就是我们从 `~/Documents/learnpackage/` 目录下不指定包名运行 `go install` 能够工作的原因。因此从 `~/Documents/learnpackage`/ 下运行以下 3 个命令功效是相同的：
```
go install

go install .

go install learnpackage  
```
我曾经提到过 `go install` 拥有在父目录里递归寻找 `go.mod` 文件的能力，让我们检验它是否能够工作：
```
cd ~/Documents/learnpackage/simpleinterest/  
```
上面的命令将把我们带到 `simpleinterest` 目录，从该目录下运行：
```
go install learnpackage  
```
`Go install` 成功地在父目录 learnpackage 里找到了一个 `go.mod` 文件， 那里定义了一个模块 `learnpackage`，因此可以工作。
### 导出名字
我们在单利包中将函数 `Calculate` 首字母大写，这在 Go 中有特殊的意义。在 Go 中任何以大写字母开头的[变量](https://golangbot.com/variables/)和函数都是导出的名字。只有导出的函数和变量才能从其它包中访问。在我们的例子中，我们想从 `main` 包中访问 `Calculate` 函数，因此它的首字母必须大写。

如果在 `simpleinterest.go` 中函数名从 `Calculate` 变为 `calculate`，然后我们从 `main.go` 中使用 `simpleinterest.calculate(p, r, t)` 调用函数，编译器将会报错：
```
# learnpackage
./main.go:13:8: cannot refer to unexported name simpleinterest.calculate
./main.go:13:8: undefined: simpleinterest.calculate
```
因此如果你期待从包外访问函数，他的首字母应该大写。
### init 函数
Go 中的每个包可以包含一个 `init` 函数。`init` 函数不应该拥有任何返回类型，也不能拥有任何参数。`init` 函数不能从我们的代码中显式调用。它在包初始化时自动调用。`init` 函数拥有下面的语法：
```
func init() {  
}
```
`init` 函数可被用于执行初始化任务，也可被用于在执行开始前验证程序正确性。

一个包的初始化顺序如下：
1. 包级别的变量首先初始化
2. 接下来 `init` 函数被调用。一个包可以拥有多个 `init` 函数（或者在单个文件或分布于多个文件）。它们以被呈献给编译器的顺序被调用。

如果一个包导入了其它包，被导入的包首先初始化。

一个包即使被多个吧哦导入，它也仅仅初始化一次。

让我们对我们的应用稍作修改以理解 `init` 函数。

让我们将 init 函数添加到simpleinterest.go 文件中：
```
package simpleinterest

import "fmt"

/*
 * init function added
 */
func init() {  
    fmt.Println("Simple interest package initialized")
}
//Calculate calculates and returns the simple interest for principal p, rate of interest r for time duration t years
func Calculate(p float64, r float64, t float64) float64 {  
    interest := p * (r / 100) * t
    return interest
}
```
我们已经添加了一个简单的 `init` 函数，它仅仅打印 `Simple interest package initialised`。

现在让我们来修改 `main` 包。我们知道在计算单利时利息的本金和利率以及时间跨度必须是大于0。我们将在 `main.go` 文件中利用 `init` 函数及包级别变量来定义这种检查。

修改 main.go 如下：
```
package main 

import (  
    "fmt"
    "learnpackage/simpleinterest" //importing custom package
    "log"
)
var p, r, t = 5000.0, 10.0, 1.0

/*
* init function to check if p, r and t are greater than zero
 */
func init() {  
    println("Main package initialized")
    if p < 0 {
        log.Fatal("Principal is less than zero")
    }
    if r < 0 {
        log.Fatal("Rate of interest is less than zero")
    }
    if t < 0 {
        log.Fatal("Duration is less than zero")
    }
}

func main() {  
    fmt.Println("Simple interest calculation")
    si := simpleinterest.Calculate(p, r, t)
    fmt.Println("Simple interest is", si)
}
```
下面总结了对 `main.go` 的修改：
1. 变量 `p, r 和 t` 从 `main` 函数级别移至包级别
2. 一个 `init` 函数被加入。如果本金，利率以及时间跨度小于0，`init` 函数将使用**log.Fatal**打印一条消息并终止函数执行。

现在的初始化顺序如下：
1. 导入包首先初始化。因此 `simpleinterest` 包首先初始化，其 `init` 函数被调用
2. 接下来包级别变量  p, r 和 t 被初始化
3. `main` 包中的 `init` 函数被调用
4. `main` 函数被调用

如果你运行程序你将会得到下面的输出：
```
Simple interest package initialized  
Main package initialized  
Simple interest calculation  
Simple interest is 500  
```
和期待的一样 simpleinterest 包的 `init` 函数首先被调用，然后是包级别变量 p, r 和 t 的初始化。`main` 包中的 `init` 函数然后被调用，它检查 p, r 和 t 是否小于 0，如果是则终止程序。我们将在单独的[教程](https://golangbot.com/if-statement/)里深入学习 `if` 语句。现在你可以假设 `if p < 0` 将检查 `p` 是否小于 0，如果是，程序就爱那个会被终止。我们为 `r` 和 `t` 便写了同样的检查。在这个例子中，所有的条件都不满足，最终，`main` 函数被调用。

让我们稍加修改程序来学习 `init` 函数的使用。在 `main.go` 中将下面的行
```
var p, r, t = 5000.0, 10.0, 1.0  
```
修改为：
```
var p, r, t = -5000.0, 10.0, 1.0  
```
即我们将 p` 初始化为负数。现在你运行程序你将会看到：
```
Simple interest package initialized  
Main package initialized  
2020/02/15 21:25:12 Principal is less than zero   
```
`p` 是负数。因此当 `init` 函数运行时，程序打印 `Principal is less than zero` 然后退出。
### 空标识符使用
在 Go 中导入一个包却从不使用它时非法的。如果你这么做，编译器将会抱怨。如此做的原因是避免未使用的包的膨胀而导致编译时间急剧增加。在 `main.go` 将代码替换如下：
```
package main

import (  
    "learnpackage/simpleinterest"
)

func main() {

}
```
上面的程序将打印错误：
```
# go build main.go
./main.go:4:2: imported and not used: "learnpackage/simpleinterest"
```
但是在应用开发的活跃阶段导入包而当前未使用是很常见的，这种情况下空标识符（_）可以帮助我们。

上面程序的错误可以通过下面的代码来缓解：
```
package main

import (  
        "learnpackage/simpleinterest"
)

var _ = simpleinterest.Calculate

func main() {

}
```
代码行 `var _ = simpleinterest.Calculate` 使得错误消失。我们应高追中这种类型的“错误静默器”，并在我们程序开发的后期将不再使用的包移除。也因推荐在导入语句后开启包级别“错误静默器”。

有时候我们导入包却从未使用过其包内函数和变量，仅仅是为确保了初始化发生。例如，我们仅仅需要确保 `simpleinterest` 包的 `init` 函数被调用，虽然我们并没有在我们的代码中使用该包的计划。_空标识符在这种情况下也是可用的：
```
package main

import (  
    _ "learnpackage/simpleinterest"
)

func main() {

}
```
运行上面的程序将会输出 `Simple interest package initialized`。我们已经成功地初始化了 `simpleinterest` 包，即使该包北为被使用。

## Reference
- [Golang tutorial series](https://golangbot.com/learn-golang-series/)
- [函数](https://golangbot.com/functions/)