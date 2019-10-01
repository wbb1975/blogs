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
#### 2. 2.2  对象库
## 3. 构建规范和使用需求
## 4. 假目标

## 引用
- [CMake BuildSystem](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html)