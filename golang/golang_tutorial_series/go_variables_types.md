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
下面是 Go 中可用的基础类型：
- bool
- 数字类型
  + int8, int16, int32, int64, int
  + uint8, uint16, uint32, uint64, uint
  + float32, float64
  + complex64, complex128
  + byte
  + rune
- string
### 4.1 bool
bool 代表一个布尔值，它为 true 或 false。
```
package main

import "fmt"

func main() {  
    a := true
    b := false
    fmt.Println("a:", a, "b:", b)
    c := a && b
    fmt.Println("c:", c)
    d := a || b
    fmt.Println("d:", d)
}
```
### 4.2 有符号整型数
类型|大小|范围|描述
--------|--------|--------|--------
int8|8位|-128 ~ 127|代表一个8位有符号整数
int16|16位|-32768 ~ 32767|代表一个16位有符号整数
int32|32位|-2147483648 ~ 2147483647|代表一个32位有符号整数
int64|64位|-9223372036854775808 ~ 9223372036854775807|代表一个64位有符号整数
int|32或64位|在32位系统上为 -2147483648 ~ 2147483647； 在64位系统上为-9223372036854775808 ~ 9223372036854775807|依赖于平台代表一个32位或64位有符号整数。你通常应该使用 int 来代表一个整形数，除非你有明确的尺寸需求

```
package main

import "fmt"

func main() {  
    var a int = 89
    b := 95
    fmt.Println("value of a is", a, "and b is", b)
}
```
上面的程序将打印出 `value of a is 89 and b is 95`。

在上面的程序里 `a` 是 `int` 类型，`b` 的类型从给它赋予的值（95）推导而来。我们上面说过，在32位系统上 `int` 为32位，在64位系统上上为64位。让我们来验证这个说法。

变量类型可以在 `Printf` 函数里使用  `%T` 格式化符号打印。 Go 有一个包叫作 [unsafe](https://golang.org/pkg/unsafe/)，该包拥有一个叫作 [Sizeof](https://golang.org/pkg/unsafe/#Sizeof) 的函数用于返回传给它的变量的字节数。`unsafe` 包主要用于多代码可移植性比较关心的场合，这里我们主要基础教程的目的使用它。

下面的程序将打印变量 `a` 和 `b` 的类型及大小。`%T` 用于格式化类型，`%d` 用于格式化大小。
```
package main

import (  
    "fmt"
    "unsafe"
)

func main() {  
    var a int = 89
    b := 95
    fmt.Println("value of a is", a, "and b is", b)
    fmt.Printf("type of a is %T, size of a is %d", a, unsafe.Sizeof(a)) //type and size of a
    fmt.Printf("\ntype of b is %T, size of b is %d", b, unsafe.Sizeof(b)) //type and size of b
}
```
上买的呢程序将产生下面的输出：
```
value of a is 89 and b is 95  
type of a is int, size of a is 8
type of b is int, size of b is 8  
```
### 4.3 无符号整型数
类型|大小|范围|描述
--------|--------|--------|--------
uint8|8位|0 ~ 255|代表一个8位无符号整数
uint16|16位|0 ~ 65535|代表一个16位无符号整数
uint32|32位|0 ~ 4294967295|代表一个32位无符号整数
uint64|64位|0 ~ 18446744073709551615|代表一个64位无符号整数
uint|32或64位|在32位系统上为 0 ~ 4294967295，在64位系统上为0 ~ 18446744073709551615|依赖于平台代表一个32位或64位无符号整数。你通常应该使用 int 来代表一个整形数，除非你有明确的尺寸需求
### 4.4 浮点数类型
**float32**: 32位浮点数
**float64**: 64位浮点数

下面的程序演示了浮点数类型和整型数类型：
```
package main

import (  
    "fmt"
)

func main() {  
    a, b := 5.67, 8.97
    fmt.Printf("type of a %T b %T\n", a, b)
    sum := a + b
    diff := a - b
    fmt.Println("sum", sum, "diff", diff)

    no1, no2 := 56, 89
    fmt.Println("sum", no1+no2, "diff", no1-no2)
}
```
`a` 和 `b` 的类型从指派给它们的值推导而来。在本例中，`a` 和 `b` 的类型是 `float64`（`float64` 是浮点数的默认类型）。
```
type of a float64 b float64  
sum 14.64 diff -3.3000000000000007  
sum 145 diff -33  
```
### 4.5 复数类型
**complex64**: 实部和虚部皆为 float32 的复数
**complex128**: 实部和虚部皆为 float32 的复数

内建函数 [complex](https://golang.org/pkg/builtin/#complex) 用于从实部和虚部构造一个复数。`complex` 函数的签名如下：
```
func complex(r, i FloatType) ComplexType
```
复数也可以从快捷方式创建：
```
c := 6 + 7i
```
让我们写一个小程序来理解复数类型：
```
package main

import (  
    "fmt"
)

func main() {  
    c1 := complex(5, 7)
    c2 := 8 + 27i
    cadd := c1 + c2
    fmt.Println("sum:", cadd)
    cmul := c1 * c2
    fmt.Println("product:", cmul)
}
```
程序将输出：
```
sum: (13+34i)  
product: (-149+191i)  
```
### 4.6 其它数字类型
**byte** uint8别名
**rune** int32别名

当[学习字符串](https://golangbot.com/strings/)时，我们将会深入讨论 bytes 和 rune。
### 4.7 字符串
在 Go 中字符串时字节的集合。即使这个定义不合理但至少是正确的。现在，我们可以假定字符串是一个字符的集合。我们将在单独的[字符串教程](https://golangbot.com/strings/)学习到跟多字符串的细节。

让我们来编写一个使用字符串的应用：
```
package main

import (  
    "fmt"
)

func main() {  
    first := "Naveen"
    last := "Ramanathan"
    name := first +" "+ last
    fmt.Println("My name is",name)
}
```
### 4.8 类型转换
Go 在显式类型使用上非常严格。没有自动类型提升和转化。让我们从一个例子爱来看看这意味着什么：
```
package main

import (  
    "fmt"
)

func main() {  
    i := 55      //int
    j := 67.8    //float64
    sum := i + j //int + float64 not allowed
    fmt.Println(sum)
}
```
上述代码在 C 语言里绝对是合法的，但在 Go 里它却不能工作。`i` 是 `int` 类型，`j` 为 `float64` 类型。将两个不同类型的数字加载一起是不被允许的。当你运行这个程序时，你会得到 `main.go:10: invalid operation: i + j (mismatched types int and float64)`。

为了解决这个问题，`i` 和 `j` 应该为同样的类型。让我们将 `j` 转化为 `int`。`T(v)` 是将一个值 `v` 转换为 `T` 类型的语法。
```
package main

import (  
    "fmt"
)

func main() {  
    i := 55      //int
    j := 67.8    //float64
    sum := i + int(j) //j is converted to int
    fmt.Println(sum)
}
```
现在当你运行上面的程序，你将会看到输出 122.

这同样适用于赋值操作，将一种类型的值赋给另一个类型需要显式的类型转化。下面的程序解释了这个规则：
```
package main

import (  
    "fmt"
)

func main() {  
    i := 10
    var j float64 = float64(i) //this statement will not work without explicit conversion
    fmt.Println("j", j)
}
```
在第9行，`i` 被转化为 `float64`，然后被赋值给 `j`。当你试着将 `i` 赋值给 `j` 而不利用类型转化，编译器将抛出一个异常。
## 5. 常量
### 什么是常量
Go 中的术语常量用于指定固定的值如：
```
95  
"I love Go" 
67.89
```
### 声明一个常量
关键字 `const` 用于声明一个常量。让我们用一个例子来看看如何声明一个常量：
```
package main

import (  
    "fmt"
)

func main() {  
    const a = 50
    fmt.Println(a)
}
```
在上面的代码中，a 是一个常量其被赋值为 50.
### 声明一组常量
还有额外的语法可以用一条语句声明一组常量。使用这个语法定义一组常量的例子如下：
```
package main

import (  
    "fmt"
)

func main() {  
    const (
        name = "John"
        age = 50
        country = "Canada"
    )
    fmt.Println(name)
    fmt.Println(age)
    fmt.Println(country)

}
```
在上面的程序里，我们声明了3个常量 `name`, `age` 和 `country`。上面的程序将打印：
```
John  
50  
Canada  
```
常量，意如其名，不能被重新赋值为另一个值。在下面的程序中，我们尝试将 `89` 赋给 `a`。由于 `a` 是一个常量，该操作不被允许。该程序将在编译时报错 `"cannot assign to a"`。
```
package main

func main() {  
    const a = 55 //allowed
    a = 89 //reassignment not allowed
}
```
**常量的值应该在编译时已知**。因此它不能被赋值为一个[函数调用](https://golangbot.com/functions/)的返回值，原因在于函数调用仅在运行时发生。
```
package main

import (  
    "math"
)

func main() {  
    var a = math.Sqrt(4)   //allowed
    const b = math.Sqrt(4) //not allowed
}
```
在上面的程序中，`a` 是一个[变量](https://golangbot.com/variables/)，因此它可被赋值为函数 `math.Sqrt(4)` 的返回值（我们将在[单独的教程](https://golangbot.com/functions/)里讨论函数的更多细节）。

`b` 是一个常量，其值需要在编译时求值。函数 `math.Sqrt(4)` 仅仅在运行时求值，因此 `const b = math.Sqrt(4)` 编译失败并报告了下面的错误：
```
./prog.go:9:8: const initializer math.Sqrt(4) is not a constant
```
### 字符串常量，有类型常量及无类型常量
在 Go 中以双引号包裹的任意值为字符串。例如，在 Go 中字符串如 "Hello World", "Sam"都是常量。

字符串常量属于什么类型？答案是它们是**无类型的（untyped）**。

**一个字符串常量如 "Hello World" 不具有任何类型**。
```
const hello = "Hello World"  
```
在上面的代码中，常量 hello 不拥有任何类型。

Go 是强类型语言。所有的类型需要一个显示的类型。在下面的程序中，变量 name 被用一个物类型的常量 n 类赋值，它可以工作吗？
```
package main

import (  
    "fmt"
)

func main() {  
    const n = "Sam"
    var name = n
    fmt.Printf("type %T value %v", name, name)

}
```
**答案是无类型的常量拥有一个伴生默认类型，它们只有在代码需要时才提供。在第 8 行的 var name = n 中，name 需要一个类型，它得到字符串常量 n 的默认类型，即字符串**。


有方法创建有类型常量吗？答案是肯定的，下面的代码创建了一个有类型常量：
```
const typedhello string = "Hello World"  
```
**上面的代码中 typedhello 即为一个字符串类型的常量**。

`Go` 是强类型语言。在赋值中混用类型是不允许的。让我们借助一个程序来看这意味着什么：
```
package main

func main() {  
        var defaultName = "Sam" //allowed
        type myString string
        var customName myString = "Sam" //allowed
        customName = defaultName //not allowed

}
```
在上面的代码中，我们首先创建了变量 `defaultName`，并将常量值 `Sam` 赋值给它。**常量 Sam 的默认类型为字符串，因此在赋值后，defaultName 类型为字符串**。

在下一行，我们创建了类型 myString，它是字符串的别名。

接下来我们创建了 `myString` 类型的变量 `customName`，并将常量 “Sam” 赋值给它。因为 常量 “Sam” 是无类型的，它可被赋值给任何字符串类型的变量，因此这个复制是允许的，`customName` 因此具有类型 `myString`。

现在我们拥有一个变量 defaultName，其类型为字符串；另一个变量 customName，其类型为 `myString`。虽然我们知道 `myString`是字符串的别名，Go 的强类型策略不允许一种类型的变量被赋值为另一种类型。**因此赋值 ustomName = defaultName 是不被允许的，编译器将抛出错误 ./prog.go:7:20: cannot use defaultName (type string) as type myString in assignment**。
### 布尔常量
布尔常量与字符串常量不同，它们是两个没有类型的常量 `true` 和 `false`。适用于字符串常量的规则也适用于布尔常量，因此这里我们就不重复了。下面的资格小李子解释了布尔常量：
```
package main

func main() {  
    const trueConst = true
    type myBool bool
    var defaultBool = trueConst //allowed
    var customBool myBool = trueConst //allowed
    defaultBool = customBool //not allowed
}
```
上面的程序不解自明。
### 数字常量
数字常量包括整型，浮点和复数常量。关于数字常量有一些微妙之处.

让我们来看一些解释这些情况的例子：
```
package main

import (  
    "fmt"
)

func main() {  
    const a = 5
    var intVar int = a
    var int32Var int32 = a
    var float64Var float64 = a
    var complex64Var complex64 = a
    fmt.Println("intVar", intVar, "\nint32Var", int32Var, "\nfloat64Var", float64Var, "\ncomplex64Var", complex64Var)
}
```
在上面的程序中，常量 `a` 是无类型的，其值为 `5`。你可能想知道常量 `a` 的默认类型，如果它确实拥有一个，将它赋值给一个不同的类型时会发生什么？答案在于 `a` 的语法。下面的程序将使得这更清晰：
```
package main

import (  
    "fmt"
)

func main() {  
    var i = 5
    var f = 5.6
    var c = 5 + 6i
    fmt.Printf("i's type is %T, f's type is %T, c's type is %T", i, f, c)

}
```
在上面你的程序中，每个变量的类型由数字常量的语法决定。从语法上，`5` 是整型，`5.6` 是浮点数，`5 + 6i` 是复数类型。上面的程序运行后有下面的输出：
```
i's type is int, f's type is float64, c's type is complex128
```
拥有上面的知识后，让我们尽力理解下面的程序如何工作的：
```
package main

import (  
    "fmt"
)

func main() {  
    const a = 5
    var intVar int = a
    var int32Var int32 = a
    var float64Var float64 = a
    var complex64Var complex64 = a
    fmt.Println("intVar",intVar, "\nint32Var", int32Var, "\nfloat64Var", float64Var, "\ncomplex64Var",complex64Var)
}
```
在上面的例子中，`a` 的值是 `5`，其语法是泛型的。它可以代表一个浮点数，整型值甚至一个没有虚部的复数。因此它它可以赋值给任何兼容的类型。这些常量的默认类型可以认为在运行时根据上下文确定。`var intVar int = a` 需要 `a` 是整型，于是它变成了一个整型常量。`var complex64Var complex64 = a` 要求 `a` 为复数，因此它变为了一个复数常量。相当清晰。
### 数字表达式
数字常量可以自由地混入或者匹配表达式，只有当它们被赋值给变量或者在需要一个类型的代码中类型才是需要的。
```
package main

import (  
    "fmt"
)

func main() {  
    var a = 5.9 / 8
    fmt.Printf("a's type is %T and value is %v", a, a)
}
```
在上面的程序中，从语法上 5.9 是浮点数，8 是整型数。因此，5.9/8 是允许的，因为都是数字常量。除法结果为 0.7375 为浮点数，因此变量 a 是浮点类型。程序输出为：
```
a's type is float64 and value is 0.7375  
```

## Reference
- [Golang tutorial series](https://golangbot.com/learn-golang-series/)
- [Variables](https://golangbot.com/variables/)
- [Part 4: Types](https://golangbot.com/types/)
- [Constants](https://golangbot.com/constants/)