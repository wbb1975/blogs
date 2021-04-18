# Go 命令文档
有一套程序用来构建并处理 Go 源码。本套件中的程序通常并不直接运行，而是通过 go 程序来调用。

运行这些程序最普通的方式就是作为 go 程序的子命令，例如 go fmt。若像这样运行，该命令就会在 Go 源码的完整包上进行操作，它使用 go 程序通过适当的实参来调用基本的二进制程序以进行包级处理。

也可作为独立的二进制程序运行，加上未修改的实参，并使用 go 的 tool 子命令来运行，例如 go tool cgo。对于大多数命令这主要用于调试。有一些命令，如 pprof，只能通过 go 的 tool 子命令来访问。

最后，fmt 与 doc 两个命令也作为常规的二进制被安装为 gofmt 和 godoc，因为它们被经常引用。

欲获取更多文档、调用方法及用法详述，请点击以下链接。
名称|简介
--------|--------
[go](https://golang.org/cmd/go/)|go 程序管理 Go 源码以及运行其它在此列出的命令。用法详述见命令文档。
[cgo](https://golang.org/cmd/cgo/)|Cgo 使得能够创建调用 C 代码的 Go 包。
[cover](https://golang.org/cmd/cover/)|Cover 用于创建并分析由 "go test -coverprofile" 生成的coverage profiles。
[fix](https://golang.org/cmd/fix/)|Fix 发现使用旧语言与库特性的 Go 程序，并使用较新的特性来重写它们。
[fmt](https://golang.org/cmd/gofmt/)|Fmt 格式化 Go 包，它也可作为独立的[gofmt](https://golang.org/cmd/gofmt/)命令运行，使用更一般的选项同样有效。
[godoc](https://godoc.org/golang.org/x/tools/cmd/godoc/)|Godoc 从 Go 包中提取并生成文档。
[vet](https://golang.org/cmd/vet/)|Vet 检查 Go 源码并报告可疑的构造，例如 Printf 调用的实参数与格式化字符串不匹配。

这是一个简略的列表。编译器及更多文档见[完整的命令参考](https://golang.org/cmd/)。

## Reference
- [Command Documentation](https://golang.org/doc/cmd)
- [命令文档](https://go-zh.org/doc/cmd)