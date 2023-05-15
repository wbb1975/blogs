# Strings, bytes, runes and characters in Go

**Rob Pike**
**2013-10-23**

## 介绍

前面的博文[数组，切片（字符串）：'append' 的运作机制](https://blog.golang.org/slices)解释了 Go 中切片如何工作，使用了一些例子演示了它们的实现背后的机制。在那个背景之上，这篇文章讨论 Go 中的字符串。首先，对一篇博文字符串是一个简单的主题，但是如果想把它用的好则不仅需要了解它如何工作，而且需要了解字节，字符以及 `rune` 的区别，`Unicode` 和 `UTF-8` 的区别，字符串与字符串字面量的区别，甚至一些其它很微妙的差异。

处理这个主题的一种方式时将其视为对常见问题 `“当我用 n 来索引一个字符串时，为什么我没有得到第 n 个字符？”` 的一个解答。正如你将看到的，这个问题带给我们许多关于在现代世界文本如何工作的细节。

对这些问题的一个优秀回答，不依赖于 Go，是 Joel Spolsky 的博文[每一个软件开发人员必须知道的基本知识，必须知道的 Unicode 与字符集](http://www.joelonsoftware.com/articles/Unicode.html)。很多观点将在这里再次提到。

## 什么是字符串？

让我们从一些基础知识开始。

在 Go 中，**字符串实际上是一个只读字节切片**。如果你对什么是字节切片以及它如何工作不清楚，请阅读上一篇博文[数组，切片（字符串）：'append' 的运作机制](https://blog.golang.org/slices)。我们假设你已经拥有了这些知识。

预先声明一个字符串持有任意字节很重要。它无须持有 Unicode 文本，`UTF-8` 文本或者其它预定义的格式。只要关注字符串的内容，它就与一个字节切片等同。

这里有一个字符串字面量（稍后我们将讨论更多）使用 `\xNN` 标记来定义一个持有一些特殊字节值的字符串常量。（当然，字节值范围可以从 `00` 至 `FF`。）

```
 const sample = "\xbd\xb2\x3d\xbc\x20\xe2\x8c\x98"
```

## 打印字符串

因为在我们的示例字符串中的字节不是有效的 ASCII 码，甚至也不是有效的 UTF-8 码，直接打印字符串将产生丑陋的输出。简单的打印语句：

```
fmt.Println(sample)
```

产生这个混乱的输出（它的准确输出可能随环境改变）：

```
��=� ⌘
```

为了找到字符串实际持有什么，我们需要把它分开并检查其片段。有几种方式来做这个。最明显的方式是迭代其内容并打印单个字节，就像下面这个循环：

```
for i := 0; i < len(sample); i++ {
    fmt.Printf("%x ", sample[i])
}
```

正如先前暗示的，索引一个字符串将访问单个字节而非字符。下面我们将更详细地讨论这个主题。现在，让我们专注于字节。这是逐字节循环的输出：

```
bd b2 3d bc 20 e2 8c 98
```

注意单独的字节如何匹配定义在字符串里的十六进制转义符。

一个更简单的为一个凌乱的字符串产生可呈现输出的方法是使用 `fmt.Printf` 的 `%x`（十六进制）格式符。它仅仅将字符串的顺序字节以十六进制数字形式输出，每字节两个。

```
fmt.Printf("%x\n", sample)
```

可以与上面的输出比较：

```
bdb23dbc20e28c98
```

一个很好的小窍门是在格式中使用一个“空格”标记--在 `%` 和 `x` 之间放置一个空格。比较这里以上面使用的格式串：

```
fmt.Printf("% x\n", sample)
```

请注意输出的字节以及其间的空格，使得结果不那么令人难忘了：

```
bd b2 3d bc 20 e2 8c 98
```

还有更多--`%q`（引用）动词将转义一个字符串中的非打印字节序列，因此输出时很清楚的：

```
fmt.Printf("%q\n", sample)
```

当字符串的大部分是可理解文本时，这个技术是很方便的。但也有一些古怪的需要排除。它产生输出如下：

```
"\xbd\xb2=\xbc ⌘"
```

如果我们稍加关注，我们可以看到埋藏在噪音里的 ASCII 等号以及一个常规空格，在末尾出现了一个众所周知的瑞典名胜古迹符号。这个符号拥有 Unicode 值 `U+2318`，由空格（十六进制值`20`）后的字节：`e2 8c 98` 编码为 UTF-8 字符。

如果我们对字符串中的奇怪值不熟悉或感到迷惑，我们可以在 `%q` 动词上使用加号标记。这个标记使得输出转义非打印序列，非 ASCII 字节，以及整体 UTF-8 值。结果是它暴露了格式良好的 UTF-8 的 Unicode 值，非 ASCII 数据以字符串形式呈现：

```
fmt.Printf("%+q\n", sample)
```

利用这种格式，瑞典符号的 Unicode 值以一个 `\u` 转义符的形式出现：

```
"\xbd\xb2=\xbc \u2318"
```

这些打印技术在调试字符串内容时是很好的，在下面的讨论中也很方便。也值得指出所有这些方法对字符串和字节切片行为完全一致。

下面是我们列出的完整打印选项，作为一个完整的程序你可以在浏览器中运行（编辑它）：

```
package main

import "fmt"

func main() {
    const sample = "\xbd\xb2\x3d\xbc\x20\xe2\x8c\x98"

    fmt.Println("Println:")
    fmt.Println(sample)

    fmt.Println("Byte loop:")
    for i := 0; i < len(sample); i++ {
        fmt.Printf("%x ", sample[i])
    }
    fmt.Printf("\n")

    fmt.Println("Printf with %x:")
    fmt.Printf("%x\n", sample)

    fmt.Println("Printf with % x:")
    fmt.Printf("% x\n", sample)

    fmt.Println("Printf with %q:")
    fmt.Printf("%q\n", sample)

    fmt.Println("Printf with %+q:")
    fmt.Printf("%+q\n", sample)
}
```

【作业：修改上面的示例使用字节切片来代替字符串。提示：使用转换来创建切片。】

```
Println:
��=� ⌘
Byte loop:
bd b2 3d bc 20 e2 8c 98 
Printf with %x:
bdb23dbc20e28c98
Printf with % x:
bd b2 3d bc 20 e2 8c 98
Printf with %q:
"\xbd\xb2=\xbc ⌘"
Printf with %+q:
"\xbd\xb2=\xbc \u2318"
```

【作业：循环迭代字符串使用 `%q` 来打印每一个字节。输出告诉了我们什么？】

## UTF-8 以及字符串字面

我们已经看到，索引字符串返回其字节值，而不是其所含字符：一个字符串仅仅是一串字节值。这意味着当我们在存储一个字符串中的字符时，我们实际存储其一次性字节表示。让我们通过一个更受控的例子来看这是如何发生的。

这是一个简单的应用，它用三种方式打印一个仅含一个字符的字符串常量，一次作为单纯的字符串，一次作为仅包含 ACSCII 的引用字符串，一次作为十六进制字节序列。为了避免混淆，我们创建了一个**原始字符串**，以 **\`** 包围，因此它可以只包含字面量文本。（常规字符串，通常由双引号括起来，可以包括我们上面展示的转义序列。）

```
func main() {
    const placeOfInterest = `⌘`

    fmt.Printf("plain string: ")
    fmt.Printf("%s", placeOfInterest)
    fmt.Printf("\n")

    fmt.Printf("quoted string: ")
    fmt.Printf("%+q", placeOfInterest)
    fmt.Printf("\n")

    fmt.Printf("hex bytes: ")
    for i := 0; i < len(placeOfInterest); i++ {
        fmt.Printf("%x ", placeOfInterest[i])
    }
    fmt.Printf("\n")
}
```

输出如下：

```
plain string: ⌘
quoted string: "\u2318"
hex bytes: e2 8c 98
```

它提示我们 Unicode 字符值 `U+2318`，名胜古迹符号 `⌘`，由字节序列 `e2 8c 98` 表示，这些字节是十六进制数 `2318` 的 UTF-8 编码表示。

这可能很明显，也可能很微妙，取决于你对 UTF-8 的熟悉程度，但值得花一点时间来解释字符串的 UTF-8 呈现是如何创建的。简单的事实就是：当源代码被编写时它就被创建出来了。

Go 中的源代码被定义为 UTF-8 文本，其它格式不被允许。这暗示着当我们在源代码中写出：

```
`⌘`
```

创建应用的文本编辑器将把符号 ⌘ 的 UTF-8 编码表示放进源文本中。当我们打印十六进制字节时，我们实际上仅仅输出编辑器放置在文件中的数据。

简言之，Go 源代码是 UTF-8，因此字符串字面量的源代码是 UTF-8 文本。如果字符串字面量不包含转义序列--原始字符串就是这样--构造的字符串刚好持有引号之间的源文本。因此，通过定义和构造，原始字符串总是包含其内容的有效 UTF-8 表示。类似地，除非它包含如前面章节提到的非 UTF-8 转义符，一个常规字符串字面量总是包含有效地 UTF-8。

**一些人认为 Go 字符串总是 UTF-8，但是它们不是：仅仅字符串字面量是 UTF-8，正如上面章节所示，字符串值可以包含任意字节；如我们这里所说，只要不包含字节级别转义符，字符串字面量总是 UTF-8 文本**。

**总结一下，字符串能够包含任意字节，但当从字符串字面量构造时，这些字节（几乎总是）是 UTF-8**。

## 码点，字符 以及 runes

截至目前在使用文字“字节”和“字符”上我们非常谨慎。这部分源于字符串持有字节，也部分源于定义什么是“字符”有点困难。Unicode 标准使用术语`“码点”`来引用由一个单一值代表的项。码点 `U+2318`，其十六进制值 `2318`，代表符号 `⌘`。（更多关于码点的信息，请参见[它的码点页](http://unicode.org/cldr/utility/character.jsp?a=2318)）

选择一个更普通的例子，Unicode 码点 `U+0061` 是拉丁字符 ‘A’ 的小写: `a`。

但小写沉音符 ‘A’, `à` 又如何呢？那是一个字符，它也是一个码点（`U+00E0`），但它有其它的代表方式。例如，我们可以使用组合的沉音符 `U+0300`，将其附在小写字符 `a`, `U+0061` 之后以创建同样的字符 `à`。基本上，一个字符可由许多不同的码点序列代表，并由此产生不同的  UTF-8 字节。

计算中的字符概念因此很含混，至少是混淆的，因此我们要小心使用它们。为了使情况可靠，有一些标准化技术来确保一个给定字符总是由同一个码点代表，但这个话题离我们今天要讨论的主题很远。稍后的博文将解释 Go 库如何处理标准化。

码点有点拗口，因此 Go 为这个概念引入了一个更短的术语：`rune`。这个术语在库和源代码里出现，具有与码点完全一样的意义，另带有一点有意思的加成。

Go 语言定义单词 `rune` 作为 `int32` 的别名，由此程序员在一个整形数代表一个码点时会很清楚。而且，在 Go 中你可以把一个字符常量视为一个 `rune` 常量。下面的表达式的类型和值

```
'⌘'
```

是整型值为 `0x2318` 的 rune。

总结如下，有一些突出的点：

- **Go 源代码总是 UTF-8**
- **一个字符串持有任意字节值**
- **字符串字面量，如果没有字节级别转义，总是持有有效的 UTF-8 序列**
- **这些序列代表 Unicode 码点，也即 `runes`**
- **在  Go 中无法确保字符串中的字符是标准化的**

## 范围循环（Range loops）

除了公理性的细节如 Go 源代码是 UTF-8，有一个唯一方式 Go 可以特别对待 UTF-8，即使用 `for` 范围循环（`for range loop`）一个字符串。

我们已经看到了一个常规 `for loop` 会发生什么。相反，一个 `for range loop`，每次迭代都会解码一个 `UTF-8-encoded rune`。在迭代过程中，迭代的索引是当前 rune 的以字节度量的开始点，其值为码点。下面这个例子使用另一个方便的 `Printf` 格式, `%#U`，它显示码点的 Unicode 值及其打印呈现。

```
 const nihongo = "日本語"
for index, runeValue := range nihongo {
    fmt.Printf("%#U starts at byte position %d\n", runeValue, index)
}
```

输出显示每个码点拥有多个字节：

```
U+65E5 '日' starts at byte position 0
U+672C '本' starts at byte position 3
U+8A9E '語' starts at byte position 6
```

【练习：在字符串里放置一个无效UTF-8字节序列。(怎么放?)循环会发生什么？】

```
 const nihongo = "日本\xbd語"
for index, runeValue := range nihongo {
    fmt.Printf("%#U starts at byte position %d\n", runeValue, index)
}
```

输出：

```
U+65E5 '日' starts at byte position 0
U+672C '本' starts at byte position 3
U+FFFD '�' starts at byte position 6
U+8A9E '語' starts at byte position 7
```

## 库

Go 标准库提供了对 UTF-8 文本解释的强大支持。如果一个 `for range loop` 仍不能满足你的需求，库中的包可以满足你。

此类最重要的一个包是 [unicode/utf8](https://go.dev/pkg/unicode/utf8/)，它包含一些常规函数如验证，解码即及编码 UTF-8 字符串。下面这个应用功能和上面的 `for range` 一样，但使用了 `DecodeRuneInString` 来做实际的工作。函数的返回值是一个 `rune` 以及其 UTF-8 编码字节宽度。

```
const nihongo = "日本語"
for i, w := 0, 0; i < len(nihongo); i += w {
    runeValue, width := utf8.DecodeRuneInString(nihongo[i:])
    fmt.Printf("%#U starts at byte position %d\n", runeValue, i)
    w = width
}
```

运行它看看功能是否一样。`for range loop` 和 `DecodeRuneInString` 被定义产生完全一样的迭代序列。

看看 `unicode/utf8` 的[文档](https://go.dev/pkg/unicode/utf8/)，了解它提供了哪些其它方便的功能。

## 结论

为了回答在文章开头提出的问题：字符串由字节构成，当索引它时将产生字节而非字符。一个字符串甚至可能不持有字符。事实上，“character” 的定义有些含混，解决这个含混的一个错误就是定义字符串由字符构成。

关于 Unicode, UTF-8以及多语言文本处理的世界，我们可以谈论更多，但另开一篇博文可能更合适。到现在为止，我们希望你对 Go 字符串的行为，以及它们可能包含任意字节值有一个更好的理解，UTF-8 是它们设计的中心部分。

## Referecnce

- [Strings, bytes, runes and characters in Go](https://go.dev/blog/strings)
- [数组，切片（字符串）：'append' 的运作机制](https://blog.golang.org/slices)
- [The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/)
－　[博文索引](https://go.dev/blog/all)
