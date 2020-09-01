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
## 使用pkg-config文件
## FAQ

## Reference
- [Guide to pkg-config](https://people.freedesktop.org/~dbn/pkg-config-guide.html)
- [pkg-config--Linux Man Page](https://linux.die.net/man/1/pkg-config)
- [理解 Linux中的pkg-config 工具](https://www.cnblogs.com/woshijpf/articles/3840840.html)