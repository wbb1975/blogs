# Effective Modern CMake

## Getting Started
对CMake的一个简单的用户级介绍，请查看C++ Weekly, Episode 78, Jason Turner的[Intro to CMake](https://www.youtube.com/watch?v=HPMvU64RUTY)。 LLVM的 [CMake Primer](https://llvm.org/docs/CMakePrimer.html)提供了对CMake语法的一个很好的高级介绍。请前往阅读它。

之后，观看Mathieu Ropert在CppCon 2017上的演讲[Using Modern CMake Patterns to Enforce a Good Modular Design](https://www.youtube.com/watch?v=eC9-iRN2b04) ([slides](https://github.com/CppCon/CppCon2017/blob/master/Tutorials/Using%20Modern%20CMake%20Patterns%20to%20Enforce%20a%20Good%20Modular%20Design/Using%20Modern%20CMake%20Patterns%20to%20Enforce%20a%20Good%20Modular%20Design%20-%20Mathieu%20Ropert%20-%20CppCon%202017.pdf))。它对现代CMake是什么以及为什么它比旧学校的CMake好得多提供了一个详尽的解释。该演讲中模块化设计的思想基于John Lakos的书[Large-Scale C++ Software Design](https://www.amazon.de/Large-Scale-Software-Addison-Wesley-Professional-Computing/dp/0201633620)。下一个视频解释了现代CMake的更多细节，来自 Daniel Pfeifer在C++Now 2017上的演讲[Effective CMake](https://www.youtube.com/watch?v=bsXLMQ6WgIk) ([slides](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf))。

本文深受Mathieu Ropert和Daniel Pfeifer的演讲的影响。

如果你对CMake的历史和内部架构感兴趣，请看看在[The Architecture of Open Source Applications](http://aosabook.org/en/index.html)一书中的文章[CMake](http://www.aosabook.org/en/cmake.html)。
## General
### 使用至少CMake版本3.0.0.
现代CMake只有从版本3.0.0后才可用。
### 对待CMake代码应像对待产品代码
CMake时代吗。因此它应该是干净的。对`CMakeLists.txt`和模块使用与其它代码基同样的原则，
### 全局定义项目属性（Define project properties globally)
比如，一个项目可能使用一套公共编译警告。在顶部`CMakeLists.txt`中全局定义这些属性可以防止一些情况：一个依赖目标的公共头文件导致它不能通过编译，原因在于依赖目标使用更严格的编译选项。全局定义此类项目属性使得管理项目及其所有目标更简单。
### 忘记这些命令吧：`add_compile_options`, `include_directories`, `link_directories`, `link_libraries`
这些命令运作于目录级别。所有在该级别上定义的所有目标继承了这些属性。这增加了隐藏依赖的几率。最好直接在这些目标上运作。
### 放手 `CMAKE_CXX_FLAGS`
不同的编译器使用不同的命令行参数格式。借助`CMAKE_CXX_FLAGS`中的`-std=c++14`来设置C++标准未来很可能会刹车，因为这些需求也被其它标准如C++17实现了，并且（同一标准）编译器选项与老的编译器选项并不相同。因此告诉CMake编译特性从而给定使用的合适的编译特性会好得多。
### 不要滥用使用需求（Don’t abuse usage requirements）
作为一个例子，请不要添加`-Wall`到`target_compile_options`的`PUBLIC` 或 `INTERFACE`段，因为它并不用于构建依赖目标。
## 模块
### 使用现代find模块来声明导出目标
从CMake 3.4开始，越来越多的find 模块导出可通过`target_link_libraries`使用的目标。
### 使用外部包的导出目标（Use exported targets of external packages）
不要回到老的使用外部包定义的变量的CMake模式。取而代之，通过`target_link_libraries`使用导出目标。
### 使用find 模块来支持不支持客户使用CMake的第三方库
CMake为第三方库提供了一套查找模块。例如，Boost不支持CMake，取而代之，CMake提供了查找模块来在CMake中使用Boost。
### 如果一个第三方库不支持客户使用CMake，将其作为一个bug报告给库作者。如果该库是一个开源项目，考虑发送一个补丁包。
CMake已经统治了构建行业，如果一个库不支持CMake，那就是库作者的问题。
### 对于不支持客户使用CMake的第三方库，写一个查找模块
可能需要翻新一个查找模块使其能够导出目标到一个不支持CMake的外部包。
### 如果你是库作者，导出你的库接口
请查看Daniel Pfeifer的 C++Now 2017 演讲[Effective CMake](https://youtu.be/bsXLMQ6WgIk?t=37m15s) ([slide](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf) 24ff.) 关于如何实现这个。记住导出正确的信息，使用`BUILD_INTERFACE` 和 `INSTALL_INTERFACE`生成器表达式作为过滤器。
## 项目
### 避免在项目命令的参数中引入自定义变量
保持事情简单。不要引入不必要的自定义变量。取代`add_library(a ${MY_HEADERS} ${MY_SOURCES})`，使用`add_library(a b.h b.cpp)`。
### 在项目中不要使用`file(GLOB)`
CMake是一个构建系统生成器，并不是一个构建系统。在产生构建系统时，它对`GLOB`表达式求值，并得到一系列文件。构建系统接下来在这些文件上工作。因此，构建系统不能检测到文件系统中的某些更改。

CMake不能仅仅把`GLOB`转发给构建系统，因此表达式在构建时求值。CMake期待成为所有支持的构建系统的公共分母。并不是所有构建系统支持这个，因此CMake也不支持它。
### 将CI特定的设置放置在CTest脚本中，而不是在项目里
它仅仅使得事情简单。 通过CTest Script查看Dashboard苦户端来获取更多信息。
### 对于测试名，遵从一个命名规范
这简化了在通过CTest运行测试时的正则式过滤功能。
## 目标和属性
### 考虑目标和属性
就目标而言，通过定义属性（如编译定义，编译选项，编译特性，包含目录和库依赖），它帮助开发人员在目标级别推断系统。开发人员不需要理解整个系统以推断单个目标。构建系统会传递性地处理它。
### 把目标想象成对象
调用成员函数修改一个对象的成员变量。

同构造函数类似：
* `add_executable`
* `add_library`

同成员变量相似： 
* target properties (too many to list here)

同成员函数类似:
* `target_compile_definitions`
* `target_compile_features`
* `target_compile_options`
* `target_include_directories`
* `target_link_libraries`
* `target_sources`
* `get_target_property`
* `set_target_property`

### 保持内部属性 `PRIVATE`
入股一个目标需要内部属性（如编译定义，编译选项，编译特性，包含目录和库依赖），将它们添加到`target_*`的`PRIVATE`部分。
### 利用`target_compile_definitions`声明编译定义
这将把编译定义与它们的可见性（`PRIVATE`, `PUBLIC`, `INTERFACE`）关联到目标上。这比使用`add_compile_definitions`要好，后者并不与一个目标关联。
### 利用`target_compile_options`声明编译选项
这将把编译选项与它们的可见性（`PRIVATE`, `PUBLIC`, `INTERFACE`）关联到目标上。这比使用`add_compile_options`要好，后者并不与一个目标关联。但要注意不要声明影响ABI的编译选项。全局声明这些选项，可查看“不要使用`target_compile_options`来设置印象ABI的选项”。
### 利用`target_compile_features`声明编译特性
留待添加。
### Declare include directories with `target_include_directories`.

This associates the include directories with their visibility (`PRIVATE`, `PUBLIC`, `INTERFACE`) to the target. This is better than using `include_directories`, which has no association with a target.

### Declare direct dependencies with `target_link_libraries`.

This propagates usage requirements from the dependent target to the depending target. The command also resolves transitive dependencies.

### Don’t use `target_include_directories` with a path outside the component’s directory.

Using a path outside a component’s directory is a hidden dependency. Instead, use `target_include_directories` to propagate include directories as usage requirements to depending targets via `target_link_directories`. 

### Always explicitly declare properties `PUBLIC`, `PRIVATE`, or `INTERFACE` when using `target_*`.

Being explicit reduces the chance to unintendedly introduce hidden dependencies.

### Don’t use target_compile_options to set options that affect the ABI.

Using different compile options for multiple targets may affect ABI compatibility. The simplest solution to prevent such problems is to define compile options globally (also see “Define project properties globally.”). 

### Using a library defined in the same CMake tree should look the same as using an external library.

Packages defined in the same CMake tree are directly accessible. Make prebuilt libraries available via `CMAKE_PREFIX_PATH`. Finding a package with `find_package` should be a no-op if the package is defined in the same build tree. When you export target `Bar` into namespace `Foo`, also create an alias `Foo::Bar` via `add_library(Foo::Bar ALIAS Bar)`. Create a variable that lists all sub-projects. Define the macro `find_package` to wrap the original `find_package` command (now accessible via `_find_package`). The macro inhibits calls to `_find_package` if the variable contains the name of the package. See Daniel Pfeifer’s C++Now 2017 talk [Effective CMake](https://youtu.be/bsXLMQ6WgIk?t=50m30s) ([slide](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf) 31ff.) for more information.

## Functions and Macros

### Prefer functions over macros whenever reasonable.

In addition to directory-based scope, CMake functions have their own scope. This means variables set inside functions are not visible in the parent scope. This is not true of macros.

### Use macros for defining very small bits of functionality only or to wrap commands that have output parameters. Otherwise create a function.

Functions have their own scope, macros don’t. This means variables set in macros will be visible in the calling scope.

Arguments to macros are not set as variables, instead dereferences to the parameters are resolved across the macro before executing it. This can result in unexpected behavior when using unreferenced variables. Generally speaking this issue is uncommon because it requires using non-dereferenced variables with names that overlap in the parent scope, but it is important to be aware of because it can lead to subtle bugs.

### Don’t use macros that affect all targets in a directory tree, like `include_directories`, `add_definitions`, or `link_libraries`. 

Those macros are evil. If used on the top level, all targets can use the properties defined by them. For example, all targets can use (i.e., `#include`) the headers defined by `include_directories`. If a target does not require linking (e.g., interface library, inline template), you won’t even get a compiler error in this case. It is easy to accidentally create hidden dependencies through other targets with those macros.

## Arguments

### Use `cmake_parse_arguments` as the recommended way to handle complex argument-based behaviors or optional arguments in any function.

Don’t reinvent the wheel.

## Loops

### Use modern foreach syntax.

* `foreach(var IN ITEMS foo bar baz) ...`
* `foreach(var IN LISTS my_list) ...`
* `foreach(var IN LISTS my_list ITEMS foo bar baz) ...`

## Packages

### Use CPack to create packages.

CPack is part of CMake and nicely integrates with it.

## Write a `CPackConfig.cmake` that includes the one generated by CMake.

This makes it possible to set additional variables that don’t need to appear in the project.

## Cross Compiling

### Use toolchain files for cross compiling.

Toolchain files encapsulate toolchains for cross compilation.

### Keep toolchain files simple.

It’s easier to understand and simpler to use. Don’t put logic in toolchain files. Create a single toolchain file per platform.

## Warnings and Errors

### Treat build errors correctly.

* Fix them.
* Reject pull requests.
* Hold off releases.

### Treat warnings as errors.

To treat warnings as errors, never pass `-Werror` to the compiler. If you do, the compiler treats warnings as errors. You can no longer treat warnings as errors, because you no longer get any warnings. All you get is errors.

* You cannot enable `-Werror` unless you already reached zero warnings.
* You cannot increase the warning level unless you already fixed all warnings introduced by that level.
* You cannot upgrade your compiler unless you already fixed all new warnings that the compiler reports at your warning level.
* You cannot update your dependencies unless you already ported your code away from any symbols that are now `[[deprecated]]`.
* You cannot `[[deprecated]]` your internal code as long as it is still used. But once it is no longer used, you can as well just remove it.

### Treat new warnings as errors.

1. At the beginning of a development cycle (e.g., sprint), allow new warnings to be introduced.
    * Increase warning level, enable new warnings explicitly.
    * Update the compiler.
    * Update dependencies.
    * Mark symbols as `[[deprecated]]`.
2. Burn down the number of warnings.
3. Repeat.

## Static Analysis

### Use more than one supported analyzer.

Using clang-tidy (`<lang>_CLANG_TIDY`), cpplint (`<lang>_CPPLINT`), include-what-you-use (`<lang>_INCLUDE_WHAT_YOU_USE`), and `LINK_WHAT_YOU_USE` help you find issues in the code. The diagnostics output of those tools will appear in the build output as well as in the IDE.

## For each header file, there must be an associated source file that `#include`s the header file at the top, even if that source file would otherwise be empty.

Most of the analysis tools report diagnostics for the current source file plus the associated header. Header files with no associated source file will not be analyzed. You may be able to set a custom header filter, but then the headers may be analyzed multiple times.

## Sources
* [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1)
* [Intro to CMake](https://www.youtube.com/watch?v=HPMvU64RUTY) by Jason Turner at C++ Weekly (Episode 78)
* LLVM [CMake Primer](https://llvm.org/docs/CMakePrimer.html)
* [Using Modern CMake Patterns to Enforce a Good Modular Design](https://www.youtube.com/watch?v=eC9-iRN2b04) ([slides](https://github.com/CppCon/CppCon2017/blob/master/Tutorials/Using%20Modern%20CMake%20Patterns%20to%20Enforce%20a%20Good%20Modular%20Design/Using%20Modern%20CMake%20Patterns%20to%20Enforce%20a%20Good%20Modular%20Design%20-%20Mathieu%20Ropert%20-%20CppCon%202017.pdf)) by Mathieu Ropert at CppCon 2017
* [Effective CMake](https://www.youtube.com/watch?v=bsXLMQ6WgIk) ([slides](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf)) by Daniel Pfeifer at C++Now 2017
* The Architecture of Open Source Applications: [CMake](http://www.aosabook.org/en/cmake.html)
