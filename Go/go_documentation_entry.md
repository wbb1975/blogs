# Go 文档
Go 编程语言是一个开源项目，它使程序员更具生产力。

Go 语言具有很强的表达能力，它简洁、清晰而高效。得益于其并发机制，用它编写的程序能够非常有效地利用多核与联网的计算机，其新颖的类型系统则使程序结构变得灵活而模块化。Go 代码编译成机器码不仅非常迅速，还具有方便的垃圾收集机制和强大的运行时反射机制。它是一个快速的、静态类型的编译型语言，感觉却像动态类型的解释型语言。
## 1. 开始
- [安装 Go](https://golang.org/doc/install)
  下载和安装Go的指令。
- [教程：入门](https://golang.org/doc/tutorial/getting-started.html)
  从一个简单的 Hello, World 开始。学习一点关于 Go 代码，工具，包以及模块的入门知识。 
- [教程：创建一个模块](https://golang.org/doc/tutorial/create-module.html)
  简短主题的一个教程，包括函数，错误处理，数组，映射，单元测试以及编译。
- [编写Web应用](https://golang.org/doc/articles/wiki/)
  构建一个简单的Web应用。
- [如何写Go代码](https://golang.org/doc/code.html)
  这篇文档解释了如何在一个模块里开发一系列 Go 包，它也展示了如何使用[Go命令](https://golang.org/cmd/go/)来构建并测试包。
## 2. 学习 Go 语言
### 2.1 Go 语言之旅
Go 语言的交互式简介，它分为三节。第一节覆盖了基本语法及数据结构，第二节讨论了方法与接口，第三节则简单介绍了 Go 的并发原语。每节末尾都有几个练习，你可以对自己的所学进行实践。 你可以使用下面的指令安装到本地。
```
$ go get golang.org/x/tour
```
这将把 tour 程序安装在你工作空间的 bin 目录下。

- [如何编写Go代码](https://golang.org/doc/code.html)
  该文档解释了入了如何在一个模块内开发一套简单的 Go 包，它也展示了如何使用[go 命令](https://golang.org/cmd/go/)来构建和测试包。
- [编辑器插件和集成开发环境](https://golang.org/doc/editors.html)
  该文档总结了常用的编辑器插件和支持 Go 的集成开发环境（IDEs）。
- [高效 Go 编程](https://golang.org/doc/effective_go.html)
  该文档给出了一些撰写清晰，通顺的 Go 代码的小技巧。一个对新的 Go 程序员的必读材料。它应该扩大到 Go 之旅以及语言规范，这两者都需要首先阅读。
- [诊断](https://golang.org/doc/diagnostics.html)
  总结了在诊断 Go 程序问题时的工具和方法论。
- [常见问题解答（FAQ）](https://golang.org/doc/faq)
  关于 Go 的常见问题解答
- [教程](https://golang.org/doc/tutorial/)
  一系列 Go 入门教程。
- [Go 维基](https://golang.org/wiki)
  由 Go 社区维护的维基。
### 2.2 更多
参考[学习页面](https://golang.org/wiki/Learn)和[Wiki](https://golang.org/wiki)以获取更多 Go 的学习资源。
## 3. 参考
- [包文档](https://golang.org/pkg/)
  Go 标准库的文档。
- [命令文档](https://golang.org/doc/cmd)
  Go 工具的文档。
- [语言规范](https://golang.org/ref/spec)
  官方 Go 语言规范。
- [Go 内存模型](https://golang.org/ref/mem)
  此文档指定了在一个Go协程中，写入一个变量所产生的值，能够保证被另一个Go协程（goroutine）所读取的条件。
- [发行历史](https://golang.org/doc/devel/release.html)
  Go 发行版之间更改的概述。
## 4. 文章
- 代码漫步
  Go程序的旅行指南。
  + [函数 - Go 语言中的一等公民](https://golang.org/doc/codewalk/functions)
  + [生成任意文本：马尔可夫链算法](https://golang.org/doc/codewalk/markov)
  + [通过通信共享内存](https://golang.org/doc/codewalk/sharemem)
  + [编写Web应用](https://golang.org/doc/articles/wiki/) - 构建简单的Web应用
- 工具
  + [关于 Go 命令](https://golang.org/doc/articles/go_command.html) - 为什么写它？它是什么？它不是什么？它怎么用？
  + [使用GDB调试Go代码](https://golang.org/doc/gdb)
  + [数据竞态检测器](https://golang.org/doc/articles/race_detector.html) - 数据竞态检测器手册
  + [Go 汇编器快速指南](https://golang.org/doc/asm) - 对 Go 使用的汇编的介绍
- 更多
  参见[Wiki](https://golang.org/wiki)里的[文章页面](https://golang.org/wiki/Articles)以获取更多 Go 文章。
## 5. 非英语文档
本地化文档参见[维基](https://golang.org/wiki)的[非英语页面](https://golang.org/wiki/NonEnglish)。

## Reference
- [Go Documentation](https://golang.org/doc/)
- [Go 编程语言](https://go-zh.org/doc/)
- [Go 语言之旅](https://tour.go-zh.org/)
- [Effective Go and (old) Tutorial (Deprecated)](http://code.google.com/p/ac-me/downloads/detail?name=fango.pdf)