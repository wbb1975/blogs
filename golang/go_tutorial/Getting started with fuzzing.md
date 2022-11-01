# Getting started with fuzzing

这个教程介绍了 Go 中模糊测试（fuzzing）的基础知识。利用模糊测试，随机数据可以用于运行你的测试，以此试图找到软件弱点或导致程序崩溃的输入。可以通过模糊测试检测到的软件弱点包括 SQL 注入，缓存溢出，拒绝服务以及跨站脚本攻击。

在本教程，你将为一个简单的函数编写一个模糊测试，运行 go 命令，调试并修补代码中的问题。

为了帮助了解本教程中的一些术语，参考 [Go Fuzzing glossary](https://go.dev/security/fuzz/#glossary)。

本教程包括以下几个章节：

1. 为你的代码创建目录
2. 为代码添加测试
3. 添加一个单元测试
4. 添加一个模糊测试
5. 修补两个问题
6. 探索更多资源

> 注意：其它教程，请参见[教程主页](https://go.dev/doc/tutorial/index.html)

> 注意：Go 模糊测试当前支持以下部分内建类型，已在 [Go Fuzzing docs](https://go.dev/security/fuzz/#requirements) 列出，将来会添加对更多内建类型的支持。

## 0. 前提条件

- **一个 Go 1.18 或更新版本的安装**：关于安装指令，请参见[安装 Go](https://go.dev/doc/install)。
- **一个编写你的代码的工具**：任何你手上的文本编辑器可以工作得很好。大多数文本编辑器对 Go 有很好的支持。最流行的有 VSCode (免费), GoLand (付费), and Vim (免费).
- **一个命令行终端**：在 Linux 和 Mac 上使用任何终端 Go 都可以工作得很好，在 Windows 上是 PowerShell 或 `cmd`。
- **一个支持模糊测试的环境**：带有覆盖率实现的 Go 模糊测试当前只在 `AMD64` 和 `ARM64` 架构上可用。

## 1. 为你的代码创建目录

作为开始，为你即将编写的代码创建一个项目。

1. 打开命令行终端并切换到你的主目录：

   在 Linux 或 Mac:
   ```
   cd
   ```

   在 Windows:
   ```
   C:\> cd %HOMEPATH%
   ```

   教程剩余部分的提示符将显示为 `$`，你使用的命令也可作用于 `Windows`。

2. 从命令行提示符，为你的代码创建一个 `fuzz` 目录

   ```
   $ mkdir fuzz
   $ cd fuzz
   ```

3. 创建一个模块，你将在其中管理本教程中添加的依赖。

   运行 `go mod init` 命令，并传递你的新代码的模块路径。

   ```
   $ go mod init example/fuzz
   go: creating new go.mod: module example/fuzz
   ```

   > 注意：在实际开发中，你可以根据你的需求指定一个更特殊的模块路径。更多信息，请参考[管理依赖](https://go.dev/doc/modules/managing-dependencies)。

接下来，你将实现一个反转字符串的简单代码，我们稍后将对其进行模糊测试。

## 2. 为代码添加测试

这一节，我们将添加一个函数来反转字符串。

### 2.1 编写代码

1. 使用你的文本编辑器，在 `fuzz` 目录下创建名为 `main.go` 的 Go 文件。
2. 在 `main.go` 中，在文件顶部，粘贴进下面的包声明。

   ```
   package main
   ```

   一个独立应用（与库相反）总是在包 `main` 里。
3. 在包声明之下，粘贴进下面的函数代码。

    ```
    func Reverse(s string) string {
        b := []byte(s)
        for i, j := 0, len(b)-1; i < len(b)/2; i, j = i+1, j-1 {
            b[i], b[j] = b[j], b[i]
        }
        return string(b)
    }
    ```

   这个函数将接受一个字符串，一次迭代一个字节，最后返回反转后的字符串。

   > 注意：这段代码基于 `golang.org/x/example` 中的 `stringutil.Reverse` 函数。

4. 在 `main.go` 顶端，包声明之下，粘贴下面的 `main` 函数以初始化一个字符串，反转它，打印出来并重复这个操作一次。

   ```
   func main() {
       input := "The quick brown fox jumped over the lazy dog"
       rev := Reverse(input)
       doubleRev := Reverse(rev)
       fmt.Printf("original: %q\n", input)
       fmt.Printf("reversed: %q\n", rev)
       fmt.Printf("reversed again: %q\n", doubleRev)
   }
   ```

   这个函数将运行 `Reverse` 函数几次，然后在命令行上打印结果。这对于观察代码的运作以及潜在的调试是有帮助的。

5. `main` 函数使用了 `fmt` 包，因此你需要导入它。

   前面几行代码应该看起来像这样：

   ```
   package main

   import "fmt"
   ```

### 2.2 运行代码

从命令行进入包含 `main.go` 的目录，运行代码。
   
   ```
   $ go run .
   original: "The quick brown fox jumped over the lazy dog"
   reversed: "god yzal eht revo depmuj xof nworb kciuq ehT"
   reversed again: "The quick brown fox jumped over the lazy dog"
   ```

你可以看到原始字符串，它的反转值，再次反转值，它与原始值相等。

现在代码可以运行了，让我们来测试它。

## 3. 添加一个单元测试

在这一步，我们将为 `Reverse` 函数编写一个简单的测试。

### 3.1 编写代码

1. 使用你的文本编辑器，在 `fuzz` 目录下创建文件 `reverse_test.go`。
2. 将下面的代码粘贴进 `reverse_test.go`： 

   ```
   package main

   import (
       "testing"
   )

   func TestReverse(t *testing.T) {
       testcases := []struct {
           in, want string
       }{
           {"Hello, world", "dlrow ,olleH"},
           {" ", " "},
           {"!12345", "54321!"},
       }
       for _, tc := range testcases {
           rev := Reverse(tc.in)
           if rev != tc.want {
                   t.Errorf("Reverse: %q, want %q", rev, tc.want)
           }
       }
   }
   ```

   这个简单的测试将断言列出的输入字符床将被正确地反转。

### 3.2 运行代码

使用 `go test` 运行单元测试：

```
$ go test
PASS
ok      example/fuzz  0.013s
```

接下来，你将把单元测试修改为模糊测试。

## 4. 添加一个模糊测试

单元测试有一些限制，即开发者必须将每一个输入加进测试。模糊测试的好处之一就是它为你的代码提供输入，并可能识别出你的测试样例不能触发的边缘样例。

这一节我们将把单元测试改为模糊测试，如此你可以以更少的工作产生更多的输入。

注意你可以把单元测试，基准测试，以及模糊测试放在一个同样的 `*_test.go` 文件，但对于这个例子，我们将把单元测试转为模糊测试。

### 4.1 编写代码

在你的文本编辑器中，将 `reverse_test.go` 里的单元测试替换为下面的模糊测试。

```
func FuzzReverse(f *testing.F) {
    testcases := []string{"Hello, world", " ", "!12345"}
    for _, tc := range testcases {
        f.Add(tc)  // Use f.Add to provide a seed corpus
    }
    f.Fuzz(func(t *testing.T, orig string) {
        rev := Reverse(orig)
        doubleRev := Reverse(rev)
        if orig != doubleRev {
            t.Errorf("Before: %q, after: %q", orig, doubleRev)
        }
        if utf8.ValidString(orig) && !utf8.ValidString(rev) {
            t.Errorf("Reverse produced invalid UTF-8 string %q", rev)
        }
    })
}
```

模糊测试也有一些限制。在你的单元测试中，你能够预测 `Reverse` 函数的预期结果，并验证实际结果与预期一致。

例如，在测试 `case Reverse("Hello, world")` 中，单元测试指定其返回值为 `"dlrow ,olleH"`。

但对于模糊测试，你不能预测预期结果，愿意在于你并能控制（测试）输入。

但是，在 `Reverse` 函数中有一些属性你可以在模糊测试中验证。这次模糊测试中检查到的属性包括：

- 两次反转将回归原始值
- 反转字符串保持其状态为有效 `UTF-8`.
  
注意单元测试与模糊测试的语法差异：
+ 函数以 `FuzzXxx` 而非 `TestXxx` 开始，以携带参数 `*testing.F` 而非 `*testing.T`。
+ 在你期待一个 `t.Run` 运行的地方，你会看到 `f.Fuzz`，它带有一个模糊测试目标函数，其参数为 `*testing.T`，并且其类型为模糊的。从你的单元测试来的输入被 `f.Add` 用作种子。

确保新的包 `unicode/utf8` 已被正确导入：

```
package main

import (
    "testing"
    "unicode/utf8"
)
```

一旦单元测试被转化为模糊测试，是时候再次运行测试了。

### 4.2 运行代码

1. 没有模糊化运行模糊测试以确保种子输入可以通过。

   ```
   $ go test
   PASS
   ok      example/fuzz  0.013s
   ```

   如果你在文件里有其它测试，并且你只希望运行模糊测试，那么你也可以运行 `go test -run=FuzzReverse`。 

2. 利用模糊化运行 `FuzzReverse` 以检查是否随机产生的字符串输入将导致失败。这是使用 `go test` 带一个新的标记 `-fuzz` 执行的。

   ```
   $ go test -fuzz=Fuzz
   fuzz: elapsed: 0s, gathering baseline coverage: 0/3 completed
   fuzz: elapsed: 0s, gathering baseline coverage: 3/3 completed, now fuzzing with 8 workers
   fuzz: minimizing 38-byte failing input file...
   --- FAIL: FuzzReverse (0.01s)
       --- FAIL: FuzzReverse (0.00s)
           reverse_test.go:20: Reverse produced invalid UTF-8 string "\x9c\xdd"

       Failing input written to testdata/fuzz/FuzzReverse/af69258a12129d6cbba438df5d5f25ba0ec050461c116f777e77ea7c9a0d217a
       To re-run:
       go test -run=FuzzReverse/af69258a12129d6cbba438df5d5f25ba0ec050461c116f777e77ea7c9a0d217a
   FAIL
   exit status 1
   FAIL    example/fuzz  0.030s
   ```

   运行 `fuzz` 测试时一个失败发生了，导致问题的输入被写进一个种子文件，下次 `go test` 被调用时可以可被运行，即使不带 `-fuzz` 标记。为了观察导致失败的输入，在一个文本编辑器中打开写到 `testdata/fuzz/FuzzReverse` 目录的种子文件。你的种子文件可能包含一个不同的字符串，但是格式应该一样。

   ```
   go test fuzz v1
   string("泃")
   ```

   种子文件的第一行指示编码版本。下面的每一行代表组成种子项的每个类型。因为模糊目标仅仅需要一个输入，版本之后仅有一个值。

3. 不带 `-fuzz` 标记再次运行 `go test`：新的失败的种子项将被使用。

   ```
   $ go test
   --- FAIL: FuzzReverse (0.00s)
       --- FAIL: FuzzReverse/af69258a12129d6cbba438df5d5f25ba0ec050461c116f777e77ea7c9a0d217a (0.00s)
           reverse_test.go:20: Reverse produced invalid string
   FAIL
   exit status 1
   FAIL    example/fuzz  0.016s
   ```

   因为我们的测试失败了，是时候调试问题了。

## 5. 修补非法字符串错误

在这一节，你将调试失败，并修补这个问题。

在继续之前，可以花点时间思考这个问题，并尝试自己解决这个问题。

### 5.1 诊断错误

1. 你可以通过一些不同的方式调试错误。如果你在使用 `VS Code` 作为你的文本编辑器，你可以[设置你的调试器](https://github.com/golang/vscode-go/blob/master/docs/debugging.md) 以进一步调查。

   在本教程中，你将把有用的调试信息到终端上。

   首先，考虑 [utf8.ValidString](https://github.com/golang/vscode-go/blob/master/docs/debugging.md) 的文档：

   ```
   ValidString reports whether s consists entirely of valid UTF-8-encoded runes.
   ```

   当前的 `Reverse` 函数逐字节反转字符串，因此导致了我们的问题。为了保留源字符串的 `UTF-8` 编码字符（rune），我们必须逐字符（`rune`）反转它。

   为了检查当反转时特定输入（在这个示例中时中文字符泃）会是否导致 `Reverse` 函数产生非法字符串，你可以查看反转后的字符个数。

#### 5.1.1 编写代码

   在文本编辑器中，在 `FuzzReverse` 中将 `fuzz` 目标替换成下面的代码：

   ```
   f.Fuzz(func(t *testing.T, orig string) {
       rev := Reverse(orig)
       doubleRev := Reverse(rev)
       t.Logf("Number of runes: orig=%d, rev=%d, doubleRev=%d", utf8.RuneCountInString(orig), utf8.RuneCountInString(rev), utf8.RuneCountInString(doubleRev))
       if orig != doubleRev {
           t.Errorf("Before: %q, after: %q", orig, doubleRev)
       }
       if utf8.ValidString(orig) && !utf8.ValidString(rev) {
           t.Errorf("Reverse produced invalid UTF-8 string %q", rev)
       }
   })
   ```

   如果发生错误或带 `-v` 标记执行测试函数时，`t.Logf` 这一行将打印输出到命令行，这可以帮助你调试特定错误。

#### 5.1.2 运行代码

   使用 `go test` 运行测试：
   
   ```
   $ go test
   --- FAIL: FuzzReverse (0.00s)
       --- FAIL: FuzzReverse/28f36ef487f23e6c7a81ebdaa9feffe2f2b02b4cddaa6252e87f69863046a5e0 (0.00s)
           reverse_test.go:16: Number of runes: orig=1, rev=3, doubleRev=1
           reverse_test.go:21: Reverse produced invalid UTF-8 string "\x83\xb3\xe6"
   FAIL
   exit status 1
   FAIL    example/fuzz    0.598s
   ```
   
   这里使用的种子字符串每个字符时一个单独字节。但是，字符如 `泃` 可能需要几个字节。因此，逐字节反转字符串将会使多字节字符变得无效。

   > 注意：如果你好奇 Go 如何处理字符串，可以阅读博文[Strings, bytes, runes and characters in Go](https://go.dev/blog/strings) 以深入了解。

   随着对问题的理解加深，让我们来修正 `Reverse` 函数里的错误。

### 5.2 修正错误

为了更正 `Reverse` 函数，让我们逐 `runes` 反转字符串，而非逐字节。

#### 5.2.1 编写代码

   在文本编辑器中，用下面的代码替换已有的 `Reverse()` 函数：

   ```
   func Reverse(s string) string {
       r := []rune(s)
       for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
           r[i], r[j] = r[j], r[i]
       }
       return string(r)
   }
   ```

   关键的差别在于 `Reverse` 现在逐 `rune` 迭代字符串而非字节。

#### 5.2.2 运行代码

1. 使用 `go test` 运行测试：
   
   ```
   $ go test
   PASS
   ok      example/fuzz  0.016s
   ```
   
   测试现在通过了。

2. 使用 `go test -fuzz` 运行模糊测试以检查是否有新的问题。

   ```
    $ go test -fuzz=Fuzz
    fuzz: elapsed: 0s, gathering baseline coverage: 0/37 completed
    fuzz: minimizing 506-byte failing input file...
    fuzz: elapsed: 0s, gathering baseline coverage: 5/37 completed
    --- FAIL: FuzzReverse (0.02s)
        --- FAIL: FuzzReverse (0.00s)
            reverse_test.go:33: Before: "\x91", after: "�"

        Failing input written to testdata/fuzz/FuzzReverse/1ffc28f7538e29d79fce69fef20ce5ea72648529a9ca10bea392bcff28cd015c
        To re-run:
        go test -run=FuzzReverse/1ffc28f7538e29d79fce69fef20ce5ea72648529a9ca10bea392bcff28cd015c
    FAIL
    exit status 1
    FAIL    example/fuzz  0.032s
   ```

   我们能够看到反转两次后字符串与原始字符串并不一致，这一次输入本身时无效的 `unicode`，它是怎么产生的呢？

   让我们再次调试。

## 6. 修补二次反转错误

在这一节，你将调试二次反转失败的问题，并修补它。

在继续之前，可以花点时间思考这个问题，并尝试自己解决这个问题。

### 6.1 诊断错误

1. 像以前一样，你可以通过一些不同的方式调试错误。在这里，使用 [debugger](https://github.com/golang/vscode-go/blob/master/docs/debugging.md) 是一个很好的方式。
   在本教程中，你将打记录 Reverse 里的有用的调试信息。

   再次深入检查反转后的字符串。在 Go 中，[一个字符串仅仅是一个只读字节切片](https://go.dev/blog/strings)，并且可以包含无效 `UTF-8` 字节。原先字符串是一个一个字节的字节切片，'\x91'。当输入字符串被设置为 `[]rune`，Go 将字节切片编码为 `UTF-8`，并替换该字节为 UTF-8 字符 `�`。当我们用替换后的 `UTF-8` 字符与输入字节切片相比时，显然它们不会相等。

#### 6.1.1 编写代码

   在文本编辑器中，将 `Reverse` 函数替换成下面的代码：

   ```
   func Reverse(s string) string {
       fmt.Printf("input: %q\n", s)
       r := []rune(s)
       fmt.Printf("runes: %q\n", r)
       for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
           r[i], r[j] = r[j], r[i]
       }
       return string(r)
   }
   ```

   这将帮助我们理解当把字符串转化为 `rune` 切片时发生了什么错误。

#### 6.1.2 运行代码

这一次，我们向仅仅运行失败的测试以检验输出日志。为了实现这个，我们使用 `go test -run`。

   ```
   $ go test -run=FuzzReverse/28f36ef487f23e6c7a81ebdaa9feffe2f2b02b4cddaa6252e87f69863046a5e0
   input: "\x91"
   runes: ['�']
   input: "�"
   runes: ['�']
   --- FAIL: FuzzReverse (0.00s)
       --- FAIL: FuzzReverse/28f36ef487f23e6c7a81ebdaa9feffe2f2b02b4cddaa6252e87f69863046a5e0 (0.00s)
           reverse_test.go:16: Number of runes: orig=1, rev=1, doubleRev=1
           reverse_test.go:18: Before: "\x91", after: "�"
   FAIL
   exit status 1
   FAIL    example/fuzz    0.145s
   ```

   为了在 `FuzzXxx/testdata` 中运行一个特定测试，你可以为 `-run` 提供 `{FuzzTestName}/{filename}`。这在调试时很有用。

   知道了输入是一个无效 `unicode`，让我们在 `Reverse` 函数中修正它。

### 6.2 修正错误

为了修正这个错误，让我们在 `Reverse` 收到无效 `UTF-8` 时返回一个错误。

#### 6.2.1 编写代码

1. 在文本编辑器中，用下面的代码替换已有的 `Reverse()` 函数：

   ```
   func Reverse(s string) (string, error) {
      if !utf8.ValidString(s) {
          return s, errors.New("input is not valid UTF-8")
      }
      r := []rune(s)
      for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
          r[i], r[j] = r[j], r[i]
      }
      return string(r), nil
   }
   ```

   修改在于当输入字符串包含无效 `UTF-8` 字节时返回一个错误。
2. 因为 `Reverse` 函数现在返回一个错误，修改 `main` 函数放弃额外的错误值。用下面的代码替换已有的 `main` 函数：

   ```
   func main() {
      input := "The quick brown fox jumped over the lazy dog"
      rev, revErr := Reverse(input)
      doubleRev, doubleRevErr := Reverse(rev)
      fmt.Printf("original: %q\n", input)
      fmt.Printf("reversed: %q, err: %v\n", rev, revErr)
      fmt.Printf("reversed again: %q, err: %v\n", doubleRev, doubleRevErr)
   }
   ```
   
   对 `Reverse` 的调用应该返回一个 `nil` 错误，因为输入字符串时有效的 `UTF-8`。

3. 你将需要导入 `errors` 和 `unicode/utf8` 包。`main.go` 中的导入语句应该看起来像这样：

   ```
   import (
    "errors"
    "fmt"
    "unicode/utf8"
   )
   ```

4. 修改 `reverse_test.go` 文件以检查错误值，如果错误值有返回产生则跳过测试。
   
   ```
   func FuzzReverse(f *testing.F) {
    testcases := []string {"Hello, world", " ", "!12345"}
    for _, tc := range testcases {
        f.Add(tc)  // Use f.Add to provide a seed corpus
    }
    f.Fuzz(func(t *testing.T, orig string) {
        rev, err1 := Reverse(orig)
        if err1 != nil {
            return
        }
        doubleRev, err2 := Reverse(rev)
        if err2 != nil {
             return
        }
        if orig != doubleRev {
            t.Errorf("Before: %q, after: %q", orig, doubleRev)
        }
        if utf8.ValidString(orig) && !utf8.ValidString(rev) {
            t.Errorf("Reverse produced invalid UTF-8 string %q", rev)
        }
    })
   }
   ```

   选择返回，你也可以调用 `t.Skip()` 来停止那个模糊输入的执行。

#### 6.2.2 运行代码

1. 使用 `go test` 运行测试：
   
   ```
   $ go test
   PASS
   ok      example/fuzz  0.019s
   ```

2. 使用 `go test -fuzz=Fuzz` 运行模糊测试。几秒钟过后，使用 `ctrl-C` 以停止模糊测试。

   ```
    $ go test -fuzz=Fuzz
    fuzz: elapsed: 0s, gathering baseline coverage: 0/38 completed
    fuzz: elapsed: 0s, gathering baseline coverage: 38/38 completed, now fuzzing with 4 workers
    fuzz: elapsed: 3s, execs: 86342 (28778/sec), new interesting: 2 (total: 35)
    fuzz: elapsed: 6s, execs: 193490 (35714/sec), new interesting: 4 (total: 37)
    fuzz: elapsed: 9s, execs: 304390 (36961/sec), new interesting: 4 (total: 37)
    ...
    fuzz: elapsed: 3m45s, execs: 7246222 (32357/sec), new interesting: 8 (total: 41)
    ^Cfuzz: elapsed: 3m48s, execs: 7335316 (31648/sec), new interesting: 8 (total: 41)
    PASS
    ok      example/fuzz  228.000s
   ```

   除非你传递了 `-fuzztime` 标记，模糊测试将持续运行，除非它遇到了一个失败的输入。如果没有错误发生，默认将永远运行，该过程可以用 `ctrl-C` 中断。

3. 使用 `go test -fuzz=Fuzz -fuzztime 30s` 运行模糊测试。如果没有错误发现，在退出前它将运行模糊测试30秒。

   ```
    $ go test -fuzz=Fuzz -fuzztime 30s
    fuzz: elapsed: 0s, gathering baseline coverage: 0/5 completed
    fuzz: elapsed: 0s, gathering baseline coverage: 5/5 completed, now fuzzing with 4 workers
    fuzz: elapsed: 3s, execs: 80290 (26763/sec), new interesting: 12 (total: 12)
    fuzz: elapsed: 6s, execs: 210803 (43501/sec), new interesting: 14 (total: 14)
    fuzz: elapsed: 9s, execs: 292882 (27360/sec), new interesting: 14 (total: 14)
    fuzz: elapsed: 12s, execs: 371872 (26329/sec), new interesting: 14 (total: 14)
    fuzz: elapsed: 15s, execs: 517169 (48433/sec), new interesting: 15 (total: 15)
    fuzz: elapsed: 18s, execs: 663276 (48699/sec), new interesting: 15 (total: 15)
    fuzz: elapsed: 21s, execs: 771698 (36143/sec), new interesting: 15 (total: 15)
    fuzz: elapsed: 24s, execs: 924768 (50990/sec), new interesting: 16 (total: 16)
    fuzz: elapsed: 27s, execs: 1082025 (52427/sec), new interesting: 17 (total: 17)
    fuzz: elapsed: 30s, execs: 1172817 (30281/sec), new interesting: 17 (total: 17)
    fuzz: elapsed: 31s, execs: 1172817 (0/sec), new interesting: 17 (total: 17)
    PASS
    ok      example/fuzz  31.025s
   ```

   模糊测试通过了。

   除了 `-fuzz` 标记，几个新的标记也被添加到 `go test` 中，可从[文档](https://go.dev/security/fuzz/#custom-settings)中查到。

## 7. 结论

做的好。你已经给你自己介绍了 Go 中的模糊测试。

下一步时选自一个你代码中你期待做模糊测试的函数，自己试一试。如果模糊测试在你的代码中发现了问题，可以考虑将它加进 [trophy case](https://github.com/golang/go/wiki/Fuzzing-trophy-case)。

如果你碰到了任何问题，或者有关于特性的任何主意，[触发一个 issue](https://github.com/golang/go/issues/new/?&labels=fuzz)。

关于特性的讨论及一般性反馈，你可以从 Gophers Slack [#fuzzing channel](https://gophers.slack.com/archives/CH5KV1AKE) 中参与。

下载 `go.dev/security/fuzz` 中的文档以深入阅读。

## 8. 完整代码

### main.go

```
package main

import (
    "errors"
    "fmt"
    "unicode/utf8"
)

func main() {
    input := "The quick brown fox jumped over the lazy dog"
    rev, revErr := Reverse(input)
    doubleRev, doubleRevErr := Reverse(rev)
    fmt.Printf("original: %q\n", input)
    fmt.Printf("reversed: %q, err: %v\n", rev, revErr)
    fmt.Printf("reversed again: %q, err: %v\n", doubleRev, doubleRevErr)
}

func Reverse(s string) (string, error) {
    if !utf8.ValidString(s) {
        return s, errors.New("input is not valid UTF-8")
    }
    r := []rune(s)
    for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
        r[i], r[j] = r[j], r[i]
    }
    return string(r), nil
}
```

### reverse_test.go

```
package main

import (
    "testing"
    "unicode/utf8"
)

func FuzzReverse(f *testing.F) {
    testcases := []string{"Hello, world", " ", "!12345"}
    for _, tc := range testcases {
        f.Add(tc) // Use f.Add to provide a seed corpus
    }
    f.Fuzz(func(t *testing.T, orig string) {
        rev, err1 := Reverse(orig)
        if err1 != nil {
            return
        }
        doubleRev, err2 := Reverse(rev)
        if err2 != nil {
            return
        }
        if orig != doubleRev {
            t.Errorf("Before: %q, after: %q", orig, doubleRev)
        }
        if utf8.ValidString(orig) && !utf8.ValidString(rev) {
            t.Errorf("Reverse produced invalid UTF-8 string %q", rev)
        }
    })
}
```

## Reference

- [Getting started with fuzzing](https://go.dev/doc/tutorial/fuzz)
- [Strings, bytes, runes and characters in Go](https://go.dev/blog/strings)
- [debugger](https://github.com/golang/vscode-go/blob/master/docs/debugging.md)