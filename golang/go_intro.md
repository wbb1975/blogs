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

## 1. 编辑器插件和集成开发环境（Editor plugins and IDEs）
Go生态系统提供许多编辑器插件和集成开发环境来提升日常编辑，导航，测试及调试的体验。
- [vim](https://github.com/fatih/vim-go): vim-go插件提供Go编程语言支持
- [Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=lukehoban.Go): Go扩展提供了对Go编程语言的支持 。
- [GoLand](https://www.jetbrains.com/go): GoLand以一个独立IDE或IntelliJ IDEA旗舰版插件的模式提供
- [Atom](https://atom.io/packages/go-plus): Go-Plus是一个Atom包提供了对Go的增强支持。

注意这些只是一些靠前的选择；一个更综合的由社区维护的[集成开发环境和编辑器插件](https://github.com/golang/go/wiki/IDEsAndTextEditorPlugins)列表可以在Wiki上获得。

## 2. 第一个简单的Go程序
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
## 3. 变量和常量
### 3.1 变量声明的3种方式：
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
### 3.2 常量
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
## 4. 类型
### 4.1 值，指针和引用类型
**通常情况下Go语言的变量持有相应的值，也就是说，我们可以讲一个变量想象成它所持有的值来使用。其中有些例外是对于通道（chan），函数（func），方法，映射（map）以及切片的引用变量，它们持有的都是引用，也即保存指针的变量。**

值在传递给函数或者方法时会被复制一次，这对于布尔变量或数值类型来说是非常廉价的，因为每个这样的变量只占1～8个字节。按值传递字符串也非常廉价，因为Go语言中的字符串是不可变的，Go语言编译器会将传递过程进行安全的优化，因此无论传递的字符串长度多少，实际传递的数据量都非常小（每个字符串的代价在64位机器上大概是16字节，在32位机器上大概是8字节）。当然，如果修改了传入的字符串（例如，使用+=操作符），Go语言必须创建一个新的字符串，这对于大字符串来说可能代价非常大。

与C和C++不同，Go语言中的数组是按值传递的，因此传递一个大数组的代价非常大。幸运的是，在Go语言中数组不常用到，因为我们可以使用切片来代替。传递一个切片的成本与字符串差不多（在64位机器上大概是16字节，在32位机器上大概是12字节），无论该切片的长度或者容量多大。另外，修改切片也不会导致写时复制的负担，因为不同于字符串的是，切片是可变的（如果一个切片被修改，这些修改对于其它所有指向该切片的引用变量都是可见的）。
### 4.2 整数类型
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
### 4.3 浮点数类型
Go语言提供了两种类型的浮点类型和两种类型的复数类型。

类型|范围
--|--
float32|等价于C/C++中的float
float64|等价于C/C++中的double
complex64|实部和虚部都是一个float32
complex128|实部和虚部都是一个float64
### 4.4 字符串
一个Go语言字符串是一个任意字节的常量序列，大部分情况下，一个字符串的字节使用UTF-8编码表示Unicode文本。Unicode编码的使用意味着Go语言可以包含世界上任何语言的混合，代码页没有任何混论与限制。

Go语言的字符串类型在本质上就与其它语言的字符串类型不同。Java的String， C++的std::string以及Python的str类型都只是定宽字符序列，而Go语言的字符串是一个由UTF-8编码的变宽字符序列，它的每一个字符都用一个或多个字节表示。

> **注意：相比其它语言，字符不能被很方便地索引，这会不会是个问题呢？**
> 1. 首先，直接索引使用得不多，而Go语言支持一个字符一个字符的迭代
> 2. 其次，标准库提供了大量的字符串搜索和操作函数
> 3. 最后，我们随时可以将Go语言的字符串转换成一个Unicode码点切片（其类型为[]rune），而这个切片是可以直接索引的。
### 4.5 数组
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
grid := [3]int{4, 3, 0}
cities := [...]string{"Shanghai", "Numbai", "Istanbul", "Beijing"}
cities[len(cities])-1] = "Karachi"

for i, v := range array {
    fmt.Println("Array Element[", i, "] = ", v)
}
```
> **注意：**
> 1. 数组的长度可以使用len()获取；由于长度不可变，cap()永远等于len()；数组也可以使用for...range来进行迭代。
> 2. 数组是值类型，而所有的值类型在赋值和参数传递时将产生一次复制，换句话说，将得到原数组的一个副本。
### 4.6 切片
Go语言中的切片是长度可变，容量固定的相同类型元素的序列。虽然切片的容量固定，但也可以通过将切片收缩或者使用内置的append()函数来增长。**虽然数组和切片所保存的元素类型相同，但在实际使用中并不受此限。这是因为其类型可以是一个接口。因此我们可以保存任意满足所声明的接口的元素。然后我们可以让一个数组或者切片为空接口interface{}，这意味着我们可以存储任意类型的元素，虽然这会导致我们在获取一个元素时需要使用类型断言或者类型转型，或者两者配合使用**

我们可以使用如下语法创建切片：
```
make([]Type, length, capacity)
make([]Type, length)
[]Type{}    //与make([]Ty]e, 0)等价
[]Type{value1, value2, .., valueN}
```

内置函数make()用于创建切片，映射和通道。当用于创建一个切片时，它会创建一个隐藏的初始化为零值的数组，然后返回一个引用该隐藏数组的切片。当有多个切片引用同一个底层数组时，其中一个（切片的）修改会影响到其它所有指向该隐藏数组的任何其他引用。
#### 4.6.1 索引与分割切片
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
#### 4.6.2 遍历切片
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
#### 4.6.3 修改切片
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
#### 4.6.4 排序和搜索切片
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
### 4.7 映射（map）
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
### 4.8 指针
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
### 4.9 类型转换
Go语言提供了一种在不同但相互兼容之间相互转换的方式，并且这种转换非常有用并且安全。非数值之间的转换不会丢失精度，但是对于数值之间的转换，可能会发生丢失精度或者其它问题。例如，如果我们有一个x := uint16(65000)，然后使用转换y := int16(x)，由于x超出了int16的范围，y的值毫无悬念地被设置为-536，这也可能不是我们所想要的。

类型转换的语法为：
```
resultType := Type(expression)
```

对于数字，本质上讲我们可以将任意的整型或者浮点型数据转换成别的整型或者浮点型（如果目标类型比源类型小，则可能丢失精度）。同样的规则也适用于complex128和complex64类型之间的转换。

一个字符串可以转换成一个[]byte（其底层为UTF-8的字节）或者一个[]rune（它的Unicode码点），并且[]byte和[]rune都可以转换成一个字符串类型。单个字符是一个rune类型数据（即int32），可以转换成一个单字符的字符串。

语法|描述/结果
--|--
s[n]|字符串s中索引位置为n处的原始字节（uint8类型）
len(s)|字符串s中的字节数
[]rune(s)|将字符串s转换为一个Unicode码点切片
len([]rune(s))|字符串s中字符的个数--可以使用更快的utf8.RuneCountInString()来代替
[]byte(s)|无副本地将字符串s转换成一个原始字节的切片数组，不保证转换的字节是合法的UTF-8编码字节
string(bytes)|无副本地将[]byte或者[]uint8转换成一个字符串类型，不保证转换的字节是合法的UTF-8编码字节
string(i)|将任意数字类型i转换成字符串，假设i是一个Unicode码点。例如，如果i是65，那么其返回值为“A”
### 4.10 类型断言
类型断言有两种语法：
```
resultOfType, boolean := expression.(Type)         //安全类型断言
resultOfType := expression.(Type)                            //非安全类型断言，失败时panic()
```
成功的安全类型断言将返回目标类型的值和标识成功的true。如果安全类型断言失败（即表达式的雷星宇声明的类型不兼容），将返回目标类型的零值和false。非安全类型断言要么返回一个目标类型的值，要么调用内置的panic()韩式抛出一个异常。如果异常没有被恢复，那么该异常会导致程序终止。

```
var i interface{} = 99
var s interface{} = []string{"left", "right"}

j := i.(int)                                                   //非安全类型断言
fmt.Printf("%T -> %d\n", j, j)
if i, ok := i.(int); ok {                              //安全类型断言
    fmt.Printf("%T -> %d\n", i, j)
}

if s, ok := s.([]string); ok {                 //安全类型断言
    fmt.Printf("%T -> %q\n", s, s)
}
```
## 5. 流程控制
### 5.1 if语句
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
### 5.2 switch语句
Go语言中有两种类型的switch语句：**表达式开关（expression switch）和类型开关（type switch）**。不同于C， C++和Java的是，Go语言的switch语句不会自动向下贯穿（因此不必在每一个case自居的末尾都添加一个break语句）。相反，我们可以在需要的时候通过显式地调用fallthrough语句来这样做。
#### 5.2.1 表达式开关
Go语言的表达式开关语法如下：
```
switch optionalStaement; optionalExpression {
case expressionList1: block1
...
case expressionListN: blockN
default: blockD
}
```

用法比较：
```
// 原始的经典用法                                                  //经典用法
switch suffix := Suffix(file); suffix {                 switch Suffix(file) {
case ".gz":                                                                case ".gz":
    return GzipFileList(file)                                         return GzipFileList(file)
case ".tar":                                                               case ".tar", ".tar.gz", "tgz":
    fallthrough                                                                 return TarFileList(file)
case ".tar.gz":                                                          case ".zip":
    fallthrough                                                                return ZipFileList(file)
case ".tgz":                                                              }
    return TarFileList(file)
case ".zip":
    return ZipFileList(file)
}
```
#### 5.2.2 类型开关
Go语言的类型开关语句语法如下：
```
switch optionalStaement; typeSwitchGuard {
case typeList1: block1
...
case typeListN: blockN
default: blockD
}
```

类型开关守护（guard）是一个结果为类型的表达式。如果表达式是使用:=操作符赋值的，那么创建的变量的值为类型开关守护表达式中的值，但其类型则决定于case子句。在一个列表只有一个类型的子句中，该变量的类型即为该类型；在一个列表包含两个或更多类型的case子句中，该变量的类型则为类型开关守护表达式的类型。
```
func classifier(items...interface{}) {
    for i, x := range itemd {
        switch x.(type) {
        case bool:
            fmt.Printf("param #%d is a bool\n", i)
        case float64:
            fmt.Printf("param #%d is a float64\n", i)
        case int, int8, int16, int32, int64:
            fmt.Printf("param #%d is a int\n", i)
        case uint, uint8, uint16, uint32, uint64:
            fmt.Printf("param #%d is a uint\n", i)
        case nil:
            fmt.Printf("param #%d is a nil\n", i)
        case string:
            fmt.Printf("param #%d is a string\n", i)
        default:
            fmt.Printf("param #%d is unknown\n", i)
        }
    }
}
```
### 5.3 for循环语句
Go语言使用两种类型的for语句来进行循环，一种是无格式的for语句，另一种是for...range语句，下面是它们的语法：
```
for {      //无限循环
    block
}

for booleanExpression {      // while循环
    block
}

for optinalPreStatement; booleanExpression; optionalPostStatement {
    block
}

for index, char := range aString {    //一个字符一个字符地迭代一个字符串
    block
}

for index := range aString {             //一个字符一个字符地迭代一个字符串
    block    // char, size := utf8.DecodeRuneInString(aString[index:])
}

for index, item := range anArrayOrSlice {          //数组或切片迭代
    block
}

for index := range anArrayOrSlice {          //数组或切片迭代
    block
}

for  key, value := range aMap {                 //映射迭代
    block
}

for item := range aChannel {                    //通道迭代
    block
}
```
## 6. 错误处理
### 6.1 error接口
Go语言引入了一个关于错误处理的标准模式，即error接口，该接口的定义如下：
```
type error interface {
    Error() string
}
```

一个实际的例子：
```
type PathError struct {
    Op   string
    Path  string
    Err   error
}

func (e *PathError) Error() string {                       //以*PathError为Receiver，故下面的Stat函数必须返回*PathError
    return e.Op + " " + e.Path + " " + e.Err.Error()
}

func Stat(name string) (err error) {
    var stat  syscall.Stat_t
    err = syscall.Stat(name, &stat)
    if err != nil {
        return &PathError{"stat", name, err}
    }
    return nil
}
func main() {
    err := Stat("a.txt")

    if err != nil {
            fmt.Printf("err = %T\n", err)
    }
}
```

> **注意：**因为上面的Error()以*PathError为Receiver，故下面的Stat函数必须返回*PathError；如果改为以PathError为Receiver，下面的Stat函数必须返回PathError{}。
### 6.2 defer
defer语句用于延迟一个函数或者方法（或者当前所创建的匿名函数）的执行，它会在外围函数或者方法返回之前但是其返回值计算之后执行。这样就可能在一个被延迟执行的函数内部修改函数的命名返回值（例如，使用赋值操作符给它们赋新值）。如果一个函数或者方法中有多个defer语句，它们会以LIFO（Last InFirst Out）的顺序执行。

defer语句最常用的用法是，保证使用完一个文件后将其成功关闭，或者将一个不再使用的通道关闭，或者捕获异常：
 ```
 var file *os.File
 var err error

 if file, err = os.Open(filename); err != nil {
     log.Println("failed to open the file", err)
     return
 }
 defer file.close()
 ```
### 6.3 panic()和recover()
通过内置的panic()和recover()函数，Go语言提供了一套异常处理机制。类似于其它语言（例如，C++， java和Python）中所提供的异常机制，这些函数也可以用于实现通用的异常处理机制，但是这样做在Go语言中是不好的风格。

Go语言将错误和异常两者区分对待。错误是指可能出错的东西，程序需要以优雅的方式将其处理（例如，文件不能被打开）。而异常是指“不可能”发生的事情（例如，一个应该永远为true的条件在实际环境中却是false的）。

Go语言中处理错误的习惯用法是将错误以函数或者方法最后一个返回值的形式将其返回，并总是在调用它的地方检查返回的错误值（不过通常在将值打印到终端时会忽略错误值）。

对于“不可能发生”的情况，我们可以调用内置的panic()函数，该函数可以传入任意想要的值（例如，一个字符串用于解释为什么那些不变的东西被破坏了）。在其它语言中，在这种情况下我们可能使用一个断言，但在Go语言中我们使用panic()。在早期开发以及任何发布阶段之前，最简单同事也可能使最好的方法是调用panic()函数来中断程序的执行以强制发生错误，使得该错误不会被忽略因而能够被晶块修复。一旦开始部署程序时，在任何情况下可能发生错误都应该尽一切可能避免中断程序。我们可以保留panic()函数但在包中添加一个延迟执行的recover()调用来达到这个目的。在恢复过程中，我们可以捕捉并记录任何异常（以便这些问题保留可见），同时向调用者返回非nil的错误值，而调用之试图让程序恢复到健康状态并据需安全运行。

当内置的panic()函数被调用时，外围函数或者方法的执行会立即终止。然后，任何延迟执行的函数或者方法都会被调用，就像其外围函数正常返回一样。最后，调用返回到该外围函数的调用者，就像该外围调用函数或者方法调用了panic()一样，因此该过程一直在调用栈中重复发生：函数停止执行，调用延迟执行函数等。当到达main()函数时不再有可以返回的调用者，因此这时程序会终止，并将包含传入原始panic()函数中的值的调用栈信息输出到os.Stderr。

上面所描述的只是一个异常发生时正常情况下所展开的。然而，如果其中有个延迟执行的函数或者方法包含一个对内置的recover()函数（可能只在一个延迟执行的函数或方法中调用）的调用，该异常展开过程就会终止。在这种情况下，我们就能够以任何我们想要的方式响应该异常。有种解决方案是忽略该异常，这样控制权就会交给包含了延迟执行的recover()调用的函数，该函数然后会继续正常执行。我们通常不推荐这种方法，但如果使用了，至少需要将该异常记录到日志中以不完全隐藏该问题。另一种解决方案是，我们完成必要的清理工作，然后手动调用panic()函数来让该异常继续传播。一个通用的解决方案是，创建一个error值，并将其设置成包含了recover()调用的函数的返回值（或返回值之一），这样就可以将一个异常（即一个panic()）转换成错误（即一个error）。

绝大多数情况下，Go语言标准库使用error值而非异常。对于我们自己定义的包，最好别试用panic()。或者，如果要使用panic()，也要避免异常离开这个自定义包边界，可以通过使用recover()来捕捉异常并返回一个相应的错误值，就像标准库中所做的那样。

以下是两个实际的例子，第一个演示了如何将异常转换为错误：
```
func ConvertInt64ToInt(x int64) int {
    if math.minInt32 <= x &&  x <= math.MaxInt32 {
        return int(x)
    }

    panic(fmt.Sprintf("%d is out of the int32 range", x))
}

func IntFromInt64(x int64) (i int, err error) {
    def func() {
        if e := recover(); e != nil {
            err = fmt.Errorf("%v", e)
        }
    } ()

    i = ConvertInt64ToInt(x)
    return i, nil
}
```
> **注意：IntFromInt64函数被调用时，Go语言会自动地将其返回值设置成其对应的零值**，如在这里是0和nil。如果自定义的ConvertInt64ToIntt()函数正常返回，我们将其值赋值给i返回值，并返回i和一个表示没有错误发生的nil值。但是如果ConvertInt64ToIntt()函数抛出异常，我们可以在延迟执行的匿名函数中捕获该异常，并将err设置为一个错误值，其文本为所捕获错误的文本表示。

> **如 IntFromInt64()函数所示，我们可以非常容易地将异常转换为错误。**

第二个例子展示了如何让程序变得更健壮：
```
func homePage(writer http.ResponseWriter, request *http.Request) {
    def func() {                          //每一个页面都需要
        if x := recover(); x != nil {
            log.Printf("[%v] caught panic: %v", request.RemoteAddr, x)
        }
    }
}
```
如上，该页面如果发生了异常，将被recover()捕获，从而不会被传播到main()函数。
## 7. 函数
函数是面向过程编程的根本，Go语言原生支持函数，Go语言的方法和函数是很相似的。函数定义的基本语法如下：
```
func functionName(optionalParameters) optionalReturnType {
    block
}
func functionName(optionalParameters) (optionalReturnValues) {
    block
}
```
函数可以有任意多个参数，如果没有参数那圆括号就是空的。如果要实现可变参数，可以将最后一个参数的类型之前写上省略号，也就是说，函数可以接收任意多个那个类型的值，在函数里，实际上这个参数的类型是[]type。

函数的返回值可以是任意个，如果没有，那么返回值列表的右括号后面是紧接着左大括号的。如果只有一个返回值类型可以直接写返回的类型，如果有两个或者多个没有命名的返回值，也必须使用括号而且得这样写(type1, ..., typeN)。如果有一个或多个命名的返回值，也必须使用括号，要写成这样(type1 value1, ..., typeN valueN)，其中value1是一个返回值的名称，多个返回值之间必须使用逗号分隔开。函数的返回值可以全部命名或者全都不命名，但不能只是部分命名的。

如果函数有返回值，则函数必须至少有一个return语句或最后执行panic()调用。如果返回值不是命名的，则return语句必须制定和返回值一样多的值。如果返回值是命名的，则return语句可以像没有命名的返回值方式一样或者一个空的return语句。主要尽管空的return语句是合法的，但它被认为是一种拙劣的写法。
### 7.1 函数参数
通常所见的函数都是固定参数和吸顶类型的，但是如果参数的类型是interface{}，我们就可以传递任何类型的数据。通过使用接口类型参数（无论是自定义接口类型还是标准库里定义的接口类型），我们可以让所创建的函数接受任何实现特定方法集合的类型作为参数。

所谓可变参数函数是指函数的最后一个参数可以接受任意个参数。这个函数咋最后一个参数的类型前面添加有一个省略号。在函数里面这个参数实质上变成了对应参数的一个切片。例如，**我们有一个签名为Join(xs ...string)的函数，xs的类型其实就是[]string**。
```
func MinimumInt1(first int, rset ...int) int {
    for _, x := range rset {
        if x < first {
            first = x
        }
    }
    return first
}
```
传递切片给可变参数函数时，我们必须使用省略号 **...** 操作符来告诉Go语言将被添加进来的元素当成多个元素：
```
numbers := []int{7, 6, 2, -1, 7, -3, 6}
fmt.Println(MinimumInt1(numbers[0], numbers[1:]...))
```
**Go语言并没有直接支持可选参数。**
### 7.2  init()函数和main()函数
Go语言为特定目的保留了两个函数名： init()（可以出现在任何的包里）函数和main()函数（只出现在main包里）。这两个函数既不可接收任何参数，也不返回任何结果，一个包里可以有很多 init()函数。但当前Go编译器只支持每个包里最多一个 init()函数，所以推荐在一个包里最多只用一个 init()函数。

 init()函数和main()函数是自动执行的，所以我们不应该显式调用它们。对程序和包来说 init()函数是可选的，但是每一个程序必须在main包里包含一个main()函数。

 Go程序的初始化和执行总是从main包开始，如果main包里导入了其它的包，则会按照顺序将它们包含进main包里。如果一个包被其它的包多次导入的话，这个包实际上只会被导入一次。当一个包被导入时，如果它自己还导入了其它的包，则还是先将其它的包导入进来，然后再创建这个包的一些常量和变量。再这接着就是调用 init()函数了（如果有多个就调用多次），最终所有的包都会被导入到main包里（包括这些包所导入的包），这时候main包里的常量和变量也会被创建， init()函数会被执行（如果有或者多个的话）。最后，main包里的 main()函数会被执行，程序开始运行。
### 7.3 闭包
所谓“闭包”就是一个函数“捕获”了和它在同一作用域的其它常量和变量，这意味着当闭包被调用时，不管在程序什么地方调用，闭包能够使用这些常量和变量。它不关心这些捕获了的变量和常量是否已经超出了作用域，所以只要闭包还在使用它，这些变量就会存在。

在Go语言里，所有的匿名函数（Go语言规范之中称之为函数字面量）都是闭包。

闭包的创建方式和普通函数在语法上几乎一致，但有一个关键的区别：闭包没有名字（所以func关键字之后紧接着左括号）。通常都是通过将闭包赋值给一个变量来使用闭包，或者将它放到一个数据结构里（如映射或切片）。

闭包的一种用法就是利用包装函数来为被包装的函数定义一到多个参数。例如，加入我们想给大量文件增加不同后缀，本质上就要包装string的+连接操作符，一个参数会不断变化（文件名）而另一个参数为固定值（后缀名）。
```
func MakeAddSuffix(suffix string) func(string) string {
    return func(name string) string {
        if !strings.HasSuffix(name, suffix) {
            return name + suffix
        }
        return name
    }
}
```
工厂函数MakeAddSuffix()返回的闭包在创建时捕获了suffix变量。这个返回的闭包接受一个字符串参数（文件名）并返回添加了被捕获的suffix的文件名。
```
addZip := MakeAddSuffix(".zip")
addPng := MakeAddSuffix(".png")
fmt.Println(addZip(:filename"), addPng("filename"))
```
这里创建了两个闭包addZip和addPng并调用了它们。
### 7.4 递归函数
递归函数通常有相同的结构：一个跳出条件和一个递归体，所谓跳出条件就是一个条件语句，例如if语句的那个，根据传入的参数判断是否需要停止递归；而递归体则是函数自身所做的一些处理，包括最少也得调用自身一次（或者调用它相互递归的另一个函数），而且递归调用时所传入的参数一定不能和当前函数传入的一样，在跳出条件里还会检查是否可以终止递归。

**尾递归：当一个函数使用尾递归，也就是在最后一句执行递归调用，在这种情况下我们可以简单地将它转换成一个循环。**
### 7.5 运行时选择参数
在Go语言里，函数属于第一类值（first-class value），也就是说，你可以将它保存到一个变量（实际上是一个引用）里，这样我们就可以在运行时决定要执行哪一个函数。再者，Go语言能够创建闭包意味着我们可以在运行时创建函数，所以我们对同一个函数可以有两个或多个不同的实现（例如使用不同的算法），在使用的时候创建它们其中的一个就行。

**使用映射和函数引用来制造分支**
```
var FunctionForSuffix = map[string]func(string) ([]string, error) {
    ".gz":GzipFileList, ".tar":TarFileList, ".tar.gz":TarFileList,
    ".tgz":TarFileList, ".zip":ZipFileList}
func ArchiveFileListMap(file string) ([]string, error) {
    if function, ok = FunctionForSuffix[Suffix(file)]; ok {
        return function(file)
    }

    return nil, errors.New("unrecognized archive")
}
```
**动态函数的创建**

在运行时动态创建函数的另一个场景是，当我们有两个或者更多的函数实现了相同的功能时，比如说使用了不同的算法，我们不希望在程序编译时静态绑定到其中任一个函数，相反，我们可以动态选择它们来做性能测试或回归测试。
```
var IsPalindrom func(string) bool          //保存到函数的引用
func init() {
    if len(os.Args) > 1 && (os.Args[1] == "-a" || os.Args[1] =="--ascii") {
        os.Args = append(os.Args{:1], os.Args[2:]...)              //去掉参数
        IsPalindrom = func(s string) bool {                                 //简单的ascii版本
            if len(s) <= 1 {
                return true
            }
            if s[0] != s[len(s)-1] {
                return false
            }
            return IsPalindrom(s[1:len(s)-1])
        }
    } else {
        IsPalindrom = func(s string) bool {                //UTF-8的版本
            // ...
        }
    }
}
```

# Reference
- [Go 主页](https://golang.google.cn/)
- [Go字符串](https://github.com/wbb1975/blogs/blob/master/Go/go_string.md)
- [Go面向对象编程](https://github.com/wbb1975/blogs/blob/master/Go/go_object_oriented_programming.md)
- [Go并发编程](https://github.com/wbb1975/blogs/blob/master/Go/go_concurrent_programming.md)
