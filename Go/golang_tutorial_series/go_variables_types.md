## 3. 变量
变量是特定内存位置的名字，该位置存储特定一个[类型](https://golangbot.com/types/)的一个值。在 Go 中有多种方式语法来声明一个变量，让我们一个一个来讲解。
### 3.1 声明一个简单变量
**var name type** 是声明一个简单变量的语法：
```
package main

import "fmt"

func main() {  
    var age int // variable declaration
    fmt.Println("My age is", age)
}
```
语句 `var age int` 生命了一个名为 `age` 类型为 `int` 的变量。我们没有赋给这个变量任何值。**如果一个变量没有被赋予任何值，Go 自动用该类型的零值来初始化它**。在本例中，`age` 被赋值为 0，它是 `int` 类型的**零值**。如果你运行这个程序你将看到下面的输出：
```
My age is 0
```
一个变量可以被赋予其对应变量类型的任何值。在上面的例子中，age 可被赋予任何任何整数值。
```
package main

import "fmt"

func main() {  
    var age int // variable declaration
    fmt.Println("My age is", age)
    age = 29 //assignment
    fmt.Println("My age is", age)
    age = 54 //assignment
    fmt.Println("My new age is", age)
}
```
上面的程序将打印下面的输出：
```
My age is  0  
My age is 29  
My new age is 54  
```
### 3.2 用一个初始值来声明一个简单变量
一个变量可在被声明时提供一个初始值。下面是带初始值声明一个变量的语法：
```
var name type = initialvalue  
```

```
package main

import "fmt"

func main() {  
    var age int = 29 // variable declaration with initial value

    fmt.Println("My age is", age)
}
```
在上面的程序中，age 是一个 int 类型的变量，初始值为 29。上面的程序将打印下买你的输出：
```
My age is 29
```
### 3.3 类型推导
如果一个变量用有初始值，Go 能够利用该初始值来自动推导变量的类型。因此如果一个变量拥有初始值，变量的类型声明可以被移除。

如果一个变量按下面的语法声明：
```
var name = initialvalue  
```
Go 将自动从初始值推导变量的类型。

在下面的例子中，我们能够看到变量 `age` 的类型 `int` 已在在第 `6` 行被移除了。因为变量拥有初始值 `29`， Go 可以推导其类型为 `int`。
```
package main

import "fmt"

func main() {  
    var age = 29 // type will be inferred
    fmt.Println("My age is", age)
}
```
### 3.4 多个变量声明
用一条语句可以声明多个变量。

**var name1, name2 type = initialvalue1, initialvalue2** 是多个变脸声明的语法。
```
package main

import "fmt"

func main() {  
    var width, height int = 100, 50 //declaring multiple variables

    fmt.Println("width is", width, "height is", height)
}
```
如果变量已经提供了初始值，变量类型可以省略。上面的程序已经为变量提供了初始值，所以类型可以移除：
```
package main

import "fmt"

func main() {  
    var width, height = 100, 50 //"int" is dropped

    fmt.Println("width is", width, "height is", height)
}
```
某些场景下，我们可以希望在一条语句里声明不同的类型，其语法如下：```
```
var (  
      name1 = initialvalue1
      name2 = initialvalue2
)
```
下面的程序使用上面的语法来声明不同类型的变量：
```
package main

import "fmt"

func main() {  
    var (
        name   = "naveen"
        age    = 29
        height int
    )
    fmt.Println("my name is", name, ", age is", age, "and height is", height)
}
```
### 3.5 声明变量的快捷方式
Go 也提供了一个简洁的方式来声明变量，即使用 := 操作符来作为变量声明的快捷方式。

**name := initialvalue** 是声明变量的快捷方式。

下面的程序使用了快捷方式声明了一个变量 `count` 并初始化其值为 `10`。因为其拥有初始值整形数 `10` 所以 Go 将自动推导 `count` 类型为 `int`。
```
package main

import "fmt"

func main() {  
    count := 10
    fmt.Println("Count =",count)
}
```
**也可以利用快捷方式在一行声明多个变量**：
```
package main

import "fmt"

func main() {  
    name, age := "naveen", 29 //short hand declaration

    fmt.Println("my name is", name, "age is", age)
}
```
快捷方式需要赋值操作位右边的初始值个数与左边变量个数匹配。下面的程序将会打印一个错误 `assignment mismatch: 2 variables but 1 values`。这是因为 `age` 未被指定初始值。
```
package main

import "fmt"

func main() {  
    name, age := "naveen" //error

    fmt.Println("my name is", name, "age is", age)
}
```
快捷方式只有在赋值符左边的变量至少有一个是新声明的变量时才能工作。考虑下面的程序：
```
package main

import "fmt"

func main() {  
    a, b := 20, 30 // declare variables a and b
    fmt.Println("a is", a, "b is", b)
    b, c := 40, 50 // b is already declared but c is new
    fmt.Println("b is", b, "c is", c)
    b, c = 80, 90 // assign new values to already declared variables b and c
    fmt.Println("changed b is", b, "c is", c)
}
```
在上面的程序中，在第 8 行，`b` 已经被声明过，但 `c` 是新声明的变量。因此它能工作且打印下面的输出：
```
a is 20 b is 30  
b is 40 c is 50  
changed b is 80 c is 90  
```
当你运行下面的程序：
```
package main

import "fmt"

func main() {  
    a, b := 20, 30 //a and b declared
    fmt.Println("a is", a, "b is", b)
    a, b := 40, 50 //error, no new variables
}
```
它将打印错误 `/prog.go:8:10: no new variables on left side of :=`。这是因为 `a` 和 `b` 都已经被声明过，在第 `8` 行 `:=` 操作符左边没有新声明的变量。

变量也可以指定一个需要在运行时计算的值。考虑下面的程序：
```
package main

import (  
    "fmt"
    "math"
)

func main() {  
    a, b := 145.8, 543.8
    c := math.Min(a, b)
    fmt.Println("Minimum value is", c)
}
```
因为 Go 是强类型语言，被声明为一种类型的变量不能呗赋予另一个类型的值。下面的程序将会打印一个错误 `cannot use "naveen" (type string) as type int in assignment`，原因在于 `age` 被声明为 `int`， 但我们却试图指定一个 `string` 给它：
```
package main

func main() {  
    age := 29      // age is int
    age = "naveen" // error since we are trying to assign a string to a variable of type int
}
```
## 4. 类型
## 3. 常量

## Reference
- [Golang tutorial series](https://golangbot.com/learn-golang-series/)
- [Variables](https://golangbot.com/variables/)
- [Part 4: Types](https://golangbot.com/types/)
- [Constants](https://golangbot.com/constants/)