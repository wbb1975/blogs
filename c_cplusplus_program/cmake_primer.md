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

CMake也支持 `while` 循环，但未在LLVM 中广泛使用。
## 模块，函数和宏（Modules, Functions and Macros）
### 模块（Modules）
模块是CMake代码复用的媒介，CMake模块仅仅是CMake脚本文件。它们可以包含执行代码也可以包含命令定义。

在CMake中，宏和函数被普遍思称为命令。塔恩是定义代码从而多次调用的主要方法。

在LLVM 中我们拥有几个模块作为我们的分发版的一部分，它们主要服务于不从源代码构建我们的项目的开发人员。这些模块是利用CMake构建基于LLVM的项目的基础部分。我们也依赖模块作为LLVM 项目内部保持构建系统的功能，并实现可维护性及可复用性的一种方式。
### 参数处理（Argument Handling）
当定义一个CMake命令时处理参数是非常有用的。本节的所有示例都将使用CMake 的函数块，但这也适用于宏块。

CMake命令可以有命名参数，从而需要每次调用时传递。另外，所有的命令将隐式地接受可变数量的参数（C语言的说法，所有的命令都是变参函数）。当一个命令被带有额外参数（命名蚕食之外）调用时，CMake将参数的完整列表（命名参数和非命名参数）存储在一个加 `ARGV` 的列表中，非命名参数被存储在一个名为 `ARGN` 的子列表中。下面是一个小例子，它提供了CMake内建函数 `add_dependencies`的一个简单封装。
```
function(add_deps target)
  add_dependencies(${target} ${ARGN})
endfunction()
```
上面的示例定义了一个新的宏 `add_deps` ，它带有一个必须参数，其实现仅仅调用另一个函数并传递第一个参数及所有尾参数。

CMake提供了一个模块 `CMakeParseArguments` ，它提供了高级参数解析的实现。我们在几乎所有LLVM中使用它，对于任何需要复杂参数行为和可选参数函数它都是推荐使用的。关于模块的CMake官方文档在 `cmake-modules` 手册页面，从[CMake模块在线文档](https://cmake.org/cmake/help/v3.4/module/CMakeParseArguments.html)也可访问的到。
> **注意**：从CMake 3.5开始 `cmake_parse_arguments` 命令已经成为了一个原生命令，`CMakeParseArguments` 模块已经为空，留在那里仅仅是为了兼容性。
### 函数和宏（Functions Vs Macros）
函数和宏从使用方式上看很相似，但两者之间有一个基础的差别。函数有其自己的作用域，宏则没有。这意味着宏中的变量集会逃逸到外部作用域，这使得宏只适合定义较小的功能。

另一个函数和宏的区别是参数传递的方式。传递给宏的参数并不被设置为变量，反之在执行之前参数的解引用扩整个宏进行。如果使用了未被引用的变量，则可能导致一些不被期待的行为。例如：
```
macro(print_list my_list)
  foreach(var IN LISTS my_list)
    message("${var}")
  endforeach()
endmacro()

set(my_list a b c d)
set(my_list_of_numbers 1 2 3 4)
print_list(my_list_of_numbers)
# prints:
# a
# b
# c
# d
```
通常来讲这个问题不常见。因为它要求使用未被解引用的变量，且名字与其父作用域中的重叠。但它是很重要的，因为它可能导致很微妙的Bug。
## LLVM项目包装器（LLVM Project Wrappers）
LLVM 项目提供了很多对CMake内建命令的包装器。我们使用这些包装器提供跨LLVM组件的一致的行为，并减少代码重复。

我们通常（但不总是）遵循这样的惯例：以 `llvm_`开头的命令仅仅用于为其它命令构建块。用于直接使用的包装器命令通常映射在命令名字的中间（比如`add_llvm_executable` 是`add_executable`的包装器）。LLVM `add_*` 包装定义在AddLLVM.cmake的函数，它是作为LLVM 发布的一部分被安装的。它可被需要LLVM的LLVM子项目包含和使用。
> **注意**：并不是所有的LLVM 项目需要LLVM 。例如`compiler-rt`并不需要LLVM即可构建，并且`compiler-rt sanitizer`库主要用于GCC。
## 有用的内建命令（Useful Built-in Commands）
CMake用于丰富的内建命令。本文档并不打算它们的细节应为CMake项目拥有优秀的文档。一部分投出的供呢个如下：
- [add_custom_command](https://cmake.org/cmake/help/v3.4/command/add_custom_command.html)
- [add_custom_target](https://cmake.org/cmake/help/v3.4/command/add_custom_target.html)
- [file](https://cmake.org/cmake/help/v3.4/command/file.html)
- [list](https://cmake.org/cmake/help/v3.4/command/list.html)
- [math](https://cmake.org/cmake/help/v3.4/command/math.html)
- [string](https://cmake.org/cmake/help/v3.4/command/string.html)
关于CMake 命令的完整文档在 `cmake-commands` 的手册页和[CMake网页](https://cmake.org/cmake/help/v3.4/manual/cmake-commands.7.html)。

## Reference
- [CMake Primer](https://llvm.org/docs/CMakePrimer.html)