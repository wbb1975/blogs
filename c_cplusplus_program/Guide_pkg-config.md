# pkg-config指南
## 简介
这篇文章旨在基于用户和开发人员的观点就`pkg-config`工具的使用给简单介绍。它评论了`pkg-config`之后的概念，如何写`pkg-config`文件来支持你的项目，如何使用`pkg-config`来雨第三方项目集成。

关于`pkg-config`的更多信息可在[网页](http://pkg-config.freedesktop.org/)上和 `pkg-config(1)`手册页里找到。

这篇文章假设在类Unix系统如Linux上使用pkg-config，在其它平台上细节可能会有点不同。
## 为什么？
现代计算机系统利用多层组件來向用户提供（完整）应用。将这些部分装配在一起的一个主要难题在于合适地将它们集成。`pkg-config`收集系统安装库的元信息，且很容易提供给用户。

没有一个类似`pkg-config`的元信息系统，很难得到一台给定计算机上定位和得到服务的细节。对一个开发人员，随你的包安装`pkg-config`文件将极大地方便你的API被使用。
## 概念
`pkg-config`的主要用途在于为将一个库编译链接进一个应用提供必要的细节。这些原信息存储在`pkg-config`中。这些文件有个后缀 `.pc` 并驻留在`pkg-config`工具知道的位置。这些将稍后详细描述。

文件格式包含喝多预定义的元信息关键字和自由变量。下面是一个演示例子：
```
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: foo
Description: The foo library
Version: 1.0.0
Cflags: -I${includedir}/foo
Libs: -L${libdir} -lfoo
```
关键字定义比如`Name:`一一个关键字开始，后跟一个冒号和一个值。变量例如`prefix=`是一个等号分割的字符串和值。关键字由`pkg-config`定义并导出。变量不是必须的，但可以出于灵活性被关键字定义所使用，或者存储`pkg-config`不能覆盖的数据。

下面是关键字字段的简短描述，关于这些字段的深入描述以及如何有效地使用它们写`pkg-config`文件一节中给出。
- Name: 关于库或包的一个人可读的名字。它不影响`pkg-config`工具的使用，它使用`.pc`文件的名字。
- Description：关于包的一个简短描述
- URL:　一个URL，在哪里人们可以得到跟多关于这个包及下载包的信息
- Version:　一个定义包版本的字符串
- Requires: 这个包所需要的包列表。这些包的版本可以用比较操作符指定，如=, <, >, <= 或 >=
- Requires.private:　这个包所需要的私有包列表，该列表并不会导出到应用。`Requires`的版本指定规则在这里也适用。
- Conflicts:　一个可选的字段描述与该包冲突的包。`Requires`的版本指定规则在这里也适用。这个字段可以含有同一个包的多个实例，例如：`Conflicts: bar < 1.2.3, bar >= 1.3.0`.
- Cflags: 该包的特定编译标记，以及任何需要单不支持pkg-config的库。如果需要的库支持pkg-config，它们应该被添加到Requires 或 Requires.private。
- Libs: 该包的特定链接标记，以及任何需要单不支持pkg-config的库。`Cflags`的规则在这里也适用。
- Libs.private: 该包私有库的特定链接标记，这些库不会导出到应用。。`Cflags`的规则在这里也适用。
## 写pkg-config文件
当为一个包创建`pkg-config`文件时，第一需要决定的是如何发布它们。每个文件最好只用来描述单个库，因此每个包有多少个安装库，就应该至少有多少个`pkg-config`文件。

包的名字由`pkg-config`元文件的文件名决定，它是`.pc`后缀之前文件名的一部分。一种常见选择是让`.pc`名与库名匹配。例如，一个包安装了`libfoo`，它将有一个`libfoo.pc`的文件包含了 `pkg-config`元信息。这种选择并不是必须的：`.pc`文件应该仅仅是你的库唯一标识符。跟随上面的例子，`foo.pc` 或 `foolib.pc` 都可能工作的挺好。

`Name`, `Description` 和 `URL`是纯粹的信息性的，很容易填写。`Version` 字段有些微妙，需要确保它可被数据的用户识别。`pkg-config`用户使用源自[RPM](http://rpm.org/)的算法进行版本比较，它与点分小数数字如 `1.2.3` 工作的最好，原因在于字母可能导致无法预料的结果。数字应该单调递增，应该尽可能特殊以描述你的库。通常使用包的版本号已经足够了，原因在于用户很容易追踪它。

在描述更多有用的字段之前，演示一下变量的定义是有用的。最常见的用途是定义安装路径，这样可以使得其它字段看上去不那么混乱。因为这些变量递归扩展，联合使用从`autoconf`继承过来的路径是有帮助的。
```
prefix=/usr/local
includedir=${prefix}/include

Cflags: -I${includedir}/foo
```
最重要的`pkg-config`元字段包括`Requires`, `Requires.private`, `Cflags`, `Libs` 和 `Libs.private`。它们定义了外部项目使用的元信息，以及如何与该库链接。

`Requires` 和 `Requires.private`定义了该库需要的其它模块。通常倾向于使用`Requires`的私有变体，以此来避免向链接你的库的应用导出不必要的（依赖）库。如果应用并未使用必需库的符号，它就实际上并不直接链接该库。查看关于[overlinking](https://wiki.openmandriva.org/en/Overlinking_issues_in_packaging)的讨论来获取更详细的解释。

因为`pkg-config`总是导出`Requires`库的链接标记，这些模块将成为应用的直接依赖。另一方面，来自`Requires.private`的库仅被包含用于静态链接。基于这个原因，通常仅仅在同一个包内适合使用`Requires`添加模块。

`Libs` 字段包含使用该库所需要的链接标记。另外，`Libs` 和 `Libs.private`包含`pkg-config`不支持的其它库的链接标记。同 `Requires` 字段相似，倾向于在 `Libs.private`字段中添加外部库的链接标记，如此，应用可以不引入额外的直接依赖。

最后，`Cflags` 包含使用该库的编译标记。不像`Libs`字段，没有`Cflags`的私有变体。这是因为数据类型和宏定义无论何种链接场景都是需要的。
## 使用pkg-config文件
设想有许多`.pc`文件安装到系统里，`pkg-config`将会为了使用它们抽取元信息。执行`pkg-config --help`你可以看到选项的一个简短描述。一个更详细的讨论可以在`pkg-config(1)`手册页上找到，这一节将提供常见用法的一个简单解释。

考虑一个系统有两个模块`foo` 和 `bar`，它们的`.pc`可能看起来像这样：
```
foo.pc:
prefix=/usr
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: foo
Description: The foo library
Version: 1.0.0
Cflags: -I${includedir}/foo
Libs: -L${libdir} -lfoo

bar.pc:
prefix=/usr
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: bar
Description: The bar library
Version: 2.1.2
Requires.private: foo >= 0.7
Cflags: -I${includedir}
Libs: -L${libdir} -lbar
```
模块的版本可以通过`--modversion`选项得到：
```
$ pkg-config --modversion foo
1.0.0
$ pkg-config --modversion bar
2.1.2
```
为了打印每个模块的链接标记，请使用`--libs`选项：
```
$ pkg-config --libs foo
-lfoo
$ pkg-config --libs bar
-lbar
```
注意`pkg-config`拟制了这两个模块的`Libs`字段的部分信息。这厮因为它对`-L` 标记特殊处理，并且它知道 `${libdir}` 目录 `/usr/lib`是系统连接搜寻路径的一部分。这可以让`pkg-config`免于与链接过程干扰。

同时，虽然`bar`需要`foo`，但对`foo`的链接标记也未输出。这是因为`foo` 并非被应用直接需要，它仅仅被`bar`库使用。对于静态链接`bar` 的应用，我们需要两套链接标记：
```
$ pkg-config --libs --static bar
-lbar -lfoo
```
在这种情况下`pkg-config`需要输出两套链接标记，以此来保证静态链接的应用能找到所有需要的符号。另一方面，它总是输出所有的`Cflags`：
```
$ pkg-config --cflags bar
-I/usr/include/foo
$ pkg-config --cflags --static bar
-I/usr/include/foo
```
另一个有用的选项`--exists`，用于测试一个模块是否可用：
```
$ pkg-config --exists foo
$ echo $?
0
```
`pkg-config`一个最好的特性是提供版本检查。它被用于决定一个足够（高）的版本是否可得。
```
$ pkg-config --libs "bar >= 2.7"
Requested 'bar >= 2.7' but version of bar is 2.1.2
```
当联合`--print-errors`选项时一些命令可能提供更丰富的输出：
```
$ pkg-config --exists --print-errors xoxo
Package xoxo was not found in the pkg-config search path.
Perhaps you should add the directory containing `xoxo.pc'
to the PKG_CONFIG_PATH environment variable
No package 'xoxo' found
```
上面的消息指向`PKG_CONFIG_PATH`环境变量。这个变量用于决定`pkg-config`的搜素路径。在一个典型的Unix系统上，它会搜索`/usr/lib/pkgconfig`和`/usr/share/pkgconfig`目录。这通常会包含系统安装模块。但是，某些本地模块可能会安装在一个不同的前缀下如`/usr/local`。在这种场景下，需要事先扩展搜索路径来确保`pkg-config`可以定位`.pc`文件：
```
$ pkg-config --modversion hello
Package hello was not found in the pkg-config search path.
Perhaps you should add the directory containing `hello.pc'
to the PKG_CONFIG_PATH environment variable
No package 'hello' found
$ export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
$ pkg-config --modversion hello
1.0.0
```
一些[autoconf](http://www.gnu.org/software/autoconf/)宏被提供来方便将`pkg-config`模块集成进项目中。
- PKG_PROG_PKG_CONFIG([MIN-VERSION]): 在系统上定位 `pkg-config`工具，检查兼容性版本。
- PKG_CHECK_EXISTS(MODULES, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND]): 检查一个特定集合的模块存在。
- PKG_CHECK_MODULES(VARIABLE-PREFIX, MODULES, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND]): 检查一个特定集合的模块存在。如果存在，它根据`pkg-config --cflags` 和 `pkg-config --libs`的输出设置 `<VARIABLE-PREFIX>_CFLAGS` 和 `<VARIABLE-PREFIX>_LIBS`。
## FAQ
### 我的应用使用了库 `x`，我应该做什么？
`pkg-config`的输出可以很容易被用在编译器命令行上。假设 x 库用用一个 `x.pc pkg-config`文件：
`cc `pkg-config --cflags --libs x` -o myapp myapp.c`
如果同 [autoconf](http://www.gnu.org/software/autoconf/) 和 [automake](http://www.gnu.org/software/automake/)一起使用，该集成就会更健壮。通过使用提供的 `PKG_CHECK_MODULES` 宏，元信息更容易在构建过程中被访问到。
```
configure.ac:
PKG_CHECK_MODULES([X], [x])

Makefile.am:
myapp_CFLAGS = $(X_CFLAGS)
myapp_LDADD = $(X_LIBS)
```
如果 `x` 模块被找到，宏将填充并替换 `X_CFLAGS` 和 `X_LIBS`变量。如果模块未找到，将会产生一个错误。可选的第三和第四个参数可被传给`PKG_CHECK_MODULES`来控制该模块被找到或未找到时的行为。
### 我的库 `z`安装了头文件，其中包含了`libx` 的头文件。我在 `z.pc` 文件中应该放置写什么？
如果 `x` 库支持 `pkg-config`，将它加进`Requires.private`字段。否则，加进 `Cflags` 字段并填充使用`libx` 头文件的必要编译标志。在任一情况下，`pkg-config`都将输出编译标记，无论`--static`使用已否。
### 我的库 `z` 内部使用了 `libx`,但不期望把 `libx`的数据类型导出到公共API，我在 `z.pc` 文件中应该放置写什么？
再一次，如果x 库支持 `pkg-config`，将它加进`Requires.private`字段。在这种情况下，编译标记将会不必要地发出，但它可以确保静态链接时链接标记的存在。如果 `libx` 不支持 `pkg-config`，将必要的链接标记添加到`Libs.private`。

## Reference
- [Guide to pkg-config](https://people.freedesktop.org/~dbn/pkg-config-guide.html)
- [pkg-config--Linux Man Page](https://linux.die.net/man/1/pkg-config)
- [理解 Linux中的pkg-config 工具](https://www.cnblogs.com/woshijpf/articles/3840840.html)