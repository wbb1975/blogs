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
  
   待构建CMake项目根目录路径。
- `-B <path-to-build>`

   CMake构建目录路径

   构建树如果不存在将会被自动创建。
- `-C <initial-cache>`

   事先加载一个脚本来向构建缓存（cache）中添加内容。

   当CMake第一次在空的构建目录下运行时，它创建CMakeCache.txt文件并在其中放入项目的个性化设置。这个选项用于指定一个文件，在第一次扫描CMake的项目文件列表之前，从中加载各个缓存项。这些加载的缓存项比项目的缺省值优先级高。给定的文件必须是一个CMake脚本，含有使用Option选项的[set()](https://cmake.org/cmake/help/v3.15/command/set.html#command:set)命令，而不是一个缓存格式的文件。
- `-D <var>:<type>=<value>, -D <var>=<value>`

   创建或更新一个缓存项（CACHE entry）。

   当CMake第一次在空的构建目录下运行时，它创建CMakeCache.txt文件并在其中放入项目的个性化设置。这个选项用于指定一个比项目缺省设置有更高优先级的设置。如果需要，你可以重复使用这个选项指定许多缓存项。

   如果给出了`:<type> `部分，它必须是[set()](https://cmake.org/cmake/help/v3.15/command/set.html#command:set)命令文档中用于缓存签名的众多类型中的一种。如果没有给出`:<type> `，该缓存项给被创建为没有类型。如果一个项目中的命令设置了PATH 或 FILEPATH类型，那么其值将被转化为绝对路径。

   这个选项也可以一个参数的格式指定，`-D<var>:<type>=<value>` 或 `-D<var>=<value>`。
- `-U <globbing_expr>`
   
   从CMake缓存中移除匹配的选项。

   这个选项用于从CMakeCache.txt中移除一个或多个变量，通配表达式支持 * 和 ?。如果需要，你可以重复使用这个选项指定许多缓存项。

   小心使用这个选项，它可能使你的CMakeCache.txt 不工作。
- `-G <generator-name>`

   指定构建系统生成器。

   在特定平台上CMake可以支持多种构建系统。一个生成器用于生成一个特定的构建系统。特定的生成器名字在[cmake-generators(7)](https://cmake.org/cmake/help/v3.15/manual/cmake-generators.7.html#manual:cmake-generators(7))手册中指定。

   如果不指定，CMake将检查[CMAKE_GENERATOR](https://cmake.org/cmake/help/v3.15/envvar/CMAKE_GENERATOR.html#envvar:CMAKE_GENERATOR)环境变量，否则将使用内建缺省选项。
- `-T <toolset-spec>`

   如果支持，用于指定工具集规范。

   某些CMake生成器支持工具集规范来告诉原生构建系统如何选择编译器。参阅[CMAKE_GENERATOR_TOOLSET](https://cmake.org/cmake/help/v3.15/variable/CMAKE_GENERATOR_TOOLSET.html#variable:CMAKE_GENERATOR_TOOLSET)变量可获得等多细节。
- `-A <platform-name>`

   指定生成器支持的平台名。

   某些CMake生成器支持给定平台名来让原生构建系统如选择编译器或软件开发工具包（SDK）参阅[CMAKE_GENERATOR_PLATFORM](https://cmake.org/cmake/help/v3.15/variable/CMAKE_GENERATOR_PLATFORM.html#variable:CMAKE_GENERATOR_PLATFORM)变量可获得更多信息。
- `-Wno-dev`

   抑制开发者警告（developer warnings）。

   抑制警告是CMakeLists.txt等文件作者的职责。缺省地这也将关闭废弃（deprecation）警告。
- `-Wdev`

   打开开发者警告（developer warnings）。

   打开警告是CMakeLists.txt等文件作者的职责。缺省地这也将打开废弃（deprecation）警告。
- `-Werror=dev`

   使开发者警告（developer warnings）成为错误。

   使警告成为错误是CMakeLists.txt等文件作者的职责。缺省地这也将使废弃（deprecation）警告成为错误。
- `-Wno-error=dev`

   使开发者警告（developer warnings）不成为错误。

   使警告不成为错误是CMakeLists.txt等文件作者的职责。缺省地这也将禁止废弃（deprecation）警告成为错误。
- `-Wdeprecated`

   打开废弃功能（developer functionality）告警。

   打开废弃功能告警是CMakeLists.txt等文件作者的职责。
- `-Wno-deprecated`

   抑制废弃功能（developer functionality）告警。

   抑制废弃功能告警是CMakeLists.txt等文件作者的职责。
- `-Werror=deprecated`

   使废弃宏或函数告警成为错误。

   使废弃宏或函数告警成为错误是CMakeLists.txt等文件作者的职责。
- `-Wno-error=deprecated`

   使废弃宏或函数告警不成为错误。

   使废弃宏或函数告警不成为错误是CMakeLists.txt等文件作者的职责。
- `-L[A][H]`

   打印非高级缓存选项。

   打印运行CMake的缓存变量，打印从CMake缓存而来且没有被标记为内部（INTERNAL） 或 高级（[ADVANCED](https://cmake.org/cmake/help/v3.15/prop_cache/ADVANCED.html#prop_cache:ADVANCED)）的所有缓存选项。这将有效地显示当前CMake设置--这些设置可以被一个“-D”选项改变。改变其中某些变量可能导致更多变量被创建。如果A被指定，它将显示高级选项。入股H被指定，每个选项的帮助也会被显示。
- `-N`

   仅仅显式模式。

   仅仅加载缓存，并不运行配置和生成步骤。
- `--graphviz=[file]`

   产生各种依赖的图形显示，参阅[CMakeGraphVizOptions](https://cmake.org/cmake/help/v3.15/module/CMakeGraphVizOptions.html#module:CMakeGraphVizOptions)可见更多细节。

   产生一个图形化的输入文件，它将包括项目中可执行文件和库的各种依赖。参阅[CMakeGraphVizOptions](https://cmake.org/cmake/help/v3.15/module/CMakeGraphVizOptions.html#module:CMakeGraphVizOptions)可见更多细节。
- `--system-information [file]`

   转储系统信息。

   转储当前系统非常宽泛的信息。如果是从一个CMake的二进制树的顶级目录运行，他将会转储额外的信息，比如缓存，日志文件等。
- `--loglevel=<ERROR|WARNING|NOTICE|STATUS|VERBOSE|DEBUG|TRACE>`

   设置日志级别。

   [message()](https://cmake.org/cmake/help/v3.15/command/message.html#command:message)命令只会打印指定日志级别和更高级别的日志消息。缺省日志级别为STATUS。
- `--debug-trycompile`

   不要删除[try_compile(https://cmake.org/cmake/help/v3.15/command/try_compile.html#command:try_compile)]()构建树。只在一次性使用try_compile()时有用。

   不要删除try_compile()调用创建的文件和目录。这对于try_compile()失败时做调试是有用的。它可能产生和上一次运行try_compile()不同的结果。这个选项仅仅适用于一次性运行try_compile()，并且仅仅用于调试。
- `--debug-output`

   将CMake设置为调试模式。

   在cmake运行期间调用[message(SEND_ERROR)](https://cmake.org/cmake/help/v3.15/command/message.html#command:message)打印额外信息比如调用堆栈。
- `--trace`

   将CMake设置为Trace模式。

   打印出所有调用的信息及出处。
- `--trace-expand`

    将CMake设置为Trace模式。

    象`--trace`，但有变量扩展。
- `--trace-source=<file>`

   将CMake设置为Trace模式，但仅仅输出一个特定文件。

   允许多个选项。
- `--warn-uninitialized`

   对未初始化的值发出警告。

   当一个未初始化的值被使用时发出一个警告。
- `--warn-unused-vars`

   对从未使用的变量发出警告。

   用于找到被声明或设置但从未被使用的变量。
- `--no-warn-unused-cli`

   不对对命令行选项发出警告。

   不对命令行中声明但未被使用的变量发出警告。
- `--check-system-vars`

   在系统文件中找到变量使用的问题。

   正常情况下，未被使用和未初始化的变量仅仅在[CMAKE_SOURCE_DIR](https://cmake.org/cmake/help/v3.15/variable/CMAKE_SOURCE_DIR.html#variable:CMAKE_SOURCE_DIR)和[CMAKE_BINARY_DIR](https://cmake.org/cmake/help/v3.15/variable/CMAKE_BINARY_DIR.html#variable:CMAKE_BINARY_DIR)中查找，这个标记告诉CMake在其他它文件中也执行类似查找。
## 构建项目
CMake提供了命令行接口来构建一个已经生成的项目二进制树。
```
cmake --build <dir> [<options>] [-- <build-tool-options>]
```
它用以下选项抽象了原生构建工具的命令行借口：
- `--build <dir>`

   用于构建的项目二进制目录。这是必须的并且必须是第一个。
- `--parallel [<jobs>], -j [<jobs>]`

   构建时最大并行运行的进程数。如果没有`<jobs>`选项，原生构建工具的缺省值会被使用。

   当这个选项没被给出时，环境变量[CMAKE_BUILD_PARALLEL_LEVEL](https://cmake.org/cmake/help/v3.15/envvar/CMAKE_BUILD_PARALLEL_LEVEL.html#envvar:CMAKE_BUILD_PARALLEL_LEVEL)用于指定缺省的并行级别。

   某些构建工具总是并行构建，传递1给`<jobs>`可用于限制单个工作（job）。
- `--target <tgt>..., -t <tgt>...`

   构建`<tgt>`而非缺省构建目标。可以给出多个构建目标，以空格分割。
- `--config <cfg>`

   对于多个配置文件的工具，选择配置文件`<cfg>`。
- `--clean-first`

   首先构建clean目标，再构建其它（仅仅构建clean，使用--target clean）。
- `--use-stderr`

   忽略，在CMake >= 3.0时此行为是缺省行为。
- `--verbose, -v`

   开启细节输出--如果支持--包括执行的构建命令。

   如果[VERBOSE](https://cmake.org/cmake/help/v3.15/envvar/VERBOSE.html#envvar:VERBOSE)环境变量或[CMAKE_VERBOSE_MAKEFILE](https://cmake.org/cmake/help/v3.15/variable/CMAKE_VERBOSE_MAKEFILE.html#variable:CMAKE_VERBOSE_MAKEFILE)缓存变量已经设置，可以不使用这个选项。
- `--`

   传递剩余的选项给原生工具。

不带选项运行cmake --build以获取快速帮助。
## 安装项目
Make提供了命令行接口来安装一个已经生成的项目二进制树。
```
cmake --install <dir> [<options>]
```
用于在构建了一个项目后安装一个项目，不使用生成的构建系统，也不实用原生工具。
- `--install <dir>`

   用于安装的项目二进制目录。这是必须的并且必须是第一个。
- `--config <cfg>`

   对于多个配置文件的工具，选择配置文件`<cfg>`。
- `--component <comp>`

   基于组件的安装，仅仅安装组件`<comp>`。
- `--prefix <prefix>`

   覆盖安装前缀，[CMAKE_INSTALL_PREFIX](https://cmake.org/cmake/help/v3.15/variable/CMAKE_INSTALL_PREFIX.html#variable:CMAKE_INSTALL_PREFIX)。
- `--strip`

   安装前去除符号。
- `-v, --verbose`

   细节输出模式。

   如果[VERBOSE](https://cmake.org/cmake/help/v3.15/envvar/VERBOSE.html#envvar:VERBOSE)环境变量已经设置，可以不使用这个选项。

不带选项运行cmake --install以获取快速帮助。
## 打开项目
```
make --open <dir>
```
用关联程序打开已经产生的项目。这仅仅被某些生成器支持。
## 运行脚本
```
cmake [{-D <var>=<value>}...] -P <cmake-script-file>
```
把一个用CMake语言写成的cmake文件作为脚本处理。没有配置或生成步骤被执行，缓存也未被修改。如果使用“-D”定义了变量，那它必须位于“-P”参数之前。
## 运行一个命令行工具
CMake提供内建如下命令行工具支持：
```
cmake -E <command> [<options>]
```
运行cmake -E 或 cmake -E help来获取命令行总结。可用命令行包括：
- `capabilities`

   将cmake的功能以JSON格式汇报出来。输出是个用于下列键的JSON对象。
   - version
      
      一个带有版本信息的JSON对象。包括的键有：
      + string
          
          由cmake --version返回的全版本字符串。
      + major

          整数形式的主版本号。
      + minor

          整数形式的次版本号。
      + patch

          整数形式的补丁版本号。
      + suffix

          cmake版本后缀字符串。
      + isDirty

         一个bool值用于指示cmake是否从一个脏的树上构建。
   - generators

      可用的生成器列表。每个生成器是一个带有如下键的JSON对象。
      + name

          包含生成器名字的字符串。
      + toolsetSupport

          如果生成器支持工具集则为true，否则为false。
      + platformSupport

          如果生成器支持平台则为true，否则为false。
      + extraGenerators

         一系列与该生成器兼容的生成器名字。
   - fileApi

      当[cmake-file-api(7)](https://cmake.org/cmake/help/v3.15/manual/cmake-file-api.7.html#manual:cmake-file-api(7))可用时存在的一个可选成员。它是有一个成员的JSON对象。
      + requests

         一个JSON数组包含零个或多个file-api请求。每个请求时含有如下成员的JSON对象
         + kind

             指定某个支持的[对象类型](https://cmake.org/cmake/help/v3.15/manual/cmake-file-api.7.html#file-api-object-kinds)。
         + version

            一个JSON数组，每个元素是含有major和minor成员的JSON对象。
   - serverMode
  
      如果cmake支持服务器模式则为true，否则为false。
- `chdir <dir> <cmd> [<arg>...]`

   改变当前工作目录并运行命令。
- `compare_files [--ignore-eol] <file1> <file2>`

   比较`<file1>` 是否和`<file2>`一样。如果他们一样，返回0，否则返回1。`--ignore-eol`选项暗示逐行比较时忽略回车换行符的差别。
- `copy <file>... <destination>`

   拷贝文件到`<destination>`（无论文件或目录）。如果多个文件被指定，`<destination>`必须是个目录并必须存在。星号（*）不被支持。拷贝跟随符号链接。这意味着它不拷贝符号链接，但它指向的文件或目录被拷贝。
- `copy_directory <dir>... <destination>`

   拷贝目录到`<destination>`目录。如果`<destination>`怒存在，它就会被创建。copy_directory也跟随符号链接。
- `copy_if_different <file>... <destination>`

   拷贝文件到`<destination>`（无论文件或目录），如果文件已经改变。如果多个文件被指定，`<destination>`必须是个目录并必须存在。`copy_if_different`也跟随符号链接。
- `echo [<string>...]`

   将参数作为文本显示。
- `echo_append [<string>...]`

   将参数作为文本显示，但不加换行符。
- `env [--unset=NAME]... [NAME=VALUE]... COMMAND [ARG]...`

   在一个修改过的环境中运行命令。
- `environment`

   显示当前环境变量。
- `make_directory <dir>...`

   创建`<dir>`目录，如果必要，父目录也会被创建。如果目录已经存在，命令将会被安静地忽略。
- `md5sum <file>...`

   以md5sum兼容的格式计算文件的MD5校验码。
   ```
   351abe79cd3800b38cdfb25d45015a15  file1.txt
   052f86c15bbde68af55c7f7b340ab639  file2.txt
   ```
- `sha1sum <file>...`
- `sha224sum <file>...`
- `sha256sum <file>...`
- `sha384sum <file>...`
- `sha512sum <file>...`
- `remove [-f] <file>...`
- `remove_directory <dir>...`
- `rename <oldname> <newname>`
- `server`
- `sleep <number>...`
- `tar [cxt][vf][zjJ] file.tar [<options>] [--] [<pathname>...]`
- `time <command> [<args>...]`
- `touch <file>...`
- `touch_nocreate <file>...`
- `create_symlink <old> <new>`
   
   创建一个到文件old的符号链接new
   > **主语**：符号链接的目标文件必须事先存在。
## Windows特定的命令行工具
下面的cmake -E命令只在Windows平台上可用
- `delete_regv <key>`

   删除Windows注册表项
- `env_vs8_wince <sdkname>`

   显示在VS2005安装中为Windows CE SDK提供环境的batch文件
- `env_vs9_wince <sdkname>`

   显示在VS2008安装中为Windows CE SDK提供环境的batch文件
- `write_regv <key> <value>`

   写Windows注册表项
## 运行包查找工具
CMake为基于Makefile的项目提供象pkg-config一样的帮助功能。
```
cmake --find-package [<options>]
```
它利用[find_package()](https://cmake.org/cmake/help/v3.15/command/find_package.html#command:find_package)搜索一个包，并在标准输出上打印结果。这可被用户替代pkg-config在基于Makefile或autoconf（通过share/aclocal/cmake.m4）的项目中找到已安装的库。

> **注意**：由于技术限制这个模式并没有很好地支持。它被保留仅仅因为兼容性，新项目中绝不应使用它。
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