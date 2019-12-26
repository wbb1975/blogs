# Go FAQ
Go语言最初被构思为一门可充分利用分布式系统以及多核联网计算机优势并适用于开发大型项目的编译速度很快的系统级语言。现在，Go语言的触角已经远远超出了原定的范畴，它正被用作一个具有高度生产力的通用性编程语言。

Go is expressive, concise, clean, and efficient. Its concurrency mechanisms make it easy to write programs that get the most out of multicore and networked machines, while its novel type system enables flexible and modular program construction. Go compiles quickly to machine code yet has the convenience of garbage collection and the power of run-time reflection. It's a fast, statically typed, compiled language that feels like a dynamically typed, interpreted language.

> 注：Go表达力强，简洁，干净并高效。它的并发机制使你可以轻易写出适用于多核和联网计算机（集群）环境的应用，它的新奇的类型系统使得弹性和模块化程序结构成为可能。Go编译机器码的速度飞快，有垃圾回收的便利，并具有运行期反射的强大功能。它是快速的，静态类型的编译型语言，但（使用起来）感觉就像是动态类型的解释型语言。

Go语言的主要特性：
- 自动垃圾回收
- 更丰富的内置类型（slice和map）
- 函数多返回值
- 错误处理
- 匿名函数和闭包
- 类型和接口
- 并发编程（goroutine和channel（通道））
- 反射
- 语言交互性（Cgo）

## 编辑器插件和集成开发环境（Editor plugins and IDEs）
Go生态系统提供许多编辑器插件和集成开发环境来提升日常编辑，导航，测试及调试的体验。
- [vim](https://github.com/fatih/vim-go): vim-go插件提供Go编程语言支持
- [Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=lukehoban.Go): Go扩展提供了对Go编程语言的支持 。
- [GoLand](https://www.jetbrains.com/go): GoLand以一个独立IDE或IntelliJ IDEA旗舰版插件的模式提供
- [Atom](https://atom.io/packages/go-plus): Go-Plus是一个Atom包提供了对Go的增强支持。

注意这些只是一些靠前的选择；一个更综合的由社区维护的[集成开发环境和编辑器插件](https://github.com/golang/go/wiki/IDEsAndTextEditorPlugins)列表可以在Wiki上获得。

## 第一个简单的Go程序
```
package main

import (
    "fmt"     // 我们需要使用fmt中的Println()函数
    "os"
    "strings"
)

def main() {
    who := "World!"
    if len(os.Args) > 1 {  /* os.Args[0]是"hello"或者"hello.exe"
        who = strings.join(os.Args[1:], " ")
    }
    fmt.Println("Hello ", who)
}
```
**注意：**
1. main函数不带参数，也不能定义返回值
2. Go代码注释与C/C++一样，支持行注释和块注释
3. 可以在小括号中导入多个包，也可以一行到入一个包
4. 每个Go源代码文件的开头都是一个包声明，表示该代码所属的包，Go可执行程序必须在main包中。
## 变量和常量
### 变量声明的3种方式：
- var v1 int = 10
- var v2 = 10
- v3 := 10        // 快速变量声明，Go可以从其初始化之中推导出其类型

> **注意：**
> 1. 如果变量未提供显示初始化，Go语言总会将零值赋值给该变量。这意味着每一个数值变量的默认值保证为0，而每个字符串都默认为空，其它为nil。
> 2. 变量赋值与变量初始化是两个不同的概念：
>    ```
>    var v10 int         //变量声明（与初始化一体）
>    v10 = 9                //变量赋值 
>    ```
> 3. Go支持多重赋值，如下：
>    ```
>    i, j = j, i             //直接交换两个变量的值
>    ```
> 4. 空标识符"_"是一个占位符，它用于在赋值操作的时候将某个值赋值给空操作符，从而达到丢弃该值的目的。
>    ```
>    _, err = fmt.Println(x)             //忽略返回字节数
>    ```
> 5. 对于整形字面量，Go推导其类型为int，对于浮点型字面量，Go推导其类型为float64，对于复数字面量，Go语言推导其类型为complex128。通常的做法是不去显示地声明其类型，除非我们需要使用一个Go语言无法推导的特殊类型。
### 常量
Go的常量定义可以限定常量类型，但不是必须的。如果定义常量时没有指定类型，那么它是无类型常量，可用于别的数值类型为任何内置类型的表达式中。
   ```
   const limit = 512                       //常量，其类型兼容任何数字
   const top uint16 = 500           //常量，其类型为uint16
   ```
**预定义常量：true，false和iota。**

iota比较特殊，可以被认为是一个可被编译器修改的常量，在每一个const关键字出现的时候被重置为0，然后在下一个const出现之前，每出现一次iota，其所代表的数字会自动增1.
```
const (             // iota被重置为0
    c0 = iota      // c0 == 0
    c1 = iota      // c1 == 1
    c2 = iota      // c2 == 2
)
```
如果两个const的赋值语句的表达式是一样的，那么可以省略后一个赋值表达式：
```
const (
    Sunday = iota
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
    numOfDays     //这个常量没有导出
)
```
> **注意：Go语言并支持众多其它语言支持的enum关键字。**
## 类型
### 整数类型
类型|长度|范围
--|--|--
**byte**|1|等同于uint8
**int**|平台相关|int32或int64
**uint**|平台相关|uint32或uint64
int8|1|[-128, 127]
uint8|1|[0, 255]
int16|2|[-32768, 32767]
uint16|2|[0, 65535]
int32|4|[-2147483648, 2147483647]
uint32|4|[0, 4294967295]
int64|8|[-9223372036854775808, 9223372036854775807]
uint64|8|[0, 18446744073709551615]
**uintptr**|平台相关|一个可以恰好容纳指针值的无符号证书类型，uint32或uint64
**rune**|4|等同于int32

> **注意：**
> 1. **Go语言中按位取反是^x而非~x**
> 2. 如果需要超出64位进行高精度计算，可以采用Go提供的两个无限精度的整数类型，即big.Int和big.Rat(即可以表示成分数的数字如2/3和1.1496，不包括无理数如π或者e)。
> 3. 类型转换采用type(value)的形式，只要合法，就总能转换成功--即使会导致数据丢失。
### 浮点数类型
## 流程控制
## 函数
## 错误处理


# Reference
- [Go 主页](https://golang.google.cn/)