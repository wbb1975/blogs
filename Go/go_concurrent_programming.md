# Go并发编程
并发编程可以让开发者实现并行的算法以及编写充分利用多处理器和多核性能的程序。在当前大部分主流的编程语言里，如C、C++、Java等，编写、维护和调试并发程序相比单线程而言要困难很多。而且，也不能总是为了使用多线程而将一个过程切分成更小的粒度来处理。不管怎么说，由于线程本身的性能损耗，多线程编程不一定能够达到我们想要的性能，而且很容易犯错误。

Go语言的解决方案由3个优点：首先，Go语言对并发编程提供了上层支持，因此正确处理并发是很容易做到的。其次，用来处理并发的goroutine比线程更加轻量。第三，并发程序的内存管理有时候是非常复杂的，而Go语言提供了自动垃圾回收机制，让程序员的工作轻松很多。

Go语言为并发编程而内置的上层API基于CSP模型（Communicating Sequential Processes）。这意味着显式锁（以及所有在恰当的时候上锁和解锁所需要关心的东西）都是可以避免的，因为Go语言通过线程安全的通道发送和接受数据以实现同步。这大大简化了并发程序的编写。还有，通常一个普通的桌面计算环境跑十几二十几个线程就有点负载过大了，但是同样这台机器却可以轻松地让成百上千甚至上万个goroutine进行资源竞争。Go语言的做法让程序员理解自己的程序变得更加容易，他们可以从自己希望程序实现什么样的功能来推断，而不是从锁和其它更底层的东西来考虑。

除了作为本章主题的Go语言在较高层次上对并发的支持以外，Go和其它语言一样也提供了对底层动能的支持。在标准库的sync/atomic包里提供了最底层的原子操作，保活相加，比较和交换操作。这些高级功能是为了支持实现线程安全的同步算法和数据结构而设计的，但是这些并不是给程序员准备的。Go语言的sync包里还提供了非常方便的底层并发原语条件等待和互斥量。这些和其它大多数语言一样属于比较高层次的抽象，因此程序猿通常必须使用它们。

Go语言推荐程序员在并发编程时使用语言的上层功能，例如通道和goroutine。此外，sync.Once类型可以用来执行一次函数调用，不管程序滴啊用了多少次，这个函数只会执行一次，还有sync.WaitGroup类型提供了一个上层的同步机制。
## 0. 通信与并发语句
goroutine是程序中与其它goroutine完全相互独立而并发执行的函数或者方法调用。每一个Go程序都至少有一个goroutine，即会执行main包中的main()函数的主goroutine。goroutine非常像轻量级的线程或者协程，它们可以被大批量地创建（相比之下，即使线程也会消耗大量的机器资源）。所有的goroutine共享相同的地址空间，同事Go语言还提供了锁原语来保证数据能够安全地跨goroutine共享。然而，**Go语言推荐的并发编程方式是通信，而非共享数据**。

Go语言的通道是一个双向或者单向的通信管道，它们可用于在两个或者多个goroutine之间通信（即发送和接受数据）。

在goroutine和通道之间，它们提供了一种轻量级（即可扩展的）并发方式，该方式不需要共享内存，因此也不需要锁。但是，与所有其它的并发方式一样，创建并发程序时务必要小心，同时与非并发程序相比，对并发程序的维护也更有挑战。大多数操作系统都能够很好地同时运行多个程序，因此利用这点可以降低程序维护难度。**优秀的程序员只有在其带来的优点明显超过其所带来的负担时才会编写并发程序**。 

goroutine使用以下的语法创建：
```
go function(arguments)
go func(parameters) {block} (arguments)
```
我们必须要么调用一个已有的函数，要么调用一个临时创建的匿名函数。与其它函数一样，该函数可能包含一个或多个参数，并且如果它包含参数，那么必须像其它函数调用一样传入对应的参数。

被调用函数会立即执行，但它是在另一个goroutine上执行，并且当前goroutine的执行（即包含该go语句的goroutine）会从下一条语句中立即恢复。因此，执行一个go豫剧之后，当前程序至少有两个goroutine在运行，其中包含原始的goroutine（初始的主goroutine）和新创建的goroutine。

少数情况下需要开启一串goroutine，并等待它们完成，同时也不需要通信。然而，在大多数情况下，goroutine之间需要互相协作，这最好通过让它们互相通信来完成。下面是用于发送和接受数据的语法：
```
channel <- value             //阻塞发送
<-channel                          //接收并将其丢弃
x := <-channel                  //接收并将其保存
x, ok := <- channel         //同上，同时检查通道是否已经关闭或是否为空
```
非阻塞的发送可以使用select语句来达到，或者在一些情况下使用带缓冲的通道。

通道可以使用内置的make()函数通过以下语法来创建：
```
make(chan type)
make(chan type, capacity)
```
如果没有声明缓冲区容量，那么该通道就是同步的，因此会阻塞直到发送者准备好发送且接收者准备好接收。如果给定了一个缓冲区容量，通道就是异步的。只要缓冲区有未使用空间用于发送数据，或还包含可以接受的数据，那么企通信就会无阻塞地进行。

通道默认是双向的，但如果需要我们可以使得它们是单向的。例如，为了以编译器强制的方式表达我们的语义。
```
func createCounters(start int) chan int {
    next := make(chan int)
    go func(i int) {
        for {
            next <- i
            i++
        }
    } (start)
    return next
}

counterA := createCounters(2)
counterB := createCounters(102)
for i := 0; i < 5; i++ {
    a := <-counterA
    fmt.Printf("(A->%d B->%d)", a, <-counterB)
}
```
### 0.1 select语句
可以使用select语句来监控通道的通信。其语法如下：
```
select {
case sendOrReceive1: block1
...
case sendOrReceive1: blockN
default: blockD
}
```
在一条select语句中，Go语言会按顺序从头至尾评估每一个发送和接收语句。如果其中的任一个可以继续执行（即没有被阻塞），那么就从那些可以被执行的语句中任意选择一条来使用。如果没有任意一条语句可以执行（即所有的通道都被阻塞），那么就有两种可能的情况。如果给出了default语句，那么就会执行default语句，同时程序的执行也会从select语句后的语句中恢复；但是如果没有default语句，那么select语句将会被阻塞，知道至少有一条通信可以继续下去。

一个简单的不那么真实select使用例子，用来模拟一个公平骰子的滚动：
```
channels := make([]chan boo, 6)
for i := range chaneels {
    channels[i] = make(chan bool)
}
go func() {
    for {
        channels[rand.Intn(6)] <- true
    }
}

for  i := 0; i < 36; i++ {
    var x int
    select {
    case <- channels[0]:
        x = 1
     case <- channels[1]:
        x = 2
     case <- channels[2]:
        x = 3
     case <- channels[3]:
        x = 4
     case <- channels[4]:
        x = 5
     case <- channels[5]:
        x = 6
    }
    fmt.Printf("%d", x)
}
fmt.Println()
```

一个看起来更加实际的例子。计入我们要对两个独立的数据集进行同样的昂贵的计算，并产生一系列结果。下面是执行该运算的函数框架：
```
func expensiveComputation(date Data, answer chan int, done chan bool) {
    // 设置...
    finished := false
    for !finished {
        // 计算...
        answer <- resul
        done <- true
    }
}
```
该函数接受需要计算的数据和两个通道。answer通道用于将每个结果发送回监控代码中，而done通道则利用通知监控代码计算已经完成。
```
const allDone = 2
doneCount := 0
answerA := make(chan int)
answerB := make(chan int)
defer func() {
    close(answerA)
    close(answerB)
}()
sone := make(chan bool)
defer func() {close(done)}()
go expensiveComputation(data1, answerA, done)
go expensiveComputation(data2, answerB, done)
for doneCount != allDone {
    var which, result  int
    select {
    case result = <- answerA:
        which = 'A'
    case result = <- answerB:
        which = 'B'
    case <- Done:
        doneCount++
    }

    if which != 0 {
        fmt.Printf("%c->%d ", which, result)
    }
}
fmt.Println(0)
```
## 1. 关键概念
尽管我们使用Go语言上层的API来处理并发，但仍有必要去避免一些陷阱。例如，其中一个常见的问题就是很可能当程序完成时我们没有得到任何结果。，因为当主goroutine退出后，其它的工作goroutine也会自动退出，所以我们必须非常小心低保证所有工作goroutine都完成后才让主goroutine退出。

另一个陷阱就是容易发生死锁，这个问题有一点和第一个陷阱是刚好相反的，就是即使所有的工作已经完成了，但是主goroutine和工作goroutine还存活，这种情况通常是由于工作完成了但是主goroutine无法获得工作goroutine的完成状态。死锁的另一种情况就是，当两个不同的goroutine（或者线程）都锁定了受保护的资源而且同时尝试去获得对方资源的时候。也就是说，只有在使用锁的时候才会出现，所以这种风险一般在其它语言里比较常见。但在Go语言里并不多见，因为Go程序可以使用通道来避免使用锁。

为了避免程序提前退出或不能正常退出，常见的做法是让主goroutine在一个done通道上等待，更具接收到的消息来判断工作是否完成了。

另一种避免这些陷阱的办法就是使用sync.WaitGroup来让每个工作goroutine报告自己的完成状态。但是，使用sync.WaitGroup本身也会产生死锁，特别是当所有工作goroutine都处于锁定状态的时候（等待接收通道的数据）调用sync.WaitGroup.Wait()。

**就算只使用通道，在Go语言里仍然可能发生死锁**。

通道为并发运行的goroutine之间提供了一种无锁通信方式（尽管实现内部可能使用了锁，但无需我们关系）。当一个通道发生通信时，发送通道和接收通道（包括他们对应的goroutine）都处于同步状态。

默认情况下，通道是双向的，也就是说，即可以往里面发送数据也可以从里面接收数据。但是我们经常讲一个通道作为参数进行传递而只希望对方是单向使用的，要么只让它发送数据，要么只让它接收数据，这个时候我们就可以指定通道的方向。例如，chan<-type类型就是一个只发送数据的通道。使用精确的通道类型（单项或双向）可以提供额外的编译期检查，这是非常好的处理方式。

本质上说，在通道里发送布尔类型，整型或浮点，以及字符串都是安全的。但是Go语言并不保证在通道里发送指针或者引用类型（如切片或映射）的安全性，因为指针所指向的内容或者所引用的值可能在对方接受到时已被发送方修改，所以，当涉及指针和引用时，我们必须保证这些值在任何时候只能被一个goroutine访问得到，也就是说，对这些值的访问必须是串行进行的。除非文档特别声明传递这个指针是安全的，比如，*regexp.Regexp可以同时被多个goroutine访问，因为这个指针指向的值的所有方法都不会修改这个值的状态。

除了使用互斥量实现串行化访问，另一种办法就是设定一个规则，一旦指针或者引用发送之后发送方就不会再访问它，然后让接收者来访问或释放指针或者引用指向的值。如果双方都有发送指针或者引用的话，那就发送方和接收方都要应用这种机制，这种方法的问题是使用者必须足够自律。第三种安全传输指针和引用的方法就是让所有导出的方法不能修改其值，所有可修改值的方法都不导出。这样外部可以通过导出的这些方法进行并发访问，但是内部实现只允许一个goroutine去访问它的非导出方法。

Go语言里还可以传送接口类型的值，也就是说，只要这个值实现了接口定义的所有方法，就可以以这个接口的方式在通道里传输。只读型接口的值可以在任意多个goroutine里使用（除非文档特别声明），但是对于某些值，它虽然实现了这个接口的方法，但是某些方法也修改了这个值本身的状态，就必须和指针一样处理，让它的访问串行化。
## 2. 例子
### 2.1 过滤器
### 2.2 并发的Grep
### 2.3 线程安全的映射
### 2.4 Apache报告
### 2.5 查找副本

## Reference
- [An Introduction to Programming in Go](http://www.golang-book.com/books/intro)