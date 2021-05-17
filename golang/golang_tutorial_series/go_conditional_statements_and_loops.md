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
循环语句用于重复地执行代码块。

`for` 是 Go 中唯一可用的循环语句。Go 不具有其它语言如 C 中存在的 `while` 或 `do while` 循环。
### for 循环语法
```
for initialisation; condition; post {  
}
```
初始化语句仅仅执行一次。当循环初始化后，条件将被检查。如果条件求值为 true，`{ }` 内的循环体将被执行，然后执行 post 语句。post 语句将会在循环的每一次成功迭代之后执行。post 语句执行之后，条件将会被再次检查。如果为 true，循环将会继续执行，否则循环终止。

在 Go 中循环的3个部分，即初始化，条件，post 是可选的。让我们看一个例子来更好地理解循环。
### 示例
让我们写一个应用来打印从1至10的数字：
```
package main

import (  
    "fmt"
)

func main() {  
    for i := 1; i <= 10; i++ {
        fmt.Printf(" %d",i)
    }
}
```
在上面的程序中，i 被初始化为1；条件语句将检查是否 `i <= 10`。如果条件为 true，i 的值将被打印；否则循环终止。post 语句在每次迭代结束时将 i 增 1。一旦 i 大于10，循环终止。上面程序将打印 `1 2 3 4 5 6 7 8 9 10`。

在一个 for 循环里生声明的变量仅仅在循环范围内可见，因此 i 不能在 for 循环体之外访问。
### break
break 语句用于在 for 循环的正常执行流程结束之前终止循环并将控制转移到 for 循环之后的下一行代码。让我们写一个应用通过 break 来打印从1至5的数字：
```
package main

import (  
    "fmt"
)

func main() {  
    for i := 1; i <= 10; i++ {
        if i > 5 {
            break //loop is terminated if i > 5
        }
        fmt.Printf("%d ", i)
    }
    fmt.Printf("\nline after for loop")
}
```
在上面的程序中，i 的值在每次迭代中都被检查。如果 i 的值大于 5，则 break 被执行，循环终止。for 循环之后的打印语句被执行。上面的程序将输出：
```
1 2 3 4 5  
line after for loop
```
### continue
continue 语句也跳出 for 循环的当前迭代。for 循环中 continue 之后的所有语句在这个迭代中都不会被执行。循环将直接跳到下一次迭代。

让我们写一个应用来打印从1至10的奇数数字：
```
package main

import (  
    "fmt"
)

func main() {  
    for i := 1; i <= 10; i++ {
        if i%2 == 0 {
            continue
        }
        fmt.Printf("%d ", i)
    }
}
```
在上面的代码中 `if i%2 == 0` 将检查 i 被 2 除的余数是否为 0。如果是0，则该数为偶数，continue 语句会被指I下那个，控制流到达下一次迭代。因此 continue 语句后的打印语句不会被执行，程序前进到下一次循环。上面程序的输出为：`1 3 5 7 9`。
### 嵌套 for 循环
一个 for 循环内部拥有另一个 for 循环即被称为 嵌套for循环。让我们写一个程序打印下面的输出以理解嵌套循环：
```
*
**
***
****
*****
```
其对应程序采用嵌套循环如下：
```
package main

import (  
    "fmt"
)

func main() {  
    n := 5
    for i := 0; i < n; i++ {
        for j := 0; j <= i; j++ {
            fmt.Print("*")
        }
        fmt.Println()
    }
}
```

### 标记 （Labels）
标记可用于从内层循环跳出到外层循环。让我们用一个简单的例子来理解我所说的：
```
package main

import (  
    "fmt"
)

func main() {  
    for i := 0; i < 3; i++ {
        for j := 1; j < 4; j++ {
            fmt.Printf("i = %d , j = %d\n", i, j)
        }

    }
}
```

在下面的程序中，当 i 和 j 相等时，程序将会停止执行并输出如下：
```
package main

import (  
    "fmt"
)

func main() {  
outer:  
    for i := 0; i < 3; i++ {
        for j := 1; j < 4; j++ {
            fmt.Printf("i = %d , j = %d\n", i, j)
            if i == j {
                break outer
            }
        }

    }
}
```

```
i = 0 , j = 1  
i = 0 , j = 2  
i = 0 , j = 3  
i = 1 , j = 1  
```
### 更多例子
让我们编写更多的代码来覆盖各种各样的 for 循环。

下面的程序打印从0至10的偶数，其初始化及 post 语句都不在循环语句内：
```
package main

import (  
    "fmt"
)

func main() {  
    i := 0
    for ;i <= 10; { // initialisation and post are omitted
        fmt.Printf("%d ", i)
        i += 2
    }
}
```
上面程序的循环中的分号可以进一步省略，它可被视为 while 循环的一种替代。上面的程序可被重写如下：
```
package main

import (  
    "fmt"
)

func main() {  
    i := 0
    for i <= 10 { //semicolons are ommitted and only condition is present
        fmt.Printf("%d ", i)
        i += 2
    }
}
```
初始化，条件判断以及 post 都可以包含多个表达式，如下所示：
```
package main

import (  
    "fmt"
)

func main() {  
    for no, i := 10, 1; i <= 10 && no <= 19; i, no = i+1, no+1 { //multiple initialisation and increment
        fmt.Printf("%d * %d = %d\n", no, i, no*i)
    }

}
```
### 无限循环
```
for {  
}
```
## 第10章 switch 语句


## reference
- [If else statement](https://golangbot.com/if-statement/)
- [Loops](https://golangbot.com/loops/)
- [Switch Statement](https://golangbot.com/switch/)