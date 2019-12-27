# Go语言入门
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
### 值，指针和引用类型
**通常情况下Go语言的变量持有相应的值，也就是说，我们可以讲一个变量想象成它所持有的值来使用。其中有些例外是对于通道（chan），函数（func），方法，映射（map）以及切片的引用变量，它们持有的都是引用，也即保存指针的变量。**

值在传递给函数或者方法时会被复制一次，这对于布尔变量或数值类型来说是非常廉价的，因为每个这样的变量只占1～8个字节。按值传递字符串也非常廉价，因为Go语言中的字符串是不可变的，Go语言编译器会将传递过程进行安全的优化，因此无论传递的字符串长度多少，实际传递的数据量都非常小（每个字符串的代价在64位机器上大概是16字节，在32位机器上大概是8字节）。当然，如果修改了传入的字符串（例如，使用+=操作符），Go语言必须创建一个新的字符串，这对于大字符串来说可能代价非常大。

与C和C++不同，Go语言中的数组是按值传递的，因此传递一个大数组的代价非常大。幸运的是，在Go语言中数组不常用到，因为我们可以使用切片来代替。传递一个切片的成本与字符串差不多（在64位机器上大概是16字节，在32位机器上大概是12字节），无论该切片的长度或者容量多大。另外，修改切片也不会导致写时复制的负担，因为不同于字符串的是，切片是可变的（如果一个切片被修改，这些修改对于其它所有指向该切片的引用变量都是可见的）。
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
**uintptr**|平台相关|一个可以恰好容纳指针值的无符号整数类型，uint32或uint64
**rune**|4|等同于int32

> **注意：**
> 1. **Go语言中按位取反是^x而非~x**
> 2. 如果需要超出64位进行高精度计算，可以采用Go提供的两个无限精度的整数类型，即big.Int和big.Rat(即可以表示成分数的数字如2/3和1.1496，不包括无理数如π或者e)。
> 3. 类型转换采用type(value)的形式，只要合法，就总能转换成功--即使会导致数据丢失。
### 浮点数类型
Go语言提供了两种类型的浮点类型和两种类型的复数类型。

类型|范围
--|--
float32|等价于C/C++中的float
float64|等价于C/C++中的double
complex64|实部和虚部都是一个float32
complex128|实部和虚部都是一个float64
### 字符串
一个Go语言字符串是一个任意字节的常量序列，大部分情况下，一个字符串的字节使用UTF-8编码表示Unicode文本。Unicode编码的使用意味着Go语言可以包含世界上任何语言的混合，代码页没有任何混论与限制。

Go语言的字符串类型在本质上就与其它语言的字符串类型不同。Java的String， C++的std::string以及Python的str类型都只是定宽字符序列，而Go语言的字符串是一个由UTF-8编码的变宽字符序列，它的每一个字符都用一个或多个字节表示。

> **注意：相比其它语言，字符不能被很方便地索引，这会不会是个问题呢？**
> 1. 首先，直接索引使用得不多，而Go语言支持一个字符一个字符的迭代
> 2. 其次，标准库提供了大量的字符串搜索和操作函数
> 3. 最后，我们随时可以将Go语言的字符串转换成一个Unicode码点切片（其类型为[]rune），而这个切片是可以直接索引的。
### 数组
Go语言的数组是一个定长的序列，其中的元素类型相同。任何情况下，一个数组的长度都是固定的并且不可更改。

数组使用以下语法创建：
```
[length]Type
[N]Type{value1, value2, ..., valueN}
[...]Type{value1, value2, ..., valueN}          //Go语言会自动为我们自动计算数组的长度
```

以下示例展示了如何创建和索引数组：
```
var buffer  [20]byte
grid := [3][3]int{{4, 3}. {8, 6, 2}}
cities := [...]string{"Shanghai", "Numbai", "Istanbul", "Beijing"}
cities[len(cities])-1] = "Karachi"

for i, v := range array {
    fmt.Println("Array Element[", i, "] = ", v)
}
```
> **注意：**
> 1. 数组的长度可以使用len()获取；由于长度不可变，cap()永远等于len()；数组也可以使用for...range来进行迭代。
> 2. 数组是值类型，而所有的值类型在赋值和参数传递时将产生一次复制，换句话说，将得到原数组的一个副本。
### 切片
Go语言中的切片是长度可变，容量固定的相同类型元素的序列。虽然切片的容量固定，但也可以通过将切片收缩或者使用内置的append()函数来增长。**虽然数组和切片所保存的元素类型相同，但在实际使用中并不受此限。这是因为其类型可以是一个接口。因此我们可以保存任意满足所声明的接口的元素。然后我们可以让一个数组或者切片为空接口interface{}，这意味着我们可以存储任意类型的元素，虽然这会导致我们在获取一个元素时需要使用类型断言或者类型转型，或者两者配合使用**

我们可以使用如下语法创建切片：
```
make([]Type, length, capacity)
make([]Type, length)
[]Type{}    //与make([]Ty]e, 0)等价
[]Type{value1, value2, .., valueN}
```

内置函数make()用于创建切片，映射和通道。当用于创建一个切片时，它会创建一个隐藏的初始化为零值的数组，然后返回一个引用该隐藏数组的切片。当有多个切片引用同一个底层数组时，其中一个（切片的）修改会影响到其它所有指向该隐藏数组的任何其他引用。
#### 索引与分割切片
一个切片时一个隐藏数组的引用，并且对于该切片的切片也引用同一个数组。这里有一个例子可以解释上面提到的：
```
s := []string{"A", "B", "C", "D", "E", "F", "G"}
t = s[2:6]
fmt.Println(t, s, "=", s[]:4], "+", s[4:])
s[3] = "x"
t[len(t)-1] = "y"
fmt.Println(t, s, "=", s[]:4], "+", s[4:])

输出为：
[C D E F] [A B C D E F] G] = [A B C D] + [E F G]
[C x E Fy [A B C x E y] G] = [A B C x] + [E y G]
```
> **注意：**
> 1. 对于一个切片s和一个索引值i（0 <= i <= len(s))， s等于s[:i]与s[i:]的连接。即s == s[:i] + s[i:]        // s是一个字符串，i是整数，0<= i <= len(s)
> 2. 切片不支持+或+=操作符。，然而可以很容易地往切片后面追加以及插入和删除元素
#### 遍历切片
```
amounts := []float64{237.81, 26187, 273.93, 279.99, 281.07, 303.17, 231.47, 227.33, 209.23, 197.09}
sum := 0.0
for _, amount := range amounts {
    sum += amount
}
fmt.Println("sum of %.1f -> %1f", amounts, sum)
```

> 注意：上步中amount只是切片元素的副本，如果期望修改元素，可以如下面的循环：
```
amounts := []float64{237.81, 26187, 273.93, 279.99, 281.07, 303.17, 231.47, 227.33, 209.23, 197.09}
sum := 0.0
for i := range amounts {
    amounts[i] *= 1.05
    sum += amount
}
fmt.Println("sum of %.1f -> %1f", amounts, sum)
```
#### 修改切片
如果我们需要往切片中追加元素，可以使用内置的append()函数。这个函数接受一个需要被追加的切片，以及一个或者多个要被追加的元素。**如果我们希望往一个切片中追加另一个切片，那么我们必须使用...（省略号）操作符来告诉Go语言将被添加进来的切片当做多个元素。**
```
s := []string{"A", "B", "C", "D", "E", "F", "G"}
t := []string{"K", "L", "M", "N"}
u := []string{"m", "n", "o", "p", "q", "r"}

s = append(s, "h", "i", "j")            //添加单一的值
s = append(s, t...)                             //添加切片中的所有值
s = append(s, u[2:5])                      //添加一个子切片

b := []byte{'U', 'V'}
letters := "WXY"
b = append(b, letters...)               //讲一个字符串添加进一个字节切片中
fmt.Println("%v\n%s", s, b)
```

Go语言支持的另一个内置函数copy()可用于切片--它用于将一个切片复制到另一个切片。如果源切片和目标切片不一样大，就会按照其中较小的那个数组切片的元素个数进行复制：
```
slice1 := []int{1, 2, 3, 4, 5}
slice2 := []int{5, 4, 3}

copy(slice2, slice1)           //只会复制slice1的3个元素到slice2中
copy(slice1, slice2)           //只会复制slice2的3个元素到slice1中
```
#### 排序和搜索切片
标准库中的sort包提供了对整型，浮点型和字符串类型切片进行排序的函数。

语法|含义/结果
--|--
sort.Float64s(fs)|将[]float64按升序排序
sort.Float64AreSorted(fs)|如果[]float64是有序的则返回true
sort.Ints(is)|将[]int按升序排序
sort.IntsAreSorted(is)|如果[]int是有序的则返回true
sort.IsSorted(d)|如果sort.Interface的值d是有序的则返回true
sort.Search(size, fn)|在一个排好序的数组中根据函数签名为func(int) bool的函数fn进行搜索，返回第一个使得fn返回值为true的索引
sort.SearchFloat64s(fs, f)|返回有序[]float64切片中类型为float64的值f的索引
sort.SearchInts(is, i)|返回有序[]int切片中类型为int的值i的索引
sort.SearchStrings(ss, s)|返回有序[]string切片中类型为string的值s的索引
sort.Sort(d)|排序类型为sort.Interface的切片d
sort.Strings(ss)|按升序排序[]string类型的切片ss
sort.StringsAsSorted(ss)|如果[]string类型的切片ss是有序的则返回true
### 映射（map）
Go语言中的映射（map）是一种内置的数据结构，保存键值对的无序集合，它的容量只受到机器内存的限制。在一个映射里所有的键都是唯一的并且必须是支持==和!=操作符的类型。大部分Go语言的基本类型都可以作为映射的键，例如，int，float64， rune，string，可比较的数组和结构体，基于这些类型的自定义类型，以及指针。Go语言的切片和不能用于比较的数组和结构体（这些类型的成员或字段不支持==或!=操作）或者基于这些的自定义类型则不能作为键。

语法|含义/结果
--|--
m[k] = v|用键k来将v赋值给映射m。如果映射m中的k已经存在，则将以前的值丢弃
Delete(m, k)|将键k及其相关的值从映射m中删除。如果k不存在则安全地不进行任何操作
v := m[k]|从映射m中取得键k对应的值并将其赋值给v。如果k在映射在不存在，则将映射类型的0值赋值给v
v, found := m[k]|从映射m中取得键k对应的值并将其赋值给v，并将found的值赋值为true。如果k在映射中不存在，则将映射类型的0值赋值给v，并将found的值赋值为false
len(m)|返回映射m中的项（“键/值”对）的数目

**应为映射属于引用类型，所以不管一个映射保存了多少数据，传递都是很廉价的（在64位机器上只需要8个字节，在32位机器上则只需要4个字节）**

映射的创建方式如下：
```
make(map[KeyType]ValueType, initialCapacity)
make(map[KeyType]ValueType)
map[KeyType]ValueType{}
map[KeyType]ValueType{key1:value1, key2:value2, ., keyN:valueN}
```

映射遍历：
```
for city, population := range populationForCity {
    fmt.Println("%s has %d people", city, population)
}
```
### 指针
指针是指保存了另一个变量地址的变量。通过使用指针，我们可以让参数的传递成本最低并且内容可修改，而且还可以让变量的生命周期独立于作用域。

&被称为取址操作符，它返回的是操作数的地址；
*则被称为内容操作符，间接操作符或者接引用操作符。

Go语言提供了两种创建变量的语法，同事获得指向它们的指针，其中一种方法是使用内置的new()函数，另一种方法是使用取地址操作符。
```
type composer struct {
    name string
    birthday int
}

agnes := new(composer)   //指向composer的指针
agnes.nae, agnes.birthday = "Agnes Zimmermann", 1845

junia := &composer{}        //指向composer的指针
junia.nae, junia.birthday = "Junia Ward Howe", 1847

anguste := &composer{"Anhuste Holema", 1878}         //指向composer的指针
```

**new(Type) === &Type{}**
这两种语法都分配了一个Type类型的空值，同时返回了一个指向该值的指针。如果Type不是一个可以使用大括号初始化的类型，我们只可以使用new()函数。使用结构体的&Type{}语法的一个好处是我们可以为其指定初始值，就像我们这里创建anguste指针时所做的那样。
## 流程控制
### if语句
Go语言的if语句语法如下：
```
if optionalStatement1; booleanExpression1 {
    block1
} else if optionalStatement2; booleanExpression2 {
    block2
} else {
    block3
}
```
一个if语句中可能包含0个到多个 else if子句，以及0到1个else子句。每一个代码块都由0个到多个语句组成。

语句中的大括号是强制性的，但条件判断中的分号只有在可选的声明语句optionalStatement1出现的情况下才需要，该可选的声明语句用Go语言的术语来说叫做“简单语句”。这意味着它只能是一个表达式，发送到通道（使用<-操作符），增减值语句，赋值语句或者短变量声明语句。如果变量是在一个可选的声明语句中创建的（即使用:=操作符创建的），它们的作用域会从声明处扩展到if语句的完成处，因此它们在声明它们的if或者else if语句以及相应的分支中一直存在着，直到if语句的末尾。
```
//景点用法                                                                               //啰嗦用法
if a := compute(); a < 0 {                                                    {
    fmt.Printf("(%d)\n", -a)                                                    a := compute()
} else {                                                                                           if a < 0 {
    fmt.Println(a)                                                                             fmt.Printf("(%d)\n", -a)
}                                                                                                       } else {
                                                                                                             fmt.Println(a)
                                                                                                        }
                                                                                                    }
```
### switch语句
### for循环语句
## 函数
## 错误处理


# Reference
- [Go 主页](https://golang.google.cn/)