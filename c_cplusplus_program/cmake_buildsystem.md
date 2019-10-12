# cmake构建系统
## 1. 简介
一个基于CMake的构建系统被组织为一套高级目标的集合。每个目标代表一个可执行程序或库，或者是一个包含用户命令的自定义目标。目标间的依赖被用来在构建系统中用来决定构建的顺序，以及变化发生时的重新生成规则。
## 2. 二进制目标
可执行文件和库是用[add_executable()](https://cmake.org/cmake/help/latest/command/add_executable.html#command:add_executable) 和 [add_library()](https://cmake.org/cmake/help/latest/command/add_library.html#command:add_library)命令来定义的。生成的二进制文件拥有匹配目标平台的合适的前缀，后缀和扩展名。二进制目标之间的依赖用[target_link_libraries()](https://cmake.org/cmake/help/latest/command/target_link_libraries.html#command:target_link_libraries) 命令来表示。
```
add_library(archive archive.cpp zip.cpp lzma.cpp)
add_executable(zipapp zipapp.cpp)
target_link_libraries(zipapp archive)
```
archive被定义为静态库--archive包含从archive.cpp, zip.cpp, 和 lzma.cpp便以来的目标文件。zipapp被定义为从zipapp.cpp编译，连接而来的可执行程序。当连接可执行文件zipapp时，archive静态库也被连接进来。
### 2.1 二进制可执行文件
[add_executable()](https://cmake.org/cmake/help/latest/command/add_executable.html#command:add_executable) 命令定义了一个可执行文件目标。
```
add_executable(mytool mytool.cpp)
```
许多命令，比如[add_custom_command()](https://cmake.org/cmake/help/latest/command/add_custom_command.html#command:add_custom_command)，产生运行时规则，透明地使用将一个[可执行文件](https://cmake.org/cmake/help/latest/prop_tgt/TYPE.html#prop_tgt:TYPE)作为命令的可执行文件（a COMMAND executable）。构建系统规则可以确保在试图运行命令前先构建可执行文件。
### 2. 2 二进制库类型
#### 2. 2.1 正常库
缺省地， [add_library()](https://cmake.org/cmake/help/latest/command/add_library.html#command:add_library)定义一个静态库，除非指定别的类型。类型可在使用该命令时指定。
```
add_library(archive SHARED archive.cpp zip.cpp lzma.cpp)
add_library(archive STATIC archive.cpp zip.cpp lzma.cpp)
```
变量[BUILD_SHARED_LIBS](https://cmake.org/cmake/help/latest/variable/BUILD_SHARED_LIBS.html#variable:BUILD_SHARED_LIBS)可被开启来改变[add_library()](https://cmake.org/cmake/help/latest/command/add_library.html#command:add_library)的行为使其缺省编译动态库。

在构建系统定义的整体语境下，特定库是静态或动态大体是无关的--不管什么库类型，命令，依赖规范和其它API都一样工作。MODULE库类型是不同的，因为它并不用于被连接--它不能出现在[target_link_libraries()](https://cmake.org/cmake/help/latest/command/target_link_libraries.html#command:target_link_libraries)命令的右边。它是一种使用运行时技术以插件形式加载的类型。如果一个库没有导出任何非受控符号（比如，Windows resource DLL, C++/CLI DLL），那么库就必须不是共享库，因为CMake期待共享库至少导出一个符号。
```
add_library(archive MODULE 7z.cpp)
```
#### 2. 2.2  对象库（Object Libraries）
对象库类型定义了一个从给定源代码文件编译出的目标文件的非归档集合。目标文件集合可以用作其它目标的输入。
```
add_library(archive OBJECT archive.cpp zip.cpp lzma.cpp)

add_library(archiveExtras STATIC $<TARGET_OBJECTS:archive> extras.cpp)

add_executable(test_exe $<TARGET_OBJECTS:archive> test.cpp)
```

其它目标的链接（归档）环节除了利用它本身的源文件外，也将使用目标文件集合。

可选地，目标文件库可被链接进其他目标：
```
add_library(archive OBJECT archive.cpp zip.cpp lzma.cpp)

add_library(archiveExtras STATIC extras.cpp)
target_link_libraries(archiveExtras PUBLIC archive)

add_executable(test_exe test.cpp)
target_link_libraries(test_exe archive)
```

对象库是直接链接的，其它目标的链接（归档）环节将使用对象库中的目标文件。另外，当编译其它目标时，对象库的使用需求必须得到尊重。更进一步，对象库的使用需求将被传递到其它目标的依赖中。

当使用[add_custom_command(TARGET)](https://cmake.org/cmake/help/latest/command/add_custom_command.html#command:add_custom_command) 命令时，对象库不能用作其中的目标（TARGET）。但是，对象文件列表可被用于[add_custom_command(OUTPUT)](https://cmake.org/cmake/help/latest/command/add_custom_command.html#command:add_custom_command)，或者使用`$<TARGET_OBJECTS:objlib>`时的[file(GENERATE)](https://cmake.org/cmake/help/latest/command/file.html#command:file)。
## 3. 构建规范和使用需求
命令[target_include_directories()](https://cmake.org/cmake/help/latest/command/target_include_directories.html#command:target_include_directories), [target_compile_definitions()](https://cmake.org/cmake/help/latest/command/target_compile_definitions.html#command:target_compile_definitions) 和 [target_compile_options()](https://cmake.org/cmake/help/latest/command/target_compile_options.html#command:target_compile_options)指定了二进制目标的构建规范和使用需求。这些命令分别指定了[INCLUDE_DIRECTORIES](https://cmake.org/cmake/help/latest/prop_tgt/INCLUDE_DIRECTORIES.html#prop_tgt:INCLUDE_DIRECTORIES), [COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_DEFINITIONS.html#prop_tgt:COMPILE_DEFINITIONS) 和 [COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_OPTIONS.html#prop_tgt:COMPILE_OPTIONS)目标属性，并/或[INTERFACE_INCLUDE_DIRECTORIES](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html#prop_tgt:INTERFACE_INCLUDE_DIRECTORIES), [INTERFACE_COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_COMPILE_DEFINITIONS.html#prop_tgt:INTERFACE_COMPILE_DEFINITIONS) 以及 [INTERFACE_COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_COMPILE_OPTIONS.html#prop_tgt:INTERFACE_COMPILE_OPTIONS)等目标属性。

每条命令可以有PRIVATE, PUBLIC 和 INTERFACE 模式。PRIVATE模式仅仅植入目标属性的非INTERFACE_变体中，而INTERFACE 模式仅仅植入INTERFACE_变体中。PUBLIC模式则植入目标属性的两种变体中。每个命令调用一个关键字可以多次使用：
```
target_compile_definitions(archive
  PRIVATE BUILDING_WITH_LZMA
  INTERFACE USING_ARCHIVE_LIB
)
```
注意使用需求并不是设计为仅仅让下游更方便使用 [COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_DEFINITIONS.html#prop_tgt:COMPILE_DEFINITIONS) 和 [COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_OPTIONS.html#prop_tgt:COMPILE_OPTIONS)等的方式。这些属性的内容为必须，而不仅仅是建议或方便之举。

从[cmake-packages(7)](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#manual:cmake-packages(7)) 手册的[Creating Relocatable Packages](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#creating-relocatable-packages)小节可以看到许多关于在创建发布包时指定使用需求的额外关注点的讨论。
### 3.1 目标属性（Target Properties）
当编译二进制目标的源文件时，[INCLUDE_DIRECTORIES](https://cmake.org/cmake/help/latest/prop_tgt/INCLUDE_DIRECTORIES.html#prop_tgt:INCLUDE_DIRECTORIES), [COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_DEFINITIONS.html#prop_tgt:COMPILE_DEFINITIONS) 和 [COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_OPTIONS.html#prop_tgt:COMPILE_OPTIONS)等目标属性的内容将被合理使用。

[INCLUDE_DIRECTORIES](https://cmake.org/cmake/help/latest/prop_tgt/INCLUDE_DIRECTORIES.html#prop_tgt:INCLUDE_DIRECTORIES)中的条目将以`-I` 或`-isystem`前缀的形式添加到编译行中，并且按照属性值中出现的顺序添加。

[COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_DEFINITIONS.html#prop_tgt:COMPILE_DEFINITIONS)中的条目将以-D or /D 前缀的形式被添加到编译行中，没有指定顺序。DEFINE_SYMBOL目标属性也以适用于共享和模块库目标的特殊便利设施被添加到编译定义中。

 [COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_OPTIONS.html#prop_tgt:COMPILE_OPTIONS)中的条目将作用到shell中，并且按照属性值中出现的顺序添加。几种编译选项有其特殊的独立处理方式，也可参阅 [POSITION_INDEPENDENT_CODE](https://cmake.org/cmake/help/latest/prop_tgt/POSITION_INDEPENDENT_CODE.html#prop_tgt:POSITION_INDEPENDENT_CODE)。

 [INTERFACE_INCLUDE_DIRECTORIES](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html#prop_tgt:INTERFACE_INCLUDE_DIRECTORIES), [INTERFACE_COMPILE_DEFINITIONS](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_COMPILE_DEFINITIONS.html#prop_tgt:INTERFACE_COMPILE_DEFINITIONS) 以及 [INTERFACE_COMPILE_OPTIONS](https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_COMPILE_OPTIONS.html#prop_tgt:INTERFACE_COMPILE_OPTIONS)等目标属性的内容是使用需求--他们指定了客户用于正确编译和链接目标的内容。对于任何二进制目标，在一条[target_link_libraries(](https://cmake.org/cmake/help/latest/command/target_link_libraries.html#command:target_link_libraries))命令中指定的任一目标上的INTERFACE_ 属性内容会被消费：
 ```
 set(srcs archive.cpp zip.cpp)
if (LZMA_FOUND)
  list(APPEND srcs lzma.cpp)
endif()
add_library(archive SHARED ${srcs})
if (LZMA_FOUND)
  # The archive library sources are compiled with -DBUILDING_WITH_LZMA
  target_compile_definitions(archive PRIVATE BUILDING_WITH_LZMA)
endif()
target_compile_definitions(archive INTERFACE USING_ARCHIVE_LIB)

add_executable(consumer)
# Link consumer to archive and consume its usage requirements. The consumer
# executable sources are compiled with -DUSING_ARCHIVE_LIB.
target_link_libraries(consumer archive)
 ```
### 3.2 传递的使用需求
### 3.3 兼容接口属性
### 3.4 属性源调试
### 3.5 构建规范和生成器表达式
#### 3.5.1 包含目录和使用需求
### 3.6 链接库和生成器表达式
### 3.7 输出组件（Output Artifacts）
#### 3.7.1 运行时输出组件
#### 3.7.2 库输出组件
#### 3.7.3 归档文件输出组件
### 3.8 目录范围的命令
## 4. 假目标
### 4.1 导入目标
### 4.2 别名目标
### 4.3 接口库

## 引用
- [CMake BuildSystem](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html)