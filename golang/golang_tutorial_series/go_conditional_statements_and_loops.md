## 第8章 if else 语句
### if 语句语法
if 语句的语法如下：
```
if condition {  
}
```
如果条件为真，在 { 和 } 之间的代码块将被执行。不像其它语言如 C，{  } 是必须的，即使 {  } 内仅仅由有一行代码。
```
package main

import (  
    "fmt"
)

func main() {  
    num := 10
    if num%2 == 0 { //checks if number is even
        fmt.Println("The number", num, "is even")
        return
    }
    fmt.Println("The number", num, "is odd")
}
```
### If else 语句
if 语句有一个可选的 else 构造，它在 if 欲绝条件被求值为 false 时执行。
```
if condition {  
} else {
}
```

```
package main

import (  
    "fmt"
)

func main() {  
    num := 11
    if num%2 == 0 { //checks if number is even
        fmt.Println("the number", num, "is even")
    } else {
        fmt.Println("the number", num, "is odd")
    }
}
```
### If ... else if ... else 语句
```
if condition1 {  
...
} else if condition2 {
...
} else {
...
}
```
**基本上，只要 if 或 else if 中任一条件求值为真，其所含代码块将会被执行；如果没有任一条件为真，else 里的代码块将会被执行。**
### if with 赋值语句
有一个 if 语句的变体，其包含一个可选的[快捷赋值](https://golangbot.com/variables/#shorthanddeclaration)语句，它在条件被执行之前被执行。其语法如下：
```
if assignment-statement; condition {  
}
```
在上面的语句中，assignment-statement 语句将会在条件被求值之前执行。
```
package main

import (  
    "fmt"
)

func main() {  
    if num := 10; num % 2 == 0 { //checks if number is even
        fmt.Println(num,"is even") 
    }  else {
        fmt.Println(num,"is odd")
    }
}
```
**值得注意的一点是 num 只在 if 和 else 的语句块内访问可用**，即 num 被限制在 if else。如果我们想从 if 或 else 外访问 num，编译器将会报错。
### Gotcha
else 应该写在与大括号闭括号 } 同一行上，否则编译器将会抱怨。

让我们从一个程序来理解这个：
```
package main

import (  
    "fmt"
)

func main() {  
    num := 10
    if num % 2 == 0 { //checks if number is even
        fmt.Println("the number is even") 
    }  
    else {
        fmt.Println("the number is odd")
    }
}
```
在上面的代码里，else 语句并未与闭括号 } 在同一行上。取而代之，它另起一行，这在 Go 中是不允许的。如果你便一这个程序，编译器将会打印下面你的错误：
```
./prog.go:12:5: syntax error: unexpected else, expecting }
```
原因在于 Go 自动插入分号的方式。你可以在[这里](https://golang.org/ref/spec#Semicolons)读到分号插入规则。

在这个规则中，它指定了一个分号将被插入到大括号闭括号 } 后。如果它是这一行的最后一个标识。因此 Go 编译器会自动在第 11 行语句的闭括号 } 后添加一个分号。因此我们的程序在分号插入后实际上变成：
```
...
if num%2 == 0 {  
      fmt.Println("the number is even") 
};  //semicolon inserted by Go Compiler
else {  
      fmt.Println("the number is odd")
}
```
编译器已经在上面代码片段的第4行为尾部插入了一个分号。

因为 if{...} else {...} 是一个单一语句，一个分号不应该在其中间插入。因此程序不能编译。因此将 else 与 if 的结束大括号放在一行是一个语法要求。

我已经重写了程序，将 else 放在 if 语句的结束大括号后以防止分号自动插入：
```
package main

import (  
    "fmt"
)

func main() {  
    num := 10
    if num%2 == 0 { //checks if number is even
        fmt.Println("the number is even") 
    } else {
        fmt.Println("the number is odd")
    }
}
```
### 惯用的 Go
在 Go 的哲学中，最好避免不必要的分支和代码缩进。尽可能早第返回也被认为更好。之前我已经提供了下面的程序：
```
package main

import (  
    "fmt"
)

func main() {  
    if num := 10; num % 2 == 0 { //checks if number is even
        fmt.Println(num,"is even") 
    }  else {
        fmt.Println(num,"is odd")
    }
}
```
在 Go 的哲学里上面的程序的惯用写法应该是避免 else 语句，在 if 条件为真时就返回。
```
package main

import (  
    "fmt"
)

func main() {  
    num := 10;
    if num%2 == 0 { //checks if number is even
        fmt.Println(num, "is even")
        return
    }
    fmt.Println(num, "is odd")

}
```
在上面的程序中，只要我们发现数字为偶数，我们立即反回。这避免了不必要的 else 分支。这是 Go 的做事方式。无论何时你写 Go 应用时请记住这一点。
## 第9章 循环 （Loops）
## 第10章 switch 语句


## reference
- [If else statement](https://golangbot.com/if-statement/)