# Effective Go

## 1. 引言

Go 是一门全新的语言。尽管它从既有的语言中借鉴了许多理念，但其与众不同的特性，使得使用 Go 编程在本质上就不同于其它语言。将现有的 C++ 或 Java 程序直译为 Go 程序并不能令人满意 —— 毕竟 Java 程序是用 Java 编写的，而不是 Go。 另一方面，若从 Go 的角度去分析问题，你就能编写出同样可行但大不相同的程序。 换句话说，要想将 Go 程序写得好，就必须理解其特性和风格。了解命名、格式化、 程序结构等既定规则也同样重要，这样你编写的程序才能更容易被其他程序员所理解。

本文档就如何编写清晰、地道的 Go 代码提供了一些技巧。它是对 [Go 语言规范](https://go-zh.org/ref/spec)、 [Go 语言之旅](https://learnku.com/golang/wikis/38166)以及[如何使用 Go 编程](https://learnku.com/golang/wikis/38174)的补充说明，因此我们建议您先阅读这些文档。

> 2022-01 新加：这个文档于 2009　为 Go 发布时撰写，并且自那之后历经重大修改。虽然它是理解如何使用这门语言的很好的指南，归功于语言本身的稳定性，它对库涉及很少，也不曾提及自其写成之后 Go 生态的重要改变，测试，模块以及多态。由于变化巨大，越来越多的文档，博客，枢机描述了现代 Go 语言，没有计划来更新它们。Effective Go 继续保持有用，但是读者应该理解他并不是一个完全指南。查看 [issue 28782](https://github.com/golang/go/issues/28782) 以了解上下文。

### 1.1 示例

[Go package sources](https://go.dev/src/) 不仅是核心库，同时也是学习如何使用 Go 语言的示例源码。此外，其中的一些包还包含了可独立的可执行示例，你可以直接在 [golang.org](https://golang.org/) 网站上运行它们，比如[这个例子](https://go.dev/pkg/strings/#example_Map)（如果需要，点击单词"Example"来打开）。如果你有任何关于某些问题如何解决，或某些东西如何实现的疑问， 也可以从中获取相关的答案、思路以及后台实现。

## 2. 格式化

格式化问题总是充满了争议，但却始终没有形成统一的定论。虽说人们可以适应不同的编码风格，但抛弃这种适应过程岂不更好？若所有人都遵循相同的编码风格，在这类问题上浪费的时间将会更少。 问题就在于如何实现这种设想，而无需冗长的语言风格规范。

在 Go 中我们另辟蹊径，让机器来处理大部分的格式化问题。`gofmt` 程序（也可用 `go fmt`，它以包为处理对象而非源文件）将 Go 程序按照标准风格缩进、 对齐，保留注释并在需要时重新格式化。若你想知道如何处理一些新的代码布局，请尝试运行 `gofmt`；若结果仍不尽人意，请重新组织你的程序（或提交有关 `gofmt` 的 Bug），而不必为此纠结。

举例来说，你无需花时间将结构体中的字段注释对齐，`gofmt` 将为你代劳。 假如有以下声明：

```
type T struct {
    name string // name of the object
    value int // its value
}
```

gofmt 会将它按列对齐为：

```
type T struct {
    name    string // name of the object
    value   int    // its value
}
```

标准包中所有的 Go 代码都已经用 `gofmt` 格式化过了。

还有一些关于格式化的细节，它们非常简短：

- 缩进：我们使用制表符（`tab`）缩进，`gofmt` 默认也使用它。在你认为确实有必要时再使用空格。
- 行的长度：Go 对行的长度没有限制，别担心打孔纸不够长。如果一行实在太长，也可进行折行并插入适当的 tab 缩进。
- 括号：比起 C 和 Java，Go 所需的括号更少：控制结构（if、for 和 switch）在语法上并不需要圆括号。此外，操作符优先级处理变得更加简洁，因此 `x<<8 + y<<16` 的含义就已经由空格表明了。这不像其它语言。

## 3. 代码注释

Go 语言支持 C 风格的块注释 `/* */` 和 C++ 风格的行注释 `//`。 行注释更为常用，而块注释则主要用作包的注释，当然也可在禁用一大段代码时使用。

`godoc` 既是一个程序，又是一个 Web 服务器，它对 Go 的源码进行处理，并提取包中的文档内容。出现在顶级声明之前，且与该声明之间没有空行的注释，将与该声明一起被提取出来，作为该条目的说明文档。 这些注释的类型和风格决定了 `godoc` 生成的文档质量。

每个包都应包含一段包注释，即放置在包子句前的一个块注释。对于包含多个文件的包， 包注释只需出现在其中的任一文件中即可。包注释应在整体上对该包进行介绍，并提供包的相关信息。 它将出现在 godoc 页面中的最上面，并为紧随其后的内容建立详细的文档。

```
/*
regexp 包为正则表达式实现了一个简单的库。

该库接受的正则表达式语法为：

    regexp:
        concatenation { '|' concatenation }
    concatenation:
        { closure }
    closure:
        term [ '*' | '+' | '?' ]
    term:
        '^'
        '$'
        '.'
        character
        '[' [ '^' ] character-ranges ']'
        '(' regexp ')'
*/
package regexp
```

若某个包比较简单，包注释同样可以简洁些。

```
// path 包实现了一些常用的工具，
// 以便于操作用反斜杠分隔的路径.
```

注释无需进行额外的格式化，如用星号来突出等。生成的输出甚至可能无法以等宽字体显示， 因此不要依赖于空格对齐，`godoc` 会像 `gofmt` 那样处理好这一切。 注释是不会被解析的纯文本，所以HTML和其它注解，例如_this_，将会逐字的被复制，因此不应使用它们。`godoc` 所做的调整， 就是将已缩进的文本以等宽字体显示，来适应对应的程序片段。 [fmt 包](http://golang.org/pkg/fmt/)的注释就用了这种不错的效果。

`godoc` 是否会重新格式化注释取决于上下文，因此必须确保它们看起来清晰易辨：使用正确的拼写、标点和语句结构以及折叠长行等。

在包中，任何顶级声明前面的注释都将作为该声明的文档注释。在程序中，每个可导出（首字母大写）的名称都应该有文档注释。

文档注释最好是完整的句子，这样它才能适应各种自动化的展示。 第一条语句应该为一条概括语句，并且使用被声明的名字作为开头。

```
// Compile 用于解析正则表达式并返回，如果成
// 功，则 Regexp 对象就可用于匹配所针对的文本。
func Compile(str string) (*Regexp, error) {
```

如果都是使用名字来起始一个注释，那么就可以通过 `grep` 来处理 `godoc` 的输出。设想你正在查找正规表达式的解析函数（`解析`意味着关键词为 `parse`），但是不记得名字“Compile”了，那么，你运行命令

```
go doc -all regexp | grep -i parse
```

若包中的所有文档注释都以 `This function...` 开头，`grep` 就无法帮你记住此名称。 但由于每个包的文档注释都以其名称开头，你就能看到这样的内容，它能显示你正在寻找的词语。

```
go doc -all regexp | grep -i parse
Compile parses a regular expression and returns, if successful, a Regexp
MustCompile is like Compile but panics if the expression cannot be parsed.
parsed. It simplifies safe initialization of global variables holding
$
```

Go 的声明语法允许成组声明。单个文档注释应介绍一组相关的常量或变量。 由于是整体声明，这种注释往往较为笼统。

```
// 表达式解析失败后返回错误代码
var (
    ErrInternal      = errors.New("regexp: internal error")
    ErrUnmatchedLpar = errors.New("regexp: unmatched '('")
    ErrUnmatchedRpar = errors.New("regexp: unmatched ')'")
    ...
)
```

即便是对于私有名称，也可通过成组声明来表明各项间的关系，例如某一组由互斥体保护的变量。

```
var (
    countLock   sync.Mutex
    inputCount  uint32
    outputCount uint32
    errorCount  uint32
)
```

## 4. 命名规则

正如命名在其它语言中的地位，它在 Go 中同样重要。有时它们甚至会影响语义：例如，某个名称在包外是否可见，就取决于其首个字符是否为大写字母。 因此有必要花点时间来讨论 Go 程序中的命名约定。

### 4.1 程序包名

当一个包被导入后，包名就会成了内容的访问器。在以下代码

```
import "bytes"
```

之后，被导入的包就能通过 `bytes.Buffer` 来引用了。 若所有人都以相同的名称来引用其内容将大有裨益， 这也就意味着包应当有个恰当的名称：其名称应该简洁明了而易于理解。按照惯例， 包应当以小写的单个单词来命名，且不应使用下划线或驼峰记法。`err` 的命名就是出于简短考虑的，因为任何使用该包的人都会键入该名称。 不必担心引用次序的冲突。包名就是导入时所需的唯一默认名称， 它并不需要在所有源码中保持唯一，即便在少数发生冲突的情况下， 也可为导入的包选择一个别名来局部使用。 无论如何，通过文件名来判定使用的包，都是不会产生混淆的。

另一个约定就是包名应为其源码目录的基本名称。在 `src/encoding/base64` 中的包应作为 `"encoding/base64"` 导入，其包名应为 `base64`， 而非 `encoding_base64` 或 `encodingBase64`。

包的导入者可通过包名来引用其内容，因此包中的可导出名称可以此来避免冲突。 （请勿使用 `import .` 记法，它可以简化必须在被测试包外运行的测试， 除此之外应尽量避免使用。）例如，`bufio` 包中的缓存读取器类型叫做 `Reader` 而非 `BufReader`，因为用户将它看做 `bufio.Reader`，这是个清楚而简洁的名称。 此外，由于被导入的项总是通过它们的包名来确定，因此 `bufio.Reader` 不会与 `io.Reader` 发生冲突。同样，用于创建 `ring.Ring` 的新实例的函数（这就是 Go 中的构造函数）一般会称之为 `NewRing`，但由于 `Ring` 是该包所导出的唯一类型，且该包也叫 `ring`，因此它可以只叫做 `New`，它跟在包的后面，就像 `ring.New`。使用包结构可以帮助你选择好的名称。

另一个简短的例子是 `once.Do`，`once.Do(setup)` 表述足够清晰， 使用 `once.DoOrWaitUntilDone(setup)` 完全就是画蛇添足。 长命名并不会使其更具可读性。一份有用的说明文档通常比额外的长名更有价值。

### 4.2 Get方法

Go 并不对获取器（`getter`）和设置器（`setter`）提供自动支持。 你应当自己提供获取器和设置器，通常很值得这样做，但若要将 `Get` 放到获取器的名字中，既不符合习惯，也没有必要。若你有个名为 `owner` （小写，未导出）的字段，其获取器应当名为 `Owner`（大写，可导出）而非 `GetOwner`。大写字母即为可导出的这种规定为区分方法和字段提供了便利。 若要提供设置器方法，`SetOwner` 是个不错的选择。两个命名看起来都很合理：

```
owner := obj.Owner()
if owner != user {
    obj.SetOwner(user)
}
```

### 4.3 接口名

按照约定，只包含一个方法的接口应当以该方法的名称加上 `er` 后缀来命名，如 `Reader`、`Writer`、`Formatter`、`CloseNotifier` 等。

诸如此类的命名有很多，遵循它们及其代表的函数名会让事情变得简单。`Read`、`Write`、`Close`、`Flush`、 `String` 等都具有典型的签名和意义。为避免冲突，请不要用这些名称为你的方法命名， 除非你明确知道它们的签名和意义相同。反之，若你的类型实现了的方法，与一个众所周知的类型的方法拥有相同的含义，那就使用相同的命名。 请将字符串转换方法命名为 `String` 而非 `ToString`。

### 4.4 混合大小写

最后，Go约定使用 `MixedCaps` 或者 `mixedCaps` 的形式，而不是下划线来书写多个单词的名字。

## 5. 分号

和 C 一样，Go 的正式语法使用分号来结束语句，和 C 不同的是，这些分号并不在源码中出现。 取而代之，词法分析器会使用一条简单的规则来自动插入分号，因此源码中基本就不用分号了。

规则是这样的，如果在换行之前的最后一个符号为一个标识符（包括像int和float64这样的单词），一个基本的文字，例如数字或者字符串常量，或者如下的一个符号：

```
break continue fallthrough return ++ -- ) }
```

则词法分析器总是会在符号之后插入一个分号。这可以总结为“如果换行出现在可以结束一条语句的符号之后，则插入一个分号”。

紧挨着右大括号之前的分号也可以省略掉，这样，语句：

```
 go func() { for { dst <- <-src } }()
```

就不需要分号。地道的 Go 程序只在 `for` 循环子句中使用分号，来分开初始化，条件和继续执行，这些元素。分号也用于在一行中分开多条语句，这也是你编写代码应该采用的方式。

分号插入规则所导致的一个结果是，你不能将控制结构（`if`，`for`，`switch` 或 `select`）的左大括号放在下一行。如果这样做，则会在大括号之前插入一个分号，这将会带来不是想要的效果。应该这样编写：

```
if i < f() {
    g()
}
```

而不是这样：

```
if i < f()  // wrong!
{           // wrong!
    g()
}
```

## 6. 控制结构

Go 中的结构控制与 C 有许多相似之处，但其不同之处才是独到之处。 Go 不再使用 `do` 或 `while` 循环，只有一个更通用的 `for`；`switch` 要更灵活一点；`if` 和 `switch` 像 `for` 一样可接受可选的初始化语句； 此外，还有一个包含类型选择和多路通信复用器的新控制结构：`select`。 其语法也有些许不同：没有圆括号，而其主体必须始终使用大括号括住。

### 6.1 if

Go中，简单的if看起来是这样的：

```
if x > 0 {
    return y
}
```

强制的大括号可以鼓励大家在多行中编写简单的 `if` 语句。不管怎样，这是一个好的风格，特别是当控制结构体包含了一条控制语句，例如 `return` 或者 `break`。

既然 `if` 和 `switch` 接受一个初始化语句，那么常见的方式是用来建立一个局部变量。

```
if err := file.Chmod(0664); err != nil {
    log.Print(err)
    return err
}
```

在 Go 的库中，你会发现若 if 语句不会执行到下一条语句时，亦即其执行体 以 `break`、`continue`、`goto` 或 `return` 结束时，不必要的 `else` 会被省略。

```
f, err := os.Open(name)
if err != nil {
    return err
}
codeUsing(f)
```

下例是一种常见的情况，代码必须防范一系列的错误条件。若控制流成功继续， 则说明程序已排除错误。由于出错时将以 `return` 结束， 之后的代码也就无需 `else` 了。

```
f, err := os.Open(name)
if err != nil {
    return err
}
d, err := f.Stat()
if err != nil {
    f.Close()
    return err
}
codeUsing(f, d)
```

### 6.2 重新声明和重新赋值

题外话：上一节中最后一个示例展示了短声明 `:=` 如何使用。 调用了 `os.Open` 的声明为：

```
f, err := os.Open(name)
```

该语句声明了两个变量 `f` 和 `err`。在几行之后，又通过：

```
d, err := f.Stat()
```

调用了 `f.Stat`。它看起来似乎是声明了 `d` 和 `err`。 注意，尽管两个语句中都出现了 `err`，但这种重复仍然是合法的：`err` 在第一条语句中被声明，但在第二条语句中只是被再次赋值罢了。也就是说，调用 `f.Stat` 使用的是前面已经声明的 `err`，它只是被重新赋值了而已。

在满足下列条件时，已被声明的变量 `v` 可出现在 `:=` 声明中：

- 本次声明与已声明的 `v` 处于同一作用域中（若 `v` 已在外层作用域中声明过，则此次声明会创建一个新的变量 `§`），
- 在初始化中与其类型相应的值才能赋予 `v`，且
- 在此次声明中至少另有一个变量是新声明的。

这个特性简直就是纯粹的实用主义体现，它使得我们可以很方便地只使用一个 `err` 值，例如，在一个相当长的 `if-else` 语句链中， 你会发现它用得很频繁。

`§` 值得一提的是，即便 Go 中的函数形参和返回值在词法上处于大括号之外， 但它们的作用域和该函数体仍然相同。

### 6.3 for

Go 的 for 循环类似于 C，但却不尽相同。它统一了 `for` 和 `while`，不再有 `do-while` 了。它有三种形式，但只有一种需要分号。

```
// 类似 C 语言中的 for 用法
for init; condition; post { }

// 类似 C 语言中的 while 用法
for condition { }

// 类似 C 语言中的 for(;;) 用法
for { }
```

简短声明能让我们更容易在循环中声明下标变量：

```
sum := 0
for i := 0; i < 10; i++ {
    sum += i
}
```

若你想遍历数组、切片、字符串或者映射，或从信道中读取消息， `range` 子句能够帮你轻松实现循环。

```
for key, value := range oldMap {
    newMap[key] = value
}
```

若你只需要该遍历中的第一个项（键或下标），去掉第二个就行了：

```
for key := range m {
    if key.expired() {
        delete(m, key)
    }
}
```

若你只需要该遍历中的第二个项（值），请使用空白标识符，即下划线来丢弃第一个值：

```
sum := 0
for _, value := range array {
    sum += value
}
```

空白标识符还有多种用法，它会在后面的小节中描述。

对于字符串，`range` 能够提供更多便利。它能通过解析 `UTF-8`，将每个独立的 `Unicode` 码点分离出来。错误的编码将占用一个字节，并以符文 `U+FFFD` 来代替。 （名称 “符文” 和内建类型 `rune` 是 Go 对单个 `Unicode` 码点的成称谓。 详情见[语言规范](http://golang.org/ref/spec#Rune_literals)）。循环：

```
for pos, char := range "日本\x80語" { // \x80 在 UTF-8 编码中是一个非法字符
    fmt.Printf("character %#U starts at byte position %d\n", char, pos)
}
```

打印结果：

```
character U+65E5 '日' starts at byte position 0
character U+672C '本' starts at byte position 3
character U+FFFD '�' starts at byte position 6
character U+8A9E '語' starts at byte position 7
```

最后，Go 没有逗号操作符，而 `++` 和 `--` 为语句而非表达式。 因此，若你想要在 for 中使用多个变量，应采用平行赋值的方式 （因为它会拒绝 `++` 和 `--`）：

```
// Reverse a
for i, j := 0, len(a)-1; i < j; i, j = i+1, j-1 {
    a[i], a[j] = a[j], a[i]
}
```

### 6.4 switch


### 6.5 类型 switch

## 7. 函数

## 8. 数据

## 9. 初始化

## 10. 方法

## 11. 接口与其它类型

## 12. 空白标识符

## 13. 内嵌

## 14. 并发

## 15. 错误

## 16. 示例：Web 服务器

## Reference

- [Effective Go](https://go.dev/doc/effective_go)
- [高效的 Go 编程 Effective G](https://learnku.com/docs/effective-go/2020)
- [Effective Go　中文版](https://www.kancloud.cn/kancloud/effective/72199)