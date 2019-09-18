## 大纲
- 产生项目构建系统
  ```
   cmake [<options>] <path-to-source>
   cmake [<options>] <path-to-existing-build>
   cmake [<options>] -S <path-to-source> -B <path-to-build>
   ```
- 构建项目
  ```
  cmake --build <dir> [<options>] [-- <build-tool-options>]
  ```
- 安装项目
  ```  
  cmake --install <dir> [<options>]
  ```
- 打开项目
  ```
  cmake --open <dir>
  ```
- 运行脚本
  ```
  cmake [{-D <var>=<value>}...] -P <cmake-script-file>
  ```
- 运行一个命令行工具
  ```
  cmake -E <command> [<options>]
  ```
- 运行报查找工具
  ```
  cmake --find-package [<options>]
  ```
- 查看帮助
  ```
  cmake --help[-<topic>]
  ```
## 描述

## CMake构建系统介绍
## 产生项目构建系统