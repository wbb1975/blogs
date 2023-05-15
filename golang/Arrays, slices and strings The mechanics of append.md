# 数组，切片（字符串）：'append' 的运作机制

**Rob Pike**
**2013-09-26**

## 介绍

过程式编程语言的一个最常见特性就是数组的概念。数组看起来简单，但在将它们加入到一门语言之前与许多问题需要回答，比如：

- 固定大小还是可变大小？
- 大小是类型的一部分吗？
- 多维数组如何构成？
- 空数组有没有意义？

对这些问题的回答影响了数组是语言特性的一部分或者是语言设计的核心部分。

在 Go 的早期发展阶段，在设计走上正轨之前花费了约一年时间来决定对这些问题的回答。其中关键一步是切片的引入，它构建于固定大小数组之上，提供了一个弹性可扩展的数据结构。但直到今天，Go 新手程序员仍受困于切片的工作方式，可能是其它语言的体验导致了他们的思维混乱。

在本文中我试图厘清这些混淆，我们将通过构建代码片段来解释内建 `append` 函数如何工作，以及为何它以腺癌这种方式工作。

## 数组

Go 中数组是一个重要的构件，但就像建筑的基础一样，它们经常隐藏于其它可见组件之下。在谈论更有趣，更强大以及更突出的切片灵感之前，我们必须简单地介绍它们（数组）。

数组在 Go 程序中很常见，因为数组大小是其类型的一部分，这限制了其表达能力。

下面的声明：

```
var buffer [256]byte
```

声明了变量 `buffer`，它可以容纳 `256` 字节。`buffer` 类型包含其大小，`[256]byte`。一个 `512` 字节的数组是一个截然不同的类型 `[512]byte`。

与一个数组关联的数据是数组的元素。我们的 `buffer` 在内存中呈现如下布局：

```
buffer: byte byte byte ... 256 times ... byte byte byte
```

即这个变量除了持有 `256` 字节数据外不再持有任何东西。我们能够通过熟悉的索引语法访问其元素，`buffer[0]`, `buffer[1]`, 直至 `buffer[255]`。（索引方位从 `0` 至 `255`，包含 256 个元素）试图索引 buffer 范围之外的元素将导致程序崩溃。

有内建函数 `len` 可以返回一个数组，切片或其它一些数据类型的元素数目。对于数组，`len` 返回什么很明显。在我们的例子中，`len(buffer)` 返回固定数值 `256`。

数组有它们的位置--例如它们是转换矩阵的一个很好的表示--但是在 Go 中它们最常见的用途是持有一个切片的存储。

## 切片：切片头

切片是应对方案，但为了把它们用好你必须精确理解它们是什么以及能做什么。

切片是一种数据结构，它描述了独立存储于切片变量自身之外的一个数组内的连续片段。一个切片不是一个数组，一个切片描述了数组的一部分。

考虑前面章节的　`buffer` 数组变量，通过对数组切片我们可以创建一个描述从索引 `100` 至 `150` 的元素（准确说来是从 100 至 149（含））：

```
var slice []byte = buffer[100:150]
```

在一个函数内部我们可以使用短声明格式：

```
slice := buffer[100:150]
```

切片变量到底代表什么？这不是故事的全部，但是从现在开始把切片当作一个小的数据结构，其包含两个元素：一个长度及一个包含指向数组元素的指针。你可以将其视作按如下结构构建：

```
type sliceHeader struct {
    Length        int
    ZerothElement *byte
}

slice := sliceHeader{
    Length:        50,
    ZerothElement: &buffer[100],
}
```

当然，这仅仅是个演示。不管上面的代码说了什么，`sliceHeader` 结构体对程序员来讲是不可见的，元素指针类型依赖于元素类型，但它给出了这种机制的一个概览。

到目前为止我们已经在一个数组上运用了切片操作，但我们也可以在一个切片上做切片，如下所示：

```
slice2 := slice[5:10]
```

如前所示，这个操作创建了一个切片，此例中对原始切片从 `5` 至 `9`（含），它意味着囊括原始数组的 `105` 至 `109` 元素。底层的 `sliceHeader` 数据结构变量 slice2 如下所示：

```
slice2 := sliceHeader{
    Length:        5,
    ZerothElement: &buffer[105],
}
```

注意这个头仍然指向最初的同一存储于 `buffer` 的数组。

我们也可以 `reslice`，即对一个切片做切片并将结果存回最初的 `slice` 结构体，在如下调用之后：

```
slice = slice[5:10]
```

`sliceHeader` 结构体变量 `slice` 看起来就像对 `slice2` 变量所作操作。你将看到 `reslice` 经常被使用，例如截断一个切片。下面的语句将我们的切片的第一及最后一个元素丢弃：

```
slice = slice[1:len(slice)-1]
```

【练习：写出如上赋值之后 sliceHeader 结构体的各项细节】

你将经常听到有经验的 Go 程序员谈论切片头（“slice header”），那是真实存储于一个切片变量里的内容。例如，当你调用一个取一个切片作为参数的函数时，例如 [bytes.IndexRune](https://go.dev/pkg/bytes/#IndexRune)，这个切片头将被传递给函数。在这个调用中：

```
slashPos := bytes.IndexRune(slice, '/')
```

传递给 `IndexRune` 函数的 `slice` 变量实际上就是一个切片头。

在切片头里有额外一个数据项，我们下面将讨论到它，但首先让我们来看看切片头的存在对我们使用切片编程意味着什么。

## 传递切片给函数

虽然切片包含指针，它任然是一个值，理解这一点很重要。表层之下（Under the covers），它是一个结构体值，包含一个指针和长度，它并不是一个指向结构体的指针。

这个很重要。

在前面的例子中我们调用 `IndexRune`，它传递了一个结构体的拷贝。这个行为是一个重要的分歧点。

考虑下面的简单函数：

```
func AddOneToEachElement(slice []byte) {
    for i := range slice {
        slice[i]++
    }
}
```

意如其名，它迭代切片的索引（使用 for range 循环），将每个元素加 `1`。

试试这个：

```
func main() {
    slice := buffer[10:20]
    for i := 0; i < len(slice); i++ {
        slice[i] = byte(i)
    }
    fmt.Println("before", slice)
    AddOneToEachElement(slice)
    fmt.Println("after", slice)
}
```

【如果你想探索更多，你可以编辑并重新执行这个代码片段。】

即使切片头以值的方式传递，头包含了一个指向数组元素的指针。因此，不论传递个函数的最初切片头和切片头拷贝都描述了同一个数组。因此，当函数返回时，修改过的元素能够通过最初的切片变量观察到。

传递给函数的参数确实是一个拷贝，如下例所示：

```
func SubtractOneFromLength(slice []byte) []byte {
    slice = slice[0 : len(slice)-1]
    return slice
}

func main() {
    fmt.Println("Before: len(slice) =", len(slice))
    newSlice := SubtractOneFromLength(slice)
    fmt.Println("After:  len(slice) =", len(slice))
    fmt.Println("After:  len(newSlice) =", len(newSlice))
}
```

运行后输出：

```
Before: len(slice) = 50
After:  len(slice) = 50
After:  len(newSlice) = 49
```

这里我们注意到传递的切片参数的内容可以被调用函数修改，但其头不能。存储于 `slice` 变量的长度未被调用函数修改，原因在于被传递了一个切片头的拷贝而非原始切片头。因此如果我们想编写一个函数来修改切片头，我们必须如我们这里所做的那样返回它作为结果参数。`slice` 变量没有改变但返回值拥有了新的长度－－其存储于 `newSlice`。

## 切片指针：方法接收者

通过函数修改切片头的另一种方式时传递其指针。以下是实现此功能的上面例子的一个变体：

```
func PtrSubtractOneFromLength(slicePtr *[]byte) {
    slice := *slicePtr
    *slicePtr = slice[0 : len(slice)-1]
}

func main() {
    fmt.Println("Before: len(slice) =", len(slice))
    PtrSubtractOneFromLength(&slice)
    fmt.Println("After:  len(slice) =", len(slice))
}
```

上面的例子看起来很笨拙，尤其处理额外的重定向（一个临时变量帮助实现这个），但有一个常见用例你将看到切片指针。惯用法是使用一个指定方法的指针接收者来修改切片。

加入我们拥有一个方法想截掉一个切片最后一个斜线之后的部分，我们可能写出如下代码：

```
type path []byte

func (p *path) TruncateAtFinalSlash() {
    i := bytes.LastIndex(*p, []byte("/"))
    if i >= 0 {
        *p = (*p)[0:i]
    }
}

func main() {
    pathName := path("/usr/bin/tso") // Conversion from string to path.
    pathName.TruncateAtFinalSlash()
    fmt.Printf("%s\n", pathName)
}
```

如果你运行上面的例子，你会看到它正常工作，更新了调用的切片。

【练习：将接受者类型从指针改为值，并重新运行它，并解释发生的事情。】

另一方面，如果我们想编写一个方法来将一个路径中的　ASCII 字符转换为大写（简单忽略非英语名字），这个方法可以是一个值，原因在于值接收者任然指向同一个数组。

```
type path []byte

func (p path) ToUpper() {
    for i, b := range p {
        if 'a' <= b && b <= 'z' {
            p[i] = b + 'A' - 'a'
        }
    }
}

func main() {
    pathName := path("/usr/bin/tso")
    pathName.ToUpper()
    fmt.Printf("%s\n", pathName)
}
```

这里 `ToUpper` 方法在 `for range` 构造中使用两个变量来捕捉索引和切片元素，这种方式避免了在代码块中多次写下 `p[i]`。 

## 容量（Capacity）

看看下面的函数它将作为参数的整数切片扩充一个指定的元素。

```
func Extend(slice []int, element int) []int {
    n := len(slice)
    slice = slice[0 : n+1]
    slice[n] = element
    return slice
}
```

（为什么它需要返回修改过的切片？）现在运行它：

```
func main() {
    var iBuffer [10]int
    slice := iBuffer[0:0]
    for i := 0; i < 20; i++ {
        slice = Extend(slice, i)
        fmt.Println(slice)
    }
}
```

看看切片如何增长至...，等等，它不能工作。

现在是时候讨论切片头的第三个元素了：它的容量。除了数组指针及其长度，切片头也存储其容量。

```
type sliceHeader struct {
    Length        int
    Capacity      int
    ZerothElement *byte
}
```

`Capacity` 字段记录其底层数组实际拥有多少空间，即其 `Length` 可以达到的最大值。试着增长切片至其容量超过数组容量限制将触发一个 `panic`。

当我们由下面的代码创建切片：

```
slice := iBuffer[0:0]
```

其切片头看起来如下：

```
slice := sliceHeader{
    Length:        0,
    Capacity:      10,
    ZerothElement: &iBuffer[0],
}
```

## Make

## Copy

## Append：一个例子

## Append：内建函数

## Nil

## Strings

## 结论

## 更多阅读


## Reference

- [数组，切片（字符串）：'append' 的运作机制](https://go.dev/blog/slices)
- [博文索引](https://go.dev/blog/all)