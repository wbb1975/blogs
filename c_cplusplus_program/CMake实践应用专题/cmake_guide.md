# CMake实践应用专题
> CMake是一个开源、跨平台的编译、测试和打包工具，它使用比较简单的语言描述编译、安装的过程，输出Makefile或者project文件，再去执行构建。
## $1 基础篇
在使用IDE开发软件的过程中，代码的编译和构建一般是使用IDE自带的编译工具和环境进行编译，开发者参与的并不算多。如果想要控制构建的细节，则需要开发者自己定义构建的过程。

本文主要介绍以下内容：
- 编译构建相关的核心概念及它们之间的关系
- CMake的一般使用流程
- 一个简单的实例
### 一 核心概念
#### 1. gcc、make和cmake
gcc（GNU Compiler Collection）将源文件编译（Compile）成可执行文件或者库文件；

而当需要编译的东西很多时，需要说明先编译什么，后编译什么，这个过程称为构建（Build）。常用的工具是make，对应的定义构建过程的文件为Makefile；

而编写Makefile对于大型项目又比较复杂，通过CMake就可以使用更加简洁的语法定义构建的流程，CMake定义构建过程的文件为CMakeLists.txt。

它们的大致关系如下图：

![cmake与gcc的关系](images/gcc_cimake_relationship.jpg)

> 这里的GCC只是示例，也可以是其他的编译工具。这里的Bin表示目标文件，可以是可执行文件或者库文件。
### 二 CMake一般使用流程
CMake提供cmake、ctest和cpack三个命令行工具分别负责构建、测试和打包。本文主要介绍cmake命令。

使用cmake一般流程为：
- 生成构建系统（buildsystem，比如make工具对应的Makefile）；
- 执行构建（比如make），生成目标文件；
- 执行测试、安装或打包。
本文先介绍前面两个步骤。
#### 1. 生成构建系统
通过cmake命令生成构建系统。

通过 `cmake --help` 可以看到cmake命令支持的详细参数，常用的参数如下：
参数|含义
-------|--------
-S|指定源文件根目录，必须包含一个CMakeLists.txt文件
-B|指定构建目录，构建生成的中间文件和目标文件的生成路径
-D|指定变量，格式为-D <var>=<value>，-D后面的空格可以省略

比如，指明使用当前目录作为源文件目录，其中包含CMakeLists.txt文件；使用build目录作为构建目录；设定变量CMAKE_BUILD_TYPE的值为Debug，变量AUTHOR的值为RealCoolEngineer：
```
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DAUTHOR=RealCoolEngineer
```
> 使用-D设置的变量在CMakeLists.txt中生效，可以设置cmake的内置支持的一些变量控制构建的行为；当然也可以使用自定义的变量，在CMakeLists.txt中自行判断做不同的处理。
#### 2. 执行构建
使用 `cmake --build [<dir> | --preset <preset>]` 执行构建。

这里要指定的目录就是生成构建系统时指定的构建目录。常用的参数如下：
参数|含义
--------|--------
--target|指定构建目标代替默认的构建目标，可以指定多个
--parallel/-j [<jobs>]|指定构建目标时使用的进程数
> 在这一步，如果使用的是make构建工具，则可以在构建目录下直接使用make命令。
### 三 CMake应用示例
#### 1. 一个简单的例子
下面使用cmake编译一个c语言的 `hello world` 程序。创建一个项目文件夹 `cmake-template`，目录结构如下：
```
cmake-template
├── CMakeLists.txt
└── src
    └── c
        └── main.c
```
main.c内容如下：
```
// @Author: Farmer Li, 公众号: 很酷的程序员/RealCoolEngineer
// @Date: 2021-04-24

#include <stdio.h>

int main(void) {
  printf("Hello CMake!");

  return 0;
}
```
CMakeLists.txt的内容如下：
```
cmake_minimum_required(VERSION 3.12)
project(cmake_template VERSION 1.0.0 LANGUAGES C CXX)

add_executable(demo src/c/main.c)
```
该 `CMakeLists.txt` 声明了需要使用的cmake的最低版本；项目的名字、版本以及编译语言；最后一句定义了通过源文件 `main.c` 生成可执行文件 `demo`。
#### 2. 生成构建系统
在cmake-template目录下，执行以下命令：
```
cmake -B build
```
执行完成后，在项目的根目录下会创建build目录，可以看到其中生成了Makefile文件。
#### 3. 执行构建
还是在cmake-template目录下，执行以下命令：
```
cmake --build build
```
因为使用的是make工具，所以也可以在build目录直接执行make命令：
```
cd build && make && cd -
```
执行完成后，可以在build目录下看到已经生成可执行文件demo，执行demo：
```
cmake-template # ./build/demo
Hello CMake!
```
## $2 核心语法篇
> 本文是深入CMakeLists.txt之前的前导文章，介绍CMake语言的核心概念，以及常用的CMake脚本命令，以期对CMake的语法能有比较好的认知和实践基础。

在开始深入如何编写完备的CMakeLists.txt之前，先了解下CMake的语言和它的组织方式对后续内容的理解是很有帮助的。本文将会介绍以下内容：
- CMake语言的核心概念
- CMake常用脚本命令及示例
### 一 CMake语法核心概念
下面介绍的内容，可以只先有一些概念，不求甚解，在后续需要深入的时候查看文档即可。

CMake的命令有不同类型，包括**脚本命令、项目配置命令和测试命令**，细节可以查看官网[cmake-commands](https://link.zhihu.com/?target=https%3A//cmake.org/cmake/help/v3.20/manual/cmake-commands.7.html)。

CMake语言在项目配置中组织为三种源文件类型：
- 目录：`CMakeLists.txt`，针对的是一个目录，描述如何针对目录 `（Source tree）`生成构建系统，会用到项目配置命令；
- 脚本：`<script>.cmake`，就是一个CMake语言的脚本文件，可使用 `cmake -P` 直接执行，只能包含脚本命令；
- 模块：`<module>.cmake`，实现一些模块化的功能，可以被前面两者包含，比如 `include(CTest)` 启用测试功能。
#### 1. 注释
行注释使用 `"#"`；块注释使用 `"#[[Some comments can be multi lines or in side the command]]"`。比如:
```
# Multi line comments follow
#[[
Author: FarmerLi, 公众号: 很酷的程序员/RealCoolEngineer
Date: 2021-04-27
]]
```
#### 2. 变量
CMake中使用 `set` 和 `unset` 命令设置或者取消设置变量。CMake中有以下常用变量类型：
##### 一般变量
设置的变量可以是字符串，数字或者列表（直接设置多个值，或者使用分号隔开的字符串格式为"v1;v2;v3"），比如：
```
# Set variable
set(AUTHOR_NAME Farmer)
set(AUTHOR "Farmer Li")
set(AUTHOR Farmer\ Li)

# Set list
set(SLOGAN_ARR To be)   # Saved as "To;be"
set(SLOGAN_ARR To;be)
set(SLOGAN_ARR "To;be")

set(NUM 30)   # Saved as string, but can compare with other number string
set(FLAG ON)  # Bool value
```
主要有以下要点：
1. 如果要设置的变量值包含空格，则需要使用双引号或者使用"\"转义，否则可以省略双引号；
2. 如果设置多个值或者字符串值的中间有";"，则保存成list，同样是以";"分割的字符串；
3. 变量可以被list命令操作，单个值的变量相当于只有一个元素的列表；
4. 引用变量：`${<variable>}`，在if()条件判断中可以简化为只用变量名 `<variable>`。
##### Cache变量
Cache变量（缓存条目，`cache entries`）的作用主要是为了提供**用户配置选项**，如果用户没有指定，则使用默认值，设置方法如下：
```
# set(<variable> <value>... CACHE <type> <docstring> [FORCE])
set(CACHE_VAR "Default cache value" CACHE STRING "A sample for cache variable")
```
要点：
- 主要为了提供可配置变量，比如编译开关；
- 引用CACHE变量：$CACHE{<varialbe>}。
> Cache变量会被保存在构建目录下的CMakeCache.txt中，缓存起来之后是不变的，除非重新配置更新。 
##### 环境变量
修改当前处理进程的环境变量，设置和引用格式为：
```
# set(ENV{<variable>} [<value>])
set(ENV{ENV_VAR} "$ENV{PATH}")
message("Value of ENV_VAR: $ENV{ENV_VAR}")
```
和CACHE变量类似，要引用环境变量，格式为：`$ENV{<variable>}`。
#### 3. 条件语句
支持的语法有：
- 字符串比较，比如：**STREQUAL、STRLESS、STRGREATER** 等；
- 数值比较，比如：**EQUAL、LESS、GREATER** 等；
- 布尔运算，**AND、OR、NOT**；
- 路径判断，比如：**EXISTS、IS_DIRECTORY、IS_ABSOLUTE** 等；
- 版本号判断；等等；
- 使用小括号可以组合多个条件语句，比如：**(cond1) AND (cond2 OR (cond3))**。

对于**常量**：
1. **ON、YES、TRUE、Y和非0值**均被视为True；
2. **0、OFF、NO、FALSE、N、IGNORE、空字符串、NOTFOUND、及以"-NOTFOUND"结尾的字符串**均视为False。

对于**变量**，只要其值不是常量中为False的情形，则均视为True。
### 二 常用的脚本命令
有了前面的总体概念，下面掌握一些常用的CMake命令，对于CMake脚本编写就可以有不错的基础。
#### 1. 消息打印
前面已经有演示，即 `message` 命令，其实就是打印log，用来打印不同信息，常用命令格式为：
```
message([<mode>] "message text" ...)
```
其中 `mode` 就相当于打印的等级，常用的有这几个选项：
- 空或者NOTICE：比较重要的信息，如前面演示中的格式
- DEBUG：调试信息，主要针对开发者
- STATUS：项目使用者可能比较关心的信息，比如提示当前使用的编译器
- WARNING：CMake警告，不会打断进程
- SEND_ERROR：CMake错误，会继续执行，但是会跳过生成构建系统
- FATAL_ERROR：CMake致命错误，会终止进程
#### 2. 条件分支
这里以 `if()/elseif()/else()/endif()` 举个例子，`for/while` 循环也是类似的：
```
set(EMPTY_STR "")
if (NOT EMPTY_STR AND FLAG AND NUM LESS 50 AND NOT NOT_DEFINE_VAR)
    message("The first if branch...")
elseif (EMPTY_STR)
    message("EMPTY_STR is not empty")
else ()
    message("All other case")
endif()
```
#### 3. 列表操作
`list` 也是CMake的一个命令，有很多有用的子命令，比较常用的有：
- APPEND，往列表中添加元素；
- LENGTH，获取列表元素个数；
- JOIN，将列表元素用指定的分隔符连接起来；

示例如下：
```
set(SLOGAN_ARR To be)   # Saved as "To;be"
set(SLOGAN_ARR To;be)
set(SLOGAN_ARR "To;be")
set(WECHAT_ID_ARR Real Cool Eengineer)
list(APPEND SLOGAN_ARR a)                # APPEND sub command
list(APPEND SLOGAN_ARR ${WECHAT_ID_ARR}) # Can append another list
list(LENGTH SLOGAN_ARR SLOGAN_ARR_LEN)   # LENGTH sub command
# Convert list "To;be;a;Real;Cool;Engineer"
# To string "To be a Real Cool Engineer"
list(JOIN SLOGAN_ARR " " SLOGEN_STR)
message("Slogen list length: ${SLOGAN_ARR_LEN}")
message("Slogen list: ${SLOGAN_ARR}")
message("Slogen list to string: ${SLOGEN_STR}\n")
```
对于列表常用的操作，list命令都基本实现了，需要其他功能直接查阅官方文档即可。
#### 4. 文件操作
CMake的file命令支持的操作比较多，可以读写、创建或复制文件和目录、计算文件hash、下载文件、压缩文件等等。 使用的语法都比较类似，以笔者常用的递归遍历文件为例，下面是获取src目录下两个子目录内所有c文件的列表的示例：
```
file(GLOB_RECURSE ALL_SRC
        src/module1/*.c
        src/module2/*.c
        )
```
> GLOB_RECURSE表示执行递归查找，查找目录下所有符合指定正则表达式的文件。
#### 5. 配置文件生成
使用configure_file命令可以将配置文件模板中的特定内容替换，生成目标文件。输入文件中的内容@VAR@或者${VAR}在输出文件中将被对应的变量值替换。 使用方式为：
```
set(VERSION 1.0.0)
configure_file(version.h.in "${PROJECT_SOURCE_DIR}/version.h")
```
假设version.in.h的内容为：
```
#define VERSION "@VERSION@"
```
那么生成的version.h的内容为：
```
#define VERSION "1.0.0"
```
#### 6. 执行系统命令
使用 `execute_process` 命令可以执行一条或者顺序执行多条系统命令，对于需要使用系统命令获取一些变量值是有用的。比如获取当前仓库最新提交的 `commit` 的 `commit id`：
```
execute_process(COMMAND bash "-c" "git rev-parse --short HEAD" OUTPUT_VARIABLE COMMIT_ID)
```
#### 7. 查找库文件
通过 `find_library` 在指定的路径和相关默认路径下查找指定名字的库，常用的格式如下：
```
find_library (<VAR> name1 [path1 path2 ...])
```
找到的库就可以被其它target使用，表明依赖关系。
#### 8. include其他模块
`include` 命令将cmake文件或者模块加载并执行。比如：
```
include(CPack) # 开启打包功能
include(CTest) # 开启测试相关功能
```
CMake自带有很多有用的模块，可以看看官网的链接：[cmake-modules](https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html)，对支持的功能稍微有所了解，后续有需要再细看文档。

当然，如果感兴趣，也可以直接看CMake安装路径下的目录 `CMake\share\cmake-<version>\Modules` 中的模块源文件。

文中的示例代码均共享在开源仓库：https://gitee.com/RealCoolEngineer/cmake-template，当前commit id：f8f3948。

关于CMake脚本源文件的示例位于路径：`cmake/script_demo.cmake`，可以使用 `cmake -P cmake/script_demo.cmake` 执行查看结果; 关于配置文件生成的操作在项目根目录的CMakeLists.txt中也有示例。
## $3 CMakeLists.txt完全指南

## Reference
- [本文首发专栏：CMake实践应用专题](https://www.zhihu.com/column/c_1369781372333240320)
- [本文示例代码上传到开源仓库：FarmerLi / cmake-template](https://gitee.com/RealCoolEngineer/cmake-template)