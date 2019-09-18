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
- 运行包（package）查找工具
  ```
  cmake --find-package [<options>]
  ```
- 查看帮助
  ```
  cmake --help[-<topic>]
  ```
## 描述
cmake可执行程序是跨平台构建系统生成工具CMake的命令行接口。上面的大纲列出了cmake的各种操作（action），下面的章节会具体描述。

为了用CMake构建软件项目，先生成一个项目构建系统。可选地，用cmake构建一个项目，安装一个项目，或者直接运行对应构建工具（如make）。cmake也可用于[查看帮助](https://cmake.org/cmake/help/v3.15/manual/cmake.1.html#view-help)。

其它动作是被软件开发人员用[CMake语言](https://cmake.org/cmake/help/v3.15/manual/cmake-language.7.html#manual:cmake-language(7))撰写脚本来支持他们的构建。

关于用来替换cmake的图形用户界面，参见[ccmake](https://cmake.org/cmake/help/v3.15/manual/ccmake.1.html#manual:ccmake(1)) 和 [cmake-gui](https://cmake.org/cmake/help/v3.15/manual/cmake-gui.1.html#manual:cmake-gui(1))。关于CMake测试和打包设施的命令行借口，参见[ctest](https://cmake.org/cmake/help/v3.15/manual/ctest.1.html#manual:ctest(1)) 和 [cpack](https://cmake.org/cmake/help/v3.15/manual/cpack.1.html#manual:cpack(1))。

关于CMake的更多详尽相信，请参阅本手册页的[尾部连接](https://cmake.org/cmake/help/v3.15/manual/cmake.1.html#see-also)。
## CMake构建系统介绍
一个构建系统描述了如何从项目的源代码编译可执行程序或库，并使用构建工具使这一过程自动化。例如，一个构建系统可以是一个利用命令行make工具的Makefile，或一个基于集成开发环境（IDE）的项目文件。为了避免维护多套类似的构建系统，一个项目可以用[CMake语言](https://cmake.org/cmake/help/v3.15/manual/cmake-language.7.html#manual:cmake-language(7))写就的文件来抽象地指定构建系统。从这些文件，CMake利用一个叫生成器（generator）的后端来为每个用户产生一个喜爱的本地构建系统。

为了利用CMake产生构建系统，必须利用下面的选项：
- 源代码树
  
   顶级目录提供项目的源文件。项目利用[CMake语言](https://cmake.org/cmake/help/v3.15/manual/cmake-language.7.html#manual:cmake-language(7))描述的文件指定构建系统，从一个顶级文件 CMakeLists.txt开始。这些文件指定了由[cmake-buildsystem(7)](https://cmake.org/cmake/help/v3.15/manual/cmake-buildsystem.7.html#manual:cmake-buildsystem(7))手册描述的构建目标及其依赖。
- 构建树
  
   顶级目录是构建系统文件及构建输出（可执行文件和库）所驻。CMake 将写一个文件CMakeCache.txt，用它来标识用作构建树的目录，并存储一些持久信息，比如构建系统配置选项。

    为了维持干净的源代码树，适应一个单独的独占构建树来推行“源代码之外”的构建。“源代码内”的构建，即构建树与源代码树是同一个目录依然支持，但不鼓励。
- 生成器
  
   用户选择生成哪种构建系统，参见[cmake-generators(7)](https://cmake.org/cmake/help/v3.15/manual/cmake-generators.7.html#manual:cmake-generators(7))手册来获取各种生成器的文档。运行cmake --help可看到本地可用的一系列生成器。可选地，利用下面的-G选项来指定生成器，或者接受CMake为当前平台选择的缺省值。

   当选择[命令行构建工具生成器](https://cmake.org/cmake/help/v3.15/manual/cmake-generators.7.html#command-line-build-tool-generators)之一时，CMake期盼工具链所需环境已经在shell上配置好了。当使用[集成开发环境构建生成器](https://cmake.org/cmake/help/v3.15/manual/cmake-generators.7.html#ide-build-tool-generators)时，并不需要特殊环境。
## 产生项目构建系统
使用下面的命令行签名指定源代码树和构建树来运行CMake，从而产生一个构建系统。
- `cmake [<options>] <path-to-source>`

   使用当前目录作为构建树，`<path-to-source>`作为源代码树。指定的路径可以使绝对路径，也可以是基于当前路径的相对路径。源代码树必须包含一个CMakeLists.txt ，且不能包含CMakeCache.txt，因为后者表示一个已经存在的构建树。例如：
   ```
   $ mkdir build ; cd build
   $ cmake ../src
   ```
- `cmake [<options>] <path-to-existing-build>`
   
   使用`<path-to-existing-build>`作为构建树，从CMakeCache.txt中加载源代码树路径--CMakeCache.txt必须是运行CMake产生的。指定的路径可以使绝对路径，也可以是基于当前路径的相对路径。例如：
   ```
   $ cd build
   $ cmake .
   ```
- `cmake [<options>] -S <path-to-source> -B <path-to-build>`

   使用`<path-to-build>`作为构建树，`<path-to-source>`作为源代码树。指定的路径可以使绝对路径，也可以是基于当前路径的相对路径。源代码树必须包含一个CMakeLists.txt文件。构建树如果不存在将会被自动创建。例如：
   ```
   $ cmake -S src -B build
   ```

在任何一种场景下你都可以指定0个或多个下面列出的选项。

当产生一个构建系统后，你可以使用原生构建工具来构建项目。例如，在使用[Unix Makefiles](https://cmake.org/cmake/help/v3.15/generator/Unix%20Makefiles.html#generator:Unix%20Makefiles)生成器（产生了构建系统）后，你可以直接运行make：
```
$ make
$ make install
```

可选地，你可以使用cmake来[构建项目](https://cmake.org/cmake/help/v3.15/manual/cmake.1.html#build-a-project)，它会自动选择并调用适合的原生构建工具。
### 选项
- `-S <path-to-source>`
- `-B <path-to-build>`
- `-C <initial-cache>`
- `-D <var>:<type>=<value>, -D <var>=<value>`
- `-U <globbing_expr>`
## 构建项目
## 安装项目
## 打开项目
## 运行脚本
## 运行一个命令行工具
## 运行包查找工具
## 查看帮助
## 参见
下面的链接可在使用CMake的过程中得到帮助：
- CMake主页
   
   https://cmake.org

   学习CMake的主要起始点。
- 在线文档和社区资源
  
  https://cmake.org/documentation

  包含这个页面上链接的在线文档和社区资源。
- 邮件列表

  https://cmake.org/mailing-lists

  关于CMake的帮助和讨论，一个邮件列表在cmake@cmake.org上建立起来。这个列表只有会员才能发文，但你可以从CMake网页上登录。但在向邮件列表投递问底之前，请首先阅读完 https://cmake.org 上的完整文档。