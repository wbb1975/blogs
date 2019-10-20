# cmake语言
## 1. 组织
CMake输入文件以“CMake语言”写成，其源文件名为CMakeLists.txt或以.cmake为其后缀。

一个项目的CMake语言源文件被组织为：
- 目录（`CMakeLists.txt`）
- 脚本（`<script>.cmake`）
- 模块（`<module>.cmake`）
### 1.1 目录
当CMake处理一个项目源代码树时，其入口点是项目顶级目录下的`CMakeLists.txt`文件。该文件可能包含完整的构建规范，或者使用[add_subdirectory()](https://cmake.org/cmake/help/latest/command/add_subdirectory.html#command:add_subdirectory)命令添加构建子目录。每个由该命令添加的子目录必须包含作为该目录入口点的`CMakeLists.txt`。对每个目录其`CMakeLists.txt file`文件已被处理后，CMake将在构建树中产生对应目录，作为其缺省工作和输出目录。
### 1.2 脚本
一个单独的`<script>.cmake`脚本文件可以被cmake命令行工具的`-P `选项以脚本模式处理。脚本模式仅仅在给定的CMake语言源文件中运行命令而不产生构建系统。它不允许定义构建目标或动作的CMake命令在其中。
### 1.3 模块
在目录和脚本中的CMake语言代码可能使用[include()](https://cmake.org/cmake/help/latest/command/include.html#command:include)命令在包含上下文中加载`<module>.cmake`源文件。参见[cmake-modules(7)](https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html#manual:cmake-modules(7))手册页面来获取包含在CMake发布本中的模块文档。项目源代码树可能提供它们自己的模块，并使用[CMAKE_MODULE_PATH](https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html#variable:CMAKE_MODULE_PATH)变量来指定它们的位置。
## 2. 语法
### 2.1 编码
一个CMake语言源文件可由7位ASCII文本写成，以此获取跨支持平台的最大可移植性。新行符可以被编码成`\n` 或`\r\n`，但当输入文件被读入时被转换为`\n`。

注意CMake实现是完全的8位编码，因此源文件在系统API支持UTF-8的平台上可被编码成UTF-8。另外，CMake 3.2及以上版本支持在Windows上以UTF-8编码（使用UTF-16来调用系统API）。CMake 3.0及以上版本在源文件中允许UTF-8字节顺序标记（[Byte-Order Mark](http://en.wikipedia.org/wiki/Byte_order_mark)）。
###  2.2 源文件
一个CMake语言源文件包含0个或多个由新行符分割的[命令调用](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#command-invocations)，以及可选的空格和注释。
```
file                     ::=  file_element*
file_element ::=  command_invocation line_ending |
                  (bracket_comment|space)* line_ending
line_ending  ::=  line_comment? newline
space               ::=  <match '[ \t]+'>
newline          ::=  <match '\n'>
```
注意任何源代码行如果不在[命令参数](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#command-arguments)中，也不在[括号注释](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#bracket-comment)中的话能够以一个[行注释](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#line-comment)结尾。
### 2.3 命令调用
一个命令调用是一个名字跟随着以括号包围的由空格分隔的参数。
```
command_invocation  ::=  space* identifier space* '(' arguments ')'
identifier                             ::=  <match '[A-Za-z_][A-Za-z0-9_]*'>
arguments                         ::=  argument? separated_arguments*
separated_arguments  ::=  separation+ argument? |
                         separation* '(' arguments ')'
separation                         ::=  space | line_ending
```
例如：
```
add_executable(hello world.c)
```
命令名字是大小写敏感的。参数中的嵌套圆括号必须平衡。每个`(` 或` )`被以文本[Unquoted Argument](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#unquoted-argument)传递给命令调用。这可被用于[if()](https://cmake.org/cmake/help/latest/command/if.html#command:if)命令的调用中来包含条件，例如：
```
if(FALSE AND (FALSE OR TRUE)) # evaluates to FALSE
```
> **注意**：CMake 3.0之前的版本要求命令名标识至少得2个字符。

>  CMake 2.8.12之前的版本静静地接受一个[Unquoted Argument](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#unquoted-argument) 或 [Quoted Argument](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#quoted-argument)跟随在一个 [Quoted Argument](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#quoted-argument)之后，并且不以空格分隔。为了兼容性，CMake 2.8.12及更高版本接受这种代码但产生警告。
### 2.4 命令参数
在[命令调用](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#command-invocations)中有三种类型的参数：
```
argument ::=  bracket_argument | quoted_argument | unquoted_argument
```
#### 2.4.1 括号参数
一个括号参数，从[Lua](http://www.lua.org/)长括号语法获得灵感，将内容包含在同样长度的开合括号之间：
```
bracket_argument  ::=  bracket_open bracket_content bracket_close
bracket_open           ::=  '[' '='* '['
bracket_content      ::=  <any text not containing a bracket_close with
                       the same number of '=' as the bracket_open>
bracket_close           ::=  ']' '='* ']'
```
一个开括号被写作`[`其后跟随着0个或多个`=`，然后是一个`[`。对应的关闭（合）括号是一个`]`跟随着同样数目的`=`，然后是一个`]`。括号不能嵌套。一个唯一长度会为开合括号选择出来以包含其它长度的括号

括号参数的内容包含开合括号间的所有文本。紧随开括号的新行符除外--如果有，将被忽略。包含的内容不会被求值，[转义序列](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#escape-sequences)和[变量引用](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#variable-references)将不会被执行。一个括号参数通常被传递给一个命令调用作为其参数。

例如：
```
message([=[
This is the first line in a bracket argument with bracket length 1.
No \-escape sequences or ${variable} references are evaluated.
This is always one argument even though it contains a ; character.
The text does not end on a closing bracket of length 0 like ]].
It does end in a closing bracket of length 1.
]=])
```
> **注意**： CMake 3.0以前版本不支持括号参数，它们将开括号解释为[非引用参数](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#unquoted-argument)的开始。
#### 2.4.2 引用参数
#### 2.4.3 非引用参数
### 2.5 逃离序列
### 2.6 变量引用
### 2.7 注释
#### 2.7.1 括号注释
#### 2.7.2 行注释
## 3. 控制结构
### 3.1 条件块
### 3.2 循环
### 3.3 命令定义
## 4. 变量
## ５. 环境变量
## ６. 列表

## 引用
- [cmake-language](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#organization)