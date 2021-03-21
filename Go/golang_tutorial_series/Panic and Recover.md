# Panic and Recover
欢迎来到 [Go 教程系列](https://golangbot.com/learn-golang-series/)的第 `32` 讲。
## 什么是 Panic?
在 Go 语言中处理非正常情况的常用做法是使用[error](https://golangbot.com/error-handling/)。errors 对于在程序中出现的大多数异常情况是够用的。

**但是有一些情况但异常状态出现后程序不能够继续执行，在这种情况下，我们使用 `panic` 来提前终止程序。当一个[函数](https://golangbot.com/functions/)遇到一个 `panic`，它的执行将会被停止，[延迟调用函数(deferred functions)](https://golangbot.com/defer/)被调用，然后控制回到调用方。这个过程将持续下去，直至当前 [goroutine](https://golangbot.com/goroutines/ )的所有函数调用从打印 `panic` 消息的点返回；后面跟随调用栈并最终终止**。这个概念在我们撰写一个示例应用后会变得更清晰。

**更可能的是利用 recover 重新获得 panicking 应用的控制权**，我们将在本教程的稍后讨论它。

panic 和 recover 可被视为与其它语言如 Java 中的 try-catch-finally 惯用法类似，除了它在 Go 工应用极少。
## 什么时候我们应该使用 Panic
一个重要的因素是如果可能你应该避免使用panic 和 recover，代之以使用 [errors](https://golangbot.com/error-handling/)。只有在程序不能继续执行，只有 `panic` 和 `recover` 应该被使用的场景下使用。

由两种 `panic` 的有效使用场景：
- **当程序遇到一个不可恢复的错误而无法继续执行**
  一个例子是一个Web服务器不能绑定到请求端口上。在这种情况下，如果绑定失败，没有什么可做的时候 panic 是合理的。
- **一个编程错误**
  假设我们有一个方法https://golangbot.com/methods/，它接受一个指针作为参数，但在使用中用户传入一个 nil 作为参数。在这个例子中，在调用方法时期待一个有效指针的地方传入一个 nil 参数是一个编程错误， panic 是可以的。
## Panic 示例
内置 `panic` 的签名如下：
```
func panic(interface{})
```
传递给 panic 的参数在程序终止时将会被打印出来。当我们编写一个示例应用后这就清楚了。让我们现在马上开始。

我们将会以一个特意设计的例子开始，它展示了 `panic` 如何工作：
```
package main

import (  
    "fmt"
)

func fullName(firstName *string, lastName *string) {  
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```
上面是一个简单的应用，它打印一个人的全名。第7行的 `fullName` 函数打印一个人的全名。这个函数在第8行和第11行检查 `firstName` 和 `lastName` 指针是否为 `nil`。如果为 `nil`，函数将以对应错误消息调用 `panic`。这个消息将会在应用终止时打印出来。

运行上面的应用将产生如下输出：
```
panic: runtime error: last name cannot be nil

goroutine 1 [running]:  
main.fullName(0xc00006af58, 0x0)  
    /tmp/sandbox210590465/prog.go:12 +0x193
main.main()  
    /tmp/sandbox210590465/prog.go:20 +0x4d
```
让我们分析上面的输出，以此来理解 `panic` 如何工作以及当应用 `panic` 时调用堆栈是如何打印的。

在第19行哦我们把 "Elon" 指派给 `firstName`。我们在20行传递 `nil` 给 `lastName` 以调用 `fullName`。因此第11行的条件将被满足，程序将 `panic` 。当遇到 `panic` 时，程序执行被停止，传递给 `panic` 的参数被打印出来，并跟随由调用栈信息。因为程序在第12行 `panic` 函数调用后终止，在第13， 14及15行的代码就爱那个不会被执行。

程序首先打印传递给 `panic` 函数的消息：
```
panic: runtime error: last name cannot be nil 
```
然后打印调用堆栈.

程序在 `fullName` 函数的 第12行 `panicked`，因此
```
goroutine 1 [running]:  
main.fullName(0xc00006af58, 0x0)  
    /tmp/sandbox210590465/prog.go:12 +0x193
```
将被首先打印。接下来调用栈的第二条将会被打印。在我们的例子中，调用中的下一条是第20行的 `fullName` 函数调用，因此它被继续打印出来：
```
main.main()  
    /tmp/sandbox210590465/prog.go:20 +0x4d
```
现在我们已经到达顶层函数，它引发了 `panic` 而且没有更高级的函数，所以没有更多需要打印。
## 另一个例子
`Panics` 也可在运行时由 `errors` 引发，例如去访问一个切片不存在的索引。

让我们编写一个特意为之的例子来创建一个由切片边界之外访问触发的 `panic`。
```
package main

import (  
    "fmt"
)

func slicePanic() {  
    n := []int{5, 7, 4}
    fmt.Println(n[4])
    fmt.Println("normally returned from a")
}
func main() {  
    slicePanic()
    fmt.Println("normally returned from main")
}
```
在上面的代码中，我们在地第9行试着去访问 `n[4]`，它在该[切片](https://golangbot.com/arrays-and-slices/#slices)中是个无效所引。这个程序将会 panic 并打印以下信息：
```
panic: runtime error: index out of range [4] with length 3

goroutine 1 [running]:  
main.slicePanic()  
    /tmp/sandbox942516049/prog.go:9 +0x1d
main.main()  
    /tmp/sandbox942516049/prog.go:13 +0x22
```
## 在一个 Panic 中的延迟调用（Defer Calls During a Panic）
让我们回忆 panic 做了些什么。**当一个函数遇到 panic，它的执行被停止。任何延迟函数都会被执行并且其控制返回到调用方。之歌过程继续下去，直至当前 [goroutine](https://golangbot.com/goroutines/ )的所有函数调用从打印 `panic` 消息的点返回；后面跟随调用栈并最终终止**。

在上面的例子中，我们没有延迟任何函数调用。如果一个延迟函数存在，它就爱那个会被执行，接下来控制返回到调用方。

让我们稍微修改一下上面的例子以加入一个 defer 语句：
```
package main

import (  
    "fmt"
)

func fullName(firstName *string, lastName *string) {  
    defer fmt.Println("deferred call in fullName")
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```
唯一的修改是在第8行和20行添加的延迟函数调用。

这个程序将输出：
```
deferred call in fullName  
deferred call in main  
panic: runtime error: last name cannot be nil

goroutine 1 [running]:  
main.fullName(0xc00006af28, 0x0)  
    /tmp/sandbox451943841/prog.go:13 +0x23f
main.main()  
    /tmp/sandbox451943841/prog.go:22 +0xc6
```
当程序在第13行 panics 时，任何延迟函数调用将会被首先执行，然后控制返回到调用方，其延迟函数调用将会被执行，如此继续直至到达最高层调用方。

在我们的例子中， `fullName` 函数第8行的 `defer` 语句被首先执行。它打印下面的消息：
```
deferred call in fullName
```
接下来控制回到 `main` 函数，它的延迟函数调用被执行并打印下面的输出：
```
deferred call in main
```
现在控制已经回到了顶级函数，因此程序打印 `panic` 消息，其后是调用栈，最后程序终止。
## 从一个 Panic 中恢复（Recovering from a Panic）
`recover` 是一个内建函数用于重新获取一个 panicking 程序的控制。

`recover`函数的签名如下：
```
func recover() interface{}
``` 
recover只有在从延迟函数内部调用时才有用。在一个延迟函数内部调用 recover 将通过恢复正常执行，并检索传递给 panic 函数调用的错误消息来停止 panicking 序列。如果 recover 在延迟函数之外调用，它将不会停止 panicking 序列。

让我们修改我们的应用来使用 recover 从一个 panic 恢复正常的执行：
```
package main

import (  
    "fmt"
)

func recoverFullName() {  
    if r := recover(); r!= nil {
        fmt.Println("recovered from ", r)
    }
}

func fullName(firstName *string, lastName *string) {  
    defer recoverFullName()
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```
第7行的函数 `recoverFullName()` 调用 `recover()` 返回了传递给 `panic` 调用的值。这里我们仅仅在第9行打印由 `revocer` 返回的值。`recoverFullName()` 在 `fullName` 函数的第14行被延迟。

当 `fullName` panic时，延迟函数 `recoverName()` 将被调用，它使用 `recover()` 来终止 `panicking` 序列。

程序将打印出：
```
recovered from  runtime error: last name cannot be nil  
returned normally from main  
deferred call in main  
```
当应用在地19行 `panic` 时，被延迟的 `recoverFullName` 函数被调用，它接下来调用 `recover()` 重新获得 `panicking` 序列的控制。第8行对 `recover()` 的调用返回传递给 `panic()` 的参数并打印它：
```
recovered from  runtime error: last name cannot be nil
```
在 `recover()` 执行后，`panicking` 停止，控制返回到调用方，在这个例子中，它是 `main` 函数。程序从 `main` 函数的第29行继续正常执行，因为 `panic` 已经被恢复了。它打印 `returned normally from main` 并随后打印 `deferred call in main`。

让我们在看一个例子，它从一个来自对切片的非法索引访问引发的 `panic` 中恢复：
```
package main

import (  
    "fmt"
)

func recoverInvalidAccess() {  
    if r := recover(); r != nil {
        fmt.Println("Recovered", r)
    }
}

func invalidSliceAccess() {  
    defer recoverInvalidAccess()
    n := []int{5, 7, 4}
    fmt.Println(n[4])
    fmt.Println("normally returned from a")
}

func main() {  
    invalidSliceAccess()
    fmt.Println("normally returned from main")
}
```
运行上面的程序将输出：
```
Recovered runtime error: index out of range [4] with length 3  
normally returned from main  
```
从这个输出，你应该能够理解我们已经从 `panic` 中恢复了。
## 恢复后获取调用栈（Getting Stack Trace after Recover）
如果我们已经从 `panic` 中恢复了，我们就失去了 `panic` 的调用堆栈。即使在上面的例子中恢复之后，我们就失去了调用堆栈。

可以使用 [Debug 包](https://golangbot.com/go-packages/)中的[PrintStack函数](https://golang.org/pkg/runtime/debug/#PrintStack)来打印堆栈。
```
package main

import (  
    "fmt"
    "runtime/debug"
)

func recoverFullName() {  
    if r := recover(); r != nil {
        fmt.Println("recovered from ", r)
        debug.PrintStack()
    }
}

func fullName(firstName *string, lastName *string) {  
    defer recoverFullName()
    if firstName == nil {
        panic("runtime error: first name cannot be nil")
    }
    if lastName == nil {
        panic("runtime error: last name cannot be nil")
    }
    fmt.Printf("%s %s\n", *firstName, *lastName)
    fmt.Println("returned normally from fullName")
}

func main() {  
    defer fmt.Println("deferred call in main")
    firstName := "Elon"
    fullName(&firstName, nil)
    fmt.Println("returned normally from main")
}
```
在上面的例子中，我们使用第11行使用 `debug.PrintStack()` 来打印调用栈。

这个应用将输出：
```
recovered from  runtime error: last name cannot be nil  
goroutine 1 [running]:  
runtime/debug.Stack(0x37, 0x0, 0x0)  
    /usr/local/go-faketime/src/runtime/debug/stack.go:24 +0x9d
runtime/debug.PrintStack()  
    /usr/local/go-faketime/src/runtime/debug/stack.go:16 +0x22
main.recoverFullName()  
    /tmp/sandbox771195810/prog.go:11 +0xb4
panic(0x4a1b60, 0x4dc300)  
    /usr/local/go-faketime/src/runtime/panic.go:969 +0x166
main.fullName(0xc0000a2f28, 0x0)  
    /tmp/sandbox771195810/prog.go:21 +0x1cb
main.main()  
    /tmp/sandbox771195810/prog.go:30 +0xc6
returned normally from main  
deferred call in main  
```
从上面的输出，你可以理解 panic 已经恢复，`recovered from runtime error: last name cannot be nil` 被打印出来。之后，调用栈也被打印出来，接下来：
```
returned normally from main  
deferred call in main  
```
在 panic 被恢复后被打印出来。
## Panic, Recover 和 Goroutines
`Recover` 仅仅在从 发生 `panicking` 的同一 [goroutine](https://golangbot.com/goroutines/) 内调用时才可以工作。不可能从位于不同 goroutine 中的 panic 恢复。让我们来使用一个例子来（帮助）理解：
```
package main

import (  
    "fmt"
)

func recovery() {  
    if r := recover(); r != nil {
        fmt.Println("recovered:", r)
    }
}

func sum(a int, b int) {  
    defer recovery()
    fmt.Printf("%d + %d = %d\n", a, b, a+b)
    done := make(chan bool)
    go divide(a, b, done)
    <-done
}

func divide(a int, b int, done chan bool) {  
    fmt.Printf("%d / %d = %d", a, b, a/b)
    done <- true

}

func main() {  
    sum(5, 0)
    fmt.Println("normally returned from main")
}
```
在上面的程序中，函数 `divide()` 在第22行 `panic`，因为 `b` 是 `0`， 而且不可能用 `0` 来整除。函数 `sum()` 调用了一个延迟函数 `recovery()`，它常被用于从 `panic` 中恢复。在第17行，函数 `divide()` 从一个单独的 `goroutine` 中调用。我们在地18行的 `done` [通道](https://golangbot.com/channels) 上等待来确保 `divide()` 完成了执行。

你认为这个应用会在终端输出什么呢？`panic` 会被恢复吗？回答是 `no`。`Panic` 不会被恢复。原因在于 `recovery` 函数运行在不同的 `goroutine` 里，而且在 `divide()` 发生的 `panic` 在不同的 `goroutine` 里。因此恢复是不可能发生的。

运行这个程序会输出：
```
5 + 0 = 5  
panic: runtime error: integer divide by zero

goroutine 18 [running]:  
main.divide(0x5, 0x0, 0xc0000a2000)  
    /tmp/sandbox877118715/prog.go:22 +0x167
created by main.sum  
    /tmp/sandbox877118715/prog.go:17 +0x1a9
```
你可以从输出看到恢复没有发生。

如果 `divide()` 函数在同一个 `goroutine` 里调用，我们将会从 `panic` 里恢复。

如果第17行代码从
```
go divide(a, b, done)  
```
修改为
```
divide(a, b, done) 
```
因为 panic 在同一 `goroutine` 里发生，所以恢复将会发生。如果代有上面修改的程序运行，将会打印下买你的输出：
```
5 + 0 = 5  
recovered: runtime error: integer divide by zero  
normally returned from main  
```

到现在为止我们的教程就该结束了。

## Reference 
- [Panic and Recover](https://golangbot.com/panic-and-recover/)
- [Golang tutorial series](https://golangbot.com/learn-golang-series/)
- [The Go Playground](https://play.golang.org/)