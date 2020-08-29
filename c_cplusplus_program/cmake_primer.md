# CMake入门书（CMake Primer）
## 介绍
LLVM 项目和许多在LLVM 构建的核心项目都是用CMake构建，本文旨在为修改LLVM 项目的开发者和在LLVM 之上构建自己项目的开发者提供CMake的一个简单概览。
## 10,000 ft View
CMake 是一个工具，它读入以CMake自己的语言写成的脚本文件，该文件用于描述一个软件项目如何构建。当CMake 评估脚本时，它构造了该软件项目的内部表示。一旦这些脚本被全部处理，如果没有错误发现，CMake将产生用来实际构建项目的构建文件。CMake支持为各种各样的命令行构建工具以及许多流行的IDE产生构建文件。

当一个用户运行CMake 时，它执行各种各样的检查，就像历史上autoconf 做的一样。在检查以及构建脚本语言的评估过程中，CMake将这些值缓存到 CMakeCache中。这是有用的，因为它允许构建系统在增量开发过程中跳过长时间运行的检查。CMake 缓存也有缺陷，但我们稍后再探讨它。
## Scripting 概貌
CMake的脚本语言有很简单的语法，每个语言构造是一个命令，符合 `pattern _name_(_args_)`的模式。命令以3中主要类型呈现：语言定义的（CMake中以C++实现的命令行），定义的函数，以及定义的宏。CMake 发布也包含一套CMake模块，它们包括很多有用的功能的定义。

下面的例子是构建一个C++  “Hello World”程序的完整的CMake文件，它只适用了CMake语言定义的功能。
```
cmake_minimum_required(VERSION 3.15)
project(HelloWorld)
add_executable(HelloWorld HelloWorld.cpp)
```
CMake语言提供了控制流构造如foreach循环，if块等。为了使上面的例子更复杂，你可以加一个if块来定义“APPLE”，用于Apple目标平台。
```
cmake_minimum_required(VERSION 3.15)
project(HelloWorld)
add_executable(HelloWorld HelloWorld.cpp)
if(APPLE)
  target_compile_definitions(HelloWorld PUBLIC APPLE)
endif()
```
## 变量，类型和作用域（Variables, Types, and Scope）
### 解引用（Dereferencing）
在CMake 中，变量是“字符串化”的类型。所有的变量在整个求值过程中都以字符创形式表示。将一个变量包裹在 `${}`里来解引用它，导致对该变量用值进行文本替换。CMake 在他们的文档中将其称为“变量求值”。在被调用的命令接收参数之前解引用将被执行。这意味着解引用一个列表将导致多次独立的参数传递给命令。

变量引用可以嵌套，从而可哟构造复杂的数据结构。比如：
```
set(var_name var1)
set(${var_name} foo) # same as "set(var1 foo)"
set(${${var_name}}_var bar) # same as "set(foo_var bar)"
```
解引用一个`unset`的变量将导致空的扩展。在CMake中根据条件设置变量是很普遍的做法，他可被用于变量未被设置的代码路径上。在LLVM 的CMake构建系统中由很多这样的例子：
```
if(APPLE)
  set(extra_sources Apple.cpp)
endif()
add_executable(HelloWorld HelloWorld.cpp ${extra_sources})
```
在这个例子中，变量 `extra_sources` 只有在你的目标平台是Apple的时候才会定义。对于其它目标，在 `add_executable` 被传递参数前，`extra_sources` 会被求值为空。
### 列表（Lists）
在CMake 中列表是分号分隔的字符串，强烈建议你避免在列表中使用分号，它使用起来并不平顺（go smoothly）。下面是一些定义列表的例子：
```
# Creates a list with members a, b, c, and d
set(my_list a b c d)
set(my_list "a;b;c;d")

# Creates a string "a b c d"
set(my_string "a b c d")
```
### 千套列表（Lists of Lists）
CMake 中一种更复杂的模式就是列表嵌套。因为列表不能包含一个含有分号的元素来构造嵌套列表，你可以构造一个指向其它列表的变量名列表。例如：
```
set(list_of_lists a b c)
set(a 1 2 3)
set(b 4 5 6)
set(c 7 8 9)
```
利用这种布局你可以利用下面的代码迭代嵌套列表并打印所有值：
```
foreach(list_name IN LISTS list_of_lists)
  foreach(value IN LISTS ${list_name})
    message(${value})
  endforeach()
endforeach()
```
你可能已经注意到内层foreach 循环的列表是两次解引用。这是因为第一次解引用是把 list_name 编程子列表名（比如说a， b， c等），接下来是得到（子）列表的值。

这种模式在CMake使用广泛，最常见的例子编译器用标志选项（compiler flags options）。CMake使用下面的变量扩展来引用它：CMAKE_${LANGUAGE}_FLAGS 和 CMAKE_${LANGUAGE}_FLAGS_${CMAKE_BUILD_TYPE}.
### 其它类型（Other Types）
被缓存或从命令行传入的变量可以拥有类型。变量类型被CMake UI工具用于显示正确的输入域。一个变量的类型通常不影响求值，但CMake 读某些变量如PATH并没有特殊的处理。你可以在[CMake set文档](https://cmake.org/cmake/help/v3.5/command/set.html#set-cache-entry)了解更多关于特殊处理的信息。
### 作用域（Scope）
CMake 内部有一个基于目录的作用域。在一个 `CMakeLists` 文件中设置一个变量，将会为那个文件及其所有子目录设置变量，如果一个模块被一个 `CMakeLists` 包含，那么在该模块中设置的变量，将会在其被包含的作用域及其所有子目录设置。

当一个已经设置的变量在一个子目录中再次设置时，它将会在当前作用域及其所有子目录中被覆盖。

CMake set命令提供了两个作用域相关的选项。`PARENT_SCOPE` 在其父作用域而非当前作用域设置变量。`CACHE` 选项在CMakeCache中设置变量，它导致在所有作用域设置该变量。`CACHE` 不能设置一个已经在`CACHE` 里存在的变量，除非 `FORCE` 选项被指定。

除了基于目录的作用域，CMake 函数也有其自己的作用域。这意味着在函数内设置的变量不会混入到其父作用域里。但这对宏（macros）不成立，这也是LLVM 偏爱函数而非宏的原因，除非特殊原因尽量不用宏。
> **注意**：不像类C语言，CMake的循环和控制流块没有自己的作用域。
## 控制流（Control Flow）
CMake 拥有和其它脚本语言一样的基本控制流构造。但有一些特殊点，像所有CMake中功能一样，控制流构造也是命令。
### If, ElseIf, Else
> **注意**：关于CMake if命令的完整信息，请参阅[这里](https://cmake.org/cmake/help/v3.4/command/if.html)。该资源要完整得多。

基本上CMake if块会以你期待的方式工作：
```
if(<condition>)
  message("do stuff")
elseif(<condition>)
  message("do other stuff")
else()
  message("do other other stuff")
endif()
```
源自C语言的一个最重要的事关CMake if块的事情是它没有自己的作用域。在条件快内定义的变量在endif()后依然存在。
### Loops
最常见的CMake foreach块的形式如下：
```
foreach(var ...)
  message("do stuff")
endforeach()
```
foreach 块的那个变量部分可能包含解引用列表，可迭代的值，或者两者混合。
```
foreach(var foo bar baz)
  message(${var})
endforeach()
# prints:
#  foo
#  bar
#  baz

set(my_list 1 2 3)
foreach(var ${my_list})
  message(${var})
endforeach()
# prints:
#  1
#  2
#  3

foreach(var ${my_list} out_of_bounds)
  message(${var})
endforeach()
# prints:
#  1
#  2
#  3
#  out_of_bounds
```
也有一个更现代的CMake foreach 语法。下面的代码和上面一样：
```
foreach(var IN ITEMS foo bar baz)
  message(${var})
endforeach()
# prints:
#  foo
#  bar
#  baz

set(my_list 1 2 3)
foreach(var IN LISTS my_list)
  message(${var})
endforeach()
# prints:
#  1
#  2
#  3

foreach(var IN LISTS my_list ITEMS out_of_bounds)
  message(${var})
endforeach()
# prints:
#  1
#  2
#  3
#  out_of_bounds
```
和条件语句很相似，这些可以按你期待的方式工作，并且它们没有自己的作用域。

CMake也支持 `while` 循环，但他们未在LLVM 管饭是用。
## 模块，函数和宏（Modules, Functions and Macros）
### Modules
### Argument Handling
### Functions Vs Macros
## LLVM项目包装器（LLVM Project Wrappers）
## 有用的内建命令（Useful Built-in Commands）

## Reference
- [CMake Primer](https://llvm.org/docs/CMakePrimer.html)