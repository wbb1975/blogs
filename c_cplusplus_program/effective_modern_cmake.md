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
不要回到老的使用外部包定义的变量的CMake模式。取而代之，通过`target_link_libraries`使用倒出目标。
### 使用find 模块来支持不支持客户使用CMake的第三方库
CMake provides a collection of find modules for third-party libraries. For example, Boost doesn't support CMake. Instead, CMake provides a find module to use Boost in CMake.

### Report it as a bug to third-party library authors if a library does not support clients to use CMake. If the library is an open-source project, consider sending a patch.

CMake dominates the industry. It’s a problem if a library author does not support CMake.

### Write a find module for third-party libraries that do not support clients to use CMake.

It’s possible to retrofit a find module that properly exports targets to an external package that does not support CMake. 

### Export your library’s interface, if you are a library author.

See Daniel Pfeifer’s C++Now 2017 talk [Effective CMake](https://youtu.be/bsXLMQ6WgIk?t=37m15s) ([slide](https://github.com/boostcon/cppnow_presentations_2017/blob/master/05-19-2017_friday/effective_cmake__daniel_pfeifer__cppnow_05-19-2017.pdf) 24ff.) on how to do this. Keep in mind to export the right information. Use `BUILD_INTERFACE` and `INSTALL_INTERFACE` generator expressions as filters.

## Projects 

### Avoid custom variables in the arguments of project commands.

Keep things simple. Don't introduce unnecessary custom variables. Instead of `add_library(a ${MY_HEADERS} ${MY_SOURCES})`, do `add_library(a b.h b.cpp)`.

### Don't use `file(GLOB)` in projects. 

CMake is a build system generator, not a build system. It evaluates the `GLOB` expression to a list of files when generating the build system. The build system then operates on this list of files. Therefore, the build system cannot detect that something changed in the file system.

CMake cannot just forward the `GLOB` expression to the build system, so that the expression is evaluated when building. CMake wants to be the common denominator of the supported build systems. Not all build systems support this, so CMake cannot support it neither. 

### Put CI-specific settings in CTest scripts, not in the project.

It just makes things simpler. See Dashboard Client via CTest Script for more information.

### Follow a naming convention for test names. 

This simplifies filtering by regex when running tests via CTest.

## Targets and Properties

### Think in terms of targets and properties.

By defining properties (i.e., compile definitions, compile options, compile features, include directories, and library dependencies) in terms of targets, it helps the developer to reason about the system at the target level. The developer does not need to understand the whole system in order to reason about a single target. The build system handles transitivity.

### Imagine targets as objects.

Calling the member functions modifies the member variables of the object.

Analogy to constructors:
* `add_executable`
* `add_library`

Analogy to member variables: 
* target properties (too many to list here)

Analogy to member functions:
* `target_compile_definitions`
* `target_compile_features`
* `target_compile_options`
* `target_include_directories`
* `target_link_libraries`
* `target_sources`
* `get_target_property`
* `set_target_property`

### Keep internal properties `PRIVATE`.

If a target needs properties internally (i.e., compile definitions, compile options, compile features, include directories, and library dependencies), add them to the `PRIVATE` section of the `target_*` commands.

### Declare compile definitions with `target_compile_definitions`.

This associates the compile definitions with their visibility (`PRIVATE`, `PUBLIC`, `INTERFACE`) to the target. This is better than using `add_compile_definitions`, which has no association with a target.

### Declare compile options with `target_compile_options`.

This associates the compile options with their visibility (`PRIVATE`, `PUBLIC`, `INTERFACE`) to the target. This is better than using `add_compile_options`, which has no association with a target. But be careful not to declare compile options that affect the ABI. Declare those options globally. See “Don’t use `target_compile_options` to set options that affect the ABI.”

### Declare compile features with `target_compile_features`.

t.b.d.

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
