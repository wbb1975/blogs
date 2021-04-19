## 第6章 函数
### 什么是函数
函数是执行特定任务的代码块。一个函数接受输入，在输入上执行某些计算，并产生输出。
### 函数声明
Go 中生命一个函数的语法为：
```
func functionname(parametername type) returntype {  
 //function body
}
```
函数中输入参数和返回值是可选的，因此下面的于法也是有效的函数声明：
```
func functionname() {  
}
```
### 多返回值
从一个函数返回多个值是可能的。
```
package main

import (  
    "fmt"
)

func rectProps(length, width float64)(float64, float64) {  
    var area = length * width
    var perimeter = (length + width) * 2
    return area, perimeter
}

func main() {  
     area, perimeter := rectProps(10.8, 5.6)
    fmt.Printf("Area %f Perimeter %f", area, perimeter) 
}
```
如果一个函数返回多个返回值，它们必须在 `(` 和 `)` 之中指定。`func rectProps(length, width float64)(float64, float64)` 拥有两个 `float64` 类型参数 `length` 和 `width` 并返回两个 `float64` 值。上面的程序输出：
```
Area 60.480000 Perimeter 32.800000  
```
### 命名返回值
也可以从一个函数返回命名值。如果一个返回值是命名的，它可被视为在函数的第一行被声明为变量。

上面的 rectProps 可以利用命名返回值重写如下：
```
func rectProps(length, width float64)(area, perimeter float64) {  
    area = length * width
    perimeter = (length + width) * 2
    return //no explicit return value
}
```
在上面的函数中 `area` 和 `perimeter` 是命名返回值。注意上面的返回语句明友显式返回任何值。因为 `area` 和 `perimeter` 在函数声明中被指定为返回值，当遇到一个返回语句时，它们被自动从函数返回。
### 空标识符（Blank Identifier）
Go 语言中 `_` 以空标识符为大家所知。它可以用于替换任何类型的任何值。让我们来看看空标识符的使用。

`rectProps` 函数返回一个矩形的面积和周长。如果我们仅仅想要 `面积area` 而丢弃 `周长perimeter`，这就是 `_` 发挥作用的地方。

下面的程序仅仅使用了从 `rectProps` 函数返回的 `area` 值：
```
package main

import (  
    "fmt"
)

func rectProps(length, width float64) (float64, float64) {  
    var area = length * width
    var perimeter = (length + width) * 2
    return area, perimeter
}
func main() {  
    area, _ := rectProps(10.8, 5.6) // perimeter is discarded
    fmt.Printf("Area %f ", area)
}
```
在第 13 行我们仅仅利用了 `area`，`_` 标识符用于丢弃 `perimeter`。
## 第7章 包
### 什么是包，为什么要用到它们
到目前为止，我们看到的 Go 程序仅仅为带有main[函数](https://golangbot.com/functions/)以及一些其它函数的的单一文件。在现实世界的场景中，将所有代码写在一个单一文件中是不可扩展的。这种方式下的代码不可复用，页很难维护。这就是包可以提供帮助的地方。

**包用于组织代码使其更具可重用性和可读性。包是驻留于一个目录下的所有 Go 源代码的集合。包提供代码隔离机制，因此使得维护 Go 项目更容易**。

例如，假如我们正在用 Go 编写一个金融应用，某些功能是单利利率计算，复利计算以及借贷计算。组织应用的一个简单方法是按照功能。我么可以创建包 simpleinterest，ompoundinterest 和 loan。如果 loan 需要计算单利，它可以仅仅简单地导入 simpleinterest 包。这种方式下代码容易复用。

我们将通过常见简单的应用来学习模块，该应用基于本金（principal），利率以及以年计的时期来计算单利。
### main 函数和 main 包
### Go 模块（Module）


## Reference
- [Golang tutorial series](https://golangbot.com/learn-golang-series/)
- [函数](https://golangbot.com/functions/)