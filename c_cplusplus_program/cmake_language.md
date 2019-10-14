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
## 2. 语法
### 2.1 编码
###  2.2 源文件 
### 2.3 命令调用
### 2.4 命令参数
#### 2.4.1 括号参数
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