# Getting started with generics

这个教程将介绍 Go 泛型基础。通过泛型，你可以声明和使用可适用于一个类型集合中任意类型的函数或类型。

在这个教程中，你将声明两个简单的非泛型函数，然后将其改造成泛型版本。

你将经历以下几个章节：

1. 为你的代码创建一个目录
2. 添加非泛型函数
3. 添加一个泛型函数以处理多个类型
4. 调用泛型函数时移除类型参数
5. 声明类型限制

> 注意：其它教程，请参见[教程主页](https://go.dev/doc/tutorial/index.html)

> 注意：如果你喜欢，作为替代你可以使用[Go playground in “Go dev branch” mode](https://go.dev/play/?v=gotip)来编辑并运行你的代码。

## 0. 前提条件

- **一个 Go 1.18 或更新版本的安装**：关于安装指令，请参见[安装 Go](https://go.dev/doc/install)。
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。

## 1. 为你的代码创建一个目录

作为开始，为你即将编写的代码创建一个目录。

1. 打开命令行终端并切换到你的主目录：

   在 Linux 或 Mac:
   ```
   cd
   ```

   在 Windows:
   ```
   C:\> cd %HOMEPATH%
   ```

   教程剩余部分的提示符将显示为 `$`，你使用的命令也可作用于 `Windows`。

2. 从命令行提示符，为你的代码创建一个 `generics` 目录

   ```
   $ mkdir generics
   $ cd generics
   ```

3. 创建一个模块以容纳你的代码。

   运行 `go mod init` 命令，并传递你的新代码的模块路径。

   ```
   $ go mod init example/data-access
   go: creating new go.mod: module example/data-access
   ```

   > 注意：在实际开发中，你可以根据你的需求指定一个更特殊的模块路径。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

接下来，我们将一些简单代码来与映射互动。

## 2. 添加非泛型函数

这一步，你将创建两个函数，它们将把一个映射中的所有值相加并返回其总和。

你将声明两个函数而非一个，其原因在于你将以两种类型的映射交互：一个存储 `int64` 类型的值，另一个则为 `float64` 类型。

### 2.1 编写代码

1. 使用你的文本编辑器，在 `generics` 目录下创建名为 `main.go` 的 Go 文件。你将在这个文件里编写你的代码。
2. 在 `main.go` 中，在文件顶部，粘贴进下面的包声明。

   ```
   package main
   ```

   一个独立应用（与库相对）总是位于 `main` 包里。
3. 在包声明之下，粘贴下面两个函数声明。

    ```
    // SumInts adds together the values of m.
    func SumInts(m map[string]int64) int64 {
        var s int64
        for _, v := range m {
            s += v
        }
        return s
    }

    // SumFloats adds together the values of m.
    func SumFloats(m map[string]float64) float64 {
        var s float64
        for _, v := range m {
            s += v
        }
        return s
    }
   ```

   在这段代码中，你：
   + 声明了两个函数，将一个映射中的所有值相加并返回其值。
     - `SumFloats` 需要一个字符串至 `float64` 值的映射。
     - `SumInts` 需要一个字符串至 `int64` 值的映射。

4. 在 `main.go` 顶部，包声明之下，将下面的代码粘贴进 `main` 函数以初始化两个映射并将它们作为参数调用前面编写的两个求和函数。
   
   ```
   func main() {
       // Initialize a map for the integer values
       ints := map[string]int64{
           "first":  34,
           "second": 12,
       }

       // Initialize a map for the float values
       floats := map[string]float64{
           "first":  35.98,
           "second": 26.99,
       }

       fmt.Printf("Non-Generic Sums: %v and %v\n",
           SumInts(ints),
           SumFloats(floats))
   }
   ```

   在这段代码中，你：
   + 初始化了一个 `float64` 值的映射和一个 `int64` 值的映射，每个映射有两个元素。
   + 调用先前创建的两个函数对两个映射的值求和。
   + 打印出结果。

5. 在靠近 `main.go` 顶部，包声明之下，导入你刚编写的代码所需要的包。

    前面几行代码看起来应该像这样：

    ```
    package main

    import "fmt"
    ```

6. 保存 `main.go`。

### 2.2 运行代码

从包含 `main.go` 的目录中开启一个命令行终端，运行代码：

```
$ go run .
Non-Generic Sums: 46 and 62.97
```

使用泛型，你可以只编写一个函数而非两个。下一步，你将添加一个简单的泛型函数适用于包含 `integer` 或 `float` 值的映射。

## 3. 添加一个泛型函数以处理多个类型

在这一节，你将添加一个简单泛型函数，它可以接受包括 `integer` 或 `float` 值的映射。你可以用一个简单函数高效替代你刚刚编写的两个函数。

为了支持任意类型的值，这个简单泛型函数需要声明它支持什么类型。另一方面，调用代码需要一种方式指定它是在传递一个 `integer` 或 `float` 映射。

为了支持这个，除了常规函数参数之外，你写的函数需要声明类型参数。这些类型参数使函数成为泛型（函数），使它可以工作于不同类型的参数。你可以传递类型参数和普通函数参数以调用它。

每一个类型参数都有一个类型约束，这被用作类型参数的元类型。每个类型约束指定了调用代码针对该类型参数可以允许使用的类型参数。

一个类型参数的约束典型地代表了一系列类型，在编译期类型参数代表一个简单类型--调用代码通过类型参数提供的类型。如果类型参数的类型不被该类型参数的约束允许，则编译不能通过。

记住类型参数必须支持泛型代码作用于其上的所有操作。例如，如果你的函数代码在试图在一个其约束包括整型类型的类型参数上操作字符串（比如索引），代码将不能编译。

在你即将编写的代码里，你将使用约束允许 `integer` 或 `float` 类型。

### 3.1 编写代码

1. 在你之前添加的两个函数之下，粘贴进下面的泛型函数。

   ```
   // SumIntsOrFloats sums the values of map m. It supports both int64 and float64
   // as types for map values.
   func SumIntsOrFloats[K comparable, V int64 | float64](m map[K]V) V {
       var s V
       for _, v := range m {
           s += v
       }
       return s
   }
   ```

   在这段代码中，你：
   + 声明了一个函数 `SumIntsOrFloats`，它带两个类型参数（在方括号内），即 `K` 和 `V` 的，以及一个使用类型参数的普通参数，即类型为 `map[K]V` 的参数 `m`。函数返回一个类型为 `V` 的值。
   + 为类型参数 `K` 指定了类型限制 `comparable`。`comparable` 限制是在 Go 中预声明的，在这个 case 里是有意如此。任何其值可以被用作比较操作符 `==` 和 `!=` 的操作码的类型都被允许。Go 要求映射的键使可比较的。因此声明 `K` 为 `comparable` 使必要的，如此你才能使用 `K` 用作映射变量的键。它也确保调用代码为映射键使用一个允许的类型。
   + 为 `V` 类型参数指定一个类型限制，它是两种类型的联合：`int64` 和 `float64`。使用 `|` 指定两种类型的联合，意味着这个约束允许任一类型。任一类型都被编译器允许作为调用代码的参数。
   + 指定 `map[K]V` 类型的参数 `m`，这里 `K` 和 `V` 已经作为类型参数指定。注意我们知道 `map[K]V` 是一个有效的映射类型，原因在于 `K` 是一个 `comparable` 类型。如果我们没有声明 `K` 为 `comparable`，编译器将拒绝 `map[K]V` 引用。

2. 在 `main.go` ，在你已有的代码之下，粘贴下面的代码。

   ```
   fmt.Printf("Generic Sums: %v and %v\n",
   SumIntsOrFloats[string, int64](ints),
   SumIntsOrFloats[string, float64](floats))
   ```

   在这段代码中，你：
   + 以你创建的两个映射分别调用了你刚声明的泛型函数。
   + 指定类型参数--类型名在方括号中--调用先前创建的两个函数对两个映射的值求和。
　　　
     在下一节你将看到，你经常可以在函数调用总声调类型参数。Go 经常可以从你的代码中推导出它们。
   + 打印出结果。

### 3.2 运行代码

从包含 `main.go` 的目录中开启一个命令行终端，运行代码：

```
$ go run .
Non-Generic Sums: 46 and 62.97
Generic Sums: 46 and 62.97
```

为了运行你的代码，每次调用编译器将会用实际传递的类型替换类型参数。

在调用你写的泛型函数时，你指定类型参数用于告诉编译器什么类型被用于替换类型参数。正如你将在下一节看到的，由于编译器推导，在很多情况下你可以省略类型参数。

## 4. 调用泛型函数时移除类型参数

在本节，你将添加泛型函数调用的一个修改版本，一点小的修改就可以简化调用代码。你将移除类型参数，在本例中它们实际上不需要。

当 Go 编译器可以推导你想使用的类型时，你可以在调用代码处省掉类型参数。编译器从函数参数推导类型参数。

注意这并不总是可能的。如果你需要调用一个没有参数的泛型函数，你需要在函数调用处包括类型参数。

### 4.1 编写代码

1. 在 `main.go` 中，在你已有的代码之下，粘贴进下面的代码。

   ```
   fmt.Printf("Generic Sums, type parameters inferred: %v and %v\n", 
       SumIntsOrFloats(ints),
       SumIntsOrFloats(floats))
   ```

   在这段代码中，你：
   + 省略类型参数调用了泛型代码。

### 4.2 运行代码

从包含 `main.go` 的目录中开启一个命令行终端，运行代码：

```
$ go run .
Non-Generic Sums: 46 and 62.97
Generic Sums: 46 and 62.97
Generic Sums, type parameters inferred: 46 and 62.97
```

接下来，通过捕捉 `integers` 和 `floats` 的共性来形成一个你可以使用的类型约束，你可以进一步简化函数。如后面的代码所示。

## 5. 声明类型限制

下面的章节，你将把你先前定义的约束转化为它们的接口，如此你可以在多处复用它。当约束变得复杂时，这种方式生命约束可以精简代码。

你声明类型约束为一个接口，约束允许任何实现了该接口的类型。例如，如果你声明了一个带三个方法的类型约束接口，把它用作一个泛型函数的类型参数，调用代码时的实际类型参数必须实现了这三种方法。

约束接口可以应用特定类型，正如这一接即将展示的。

### 5.1 编写代码

1. 在 `main` 之上，导入语句之下，粘贴下面的代码以声明一个类型约束。

   ```
   type Number interface {
      int64 | float64
   }
   ```

   在这段代码中，你：
   + 声明了 `Number` 接口类型以用作类型约束。
   + 在接口内部声明了一个 `int64`和`float64`的联合。

     重要的是，你将联合从函数声明那里移至一个新的类型约束。这种方式，当你想要限制一个类型参数为 `int64` 或 `float64` 的时候，你可以使用这个 `Number` 类型约束而无需使用 `int64 | float64`。

2. 在你已有的函数之下，粘贴下面的泛型函数 `SumNumbers`：

   ```
   // SumNumbers sums the values of map m. It supports both integers
   // and floats as map values.
   func SumNumbers[K comparable, V Number](m map[K]V) V {
       var s V
       for _, v := range m {
           s += v
       }
       return s
   }
   ```

   在这段代码中，你：
   + 声明了一个和你之前创建的泛型函数一样逻辑的泛型函数，但是使用新的接口类型而非联合作为类型约束。和以前一样，你使用类型参数作为返回值类型。

3. 在 `main.go`，在你已有的代码之下，黏贴下面的代码：

   ```
   fmt.Printf("Generic Sums with Constraint: %v and %v\n",
    SumNumbers(ints),
    SumNumbers(floats))
   ```

   在这段代码中，你：
   + 用每个映射调用了 `SumNumbers`并打印各自返回的求和值。

     像前面章节一样，你在调用泛型函数时省略了类型参数（类型名在方括号里）。Go 编译器可以从其它参数里推导出类型参数。

### 5.2 运行代码

从包含 `main.go` 的目录中开启一个命令行终端，运行代码：

```
$ go run .
Non-Generic Sums: 46 and 62.97
Generic Sums: 46 and 62.97
Generic Sums, type parameters inferred: 46 and 62.97
Generic Sums with Constraint: 46 and 62.97
```

## 6. 结论

祝贺你！你已经了解了 Go 中泛型的基础知识。

建议关注下面的主题：

+ [Go Tour](https://go.dev/tour/) 是一个极好的对 Go 基础的逐步介绍。
+ 如果你是 Go 新手，你将发现在 [Effective Go](https://go.dev/doc/effective_go) 以及 [How to write Go code](https://go.dev/doc/code) 里描述的最佳实践时很有用的。

## 7. 完整代码

你可以在 [Go playground](https://go.dev/play/p/apNmfVwogK0?v=gotip) 运行这个应用。在 `playground` 仅仅点击 `Run` 即可启动它。

```
package main

import "fmt"

type Number interface {
    int64 | float64
}

func main() {
    // Initialize a map for the integer values
    ints := map[string]int64{
        "first": 34,
        "second": 12,
    }

    // Initialize a map for the float values
    floats := map[string]float64{
        "first": 35.98,
        "second": 26.99,
    }

    fmt.Printf("Non-Generic Sums: %v and %v\n",
        SumInts(ints),
        SumFloats(floats))

    fmt.Printf("Generic Sums: %v and %v\n",
        SumIntsOrFloats[string, int64](ints),
        SumIntsOrFloats[string, float64](floats))

    fmt.Printf("Generic Sums, type parameters inferred: %v and %v\n",
        SumIntsOrFloats(ints),
        SumIntsOrFloats(floats))

    fmt.Printf("Generic Sums with Constraint: %v and %v\n",
        SumNumbers(ints),
        SumNumbers(floats))
}

// SumInts adds together the values of m.
func SumInts(m map[string]int64) int64 {
    var s int64
    for _, v := range m {
        s += v
    }
    return s
}

// SumFloats adds together the values of m.
func SumFloats(m map[string]float64) float64 {
    var s float64
    for _, v := range m {
        s += v
    }
    return s
}

// SumIntsOrFloats sums the values of map m. It supports both floats and integers
// as map values.
func SumIntsOrFloats[K comparable, V int64 | float64](m map[K]V) V {
    var s V
    for _, v := range m {
        s += v
    }
    return s
}

// SumNumbers sums the values of map m. Its supports both integers
// and floats as map values.
func SumNumbers[K comparable, V Number](m map[K]V) V {
    var s V
    for _, v := range m {
        s += v
    }
    return s
}
```

## Reference

- [Getting started with generics](https://go.dev/doc/tutorial/generics)