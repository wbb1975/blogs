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

`Capacity` 字段等于底层数组的长度减去切片的第一个元素在数组中的索引（此例中为0）。如果你想查询一个切片的容量，使用内建函数 `cap`：

```
if cap(slice) == len(slice) {
    fmt.Println("slice is full!")
}
```

## Make

我们如何增长切片至其容量之外？你不能！通过定义，容量是增长的限制。但你可以通过分配一个新的数组，把数据拷贝过去，然后修改切片以描述新的数组取得同样的效果。

让我们从分配开始。我们可以使用内建 `new` 函数来分配一个更大的数组，然后对结果做切片。但是使用内建函数 `make` 会更简单。它一次性分配一个新的数组，并创建一个切片头以描述它。`make` 函数接收三个参数：切片类型，它的初始长度，以及它的容量，它是 `make` 分配以容纳切片数据的数组的长度。下面的调用创建了一个切片，其长度为 `10`，剩余空间为 `5`（15 - 10），你可以运行它以观察结果：

```
slice := make([]int, 10, 15)
fmt.Printf("len: %d, cap: %d\n", len(slice), cap(slice))

len: 10, cap: 15

Program exited.
```

下面的代码片段将一个 int 切片容量增长一倍，但其大小不变：

```
slice := make([]int, 10, 15)
fmt.Printf("len: %d, cap: %d\n", len(slice), cap(slice))
newSlice := make([]int, len(slice), 2*cap(slice))
for i := range slice {
    newSlice[i] = slice[i]
}
slice = newSlice
fmt.Printf("len: %d, cap: %d\n", len(slice), cap(slice))

len: 10, cap: 15
len: 10, cap: 30

Program exited.
```

运行上面的代码之后，切片在执行另一次分配之前拥有更多的空间来增长。

在创建切片时，通常保持长度与容量相同。`make` 对这种使用场景有一种快捷方式。长度默认为其容量，因此你可以忽略它从而将它们设为同样的值。在下面调用之后：

```
gophers := make([]Gopher, 10)
```

gophers 切片长度及其容量都被设置为 10。

## Copy

在前面的章节，我们将切片容量增长一倍，我们创建了一个循环来拷贝旧数据到新的切片。Go 拥有一个内建函数 `copy`，它可以使得这个任务容易。它的参数是两个切片，它从右手边的参数拷贝数据到左手边参数。下面是使用 `copy` 重写的上面的例子：

```
newSlice := make([]int, len(slice), 2*cap(slice))
copy(newSlice, slice)
```

`copy` 函数足够智能。它只拷贝它能够拷贝的数据--它注意到了两个参数的长度。换句话说，它拷贝的元素数目是两个切片长度的最小值，这可以减少一些样本代码。同时，`copy` 返回一个整数值，即拷贝的元素数量，通常它不值得检查。

当源和目标切片有重叠时，`copy` 函数也能做出正确的工作，这意味着它可以用于在一个单一切片中移动数据项。下面演示了如何使用 `copy` 来在一个切片中间插入一个值：

```
// Insert inserts the value into the slice at the specified index,
// which must be in range.
// The slice must have room for the new element.
func Insert(slice []int, index, value int) []int {
    // Grow the slice by one element.
    slice = slice[0 : len(slice)+1]
    // Use copy to move the upper part of the slice out of the way and open a hole.
    copy(slice[index+1:], slice[index:])
    // Store the new value.
    slice[index] = value
    // Return the result.
    return slice
}
```

在这个函数中有一些细节需要引起注意。首先，它当然必须返回更新过的切片，原因在于其长度已经改变；其次，它使用了方便的快捷方式，表达式

```
slice[i:]
```

和下面的完全一样：

```
slice[i:len(slice)]
```

同样地，我们现在人美使用很多魔法，我们也可以忽略掉切片表达式的第一个参数，它默认为0，因此：

```
slice[:]
```

仅意味着切片本身，这对于为任何数组做切片都是有用的。下面的表达式是对“一个描述了数组所有元素的切片”的最简短的方式。

```
array[:]
```

现在无路可走，让我们来运行我们的 Insert 函数：

```
slice := make([]int, 10, 20) // Note capacity > length: room to add element.
for i := range slice {
    slice[i] = i
}
fmt.Println(slice)
slice = Insert(slice, 5, 99)
fmt.Println(slice)
```

## Append：一个例子

几个章节之前，我们写了一个 `Extend` 函数他为一个切片增长一个元素。它是有缺陷的，因为如哦切片的容量太小，函数将崩溃。（我们的 `Insert` 函数有同样的问题）现在来让我们原地修正它，因此让我们来为整形切片编写一个健壮的 `Extend` 实现。

```
func Extend(slice []int, element int) []int {
    n := len(slice)
    if n == cap(slice) {
        // Slice is full; must grow.
        // We double its size and add 1, so if the size is zero we still grow.
        newSlice := make([]int, len(slice), 2*len(slice)+1)
        copy(newSlice, slice)
        slice = newSlice
    }
    slice = slice[0 : n+1]
    slice[n] = element
    return slice
}
```

在这个例子中，返回切片尤其重要，因为当它重新分配时结果切片描述了一个完全不同的数组。下面的代码片段演示了当切片填充时发生了什么：

```
slice := make([]int, 0, 5)
for i := 0; i < 10; i++ {
    slice = Extend(slice, i)
    fmt.Printf("len=%d cap=%d slice=%v\n", len(slice), cap(slice), slice)
    fmt.Println("address of 0th element:", &slice[0])
}
```

注意当初始数组的填充至5时发生的重新分配。当新数组被分配后容量和首元素的地址都发生了改变。

有了健壮的 `Extend` 函数作为指导，我们可以写出更好的函数，让我们来一次扩展切片多个元素。为了实现这个，我们利用了 Go 的在函数调用时将函数参数列表转化为一个切片的能力。即我们利用的 Go 的可变函数设施。

让我们称这个函数为 `Append`。对于第一个版本，我们重复调用 `Extend`，如此可变函数的机制是清楚的。`Append` 签名如下：

```
func Append(slice []int, items ...int) []int
```

它表明 `Append` 接受一个参数，一个切片，后跟 `0` 个多多个整形数。只要我们关注 `Append` 的实现，我们就会发现这些参数实际上就是一个整形切片，如下所示：

```
// Append appends the items to the slice.
// First version: just loop calling Extend.
func Append(slice []int, items ...int) []int {
    for _, item := range items {
        slice = Extend(slice, item)
    }
    return slice
}
```

注意 `for` 范围循环迭代了 `items` 参数的每一个元素，它隐式类型为 `[]int`。也要注意使用空标识符 `_` 丢弃了循环的索引，在这个例子中我们并不需要它。试试它：

```
slice := []int{0, 1, 2, 3, 4}
fmt.Println(slice)
slice = Append(slice, 5, 6, 7, 8)
fmt.Println(slice)
```

这个例子中的一个新技术是我们用一个复合表达式（composite literal）初始化一个切片。它包含了切片的类型后跟包含在括号里的元素。

```
slice := []int{0, 1, 2, 3, 4}
```

`Append` 有趣的还有另一个原因。我们不仅可以扩展元素，我们还可以在调用端使用 `...` 记法将第二个切片扩充为参数：

```
slice1 := []int{0, 1, 2, 3, 4}
slice2 := []int{55, 66, 77}
fmt.Println(slice1)
slice1 = Append(slice1, slice2...) // The '...' is essential!
fmt.Println(slice1)
```

当然，我们可以通过重分配不超过一次使得 `Append` 更高效。如下建立 `Extend` 函数的新内饰：

```
// Append appends the elements to the slice.
// Efficient version.
func Append(slice []int, elements ...int) []int {
    n := len(slice)
    total := len(slice) + len(elements)
    if total > cap(slice) {
        // Reallocate. Grow to 1.5 times the new size, so we can still grow.
        newSize := total*3/2 + 1
        newSlice := make([]int, total, newSize)
        copy(newSlice, slice)
        slice = newSlice
    }
    slice = slice[:total]
    copy(slice[n:], elements)
    return slice
}
```

注意到我们这里使用了两次 `copy`，一次是将切片数据移动到新分配的内存；第二次是拷贝添加的元素到旧数据末尾。

试试它，其行为应该和上面的一致：

```
slice1 := []int{0, 1, 2, 3, 4}
slice2 := []int{55, 66, 77}
fmt.Println(slice1)
slice1 = Append(slice1, slice2...) // The '...' is essential!
fmt.Println(slice1)
```

## Append：内建函数

现在到了我们讨论内建 `append` 函数的设计动机的阶段了。它精确地实现了 `Append` 示例所做的，效率也一样，但它可工作于任何切片类型。

Go 的一个弱点是任何泛型操作必须在运行时提供。可能某一天这会改变，但现在为了使切片工作容易点，Go 提供了内建泛型 `append` 函数。它的工作方式与我们的整形切片一样，但可用于任何切片类型。

记住由于切片头总会被 `append` 调用更新，你需要在调用后保存返回的切片，编译器将让你在调用 `append` 后必须保存返回结果。

下面使逻辑代码与打印代码混杂的代码片段，试着运行它，编辑它并探索更多：

```
 // Create a couple of starter slices.
slice := []int{1, 2, 3}
slice2 := []int{55, 66, 77}
fmt.Println("Start slice: ", slice)
fmt.Println("Start slice2:", slice2)

// Add an item to a slice.
slice = append(slice, 4)
fmt.Println("Add one item:", slice)

// Add one slice to another.
slice = append(slice, slice2...)
fmt.Println("Add one slice:", slice)

// Make a copy of a slice (of int).
slice3 := append([]int(nil), slice...)
fmt.Println("Copy a slice:", slice3)

// Copy a slice to the end of itself.
fmt.Println("Before append to self:", slice)
slice = append(slice, slice...)
fmt.Println("After append to self:", slice)
```

值得花上一点时间最后一段代码以理解切片该如何设计以使得这个简单调用能够正确工作。

在社区构建的 [“Slice Tricks” Wiki 页面](https://go.dev/wiki/SliceTricks) 上有很多 `append`, `copy`, 以及其它使用切片的例子。

## Nil

多说一句，利用我们新发现的知识，我们可以看到一个 `nil` 切片代表什么。自然地，其切片头里的值为零。

```
sliceHeader{
    Length:        0,
    Capacity:      0,
    ZerothElement: nil,
}
```

或仅仅：

```
sliceHeader{}
```

关键细节是元素指针也为 `nil`。下面代码创建的切片：

```
array[0:0]
```

长度为 0（容量也可能为0），但它的指针不是 `nil`，因此它不是一个 `nil` 切片。

应该更清晰一点，一个空的切片可以增长（假设它拥有非零容量），但一个 `nil` 切片没有数组以存放值，因此不能增长以容纳甚至一个值。

那样说来，一个 `nil` 切片功能上与零长度切片相同，即使它不指向任何存储。它拥有长度为零，但通过重新分配可以添加。参考上面的例子可以拷贝一个切片到一个 `nil` 切片看看会如何？

## Strings

现在在 Go 切片的语境下让我们来谈谈字符串。

字符串实际上非常简单：它们实际上是只读字节切片，并从语言级别提供了一些语法支持。

由于它们是只读的，容量是不需要的（你不能增长它们），除此之外，对于大部分使用场景你可以把它当作只读字节切片看待。

对新手来说，我们只能索引它们以访问单独的字节：

```
slash := "/usr/ken"[0] // yields the byte value '/'.
```

我们可以对字符串做切片以获得一个子字符串：

```
usr := "/usr/ken"[0:4] // yields the string "/usr"
```

现在我们对字符串做切片时背后发生了些什么就很明显了。

我们可以拿到一个字节切片，并利用一个简单的转换基于它创建一个字符串：

```
str := string(slice)
```

反向也可以工作：

```
slice := []byte(usr)
```

字符串底层的数组隐藏于里；没有办法访问其内容除非通过字符串。这意味着当我们做上面任何一个转换时，一个数组的拷贝必须被创建出来。当然，Go 帮你做了这些，你自己无须如此。当上面的转换之后，对字节切片的底层数组的修改不会影响对应的字符串。

这种字符串像字节切片风格设计的一个重要后果是创建一个字串效率很高。所有需要做的仅仅是创建一个包含两个整数的字符串头。因为字符串是只读的，原始字符串和基于切片操作派生的子字符串可以安全地共享同一个数组。

一个历史变革：字符串的早期实现总是分配；但是当切片被加进语言之后，它们提供了高效的字符串处理模型。作为结果一些性能基准可以看到巨大的提升。

当然，关于字符串有更多知识点，一个[单独的博文](https://blog.golang.org/strings)更深入地覆盖了它们。

## 结论

为了理解切片如何工作，它帮助了解了它们如何实现。数据结构很简单，切片头，与每一个切片变量关联的数据项，这个头描述了单独分配的数组的一些细节。当我们传递切片值时，切片头被拷贝但是它指向的数组时共享的。

一旦你喜欢上这种工作方式，切片将变得不仅易于使用，而且强大，富有表达力，尤其当有内建 `copy` 和 `append` 函数的帮助时。

## 更多阅读

可以发现很多 Go 中切片相关的知识网络。正如早先提到的，[“Slice Tricks” Wiki 页面](https://go.dev/wiki/SliceTricks)上有很多例子。博文 [Go Slices](https://blog.golang.org/go-slices-usage-and-internals) 用清晰的图片描述了内存布局细节。Russ Cox 的 [Go 数据结构](https://research.swtch.com/godata) 包含了一个关于切片，以及 Go 的一些其它内部数据结构的讨论。

有很多有用的材料，但学习切片最好的方式是使用它们。

## Reference

- [数组，切片（字符串）：'append' 的运作机制](https://go.dev/blog/slices)
- [博文索引](https://go.dev/blog/all)