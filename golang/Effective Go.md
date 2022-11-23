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

但如果我们要像 `Append` 那样将一个切片追加到另一个切片中呢？ 很简单：在调用的地方使用 `...`，就像我们在上面调用 `Output` 那样。以下代码片段的输出与上一个相同。

```
x := []int{1,2,3}
y := []int{4,5,6}
x = append(x, y...)
fmt.Println(x)
```

如果没有 `...`，它就会由于类型错误而无法编译，因为 `y` 不是 `int` 类型的。

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