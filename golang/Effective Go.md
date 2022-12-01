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

Go 的 `switch` 比 C 的更通用，其表达式无需为常量或整数。`case` 语句会自上而下逐一进行求值直到匹配为止。若 switch 后面没有表达式，它将匹配 true，因此，我们可以将 `if-else-if-else` 链写成一个 `switch`，这也更符合 Go 的风格。

```
func unhex(c byte) byte {
    switch {
    case '0' <= c && c <= '9':
        return c - '0'
    case 'a' <= c && c <= 'f':
        return c - 'a' + 10
    case 'A' <= c && c <= 'F':
        return c - 'A' + 10
    }
    return 0
}
```

`switch` 并不会自动下溯，但 `case` 可通过逗号分隔来列举相同的处理条件。

```
func shouldEscape(c byte) bool {
    switch c {
    case ' ', '?', '&', '=', '#', '+', '%':
        return true
    }
    return false
}
```

尽管它们在 Go 中的用法和其它类 C 语言差不多，但 `break` 语句可以使 `switch` 提前终止。不仅是 `switch`， 有时候也必须打破层层的循环。在 Go 中，我们只需将标签放置到循环外，然后 “蹦” 到那里即可。下面的例子展示了二者的用法。

```
Loop:
    for n := 0; n < len(src); n += size {
        switch {
        case src[n] < sizeOne:
            if validateOnly {
                break
            }
            size = 1
            update(src[n])

        case src[n] < sizeTwo:
            if n+1 >= len(src) {
                err = errShortInput
                break Loop
            }
            if validateOnly {
                break
            }
            size = 2
            update(src[n] + src[n+1]<<shift)
        }
    }
```

当然，continue 语句也能接受一个可选的标签，不过它只能在循环中使用。

作为这一节的结束，此程序通过使用两个 switch 语句对字节数组进行比较：

```
// 比较两个字节型切片，返回一个整数
// 按字典顺序.
// 如果a == b，结果为0；如果a < b，结果为-1；如果a > b，结果为+1
func Compare(a, b []byte) int {
    for i := 0; i < len(a) && i < len(b); i++ {
        switch {
        case a[i] > b[i]:
            return 1
        case a[i] < b[i]:
            return -1
        }
    }
    switch {
    case len(a) > len(b):
        return 1
    case len(a) < len(b):
        return -1
    }
    return 0
}
```

### 6.5 类型 switch

`switch` 也可用于判断接口变量的动态类型。如类型选择通过圆括号中的关键字 `type` 使用类型断言语法。若 `switch` 在表达式中声明了一个变量，那么该变量的每个子句中都将有该变量对应的类型。在每一个 `case` 子句中，重复利用该变量名字也是惯常的做法，实际上这是在每一个 `case` 子句中，分别声明一个拥有相同名字，但类型不同的新变量。

```
var t interface{}
t = functionOfSomeType()
switch t := t.(type) {
default:
    fmt.Printf("unexpected type %T\n", t)     // %T 打印任何类型的 t
case bool:
    fmt.Printf("boolean %t\n", t)             // t 是 bool 类型
case int:
    fmt.Printf("integer %d\n", t)             // t 是 int 类型
case *bool:
    fmt.Printf("pointer to boolean %t\n", *t) // t 是 *bool 类型
case *int:
    fmt.Printf("pointer to integer %d\n", *t) // t 是 *int 类型
}
```

## 7. 函数

### 7.1 多返回值

Go 与众不同的特性之一就是函数和方法可返回多个值。这种形式可以改善 C 中一些笨拙的习惯： 将错误值返回（例如用 `-1` 表示 `EOF`）和修改通过地址传入的实参。

在 C 中，写入操作发生的错误会用一个负数标记，而错误码会隐藏在某个易变位置（a volatile location）。 而在 Go 中，`Write` 会返回写入的字节数以及一个错误： “是的，您写入了一些字节，但并未全部写入，因为设备已满”。 在 `os` 包中，`File.Write` 的签名为：

```
func (file *File) Write(b []byte) (n int, err error)
```

正如文档所述，它返回写入的字节数，并在 `n != len(b)` 时返回一个非 `nil` 的 `error` 错误值。 这是一种常见的编码风格，更多示例见错误处理一节。

我们可以采用一种简单的方法。来避免为模拟引用参数而传入指针。 以下简单的函数可从字节数组中的特定位置获取其值，并返回该数值和下一个位置：

```
func nextInt(b []byte, i int) (int, int) {
    for ; i < len(b) && !isDigit(b[i]); i++ {
    }
    x := 0
    for ; i < len(b) && isDigit(b[i]); i++ {
        x = x*10 + int(b[i]) - '0'
    }
    return x, i
}
```

你可以像下面这样，通过它扫描输入的切片 b 来获取数字：

```
for i := 0; i < len(b); {
    x, i = nextInt(b, i)
    fmt.Println(x)
}
```

### 7.2 命名结果参数

Go 函数的返回值或结果 “形参” 可被命名，并作为常规变量使用，就像传入的形参一样。 命名后，一旦该函数开始执行，它们就会被初始化为与其类型相应的零值； 若该函数执行了一条不带实参的 `return` 语句，则结果形参的当前值将被返回。

此名称不是强制性的，但它们能使代码更加简短清晰：它们就是文档。若我们命名了 `nextInt` 的结果，那么它返回的 `int` 就值如其意了。

```
func nextInt(b []byte, pos int) (value, nextPos int) {
```

由于被命名的结果已经初始化，且已经关联至无参数的返回，它们就能让代码简单而清晰。 下面的 `io.ReadFull` 就是个很好的例子：

```
func ReadFull(r Reader, buf []byte) (n int, err error) {
    for len(buf) > 0 && err == nil {
        var nr int
        nr, err = r.Read(buf)
        n += nr
        buf = buf[nr:]
    }
    return
}
```

### 7.3 延迟 defer

Go 的 `defer` 语句用于预设一个函数调用（即推迟执行函数）， 该函数会在执行 `defer` 的函数返回之前立即执行。它显得非比寻常，但却是处理一些事情的有效方式，例如无论以何种路径返回，都必须释放资源的函数。 典型的例子就是解锁互斥和关闭文件。

```
// Contents 返回文件的内容作为字符串。
func Contents(filename string) (string, error) {
    f, err := os.Open(filename)
    if err != nil {
        return "", err
    }
    defer f.Close()  // 我们结束后就关闭了f

    var result []byte
    buf := make([]byte, 100)
    for {
        n, err := f.Read(buf[0:])
        result = append(result, buf[0:n]...) // append稍后讨论。
        if err != nil {
            if err == io.EOF {
                break
            }
            return "", err  // 如果我们回到这里，f就关闭了。
        }
    }
    return string(result), nil // 如果我们回到这里，f就关闭了。
}
```

推迟诸如 `Close` 之类的函数调用有两点好处：第一， 它能确保你不会忘记关闭文件。如果你以后又为该函数添加了新的返回路径时， 这种情况往往就会发生。第二，它意味着 “关闭” 离 “打开” 很近， 这总比将它放在函数结尾处要清晰明了。

被推迟函数的实参（如果该函数为方法则还包括接收者）在推迟执行时就会求值， 而不是在调用执行时才求值。这样不仅无需担心变量值在函数执行时被改变， 同时还意味着单个已推迟的调用可推迟多个函数的执行。下面是个简单的例子：

```
for i := 0; i < 5; i++ {
    defer fmt.Printf("%d ", i)
}
```

被推迟的函数按照后进先出（LIFO）的顺序执行，因此以上代码在函数返回时会打印 `4 3 2 1 0`。一个更具实际意义的例子是通过一种简单的方法， 用程序来跟踪函数的执行。我们可以编写一对简单的跟踪例程：

```
func trace(s string)   { fmt.Println("entering:", s) }
func untrace(s string) { fmt.Println("leaving:", s) }

// Use them like this:
func a() {
    trace("a")
    defer untrace("a")
    // do something....
}
```

我们可以充分利用这个特点，即被推迟函数的实参在推迟执行时就会求值。 跟踪例程可针对反跟踪例程设置实参。以下例子：

```
func trace(s string) string {
    fmt.Println("entering:", s)
    return s
}

func un(s string) {
    fmt.Println("leaving:", s)
}

func a() {
    defer un(trace("a"))
    fmt.Println("in a")
}

func b() {
    defer un(trace("b"))
    fmt.Println("in b")
    a()
}

func main() {
    b()
}
```

会打印：

```
entering: b
in b
entering: a
in a
leaving: a
leaving: b
```

对于习惯其它语言中块级资源管理的程序员，`defer` 似乎有点怪异，但它最有趣而强大的应用恰恰来自于其基于函数而非块的特点。在 `panic` 和 `recover` 这两节中，我们将看到关于它可能性的其它例子。

## 8. 数据

### 8.1 使用 new 进行分配

Go 提供了两种分配原语，即内建函数 `new` 和 `make`。 它们所做的事情各不相同，所应用的类型也不同。因为它们的使用规则很简单，用法也很相似所以很容易引起混淆。 让我们先来看看 `new`。这是个用来分配内存的内建函数， 但与其它语言中的同名函数不同，它不会初始化内存，只会将内存置零。 也就是说，`new(T)` 会为类型为 `T` 的新项分配已置零的内存空间， 并返回它的地址，也就是一个类型为 `*T` 的值。用 Go 的术语来说，它返回一个指针， 该指针指向新分配的，类型为 `T` 的零值。

既然 `new` 返回的内存已置零，那么当你设计数据结构时， 每种类型的零值就不必进一步初始化了，这意味着该数据结构的使用者只需用 `new` 创建一个新的对象就能正常工作。例如，`bytes.Buffer` 的文档中提到 “零值的 Buffer 就是已准备就绪的缓冲区。” 同样，`sync.Mutex` 并没有显式的构造函数或 `Init` 方法， 而是零值的 `sync.Mutex` 就已经被定义为已解锁的互斥锁了。

“零值属性” 可以带来各种好处。考虑以下类型声明。

```
type SyncedBuffer struct {
    lock    sync.Mutex
    buffer  bytes.Buffer
}
```

`SyncedBuffer` 类型的值也是在声明时就分配好内存就绪了。后续代码中， `p` 和 `v` 无需进一步处理即可正确工作。

```
p := new(SyncedBuffer)  // type *SyncedBuffer
var v SyncedBuffer      // type  SyncedBuffer
```

### 8.2 构造器和复合字面量

有时零值还不够好，这时就需要一个初始化构造函数，如来自 `os` 包中的这段代码所示：

```
func NewFile(fd int, name string) *File {
    if fd < 0 {
        return nil
    }
    f := new(File)
    f.fd = fd
    f.name = name
    f.dirinfo = nil
    f.nepipe = 0
    return f
}
```

这里显得代码过于冗长。我们可通过复合字面量来简化它， 该表达式在每次求值时都会创建新的实例：

```
func NewFile(fd int, name string) *File {
    if fd < 0 {
        return nil
    }
    f := File{fd, name, nil, 0}
    return &f
}
```

请注意，返回一个局部变量的地址完全没有问题，这点与 C 不同。该局部变量对应的数据 在函数返回后依然有效。实际上，每当获取一个复合字面的地址时，都将为一个新的实例分配内存， 因此我们可以将上面的最后两行代码合并：

```
return &File{fd, name, nil, 0}
```

复合字面的字段必须按顺序全部列出。但如果以 字段:值（field:value）对的形式明确地标出元素，初始化字段时就可以按任何顺序出现，未给出的字段值将赋予零值。 因此，我们可以用如下形式：

```
return &File{fd: fd, name: name}
```

少数情况下，若复合字面不包括任何字段，它将创建该类型的零值。表达式 `new(File)` 和 `&File{}` 是等价的。

复合字面同样可用于创建数组、切片以及映射，字段标签（field labels）是索引（indices）还是映射键（map keys）则视情况而定。 在下例初始化过程中，无论 `Enone`、`Eio` 和 `Einval` 的值是什么，只要它们的标签不同就行：

```
a := [...]string   {Enone: "no error", Eio: "Eio", Einval: "invalid argument"}
s := []string      {Enone: "no error", Eio: "Eio", Einval: "invalid argument"}
m := map[int]string{Enone: "no error", Eio: "Eio", Einval: "invalid argument"}
```

### 8.3 使用 make 进行分配

再回到内存分配上来。内建函数 `make(T, args)` 的目的不同于 `new(T)`。它只用于创建 `slice`、`map` 和 `channel`，并返回类型为 `T`（而非 `*T`）的一个已初始化（而非置零）的值。 出现这种用差异的原因在于，这三种类型本质上为引用数据类型，它们在使用前必须初始化。 例如，切片是一个具有三项内容的描述符，包含一个指向（数组内部）数据的指针、长度以及容量， 在这三项被初始化之前，该切片为 `nil`。对于 `slice`、`map` 和 `channel`，`make` 用于初始化其内部的数据结构并准备好将要使用的值。例如：

```
make([]int, 10, 100)
```

会分配一个具有 `100` 个 `int` 的数组空间，接着创建一个长度为 `10`， 容量为 `100` 并指向该数组中前 `10` 个元素的切片结构。（生成切片时，其容量可以省略，更多信息见切片一节。） 与此相反，`new([]int)` 会返回一个指向新分配的，已置零的切片结构， 即一个指向 `nil` 切片值的指针。

下面的例子阐明了 new 和 make 之间的区别：

```
var p *[]int = new([]int)       // 分配切片结构；*p == nil；很少用到
var v  []int = make([]int, 100) // 切片 v 现在引用了一个具有 100 个 int 元素的新数组

// 没必要的复杂用法:
var p *[]int = new([]int)
*p = make([]int, 100, 100)

// 常规用法:
v := make([]int, 100)
```

请记住，`make` 只适用于 `map`、`slice` 和 `channel` 且不返回指针。若要获得明确的指针， 请使用 `new` 分配内存。

### 8.4 数组

在详细规划内存布局时，数组是非常有用的，有时还能避免过多的内存分配， 但它们主要用作切片的构件。这是下一节的主题了，不过要先说上几句来为它做铺垫。

**以下为数组在 Go 和 C 中的主要区别**。在 Go 中，

- 数组是值。将一个数组赋予另一个数组会复制其所有元素。
- 特别地，若将某个数组传入某个函数，它将接收到该数组的一份副本而非指针。
- 数组的大小是其类型的一部分。类型 `[10]int` 和 `[20]int` 是不同的。

数组为值的属性很有用，但代价高昂；若你想要 C 那样的行为和效率，你可以传递一个指向该数组的指针。

```
func Sum(a *[3]float64) (sum float64) {
    for _, v := range *a {
        sum += v
    }
    return
}

array := [...]float64{7.0, 8.5, 9.1}
x := Sum(&array)  // Note the explicit address-of operator
```

但这并不是 Go 的习惯用法，切片才是。

### 8.5 切片

切片通过对数组进行封装，为数据序列提供了更通用、强大而方便的接口。 除了矩阵变换这类需要明确维度的情况外，Go 中的大部分数组编程都是通过切片来完成的。

切片保存了对底层数组的引用，若你将某个切片赋予另一个切片，它们会引用同一个数组。 **若某个函数将一个切片作为参数传入，则它对该切片元素的修改对调用者而言同样可见， 这可以理解为传递了底层数组的指针**。因此，Read 函数可接受一个切片实参 而非一个指针和一个计数；切片的长度决定了可读取数据的上限。以下为 `os` 包中 `File` 类型的 `Read` 方法签名:

```
func (f *File) Read(buf []byte) (n int, err error)
```

该方法返回读取的字节数和一个错误值（若有的话）。若要从更大的缓冲区 `b` 中读取前 `32` 个字节，只需对其进行切片即可。

```
n, err := f.Read(buf[0:32])
```

这种切片的方法常用且高效。若不谈效率，以下片段同样能读取该缓冲区的前 `32` 个字节。

```
var n int
var err error
for i := 0; i < 32; i++ {
    nbytes, e := f.Read(buf[i:i+1])  // Read one byte.
    n += nbytes
    if nbytes == 0 || e != nil {
        err = e
        break
    }
}
```

只要切片不超出底层数组的限制，它的长度就是可变的，只需将它赋予其自身的切片即可。 切片的容量可通过内建函数 `cap` 获得，它将给出该切片可取得的最大长度。 以下是将数据追加到切片的函数。若数据超出其容量，则会重新分配该切片。返回值即为所得的切片。 该函数中所使用的 `len` 和 `cap` 在应用于 `nil` 切片时是合法的，它会返回 0。

```
func Append(slice, data []byte) []byte {
    l := len(slice)
    if l + len(data) > cap(slice) {  // 重新分配
        // 为未来的增长,双重分配所需的内容.
        newSlice := make([]byte, (l+len(data))*2)
        // copy函数是预先声明的，适用于任何切片类型。
        copy(newSlice, slice)
        slice = newSlice
    }
    slice = slice[0:l+len(data)]
    copy(slice[l:], data)
    return slice
}
```

最终我们必须返回切片，因为尽管 `Append` 可修改 `slice` 的元素，但切片自身（其运行时数据结构包含指针、长度和容量）是通过值传递的。

向切片追加东西的想法非常有用，因此有专门的内建函数 `append`。 要理解该函数的设计，我们还需要一些额外的信息，我们将稍后再介绍它。

### 8.5 二维切片

Go 的数组和切片都是一维的。要创建等价的二维数组或切片，就必须定义一个数组的数组， 或切片的切片，就像这样：

```
type Transform [3][3]float64  // 一个 3x3 的数组，其实是包含多个数组的一个数组。
type LinesOfText [][]byte     // 包含多个字节切片的一个切片。
```

由于切片长度是可变的，因此其内部可能拥有多个不同长度的切片。在我们的 LinesOfText 例子中，这是种常见的情况：每行都有其自己的长度：

```
text := LinesOfText{
    []byte("Now is the time"),
    []byte("for all good gophers"),
    []byte("to bring some fun to the party."),
}
```

有时必须分配一个二维数组，例如在处理像素的扫描行时，这种情况就会发生。 我们有两种方式来达到这个目的。一种就是独立地分配每一个切片；而另一种就是只分配一个数组， 将各个切片都指向它。采用哪种方式取决于你的应用。若切片会增长或收缩， 就应该通过独立分配来避免覆盖下一行；若不会，用单次分配来构造对象会更加高效。 以下是这两种方法的大概代码，仅供参考。首先是一次一行的：

```
// Allocate the top-level slice.
picture := make([][]uint8, YSize) // One row per unit of y.
// Loop over the rows, allocating the slice for each row.
for i := range picture {
	picture[i] = make([]uint8, XSize)
}
```

现在是一次分配，对行进行切片：

```
// Allocate the top-level slice, the same as before.
picture := make([][]uint8, YSize) // One row per unit of y.
// Allocate one large slice to hold all the pixels.
pixels := make([]uint8, XSize*YSize) // Has type []uint8 even though picture is [][]uint8.
// Loop over the rows, slicing each row from the front of the remaining pixels slice.
for i := range picture {
    picture[i], pixels = pixels[:XSize], pixels[XSize:]
}
```

### 8.6 Maps

映射是方便而强大的内建数据结构，它可以关联不同类型的值。其键可以是任何相等性操作符支持的类型， 如整数、浮点数、复数、字符串、指针、接口（只要其动态类型支持相等性判断）、结构以及数组。**切片不能用作映射键，因为它们的相等性还未定义。与切片一样，映射也是引用类型。 若将映射传入函数中，并更改了该映射的内容，则此修改对调用者同样可见**。

映射可使用一般的复合字面语法进行构建，其键 - 值对使用冒号分隔，因此可在初始化时很容易地构建它们：

```
var timeZone = map[string]int{
    "UTC":  0*60*60,
    "EST": -5*60*60,
    "CST": -6*60*60,
    "MST": -7*60*60,
    "PST": -8*60*60,
}
```

赋值和获取映射值的语法类似于数组，不同的是映射的索引不必为整数：

```
offset := timeZone["EST"]
```

若试图通过映射中不存在的键来取值，就会返回与该映射中项的类型对应的零值。 例如，若某个映射包含整数，当查找一个不存在的键时会返回 0。 集合可实现成一个值类型为 `bool` 的映射。将该映射中的项置为 `true` 可将该值放入集合中，此后通过简单的索引操作即可判断是否存在：

```
attended := map[string]bool{
    "Ann": true,
    "Joe": true,
    ...
}

if attended[person] { // person不在集合中，返回 false
    fmt.Println(person, "was at the meeting")
}
```

有时你需要区分某项是不存在还是其值为零值。如对于一个值本应为零的 "UTC" 条目，也可能是由于不存在该项而得到零值。你可以使用多重赋值的形式来分辨这种情况：

```
var seconds int
var ok bool
seconds, ok = timeZone[tz]
```

显然，我们可称之为 “逗号 ok” 惯用法。在下面的例子中，若 `tz` 存在，`seconds` 就会被赋予适当的值，且 `ok` 会被置为 `true`； 若不存在，`seconds` 则会被置为零，而 `ok` 会被置为 `false`：

```
func offset(tz string) int {
    if seconds, ok := timeZone[tz]; ok {
        return seconds
    }
    log.Println("unknown time zone:", tz)
    return 0
}
```

若仅需判断映射中是否存在某项而不关心实际的值，可使用空白标识符（`_`）来代替该值的一般变量：

```
_, present := timeZone[tz]
```

要删除映射中的某项，可使用内建函数 `delete`，它以映射及要被删除的键为实参。 即便对应的键不在该映射中，此操作也是安全的：

```
delete(timeZone, "PDT")  // Now on Standard Time
```

### 8.7 打印输出

Go 采用的格式化打印风格和 C 的 `printf` 族类似，但却更加丰富而通用。 这些函数位于 `fmt` 包中，且函数名首字母均为大写：如 `fmt.Printf`、`fmt.Fprintf`，`fmt.Sprintf` 等。 字符串函数（`Sprintf` 等）会返回一个字符串，而非填充给定的缓冲区。

你无需提供一个格式字符串。每个 `Printf`、`Fprintf` 和 `Sprintf` 都分别对应另外的函数，如 `Print` 与 `Println`。 这些函数并不接受格式字符串，而是为每个实参生成一种默认格式。`Println` 系列的函数还会在实参中插入空格，并在输出时追加一个换行符，而 `Print` 版本仅在操作数两侧都没有字符串时才添加空白。以下示例中各行产生的输出都是一样的：

```
fmt.Printf("Hello %d\n", 23)
fmt.Fprint(os.Stdout, "Hello ", 23, "\n")
fmt.Println("Hello", 23)
fmt.Println(fmt.Sprint("Hello ", 23))
```

fmt.Fprint 一类的格式化打印函数可接受任何实现了 `io.Writer` 接口的对象作为第一个实参；变量 `os.Stdout` 与 `os.Stderr` 都是人们熟知的例子。

从这里开始，就与 C 有些不同了。首先，像 `%d` 这样的数值格式并不接受表示符号或大小的标记， 打印例程会根据实参的类型来决定这些属性：

```
var x uint64 = 1 << 64 - 1
fmt.Printf("%d %x; %d %x\n", x, x, int64(x), int64(x))
```

打印结果：

```
18446744073709551615 ffffffffffffffff; -1 -1
```

若你只想要默认的转换，如使用十进制的整数，你可以使用通用的格式 `%v`（对应 “值”）；其结果与 `Print` 和 `Println` 的输出完全相同。此外，这种格式还能打印任意值，甚至包括数组、结构体和映射。 以下是打印上一节中定义的时区映射的语句。

```
fmt.Printf("%v\n", timeZone)  // or just fmt.Println(timeZone)
```

打印结果:

```
map[CST:-21600 EST:-18000 MST:-25200 PST:-28800 UTC:0]
```

对于映射，`Printf` 会自动对映射值按照键的字典顺序排序。

当然，映射中的键可能按任意顺序输出。当打印结构体时，改进的格式 `%+v` 会为结构体的每个字段添上字段名，而另一种格式 `%#v` 将完全按照 Go 的语法打印值。

```
type T struct {
    a int
    b float64
    c string
}
t := &T{ 7, -2.35, "abc\tdef" }
fmt.Printf("%v\n", t)
fmt.Printf("%+v\n", t)
fmt.Printf("%#v\n", t)
fmt.Printf("%#v\n", timeZone)
```

将打印:

```
&{7 -2.35 abc   def}
&{a:7 b:-2.35 c:abc     def}
&main.T{a:7, b:-2.35, c:"abc\tdef"}
map[string]int{"CST":-21600, "EST":-18000, "MST":-25200, "PST":-28800, "UTC":0}
```

（请注意其中的 `&` 符号）当遇到 `string` 或 `[]byte` 值时， 可使用 `%q` 产生带引号的字符串；而格式 `%#q` 会尽可能使用反引号。（`%q` 格式也可用于整数和符文，它会产生一个带单引号的符文常量。） 此外，`%x` 还可用于字符串、字节数组以及整数，并生成一个很长的十六进制字符串， 而带空格的格式（`% x`）还会在字节之间插入空格。

另一种实用的格式是 `%T`，它会打印某个值的类型。

```
fmt.Printf("%T\n", timeZone)
```

将打印:

```
map[string]int
```

若你想控制自定义类型的默认格式，只需为该类型定义一个具有 `String() string` 签名的方法。对于我们简单的类型 T，可进行如下操作。

```
func (t *T) String() string {
    return fmt.Sprintf("%d/%g/%q", t.a, t.b, t.c)
}
fmt.Printf("%v\n", t)
```

会打印出如下格式：

```
7/-2.35/"abc\tdef"
```

（如果你需要像指向 `T` 的指针那样打印类型 `T` 的值， `String` 的接收者就必须是值类型的；上面的例子中接收者是一个指针， 因为这对结构来说更高效而通用。更多详情见[指针 vs. 值接收者](https://go.dev/doc/effective_go#pointers_vs_values)一节）

我们的 `String` 方法也可调用 `Sprintf`， 因为打印例程可以完全重入并按这种方式封装。不过有一个重要的细节你需要知道： 请勿通过调用 `Sprintf` 来构造 `String` 方法，因为它会无限递归你的 `String` 方法。如果 `Sprintf` 调用试图将接收器直接打印为字符串，而该字符串又将再次调用该方法，则会发生这种情况。这是一个常见的错误，如本例所示。

```
type MyString string

func (m MyString) String() string {
    return fmt.Sprintf("MyString=%s", m) // 错误：会无限递归
}
```

要解决这个问题也很简单：将该实参转换为基本的字符串类型，它没有这个方法:

```
type MyString string
func (m MyString) String() string {
    return fmt.Sprintf("MyString=%s", string(m)) // 可以：注意转换
}
```

在 [初始化一节](https://go.dev/doc/effective_go#initialization)中，我们将看到避免这种递归的另一种技术。

另一种打印技术就是将打印例程的实参直接传入另一个这样的例程。`Printf` 的签名为其最后的实参使用了 `...interface{}` 类型，这样格式的后面就能出现任意数量，任意类型的形参了。

```
func Printf(format string, v ...interface{}) (n int, err error) {
```

在 `Printf` 函数中，`v` 看起来更像是 `[]interface{}` 类型的变量，但如果将它传递到另一个变参函数中，它就像是常规实参列表了。 以下是我们之前用过的 `log.Println` 的实现。它直接将其实参传递给 `fmt.Sprintln` 进行实际的格式化。

```
// Println 通过 fmt.Println 的方式将日志打印到标准记录器
func Println(v ...interface{}) {
    std.Output(2, fmt.Sprintln(v...))  // Output takes parameters (int, string)
}
```

在该 `Sprintln` 嵌套调用中，我们将 `...` 写在 `v` 之后来告诉编译器将 `v` 视作一个实参列表，否则它会将 `v` 当做单一的切片实参来传递。

还有很多关于打印知识点没有提及。详情请参阅 `godoc` 对 `fmt` 包的说明文档。

顺便一提，`...` 形参可指定具体的类型，例如从整数列表中选出最小值的函数 `min`，其形参可为 `...int` 类型。

```
func Min(a ...int) int {
    min := int(^uint(0) >> 1)  // 最大的 int
    for _, i := range a {
        if i < min {
            min = i
        }
    }
    return min
}
```

### 8.8 append 内建函数

现在我们要对内建函数 `append` 的设计进行补充说明。`append` 函数的签名不同于前面我们自定义的 `Append` 函数。大致来说，它就像这样：

```
func append(slice []T, elements ...T) []T
```

其中的 `T` 为任意给定类型的占位符。实际上，你无法在 Go 中编写一个类型 `T` 由调用者决定的函数。这也就是为何 `append` 为内建函数的原因：它需要编译器的支持。

`append` 会在切片末尾追加元素并返回结果。我们必须返回结果， 原因与我们手写的 `Append` 一样，即底层数组可能会被改变。以下简单的例子：

```
x := []int{1,2,3}
x = append(x, 4, 5, 6)
fmt.Println(x)
```

将打印 `[1 2 3 4 5 6]`。因此 `append` 有点像 `Printf` 那样，可接受任意数量的实参。

但如果我们要像 `Append` 那样将一个切片追加到另一个切片中呢？ 很简单：在调用的地方使用 `...`，就像我们在上面调用 `Output` 那样。以下代码片段的输出与上一个相同：

```
x := []int{1,2,3}
y := []int{4,5,6}
x = append(x, y...)
fmt.Println(x)
```

如果没有 `...`，它就会由于类型错误而无法编译，因为 `y` 不是 `int` 类型的。

## 9. 初始化

尽管从表面上看，Go 的初始化过程与 C 或 C++ 差别并不算太大，但它确实更为强大。 在初始化过程中，不仅可以构建复杂的结构，还能正确处理不同包对象间的初始化顺序。

### 9.1 常量

Go 中的常量就是不变量。它们在编译时创建，即便它们可能是函数中定义的局部变量。 常量只能是数字、字符（符文，runes）、字符串或布尔值。由于编译时的限制， 定义它们的表达式必须也是可被编译器求值的常量表达式。例如 `1 << 3` 就是一个常量表达式，而 `math.Sin(math.Pi/4)` 则不是，因为对 `math.Sin` 的函数调用在运行时才会发生。

在 Go 中，枚举常量使用枚举器 `iota` 创建。由于 `iota` 可为表达式的一部分，而表达式可以被隐式地重复，这样也就更容易构建复杂的值的集合了：

```
type ByteSize float64

const (
    _           = iota // ignore first value by assigning to blank identifier
    KB ByteSize = 1 << (10 * iota)  // 1 << 10
    MB                              // 1 << 20
    GB                              // 1 << 30
    TB                              // ...
    PB
    EB
    ZB
    YB
)
```

> **注意:** 
> **1. iota 在 const 关键字出现时将被重置为 0**。
> **2. const 中每新增一行常量声明将使 iota 计数一次( iota 可理解为const 语句块中的行索引)**。

由于可将 `String` 之类的方法附加在用户定义的类型上， 因此它就为打印时自动格式化任意值提供了可能性，即便是作为一个通用类型的一部分。 尽管你常常会看到这种技术应用于结构体，但它对于像 `ByteSize` 之类的浮点数标量等类型也是有用的：

```
func (b ByteSize) String() string {
    switch {
    case b >= YB:
        return fmt.Sprintf("%.2fYB", b/YB)
    case b >= ZB:
        return fmt.Sprintf("%.2fZB", b/ZB)
    case b >= EB:
        return fmt.Sprintf("%.2fEB", b/EB)
    case b >= PB:
        return fmt.Sprintf("%.2fPB", b/PB)
    case b >= TB:
        return fmt.Sprintf("%.2fTB", b/TB)
    case b >= GB:
        return fmt.Sprintf("%.2fGB", b/GB)
    case b >= MB:
        return fmt.Sprintf("%.2fMB", b/MB)
    case b >= KB:
        return fmt.Sprintf("%.2fKB", b/KB)
    }
    return fmt.Sprintf("%.2fB", b)
}
```

表达式 `YB` 会打印出 `1.00YB`，而 `ByteSize(1e13)` 则会打印出 `9.09`。

在这里用 `Sprintf` 实现 `ByteSize` 的 `String` 方法很安全（不会无限递归），这倒不是因为类型转换，而是它以 `%f` 调用了 `Sprintf`，它并不是一种字符串格式：`Sprintf` 只会在它需要字符串时才调用 `String` 方法，而 `%f` 需要一个浮点数值。

### 9.2 变量

变量能像常量一样初始化，而且可以初始化为一个可在运行时得出结果的普通表达式：

```
var (
    home   = os.Getenv("HOME")
    user   = os.Getenv("USER")
    gopath = os.Getenv("GOPATH")
)
```

### 9.3 init 函数

最后，每个源文件都可以通过定义自己的无参数 `init` 函数来设置一些必要的状态。 （其实每个文件都可以拥有多个 `init` 函数。）而它的结束就意味着初始化结束： 只有该包中的所有变量声明都通过它们的初始化器求值后 `init` 才会被调用， 而包中的变量只有在所有已导入的包都被初始化后才会被求值。

除了那些不能被表示成声明的初始化外，`init` 函数还常被用在程序真正开始执行前，检验或校正程序的状态：

```
func init() {
    if user == "" {
        log.Fatal("$USER not set")
    }
    if home == "" {
        home = "/home/" + user
    }
    if gopath == "" {
        gopath = home + "/go"
    }
    // gopath 可通过命令行中的 --gopath 标记覆盖掉。
    flag.StringVar(&gopath, "gopath", gopath, "override default GOPATH")
}
```

## 10. 方法

### 10.1 指针 vs. 值

正如 `ByteSize` 那样，我们可以为任何已命名的类型（除了指针或接口）定义方法； 接收者可不必为结构体。

在之前讨论切片时，我们编写了一个 `Append` 函数。 我们也可将其定义为切片的方法。为此，我们首先要声明一个已命名的类型来绑定该方法， 然后使该方法的接收者成为该类型的值：

```
type ByteSlice []byte

func (slice ByteSlice) Append(data []byte) []byte {
    // 主体与上面定义的Append函数完全相同。
}
```

我们仍然需要该方法返回更新后的切片。为了消除这种不便，我们可通过重新定义该方法，将一个指向 `ByteSlice` 的指针作为该方法的接收者， 这样该方法就能重写调用者提供的切片了：

```
func (p *ByteSlice) Append(data []byte) {
    slice := *p
    // 主体同上，只是没有返回值
    *p = slice
}
```

其实我们做得更好。若我们将函数修改为与标准 `Write` 类似的方法，就像这样：

```
func (p *ByteSlice) Write(data []byte) (n int, err error) {
    slice := *p
    // 同上。
    *p = slice
    return len(data), nil
}
```

那么类型 `*ByteSlice` 就满足了标准的 `io.Writer` 接口，这将非常实用。 例如，我们可以通过打印将内容写入：

```
var b ByteSlice
fmt.Fprintf(&b, "This hour has %d days\n", 7)
```

我们将 `ByteSlice` 的地址传入，因为只有 `*ByteSlice` 才满足 `io.Writer`。以指针或值为接收者的区别在于：**值方法可通过指针和值调用， 而指针方法只能通过指针来调用**。

之所以会有这条规则是因为指针方法可以修改接收者；通过值调用它们会导致方法接收到该值的副本， 因此任何修改都将被丢弃，因此该语言不允许这种错误。不过有个方便的例外：若该值是可寻址的， 那么该语言就会自动插入取址操作符来对付一般的通过值调用的指针方法。在我们的例子中，变量 `b` 是可寻址的，因此我们只需通过 `b.Write` 来调用它的 `Write` 方法，编译器会将它重写为 `(&b).Write`。

顺便一提，在字节切片上使用 `Write` 的想法已被 `bytes.Buffer` 所实现。

## 11. 接口与其它类型

### 11.1 接口

Go 中的接口为指定对象的行为提供了一种方法：如果某样东西可以完成这个， 那么它就可以在这里使用。我们已经见过许多简单的示例了；通过实现 `String` 方法，我们可以自定义打印函数，而通过 `Write` 方法，`Fprintf` 则能对任何对象产生输出。在 Go 代码中， 仅包含一两种方法的接口很常见，且其名称通常来自于实现它的方法， 如 `io.Writer` 就是实现了 `Write` 的一类对象。

类型可以实现多个接口。例如，如果一个集合实现了 `sort.Interface`，其包含 `Len()`，`Less(i, j int) bool` 和 `Swap(i, j int)`，那么它就可以通过程序包 `sort` 中的程序来进行排序，同时它还可以有一个自定义的格式器。 以下特意构建的例子 `Sequence` 就同时满足这两种情况。

```
type Sequence []int

// sort.Interface所需的方法。
func (s Sequence) Len() int {
    return len(s)
}
func (s Sequence) Less(i, j int) bool {
    return s[i] < s[j]
}
func (s Sequence) Swap(i, j int) {
    s[i], s[j] = s[j], s[i]
}

// Copy方法返回Sequence的复制
func (s Sequence) Copy() Sequence {
    copy := make(Sequence, 0, len(s))
    return append(copy, s...)
}

// 打印方法-在打印前给元素排序
func (s Sequence) String() string {
    s = s.Copy() // 复制s，不要覆盖参数本身
    sort.Sort(s)
    str := "["
    for i, elem := range s { // Loop空间复杂度是O(N²)；将在下个例子中修复它
        if i > 0 {
            str += " "
        }
        str += fmt.Sprint(elem)
    }
    return str + "]"
}
```

### 11.2 类型转换

`Sequence` 的 `String` 方法重新实现了 `Sprint` 为切片实现的功能。若我们在调用 `Sprint` 之前将 `Sequence` 转换为纯粹的 `[]int`，就能共享已实现的功能。

```
func (s Sequence) String() string {
    s = s.Copy()
    sort.Sort(s)
    return fmt.Sprint([]int(s))
}
```

该方法是通过类型转换技术，在 `String` 方法中安全调用 `Sprintf` 的另个一例子。若我们忽略类型名的话，这两种类型（`Sequence` 和 `[]int`）其实是相同的，因此在二者之间进行转换是合法的。 转换过程并不会创建新值，它只是暂时让现有的值看起来有个新类型而已。（还有些合法转换则会创建新值，如从整数转换为浮点数等。）

在 Go 程序中，为访问不同的方法集而进行类型转换的情况非常常见。 例如，我们可使用现有的 `sort.IntSlice` 类型来简化整个示例：

```
type Sequence []int

// 打印方法-在打印之前对元素进行排序
func (s Sequence) String() string {
    s = s.Copy()
    sort.IntSlice(s).Sort()
    return fmt.Sprint([]int(s))
}
```

现在，不必让 `Sequence` 实现多个接口（排序和打印）， 我们可通过将数据条目转换为多种类型（`Sequence`、`sort.IntSlice` 和 `[]int`）来使用相应的功能，每次转换都完成一部分工作。 这在实践中虽然有些不同寻常，但往往却很有效。

### 11.3 接口转换与类型断言

[Type switches](https://go.dev/doc/effective_go#type_switch) 是类型转换的一种形式：它接受一个接口，在选择 （switch）中根据其判断选择对应的情况（case）， 并在某种意义上将其转换为该种类型。以下代码为 `fmt.Printf` 通过类型选择将值转换为字符串的简化版。如果其已经是字符串，那么我们想要接口持有的实际字符串值，如果其有一个 `String` 方法，则我们想要调用该方法的结果。

```
type Stringer interface {
    String() string
}

var value interface{} // Value 由调用者提供
switch str := value.(type) {
case string:
    return str
case Stringer:
    return str.String()
}
```

第一种情况找到一个具体的值；第二种将接口转换为另一个。使用这种方式进行混合类型完全没有问题。

如果我们只关心一种类型该如何做？如果我们知道值为一个 `string`，只是想将它抽取出来该如何做？只有一个 case 的类型 switch 是可以的，不过也可以用类型断言。类型断言接受一个接口值，从中抽取出显式指定类型的值。其语法借鉴了类型 switch 子句，不过是使用了显式的类型，而不是 `type 关键字：

```
value.(typeName)
```

结果是一个为静态类型 `typeName` 的新值。该类型或者是一个接口所持有的具体类型，或者是可以被转换的另一个接口类型。要抽取我们已知值中的字符串，可以写成：

```
str := value.(string)
```

不过，如果该值不包含一个字符串，则程序会产生一个运行时错误。为了避免这样，可以使用 “comma, ok”的习惯用法来安全地测试值是否为一个字符串：

```
str, ok := value.(string)
if ok {
    fmt.Printf("string value is: %q\n", str)
} else {
    fmt.Printf("value is not a string\n")
}
```

如果类型断言失败，则str将依然存在，并且类型为字符串，不过其为零值，一个空字符串。

这里有一个 `if-else` 语句的实例，其效果等价于这章开始的类型 `switch` 例子。

```
if str, ok := value.(string); ok {
    return str
} else if str, ok := value.(Stringer); ok {
    return str.String()
}
```

### 11.4 通用性

如果一个类型只是用来实现接口，并且除了该接口以外没有其它被导出的方法，那就不需要导出这个类型。只导出接口，清楚地表明了其重要的是行为，而不是实现，并且其它具有不同属性的实现可以反映原始类型的行为。这也避免了对每个公共方法实例进行重复的文档介绍。

这种情况下，构造器应该返回一个接口值，而不是所实现的类型。作为例子，在 `hash` 库里，`crc32.NewIEEE` 和 `adler32.New` 都是返回了接口类型 `hash.Hash32`。在 Go 程序中，用 `CRC-32` 算法来替换 `Adler-32`，只需要修改构造器调用；其余代码都不受影响。

类似的方式可以使得在不同 `crypto` 程序包中的流密码算法，可以与链在一起的块密码分离开。`crypto/cipher` 程序包中的 `Block` 接口，指定了块密码的行为，即提供对单个数据块的加密。然后，根据 `bufio` 程序包类推，实现该接口的加密包可以用于构建由 `Stream` 接口表示的流密码，而无需知道块加密的细节。

`crypto/cipher` 接口看起来是这样的：

```
type Block interface {
    BlockSize() int
    Encrypt(src, dst []byte)
    Decrypt(src, dst []byte)
}

type Stream interface {
    XORKeyStream(dst, src []byte)
}
```

这是计数器模式 `CTR` 流的定义，它将块加密改为流加密，注意块加密的细节已被抽象化了。

```
// NewCTR returns a Stream that encrypts/decrypts using the given Block in
// counter mode. The length of iv must be the same as the Block's block size.
func NewCTR(block Block, iv []byte) Stream
```

`NewCTR` 的应用并不仅限于特定的加密算法和数据源，它适用于任何对 `Block` 接口和 `Stream` 的实现。因为它们返回接口值， 所以用其它加密模式来代替 `CTR` 只需做局部的更改。构造函数的调用过程必须被修改，但由于其周围的代码只能将它看做 `Stream`，因此它们不会注意到其中的区别。

### 11.5 接口和方法

由于几乎任何类型都能添加方法，因此几乎任何类型都能满足一个接口。一个很直观的例子就是 `http` 包中定义的 `Handler` 接口。任何实现了 `Handler` 的对象都能够处理 HTTP 请求。

```
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

`ResponseWriter` 接口提供了对方法的访问，这些方法需要响应客户端的请求。 由于这些方法包含了标准的 `Write` 方法，因此 `http.ResponseWriter` 可用于任何 `io.Writer` 适用的场景。`Request` 结构体包含已解析的客户端请求。

简单起见，我们假设所有的 HTTP 请求都是 `GET` 方法，而忽略 `POST` 方法， 这种简化不会影响处理程序的建立方式。这里有个短小却完整的处理程序实现， 它用于记录某个页面被访问的次数。

```
// 简单的计数器服务器。
type Counter struct {
    n int
}

func (ctr *Counter) ServeHTTP(w http.ResponseWriter, req *http.Request) {
    ctr.n++
    fmt.Fprintf(w, "counter = %d\n", ctr.n)
}
```

(题外话，注意 `Fprintf` 是如何能够打印到 `http.ResponseWriter` 的。）作为参考，下面给出了如何将该服务附加到 `URL` 树上的节点。

```
import "net/http"
...
ctr := new(Counter)
http.Handle("/counter", ctr)
```

但为什么 `Counter` 要是结构体呢？一个整数就够了。（接收者必须为指针，增量操作对于调用者才可见。）

```
// 简单的计数器服务。
type Counter int

func (ctr *Counter) ServeHTTP(w http.ResponseWriter, req *http.Request) {
    *ctr++
    fmt.Fprintf(w, "counter = %d\n", *ctr)
}
```

当页面被访问时，怎样通知你的程序去更新一些内部状态呢？为 Web 页面绑定个信道吧。

```
// 每次浏览该信道都会发送一个提醒。
// （可能需要带缓冲的信道。）
type Chan chan *http.Request

func (ch Chan) ServeHTTP(w http.ResponseWriter, req *http.Request) {
    ch <- req
    fmt.Fprint(w, "notification sent")
}
```

最后，假设我们需要输出调用服务器二进制程序时使用的实参 `/args`。 很简单，写个打印实参的函数就行了。

```
func ArgServer() {
    fmt.Println(os.Args)
}
```

我们如何将它转换为 HTTP 服务器呢？我们可以将 `ArgServer` 实现为某种可忽略值的方法，不过还有种更简单的方法。 既然我们可以为除指针和接口以外的任何类型定义方法，同样也能为一个函数写一个方法。 `http` 包包含以下代码：

```
// HandlerFunc 类型是一个适配器，
// 它允许将普通函数用做HTTP处理程序。
// 若 f 是个具有适当签名的函数，
// HandlerFunc(f) 就是个调用 f 的处理程序对象。
type HandlerFunc func(ResponseWriter, *Request)

// ServeHTTP calls f(w, req).
func (f HandlerFunc) ServeHTTP(w ResponseWriter, req *Request) {
    f(w, req)
}
```

`HandlerFunc` 是个具有 `ServeHTTP` 方法的类型， 因此该类型的值就能处理 HTTP 请求。我们来看看该方法的实现：接收者是一个函数 `f`，而该方法调用 `f`。这看起来很奇怪，但不必大惊小怪， 区别在于接收者变成了一个信道，而方法通过该信道发送消息。

为了将 `ArgServer` 实现成 HTTP 服务器，首先我们得让它拥有合适的签名。

```
// 实参服务器。
func ArgServer(w http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(w, os.Args)
}
```

`ArgServer` 和 `HandlerFunc` 现在拥有了相同的签名， 因此我们可将其转换为这种类型以访问它的方法，就像我们将 `Sequence` 转换为 `IntSlice` 以访问 `IntSlice.Sort` 那样。 建立代码非常简单：

```
http.Handle("/args", http.HandlerFunc(ArgServer))
```

当有人访问 /args 页面时，安装到该页面的处理程序就有了值 `ArgServer` 和类型 `HandlerFunc`。 HTTP 服务器会以 `ArgServer` 为接收者，调用该类型的 `ServeHTTP` 方法，它会反过来调用 `ArgServer`（通过 `f(c, req)`），接着实参就会被显示出来。

在本节中，我们通过一个结构体，一个整数，一个信道和一个函数，建立了一个 HTTP 服务器， 这一切都是因为接口只是方法的集合，而几乎任何类型都能定义方法。

## 12. 空白标识符

我们在 [for-range 循环](https://go.dev/doc/effective_go#for)和[映射](https://go.dev/doc/effective_go#maps)中提过几次空白标识符。空白标识符可被赋予或声明为任何类型的任何值，而其值会被无害地丢弃。它有点像 Unix 中的 `/dev/null` 文件：它表示只写的值，在需要变量但不需要实际值的地方用作占位符。我们在前面已经见过它的用法了。

### 12.1 空白标识符在多赋值语句中的使用

`for range` 循环中对空表标识符的用法是一种具体情况，更一般的情况即为多个参数赋值。

若某次赋值需要匹配多个左值，但其中某个变量不会被程序使用， 那么用空白标识符来代替该变量可避免创建无用的变量，并能清楚地表明该值将被丢弃。 例如，当调用某个函数时，它会返回一个值和一个错误，但只有错误很重要， 那么可使用空白标识符来丢弃无关的值。

```
if _, err := os.Stat(path); os.IsNotExist(err) {
    fmt.Printf("%s does not exist\n", path)
}
```

你偶尔会看见为忽略错误而丢弃错误值的代码，这是种糟糕的实践。请务必检查错误返回， 它们会提供错误的理由。

```
// 很糟糕的代码！若路径不存在，它就会崩溃。
fi, _ := os.Stat(path)
if fi.IsDir() {
    fmt.Printf("%s is a directory\n", path)
}
```

### 12.2 未使用的导入和变量

如果你在程序中导入了一个包或声明了一个变量却没有使用的话,会引起编译错误。因为，导入未使用的包不仅会使程序变得臃肿，同时也降低了编译效率；初始化 一个变量却不使用，轻则造成对计算的浪费，重则可能会引起更加严重BUG。当一个程序处于开发阶段时，会存在一些暂时没有被使用的导入包和变量，如果为了使程序编译通过而将它们删除，那么后续开发需要使用时，又得重新添加，这非常麻烦。空白标识符为上述场景提供了解决方案。

以下一段代码包含了两个未使用的导入包（`fmt` 和 `io`） 以及一个未使用的变量（`fd`），因此无法编译通过。我们可能希望这个程序现在就可以正确编译。

```
package main

import (
    "fmt"
    "io"
    "log"
    "os"
)

func main() {
    fd, err := os.Open("test.go")
    if err != nil {
        log.Fatal(err)
    }
    // TODO: use fd.
}
```

为了禁止编译器对未使用导入包的错误报告，我们可以用空白标识符来引用一个被导入包中的符号。同样的，将未使用的变量 `fd` 赋值给一个空白标识符也可以禁止编译错误。这个版本的程序就可以编译通过了。

```
package main

import (
    "fmt"
    "io"
    "log"
    "os"
)

var _ = fmt.Printf // For debugging; delete when done.
var _ io.Reader    // For debugging; delete when done.

func main() {
    fd, err := os.Open("test.go")
    if err != nil {
        log.Fatal(err)
    }
    // TODO: use fd.
    _ = fd
}
```

按照约定，用来临时禁止未使用导入错误的全局声明语句必须紧随导入语句块之后，并且需要提供相应的注释信息 —— 这些规定使得将来很容易找并删除这些语句。

### 12.3 副作用式导入

上面例子中的导入的包，`fmt` 或 `io`，最终要么被使用，要么被删除：使用空白标识符只是一种临时性的举措。但有时，导入一个包仅仅是为了引入一些副作用，而不是为了真正使用它们。例如，[net/http/pprof](https://go.dev/pkg/net/http/pprof/) 包会在其导入阶段调用 `init` 函数，该函数注册 HTTP 处理程序以提供调试信息。这个包中确实也包含一些导出的API，但大多数客户端只会通过注册处理函数的方式访问 web 页面的数据，而不需要使用这些 API。为了实现仅为副作用而导入包的操作，可以在导入语句中，将包用空白标识符进行重命名：

```
import _ "net/http/pprof"
```

这一种非常干净的导入包的方式，由于在当前文件中，被导入的包是匿名的，因此你无法访问包内的任何符号。（如果导入的包不是匿名的，而在程序中又没有使用到其内部的符号，那么编译器将报错。）

### 12.4 接口检查

正如我们在前面[接口](https://go.dev/doc/effective_go#interfaces_and_types)那章所讨论的，一个类型不需要明确的声明它实现了某个接口。一个类型要实现某个接口，只需要实现该接口对应的方法就可以了。在实际中，多数接口的类型转换和检查都是在编译阶段静态完成的。例如，将一个 `*os.File` 类型传入一个接受 `io.Reader` 类型参数的函数时，只有在 `*os.File` 实现了 `io.Reader` 接口时，才能编译通过。

但是，也有一些接口检查是发生在运行时的。其中一个例子来自 [encoding/json](https://go.dev/pkg/encoding/json/) 包内定义的 [Marshaler](https://go.dev/pkg/encoding/json/#Marshaler) 接口。当 `JSON` 编码器接收到一个实现了 `Marshaler` 接口的参数时，就调用该参数的 `marshaling` 方法来代替标准方法处理 JSON 编码。编码器利用[类型断言机制](https://go.dev/doc/effective_go#interface_conversions)在运行时进行类型检查：

```
m, ok := val.(json.Marshaler)
```

假设我们只是想知道某个类型是否实现了某个接口，而实际上并不需要使用这个接口本身 —— 例如在一段错误检查代码中 —— 那么可以使用空白标识符来忽略类型断言的返回值：

```
if _, ok := val.(json.Marshaler); ok {
    fmt.Printf("value %v of type %T implements json.Marshaler\n", val, val)
}
```

在某些情况下，我们必须在包的内部确保某个类型确实满足某个接口的定义。例如类型 `json.RawMessage`，如果它要提供一种定制的 JSON 格式，就必须实现 `json.Marshaler` 接口，但是编译器不会自动对其进行静态类型验证。如果该类型在实现上没有充分满足接口定义，JSON 编码器仍然会工作，只不过不是用定制的方式。为了确保接口实现的正确性，可以在包内部，利用空白标识符进行一个全局声明：

```
var _ json.Marshaler = (*RawMessage)(nil)
```

在该声明中，赋值语句导致了从 `*RawMessage`到 `Marshaler` 的类型转换，这要求 `*RawMessage` 必须正确实现了 `Marshaler` 接口，该属性将在编译期间被检查。当`json.Marshaler` 接口被修改后，上面的代码将无法正确编译，因而很容易发现错误并及时修改代码。

在这个结构中出现的空白标识符，表示了该声明语句仅仅是为了触发编译器进行类型检查，而非创建任何新的变量。但是，也不需要对所有满足某接口的类型都进行这样的处理。按照约定，这类声明仅当代码中没有其他静态转换时才需要使用，这类情况通常很少出现。

## 13. 内嵌

Go 并不提供典型的，类型驱动的子类化概念，但通过将类型内嵌到结构体或接口中， 它就能 “借鉴” 部分实现。

接口内嵌非常简单。我们之前提到过 io.Reader 和 io.Writer 接口，这里是它们的定义：

```
type Reader interface {                       //定义读取的接口类型
    Read(p []byte) (n int, err error)         //定义方法，传入[]byte类型  返回一个整型和err
}

type Writer interface {                       //定义写入的接口类型
    Write(p []byte) (n int, err error)        //定义方法，传入[]byte类型  返回一个整型和err
}
```

`io` 包也导出了一些其它接口，以此来阐明对象所需实现的方法。 例如 `io.ReadWriter` 就是个包含 `Read` 和 `Write` 的接口。我们可以通过显示地列出这两个方法来指明 `io.ReadWriter`， 但通过将这两个接口内嵌到新的接口中显然更容易且更具启发性（evocative），就像这样：

```
// ReadWriter is the interface that combines the Reader and Writer interfaces.
type ReadWriter interface {
    Reader
    Writer
}
```

正如它看起来那样：`ReadWriter` 能够做任何 `Reader` 和 `Writer` 可以做到的事情，它是内嵌接口的联合体（它们必须是不相交的方法集）。**只有接口能被嵌入到接口中**。

同样的基本想法也可适用于结构体，但其意义更加深远。`bufio` 包中有 `bufio.Reader` 和 `bufio.Writer` 这两个结构体类型，它们每一个都实现了与 `io` 包中相同意义的接口。此外，`bufio` 还通过结合 `reader/writer` 并将其内嵌到结构体中，实现了带缓冲的 `reader/writer`：在结构体中，只列出了两种类型，但没有给出对应的字段名。

// ReadWriter stores pointers to a Reader and a Writer.
// It implements io.ReadWriter.
type ReadWriter struct {
    *Reader  // *bufio.Reader
    *Writer  // *bufio.Writer
}

**内嵌的元素为指向结构体的指针**，当然它们在使用前必须被初始化为指向有效结构体的指针。`ReadWriter` 结构体可通过如下方式定义：

```
type ReadWriter struct {
    reader *Reader
    writer *Writer
}
```

为了使各字段对应的方法能满足 `io` 的接口规范，我们还需要提供转发的方法如下：

```
func (rw *ReadWriter) Read(p []byte) (n int, err error) {
    return rw.reader.Read(p)
}
```

**而通过直接内嵌结构体，我们就能避免如此繁琐**。 内嵌类型的方法可以直接引用，这意味着 `bufio.ReadWriter` 不仅包括 `bufio.Reader` 和 `bufio.Writer` 的方法，它还同时满足下列三个接口： `io.Reader`、`io.Writer` 以及 `io.ReadWriter`。

在“内嵌”和“子类型”两种方法间存在一个重要的区别。当内嵌一个类型时，该类型的方法会成为外部类型的方法，但当它们被调用时，该方法的接收者是内部类型，而非外部类型。在我们的例子中，当 `bufio.ReadWriter` 的 `Read` 方法被调用时，它与之前写的转发方法具有同样的效果；只不过前者接收的参数是 `ReadWriter` 的 `reader` 字段，而不是 `ReadWriter` 本身。

“内嵌”还可以用一种更简单的方式表达。下面的例子展示了如何将内嵌字段和一个普通的命名字段同时放在一个结构体定义中：

```
type Job struct {
    Command string
    *log.Logger
}
```

`Job` 类型现在有了 `*log.Logger` 的 `Print`, `Printf`, `Println` 以及其它方法。我们当然可以为 `Logger` 提供一个字段名，但完全不必这么做。现在，一旦初始化后，我们就能记录 `Job` 了：

```
job.Println("starting now...")
```

`Logger` 是 `Job` 结构体的常规字段， 因此我们可在 `Job` 的构造函数中，通过一般的方式来初始化它，就像这样：

```
func NewJob(command string, logger *log.Logger) *Job {
    return &Job{command, logger}
}
```

或通过复合字面量：

```
job := &Job{command, log.New(os.Stderr, "Job: ", log.Ldate)}
```

若我们需要直接引用内嵌字段，可以忽略包限定名，直接将该字段的类型名作为字段名， 就像我们在 `ReaderWriter` 结构体的 `Read` 方法中做的那样。 若我们需要访问 Job 类型的变量 `job` 的 `*log.Logger`， 可以直接写作 `job.Logger`。若我们想精炼 `Logger` 的方法时， 这会非常有用。

```
func (job *Job) Printf(format string, args ...interface{}) {
    job.Logger.Printf("%q: %s", job.Command, fmt.Sprintf(format, args...))
}
```

内嵌类型会引入命名冲突的问题，但解决规则却很简单。首先，字段或方法 `X` 会隐藏该类型中更深层嵌套的其它项 `X`。若 `log.Logger` 包含一个名为 `Command` 的字段或方法，`Job` 的 `Command` 字段会覆盖它。

其次，若相同的嵌套层级上出现同名冲突，通常会产生一个错误。若 `Job` 结构体中包含名为 `Logger` 的字段或方法，再将 `log.Logger` 内嵌到其中的话就会产生错误。然而，若重名永远不会在该类型定义之外的程序中使用，那就不会出错。这种限定能够在外部嵌套类型发生修改时提供某种保护。 因此，就算添加的字段与另一个子类型中的字段相冲突，只要这两个相同的字段永远不会被使用就没问题。

## 14. 并发

### 14.1 以通信实现共享

并发编程是个很大的论题。但限于篇幅，这里仅讨论一些 Go 特有的东西。

在并发编程中，为实现对共享变量的正确访问需要精确的控制，这在多数环境下都很困难。Go 语言另辟蹊径，它将共享的值通过信道传递，实际上，多个独立执行的线程从不会主动共享。 在任意给定的时间点，只有一个 Go 协程能够访问该值。数据竞争从设计上就被杜绝了。 为了提倡这种思考方式，我们将它简化为一句口号：

> **不要通过共享内存来通信，而应通过通信来共享内存**。

这种方法意义深远。例如，引用计数通过为整数变量添加互斥锁来很好地实现。 但作为一种高级方法，通过信道来控制访问能够让你写出更简洁，正确的程序。

我们可以从典型的单线程运行在单 CPU 之上的情形来审视这种模型。它无需提供同步原语。 现在考虑另一种情况，它也无需同步。现在让它们俩进行通信。若将通信过程看作同步着， 那就完全不需要其它同步了。例如，Unix 管道就与这种模型完美契合。 尽管 Go 的并发处理方式来源于 `Hoare` 的通信顺序处理（CSP, Communicating Sequential Processes, 国内译为“通信顺序进程”，台湾译为“交谈循序程序”），它依然可以看作是类型安全的 Unix 管道的实现。

### 14.2 Goroutines

我们称之为 Goroutine 是因为现有的术语 — 线程、协程、进程等等 — 无法准确传达它的含义。 Goroutine 具有简单的模型：它是与其它 Goroutine 并发运行在同一地址空间的函数。它是轻量级的， 所有消耗几乎就只有栈空间的分配。而且栈最开始是非常小的，所以它们很廉价，仅在需要时才会随着堆空间的分配（和释放）而变化。

Goroutine 在多线程操作系统上可实现多路复用，因此若一个 Goroutine 阻塞，比如说等待 `I/O`， 那么其它的 Goroutine 就会运行。Goroutine 的设计隐藏了线程创建和管理的诸多复杂性。

在函数或方法前添加 `go` 关键字能够在新的 Goroutine 中调用它。当调用完成后，该 Goroutine 也会安静地退出。（效果有点像 Unix Shell 中的 & 符号，它能让命令在后台运行。）

```
go list.Sort()  // run list.Sort concurrently; don't wait for it.
```

还可以将函数字面量（function literals）嵌入到一个 Goroutine 创建之际，方法如下：：

```
func Announce(message string, delay time.Duration) {
    go func() {
        time.Sleep(delay)
        fmt.Println(message)
    }()  // Note the parentheses - must call the function.
}
```

在 Go 中，函数字面量都是闭包：其实现在保证了函数内引用变量的生命周期与函数的活动时间相同。

这些函数没什么实用性，因为执行函数无法发布其完成的信号。因此，我们需要信道。

### 14.3 Channels

信道与映射一样，也需要通过 `make` 来分配。其结果值充当了对底层数据结构的引用。若提供了一个可选的整数形参，它就会为该信道设置缓冲区大小。默认值是零，表示不带缓冲的或同步的信道。

```
ci := make(chan int)            // unbuffered channel of integers
cj := make(chan int, 0)         // unbuffered channel of integers
cs := make(chan *os.File, 100)  // buffered channel of pointers to Files
```

无缓冲信道在通信时会同步交换数据，它能确保（两个 Gorouine 的）计算处于确定状态。

信道有很多惯用法，我们从这里开始了解。在上一节中，我们在后台启动了排序操作。 信道使得启动的 Gorouine 等待排序完成。

```
c := make(chan int)  // Allocate a channel.
// Start the sort in a goroutine; when it completes, signal on the channel.
go func() {
    list.Sort()
    c <- 1  // Send a signal; value does not matter.
}()
doSomethingForAWhile()
<-c   // Wait for sort to finish; discard sent value.
```

接收者在收到数据前会一直阻塞。若信道是不带缓冲的，那么在接收者收到值前， 发送者会一直阻塞；若信道是带缓冲的，则发送者仅在值被复制到缓冲区前阻塞； 若缓冲区已满，发送者会一直等待直到某个接收者取出一个值为止。

带缓冲区的信道可以像信号量一样使用，用来完成诸如吞吐率限制等功能。在以下示例中，到来的请求以参数形式传入 `handle` 函数，该函数从信道中读出一个值，然后处理请求，最后再向信道写入以使“信号量”可用，以便响应下一次处理。该信道的缓冲区容量决定了并发调用 `process` 函数的上限，因此在信道初始化时，需要传入相应的容量参数。

```
var sem = make(chan int, MaxOutstanding)

func handle(r *Request) {
    sem <- 1    // Wait for active queue to drain.
    process(r)  // May take a long time.
    <-sem       // Done; enable next request to run.
}

func Serve(queue chan *Request) {
    for {
        req := <-queue
        go handle(req)  // Don't wait for handle to finish.
    }
}
```

一旦有 `MaxOutstanding` 个处理程序正在执行 `process`，缓冲区已满的信道的操作都暂停接收更多操作，直到至少一个程序完成并从缓冲区接收。

然而，它却有个设计问题：尽管只有 `MaxOutstanding` 个 goroutine 能同时运行，但 Serve 还是为每个进入的请求都创建了新的 goroutine 。其结果就是，若请求来得很快，该程序就会无限地消耗资源。为了弥补这种不足，我们可以通过修改 Serve 来限制创建 goroutine，这是个明显的解决方案，但要当心我们修复后出现的 Bug。

```
func Serve(queue chan *Request) {
    for req := range queue {
        sem <- 1
        go func() {
            process(req) // Buggy; see explanation below.
            <-sem
        }()
    }
}
```

Bug 出现在 Go 的 for 循环中，该循环变量在每次迭代时会被重用，因此 `req` 变量会在所有的 goroutine 间共享，这不是我们想要的。我们需要确保 `req` 对于每个 goroutine 来说都是唯一的。有一种方法能够做到，就是将 `req` 的值作为实参传入到该 goroutine 的闭包中：

```
func Serve(queue chan *Request) {
    for req := range queue {
        sem <- 1
        go func(req *Request) {
            process(req)
            <-sem
        }(req)
    }
}
```

比较前后两个版本，观察该闭包声明和运行中的差别。 另一种解决方案就是以相同的名字创建新的变量，如例中所示：

```
func Serve(queue chan *Request) {
    for req := range queue {
        req := req // Create new instance of req for the goroutine.
        sem <- 1
        go func() {
            process(req)
            <-sem
        }()
    }
}
```

它的写法看起来有点奇怪：

```
req := req
```

**但在 Go 中这样做是合法且常见的。你用相同的名字获得了该变量的一个新的版本， 以此来局部地刻意屏蔽循环变量，使它对每个 goroutine 保持唯一**。

回到编写服务器的一般问题上来。另一种管理资源的好方法就是启动固定数量的 handle goroutine，一起从请求信道中读取数据。goroutine 的数量限制了同时调用 process 的数量。Serve 同样会接收一个通知退出的信道， 在启动所有 goroutine 后，它将阻塞并暂停从信道中接收消息。

```
func handle(queue chan *Request) {
    for r := range queue {
        process(r)
    }
}

func Serve(clientRequests chan *Request, quit chan bool) {
    // 启动处理程序
    for i := 0; i < MaxOutstanding; i++ {
        go handle(clientRequests)
    }
    <-quit  // 等待通知退出。
}
```

### 14.4 Channel 类型的 Channel

Go 最重要的特性就是信道是一等公民（first-class value），它可以被分配并像其它值到处传递。 这种特性通常被用来实现安全、并行的多路分解。

在上一节的例子中，`handle` 是个非常理想化的请求处理程序， 但我们并未定义它所处理的请求类型。若该类型包含一个可用于回复的信道，那么每一个客户端都能为其回应提供自己的路径。这里提供一个简单的 `Request` 类型的框架定义。

```
type Request struct {
    args        []int
    f           func([]int) int
    resultChan  chan int
}
```

客户端提供了一个函数及其实参，此外在请求对象中还有个接收应答的信道。

```
func sum(a []int) (s int) {
    for _, v := range a {
        s += v
    }
    return
}

request := &Request{[]int{3, 4, 5}, sum, make(chan int)}
// Send request
clientRequests <- request
// Wait for response.
fmt.Printf("answer: %d\n", <-request.resultChan)
```

服务端我们只修改 `handle` 函数：

```
func handle(queue chan *Request) {
    for req := range queue {
        req.resultChan <- req.f(req.args)
    }
}
```

要使其实际可用还有很多工作要做，但是这套代码已经可以作为一类对速度要求不高、并行、非阻塞式 `RPC` 系统的实现框架了，而且它并不包含互斥锁。

### 14.5 并行

这些设计的另一个应用是在多 CPU 核心上实现并行计算。如果计算过程能够被分为几块可独立执行的过程，它就可以在每块计算结束时向信道发送信号，从而实现并行处理。

让我们看看这个理想化的例子。我们在对一系列向量项进行极耗资源的操作，而每个项的值计算是完全独立的。

```
type Vector []float64

// Apply the operation to v[i], v[i+1] ... up to v[n-1].
func (v Vector) DoSome(i, n int, u Vector, c chan int) {
    for ; i < n; i++ {
        v[i] += u.Op(v[i])
    }
    c <- 1    // signal that this piece is done
}
```

我们在循环中启动了独立的处理块，每个 CPU 将执行一个处理。 它们有可能以乱序的形式完成并结束，但这没有关系； 我们只需在所有 goroutine 开始后接收，并统计信道中的完成信号即可。

```
const numCPU = 4 // number of CPU cores

func (v Vector) DoAll(u Vector) {
    c := make(chan int, numCPU)  // Buffering optional but sensible.
    for i := 0; i < numCPU; i++ {
        go v.DoSome(i*len(v)/numCPU, (i+1)*len(v)/numCPU, u, c)
    }
    // Drain the channel.
    for i := 0; i < numCPU; i++ {
        <-c    // wait for one task to complete
    }
    // All done.
}
```

除了直接设置 `numCPU` 常量值以外，我们还可以向 `runtime` 询问一个合理的值。函数 [runtime.NumCPU](https://go.dev/pkg/runtime#NumCPU) 可以返回硬件 CPU 上的核心数量，如此使用：

```
var numCPU = runtime.NumCPU()
```

另外一个需要知道的函数是 [runtime.GOMAXPROCS](https://go.dev/pkg/runtime#GOMAXPROCS)，它报告（或设置）一个 Go 应用在同时运行时用户特定的 CPU 核数。默认情况下使用 runtime.NumCPU 的值，但是可以被命令行环境变量，或者调用此函数并传参正整数。传参 0 的话会查询并返回该值，假如说我们尊重用户对资源的分配，就应该这么写：

```
var numCPU = runtime.GOMAXPROCS(0)
```

注意不要混淆并发（concurrency）和并行（parallelism）的概念：并发是用可独立执行组件构造程序的方法， 而并行则是为了效率在多 CPU 上平行地进行计算。尽管 Go 的并发特性能够让某些问题更易构造成并行计算， 但 Go 仍然是种并发而非并行的语言，且 Go 的模型并不适合所有的并行问题。 关于其中区别的讨论，见[此博文](https://blog.golang.org/2013/01/concurrency-is-not-parallelism.html)。

### 14.6 一个 “Leaky Buffer” 的示例

并发编程的工具甚至能很容易地表达非并发的思想。这里有个提取自 `RPC` 包的例子。 客户端 goroutine 从某些来源，可能是网络中循环接收数据。为避免分配和释放缓冲区， 它保存了一个空闲链表，使用一个带缓冲信道表示。若信道为空，就会分配新的缓冲区。 一旦消息缓冲区就绪，它将通过 serverChan 被发送到服务器。

```
var freeList = make(chan *Buffer, 100)
var serverChan = make(chan *Buffer)

func client() {
    for {
        var b *Buffer
        // Grab a buffer if available; allocate if not.
        select {
        case b = <-freeList:
            // Got one; nothing more to do.
        default:
            // None free, so allocate a new one.
            b = new(Buffer)
        }
        load(b)              // Read next message from the net.
        serverChan <- b      // Send to server.
    }
}
```

服务器端循环从客户端接收并处理每个消息，然后将 `Buffer` 对象返回到空闲链表中。

```
func server() {
    for {
        b := <-serverChan    // Wait for work.
        process(b)
        // Reuse buffer if there's room.
        select {
        case freeList <- b:
            // Buffer on free list; nothing more to do.
        default:
            // Free list full, just carry on.
        }
    }
}
```

客户端试图从 `freeList` 中获取缓冲区；若没有缓冲区可用， 它就将分配一个新的。服务器将 `b` 放回空闲列表 `freeList` 中直到列表已满，此时缓冲区将被丢弃，并被垃圾回收器回收。（`select` 语句中的 `default` 子句在没有条件符合时执行，这也就意味着 `selects` 永远不会被阻塞。）依靠带缓冲的信道和垃圾回收器的记录， 我们仅用短短几行代码就构建了一个限流漏桶。

## 15. 错误

库函数很多时候必须将错误信息返回给函数的调用者。如前所述，Go 允许函数可以有多个返回值的特性，使得函数的调用者在得到正常返回值的同时，可以获取到更为详细的错误信息。对库函数的设计者来说，一种推荐的做法是使用该特性来提供详细的异常信息。 例如，`os.Open` 在异常时并不仅仅返回一个 `nil` 指针，它同时会返回一个错误值，用于描述是什么原因导致了异常的发生。

按照约定，错误的类型通常为 `error`，这是一个内置的简单接口：

```
type error interface {
    Error() string
}
```

库的开发者可以自由地用更丰富的模型实现这个接口，这样不仅可以看到错误，还可以提供一些上下文。如前所述，除了通常的 `*os.File` 返回值外，`os.Open` 还返回一个错误值。如果文件被成功打开，错误将为 `nil`，但是当出现问题时，它将返回一个 `os.PathError` 的错误，就像这样：

```
// PathError records an error and the operation and
// file path that caused it.
type PathError struct {
    Op string    // "open", "unlink", etc.
    Path string  // The associated file.
    Err error    // Returned by the system call.
}

func (e *PathError) Error() string {
    return e.Op + " " + e.Path + ": " + e.Err.Error()
}
```

`PathError` 的 `Error` 会生成如下错误信息：

```
open /etc/passwx: no such file or directory
```

这种错误包含了出错的文件名、操作和触发的操作系统错误。可见即便输出错误信息时已经远离导致错误的调用，它也会非常有用，这比简单的 “不存在该文件或目录” 包含的信息丰富得多。

错误字符串应尽可能地指明它们的来源，例如产生该错误的包名前缀。例如在 `image` 包中，由于未知格式导致解码错误的字符串为 `image: unknown format`（未知的格式）。

若调用者关心错误的完整细节，可使用类型选择或者类型断言来查看特定错误，并抽取其细节。比如 `PathErrors`，它你可能会想检查内部的 `Err` 字段来判断这是否是一个可以被恢复的错误：

```
for try := 0; try < 2; try++ {
    file, err = os.Create(filename)
    if err == nil {
        return
    }
    if e, ok := err.(*os.PathError); ok && e.Err == syscall.ENOSPC {
        deleteTempFiles()  // Recover some space.
        continue
    }
    return
}
```

这里的第二条 `if` 是另一种方式，称为[类型断言](https://go.dev/doc/effective_go#interface_conversions)。若它失败，`ok` 将为 `false`，而 `e` 则为 `nil`. 若它成功，`ok` 将为 `true`。类型断言若成功，则该错误必然属于 `*os.PathError` 类型，而 `e` 能够检测关于该错误的更多信息。

### 15.1 Panic

向调用者报告错误的一般方式就是将 `error` 作为额外的值返回。 标准的 `Read` 方法就是个众所周知的实例，它返回一个字节计数和一个 `error`。但如果错误是不可恢复的呢？有时程序就是不能继续运行。

为此，我们提供了内建的 `panic` 函数，它会产生一个运行时错误并终止程序 （但请继续看下一节）。该函数接受一个任意类型的实参（一般为字符串），并在程序终止时打印。 它还能表明发生了意料之外的事情，比如从无限循环中退出了：

```
// A toy implementation of cube root using Newton's method.
func CubeRoot(x float64) float64 {
    z := x/3   // Arbitrary initial value
    for i := 0; i < 1e6; i++ {
        prevz := z
        z -= (z*z*z-x) / (3*z*z)
        if veryClose(z, prevz) {
            return z
        }
    }
    // A million iterations has not converged; something is wrong.
    panic(fmt.Sprintf("CubeRoot(%g) did not converge", x))
}
```

这仅仅是个示例，真正的库函数应避免 `panic`。若问题可以被屏蔽或解决， 最好就是让程序继续运行而不是终止整个程序。一个可能的反例就是初始化：若某个库真的不能让自己工作，且有足够理由产生 `Panic`，那就由它去吧：

```
var user = os.Getenv("USER")

func init() {
    if user == "" {
        panic("no value for $USER")
    }
}
```

### 15.2 Recover

当 `panic` 被调用后（包括不明确的运行时错误，例如切片越界访问或类型断言失败），它将立刻中断当前函数的执行，并展开当前 Goroutine 的调用栈，依次执行之前注册的 `defer` 函数。当栈展开操作达到该 Goroutine 栈顶端时，程序将终止。但这时仍然可以使用 Go 的内建 `recover 方法重新获得 Goroutine 的控制权，并将程序恢复到正常执行的状态。

调用 `recover` 方法会终止栈展开操作并返回之前传递给 `panic` 方法的那个参数。由于在栈展开过程中，只有 `defer` 型函数会被执行，因此 `recover` 的调用必须置于 `defer` 函数内才有效。

在下面的示例应用中，调用 `recover` 方法会终止 `server` 中失败的那个 Goroutine，但 `server` 中其它的 Goroutine 将继续执行，不受影响：

```
func server(workChan <-chan *Work) {
    for work := range workChan {
        go safelyDo(work)
    }
}

func safelyDo(work *Work) {
    defer func() {
        if err := recover(); err != nil {
            log.Println("work failed:", err)
        }
    }()
    do(work)
}
```

在这里例子中，如果 `do(work)` 调用发生了 `panic`，则其结果将被记录且发生错误的那个 Goroutine 将干净地退出，不会干扰其它 Goroutine。你不需要在 `defer` 指示的闭包中做别的操作，仅需调用 `recover` 方法，它将帮你搞定一切。

只有直接在 `defer` 函数中调用 `recover` 方法，才会返回非 `nil` 的值，因此 `defer` 函数的代码可以调用那些本身使用了 `panic` 和 `recover` 的库函数而不会引发错误。还用上面的那个例子说明：`safelyDo` 里的 `defer` 函数在调用 `recover` 之前可能调用了一个日志记录函数，而日志记录程序的执行将不受 `panic` 状态的影响。

有了错误恢复的模式，`do` 函数及其调用的代码可以通过调用 `panic` 方法，以一种很干净的方式从错误状态中恢复。我们可以使用该特性为那些复杂的软件实现更加简洁的错误处理代码。让我们来看下面这个例子，它是 `regexp` 包的一个简化版本，它通过调用 `panic` 并传递一个局部错误类型来报告“解析错误”（`Parse Error`）。下面的代码包括了 `Error` 类型定义，`error` 处理方法以及 `Compile` 函数：

```
// Error is the type of a parse error; it satisfies the error interface.
type Error string
func (e Error) Error() string {
    return string(e)
}

// error is a method of *Regexp that reports parsing errors by
// panicking with an Error.
func (regexp *Regexp) error(err string) {
    panic(Error(err))
}

// Compile returns a parsed representation of the regular expression.
func Compile(str string) (regexp *Regexp, err error) {
    regexp = new(Regexp)
    // doParse will panic if there is a parse error.
    defer func() {
        if e := recover(); e != nil {
            regexp = nil    // Clear return value.
            err = e.(Error) // Will re-panic if not a parse error.
        }
    }()
    return regexp.doParse(str), nil
}
```

如果 `doParse` 方法触发 `panic`，错误恢复代码会将返回值置为 `nil` -- 因为 `defer` 函数可以修改命名的返回值变量；然后，错误恢复代码会对返回的错误类型进行类型断言，判断其是否属于 `Error` 类型。如果类型断言失败，则会引发运行时错误，并继续进行栈展开，最后终止程序 —— 这个过程将不再会被中断。类型检查失败可能意味着程序中还有其他部分触发了 `panic`，如果某处存在索引越界访问等，因此，即使我们已经使用了 `panic` 和 `recover` 机制来处理解析错误，程序依然会异常终止。

有了上面的错误处理过程，调用 `error` 方法（由于它是一个类型的绑定的方法，因而即使与内建类型 `error` 同名，也不会带来什么问题，甚至是一直更加自然的用法）使得“解析错误”的报告更加方便，无需费心去考虑手工处理栈展开过程的复杂问题：

```
if pos == 0 {
    re.error("'*' illegal at start of expression")
}
```

上面这种模式的妙处在于，它完全被封装在模块的内部，`Parse` 方法将其内部对 `panic` 的调用隐藏在 `error` 之中；而不会将 `panics` 信息暴露给外部使用者。这是一个设计良好且值得学习的编程技巧。

顺便说一下，当确实有错误发生时，我们习惯采取的“重新触发 `panic”（re-panic）`的方法会改变 `panic` 的值。但新旧错误信息都会出现在崩溃报告中，引发错误的原始点仍然可以找到。所以，通常这种简单的重新触发 `panic` 的机制就足够了—所有这些错误最终导致了程序的崩溃—但是如果只想显示最初的错误信息的话，你就需要稍微多写一些代码来过滤掉那些由重新触发引入的多余信息。这个功能就留给读者自己去实现吧！

## 16. 示例：Web 服务器

让我们以一个完整的 Go 程序示例 —— 一个web服务 —— 来作为这篇文档的结尾。事实上，这个例子其实是一类 “Web re-server”，也就是说它其实是对另一个Web服务的封装。谷歌公司提供了一个用来自动将数据格式化为图表或图形的在线服务，其网址是：`http://chart.apis.google.com`。这个服务使用起来其实有点麻烦 —— 你需要把数据添加到URL中作为请求参数，因此不易于进行交互操作。我们现在的这个程序会为用户提供一个更加友好的界面来处理某种形式的数据：对于给定的一小段文本数据，该服务将调用图标在线服务来产生一个 QR 码，它用一系列二维方框来编码文本信息。可以用手机摄像头扫描该 QR 码并进行交互操作，比如将 URL 地址编码成一个 QR 码，你就省去了往手机里输入这个 URL 地址的时间。

下面是完整的程序代码，后面会给出详细的解释：

```
package main

import (
    "flag"
    "html/template"
    "log"
    "net/http"
)

var addr = flag.String("addr", ":1718", "http service address") // Q=17, R=18

var templ = template.Must(template.New("qr").Parse(templateStr))

func main() {
    flag.Parse()
    http.Handle("/", http.HandlerFunc(QR))
    err := http.ListenAndServe(*addr, nil)
    if err != nil {
        log.Fatal("ListenAndServe:", err)
    }
}

func QR(w http.ResponseWriter, req *http.Request) {
    templ.Execute(w, req.FormValue("s"))
}

const templateStr = `
<html>
<head>
<title>QR Link Generator</title>
</head>
<body>
{{if .}}
<img src="http://chart.apis.google.com/chart?chs=300x300&cht=qr&choe=UTF-8&chl={{.}}" />
<br>
{{.}}
<br>
<br>
{{end}}
<form action="/" name=f method="GET">
    <input maxLength=1024 size=70 name=s value="" title="Text to QR Encode">
    <input type=submit value="Show QR" name=qr>
</form>
</body>
</html>
`
```

`main` 函数之前的部分很容易理解。包 `flag` 用来为我们这个服务设置默认的HTTP端口。从模板变量 `templ` 开始进入了比较好玩的部分，它的功能是用来构建一个 `HTML` 模板，该模板被我们的服务器处理并用来显式页面信息；我们后面还会看到更多细节。

`main` 函数使用我们之前介绍的机制来解析 `flag`，并将函数 `QR` 绑定到我们服务的根路径。然后调用 `http.ListenAndServe` 方法启动服务；该方法将在服务器运行过程中一直处于阻塞状态。

`QR` 函数用来接收包含格式化数据的请求信息，并以该数据 `s` 为参数对模板进行实例化操作。

模板包 `html/template` 的功能非常强大；上述程序仅仅触及其冰山一角。本质上说，它会根据传入 `templ.Execute` 方法的参数，在本例中是格式化数据，在后台替换相应的元素并重新生成 HTML 文本。在模板文本（templateStr）中，双大括号包裹的区域意味着需要进行模板替换动作。在 `{{if .}}` 和 `{{end}}` 之间的部分只有在当前数据项，也就是 `.`，不为空时才被执行。也就是说，如果对应字符串为空，内部的模板信息将被忽略。

代码片段 `{{.}}` 表示在页面中显示传入模板的数据 —— 也就是查询字符串本身。HTML 模板包会自动提供合适的处理方式，使得文本可以安全的显示。

模板串的剩余部分就是将被加载显示的普通 HTML 文本。如果你觉得这个解释太笼统了，可以进一步参考 Go 文档中，关于模板包的深入讨论。

看，仅仅用了很少量的代码加上一些数据驱动的 HTML 文本，你就搞定了一个很有用的 web 服务。这就是 Go 语言的牛X之处：用很少的一点代码就能实现很强大的功能。

## Reference

- [Effective Go](https://go.dev/doc/effective_go)
- [高效的 Go 编程 Effective G](https://learnku.com/docs/effective-go/2020)
- [Effective Go　中文版](https://www.kancloud.cn/kancloud/effective/72199)