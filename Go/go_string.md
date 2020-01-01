## Go语言字符串
一个Go语言字符串是一个任意字节的常量序列，大部分情况下，一个字符串的字节使用UTF-8编码表示Unicode文本。Unicode编码的使用意味着Go语言可以包含世界上任何语言的混合，代码页没有任何混论与限制。

Go语言的字符串类型在本质上就与其它语言的字符串类型不同。Java的String， C++的std::string以及Python的str类型都只是定宽字符序列，而Go语言的字符串是一个由UTF-8编码的变宽字符序列，它的每一个字符都用一个或多个字节表示。
### 1. 字面量、操作符和转义
字符串字面量使用双引号（“）或者反引号（`）来创建。双引号用来创建可解析的字符串字面量，如下表所示的那些支持转义的序列，但不能用来引用多行。反引号用来创建原生的字符串字面量，这些字符串可能由多行组成：它们不支持任何转义序列，并且可以包含除了反引号之外的任何字符。可解析的字符串使用得最广泛，而原生的字符串字面量则用于书写多行消息，HTML以及正则表达式。

Go语言的字符串和字符转义

转义字符|含义
--|--
\\\\|反斜线
\ooo|3个8位数给定的八进制代码的Unicode字符
\\'|单引号，只用于字符字面量内
\\"|双引号，只用于可解析的字符字面量内
\a|ASCII的响铃符
\b|ASCII的退格符
\f|ASCII的换页符
\n|ASCII的换行符
\r|ASCII的回车符
\t|ASCII的制表符
\uhhhh|4个16进制数字给定的十六进制码点的Unicode字符
\Uhhhhhhhh|8个16进制数字给定的十六进制码点的Unicode字符
\v|ASCII的垂直制表符
\xhh|2个8位数字给定的十六进制码点的Unicode字符

**字符串字面量实例：**
```
text1 :="\"what's that?\", he said"          //可解析的字符串字面量
text2 := `"what's that?", he said`           //原生的字符串字面量
radicals := "\u221A\U0000221a"              //两个字符一样
```
**字符串操作符：**

语法|描述/结果
--|--
s += t|将字符串t追加到字符串s末尾
s + t|将字符串s和t级联
s[n]|字符串s中索引位置为n处的原始字节（uint8类型）
s[n:m]|从位置n到位置m-1处取得的字符串
s[n:]|从位置n到位置len(s)-1处取得的字符串
s[:m]|从位置0到位置m-1处取得的字符串
len(s)|字符串s中的字节数
[]rune(s)|将字符串s转换为一个Unicode码点切片
len([]rune(s))|字符串s中字符的个数--可以使用更快的utf8.RuneCountInString()来代替
string(chars)|将一个[]rune或者[]int32转换成字符串，这里假设rune和int32切片都是Unicode码点
[]byte(s)|无副本地将字符串s转换成一个原始字节的切片数组，不保证转换的字节是合法的UTF-8编码字节
string(bytes)|无副本地将[]byte或者[]uint8转换成一个字符串类型，不保证转换的字节是合法的UTF-8编码字节
string(i)|将任意数字类型i转换成字符串，假设i是一个Unicode码点。例如，如果i是65，那么其返回值为“A”
strconv.Itoa(i)|int类型i的字符串表示和一个错误值。例如，如果i的值是65，那么该返回值为("65", nil)
fmt.Sprint(x)|任意类型x的字符串表示，例如，如果x是一个值为65的整型类型，那么该返回值为"65"
### 2. 比较字符串
Go语言字符串支持常规的比较操作（<， <=， ==， !=， >=）。这些比较操作符在内存中一个字节一个字节地比较字符串。比较操作可以直接使用，如比较两个字符串的相等性，也可以间接使用，例如在排序[]string时使用<操作符来比较字符串。遗憾的是，执行比较操作可能会产生3个问题。这3个问题困扰每种使用Unicode字符串的编程语言，而不局限于Go语言。
- 第一个问题是，有些Unicode编码的字符可以用两个或者多个不同的字节序列来表示。
- 第二个问题是，有些情况下洪湖可能会希望吧不同的字符看成是相同的。
- 第三个问题是，有些字符的排序是与（自然）语言相关的。
### 3. 字符与字符串
Go语言中，字符使用两种不同的方式（可以很容易地相互转换）来表示。一个单一的字符可以用一个单一的rune（或者int32）来表示。从现在开始，我们交替使用术语“字符”，“码点”，“Unicode字符”以及“Unicode码点”来表示保存在一个单一字符的rune（或者int32）.Go语言的字符串表示一个包含0个或多个字符序列的串。在一个字符串内部，每个字符都表示成一个或者多个UTF-8编码的字节。

我们可以使用Go语言的标准转换语法（string(char)）将一个字符转换成一个只包含单个字符的字符串。这里有个例子：
```
as := ""
for _, char := range []rune{'a', 0xE6, 0346, 230, '\xE6', '\u00E6'} {
    fmt.Printf("[0x%X '%c'], char, char)
    as += string(char)
}
```

**一个字符串可以使用语法chars := []rune(s)转换成一个rune（即码点）切片，其中s是一个字符串**。这在我们需要逐个字符解析字符串，同时需要在解析过程中能查看前一个或后一个字符时会有用。**相反的转换也同样简单，其语法为s := string(chars)**，其中chars的类型为[]rune或者[]int32，得到的s为字符串。这两个转换都不是无代价的，但这两个转换理论上都比较快。

连接字符串的三种方式：
1. 使用+=操作符，这不是一个很高效的方式
2. 使用strings.Join()方法将一个字符串切片中的所有字符串串联
3. 使用Buffer，类似Java中的StringBuilder：
```
var buffer bytes.Buffer
for {
    if piece, ok := getNextValidString(); ok {
        buffers.WriteString(piece)
    } else {
        break
    }
}
fmt.Print(buffer.String(), "\n"))
```
### 4. 字符串索引与切片
Go语言支持Python中字符串分割语法的一个子集，而且这个语法可以用于任意类型的切片。由于Go语言的字符串将其文本保存为UTF-8编码的字节，因此我们必须非常小心地只在字符边界处进行切片。有个能够确定按字符边界进行切片得到索引位置的方法是，使用Go语言的strings包中的函数如strings.Index()或者strings.LastIndex()。下图给出了Unicode字符，码点，字节以及一些合法的索引位置和一对切片：

// TODO: add the picture
### 5. 使用fmt包来格式化字符串
Go语言标准库中的fmt包提供了打印函数将数据以字符串形式输出到控制台，文件，其它满足io.Writer接口的值以及其它字符串中。

语法|含义/结果
--|--
fmt.Errorf(format, args...)|返回一个包含给定的格式化字符串以及args参数的错误值
fmt.Fprint(writer, args...)|按照格式%v和空格分割的非字符串将args写入writer中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Fprintf(writer, format, args...)|按照字符串格式format将args写入writer中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Fprintln(writer, args...)|按照格式%v以空格分割以换行结尾将参数args写入writer中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Print(args...)|按照格式%v和空格分割的非字符串将args写入os.Stdout中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Printf(format, args...)|按照字符串格式format将args写入os.Stdout中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Println(args...)|按照格式%v以空格分割以换行结尾将参数args写入os.Stdout中，返回写入的字节数和一个值为error或者nil的错误值
fmt.Sprint(args...)|按照格式%v和空格分割的非字符串返回由args组成的字符串
fmt.Sprintf(format, args...)|返回使用格式format格式化的args字符串
fmt.Println(args...)|返回使用格式%v格式化args后的字符串，以空格分隔以换行结尾

fmt包也提供了一系列扫描函数（如fmt.Scan()、fmt.Scanf()以及fmt.Scanln()函数）用于从控制台、文件以及其它字符串类型中读取数据。扫描函数的一种替代是使用strings.Fields()函数将字符串分隔为若干字段然后使用strconv包中的转换函数将那些非字符串的字段转换为相应的值（如数值）。

用于fmt.Errorf()，fmt.Printf()，fmt.Fprintf()以及fmt.Sprintf()函数的格式化字符串包含一个或多个格式指令，这些格式指令的形式是%ML，其中M表示一个或者多个可选的格式指令修饰符，而L则表示一个特定的格式指令字符。

**fmt包中的格式指令**

格式指令|含义/结果
--|--
%%|一个%字面量
%b|一个二进制整数（基数为2），或者是一个（高级的）用科学计数法表示的指数为2的浮点数
%c|一个Unicode字符的码点值
%d|一个十进制整数（基数为10）
%e|以科学计数法e表示的浮点数或者复数值
%E|以科学计数法E表示的浮点数或者复数值
%f|以标准计数法表示的浮点数或者复数值
%g|以%e或者%f表示的浮点数或者复数，任何一个都以最为紧凑的方式输出
%G|以%E或者%f表示的浮点数或者复数，任何一个都以最为紧凑的方式输出
%o|一个以八进制表示的数字（基数为8）
%p|以16进制（基数为16）表示的一个值的地址，前缀为0x，字母使用小写的a~f表示（用于调试）
%q|使用Go语法以及必要时使用转义，以双引号括起来的字符串或者字节切片[]byte,或者是以单引号括起来的数字。
%s|以原生的UTF-8字节表示的字符串或者[]byte切片，对于一个给定的文本文件或者在一个能够显示UTF-8编码的控制台，它会产生正确的Unicode输出。
%t|以true或false输出的布尔值
%T|使用Go语法输出的值的类型
%U|一个用Unicode表示法表示的整型码点，默认值为4个数字字符。例如，fmt.Printf("%U", '|')输出U+00B6
%v|使用默认格式输出的内置或自定义类型的值，或者使用其类型的Sting()方法输出的自定义值，如果该方法存在的话
%x|以16进制表示的整型值（基数为16），或者以十六进制数字表示的字符串或者[]byte数组（单个字节用两个数字表示），数字a~f使用小协表示
%X|以16进制表示的整型值（基数为16），或者以十六进制数字表示的字符串或者[]byte数组（单个字节用两个数字表示），数字A~F使用小协表示

**fmt包中的格式指令修饰符**

修饰符|含义/结果
--|--
空白|如果输出的数字为负数，则在其前面加上一个”-“。如果输出的是一个正数，则在其前面加上一个空格。使用%x或者%X格式指令输出时，会在结果之间添加一个空格，例如，fmt.Printf("% X", "<-")输出E2 86 92
#|让格式化以另外一种格式输出数据：%#o输出以0打头的八进制数据；%#p输出一个不含0x打头的指针；%#q尽可能以原始字符串的形式输出一个字符串或者[]byte切片（使用反引号），否则输出以双引号引起来的字符串；%#v使用Go语法啊将值自身输出；%#x输出以0x大头的16进制数；%#X输出以0X大头的16进制数
+|让格式指令在数值前面输出+号或者-号，为字符串输出ASCII字符（别的字符会转义），为结构体输出其字段名字
-|让格式指令将值进行向左对齐（默认值为向右对齐）
0|让格式指令以数字0而非空白符进行填充
n.m|对于数字，这个修饰符会使用n（int值）个字符输出浮点数或者复数（为避免截断可以输出更多个），并在小数点后面输出m（int值）个数字。对于字符串，n声明了其最小宽度，并且如果字符串的字符太少则会以空格填充，而.m则声明了输出的字符串所能使用的最长字符个数（从左至右），如果太长则可能会导致字符串被截断。吗和n两个都可以使用'*'来代替，这种情况下它们的值就可以从参数中获取。n或者m都可以被忽略
#### 5.1 格式化布尔值
布尔值使用%t（真值，truth value）格式指令来输出：
```
fmt.Printf("%t %t\n", true, false)
```
如果我们想以数值的形式输出布尔值，那么我们必须做这样的转换
```
func IntForBool(b bool) int {
    if b {
        return 1
    } else {
        return 0
    }
}
fmt.Printf("%d %d\n", IntForBool(true), IntForBool(false))
```
#### 5.2 格式化整数
**二进制输出**
```
fmt.Printf("|%b|%9b|%-9b|%09b|% 9b|\n", 37, 37, 37, 37, 37)
|100101|   100101|100101   |000100101|   100101|
```

**八进制输出**
```
fmt.Printf("|%o|%#o|%# 8o|%+ 8o|%+08o|\n", 41, 41, 41, 41, -41)
|51|051|     051|    +051| -0000051|
```

**十六进制输出**
```
i：= 3931
fmt.Printf("|%x|%X|%8x|%08x|%#04X|0x%04X|\n", i, i, i, i, i, i)
|f5b|F5B|     f5b|00000f5b|0X0F5B|0x0F5B|
```

**十进制输出**
```
i：= 569
fmt.Printf("|$%d|$%06d|$%+06d|$%s|\n", i, i, i, Pad(i, 6, '*'))
|$569|$000569|$+00569|$***569|

func Pad(number, width int, pad rune) string {
    s := fmt.Sprint(number)
    gap := width - utf8.RuneCountInString(s)
    if gap > 0 {
        return strings.Repeat(string(pad), gap) + s
    }
    return s
}
```
#### 5.3 格式化字符
Go语言的字符都是rune（即int32）值，它们可以以数字或Unicode字符（%c）的形式输出。

```
fmt.Printf(%d %#04x %U '%c'\n", 0x3A6, 934, '\u03a6', '\U000003A6')
```

注意这里我们使用%U格式指令输出Unicode码点，使用%从格式指令来输出Unicode字符。
#### 5.4 格式化浮点数
浮点数格式化可以指定整体长度，小数位数，以及使用标准计数法还是科学计数法。
```
for _, x := range []float{-.258, 7194.84, -60897162.0218, 1.500089e-8} {
    fmt.Printf(|%20.5e|%20.5f|\n", x, x)
}

|           -2.58000e-1|                    -0.25800|
|         7.19484e+03|              7194.84000|
|        -6.08972e+07|  -60897162.02180|
|          1.50009e-08|                     0.00000|
```
#### 5.5 格式化字符串和切片
字符串输出时可以指定一个最小宽度（如果字符串太短，打印函数会以空格填充）或者一个最大输出字符数（会将太长的字符串截断）。字符串可以以Unicode编码（即字符），一个码点序列（即rune）或者表示它们的UTF-8字节码的形式输出。
```
slogan := "End (⊙o⊙)…attl“
fmt.Printf("%s\n%q\n%+q\n%#q\n", slogan, slogan, slogan, slogan)
```
%s格式指令用于输出字符串，%q（引用字符串）格式指令用于以Go语言的双引号形式输出字符串，其中会直接将可打印字符的可打印字面量输出，而其它不可打印字符则使用转义的形式输出。如果使用了+号修饰符，那么只有ASCII字符（从U+0020到U+007E）会直接输出，而其它字符则以转义的形式输出。如果使用了#修饰符，那么只要在可能的情况下就会输出Go原始字符串，否则输出以双引号引用的字符串。

虽然通常与一个格式指令相对应的变量是一个兼容类型的单一值（比如int型值相对应的%d或者%x），该变量可以是一个切片数组或者一个映射，如果该映射的键与值与该格式指令是兼容的（比如都是字符串或者数字）。
```
chars := []rune(slogan)
fmt.Printf("%x\n%#x\n%#X\n", chars, chars, chars)
```
#### 5.6 为调试格式化
%T(类型)格式指令用于打印一个内置的或者自定义值的类型，而%v格式指令则用于打印一个内置值的值。事实上，%v也可以打印自定义类型的值，对于没有定义String()方法的值使用其默认格式，对于定义了String()方法的值则使用该方法打印。**与%v一起使用可选的格式化指令修饰符#只对结构体类型起作用，这使得结构体输出它们的类型名字和字段名字**。
### 6. 其它字符串处理相关的包
#### 6.1 strings包
> 变量s和t都是字符串类型，xs则是字符串切片，i是int型，f是一个签名为func(rune)bool的函数引用。索引位置是指匹配Unicode码点或者字符串的第一个UTF-8字节的位置，如果没有找到匹配的字符串则为-1.

语法|含义/结果
--|--
strings.Contains(s, t)|如果t在s中则返回true
strings.Count(s, t)|t在s中出现了多少次
strings.EqualFold(s, t)|如果字符串相等的话则返回true，注意此函数比较时是区分大小写的
strings.Fields(s)|在字符串空白处进行切分，返回字符串切片
strings.FieldsFunc(s, f)|按照f的返回结果进行切分，如果f返回true，则在那个字符上进行切分
strings.HasPrefix(s, t)|如果字符串s是以t开头的则返回true
strings.HasSuffix(s, t)|如果字符串s是以t结尾的则返回true
strings.Index(s, t)|t在s中第一次出现的索引位置
strings.IndexAny(s, t)|s中第一个出在t中的字符的索引位置
strings.IndexFunc(s, f)|s中第一次令f函数返回true的字符的索引位置
strings.IndexRune(s, char)|返回字符char在s中第一次出现的索引位置
strings.Join(xs, t)|将xs中的所有字符串按照t分隔符进行合并（t可能为""）
strings.LastIndex(s, t)|t在s中最后一次出现的索引位置
strings.LastIndexAny(s, t)|s中最后一个出在t中的字符的索引位置
strings.LastIndexFunc(s, f)|s中最后一次令f函数返回true的字符的索引位置
strings.Map(mf, t)|按照mf函数规则（func(rune)rune）替换t中所有的字符
strings.NewReader(s)|创建一个字符串s的对象，支持Read()，ReadByte()和ReadRune()方法
strings.NewReplacer(...)|创建一个替换器能够处理多对旧新字符串的替换
strings.Repeat(s, i)|重复i次字符串s
strings.Replace(s, old, new, i)|返回一个新的字符串，对s中的旧的非重叠字符串用新的字符串进行替换，执行i次替换操作。如果i=-1则全部替换
strings.Split(s, t)|返回一个新的字符串切片，在源s上所有出现t的位置进行切分
strings.SplitAfter(s, t)|同上，但是保留分隔符
strings.SplitAfterN(s, t)|同上，但是只进行前i次分割操作
strings.SplitN(s, t, i)|同strings.Split(s, t)，但是只执行前i次分割操作
strings.Title(s)|返回一个新的字符串，对原字符串中每一个单词进行标题首字母大写处理
strings.ToLower(s)|返回一个新的字符串，对原s进行字母小写转换
strings.ToLowerSpecial(r, s)|返回一个新的字符串，按照指定的优先规则对原s中的相应的Unicode字符进行小写转换
strings.ToTitle(s)|返回一个新的字符串，对原字符串是s进行标题格式转换
strings.ToTitleSpecial(r, s)|返回一个新的字符串，对原s按照指定的优先规则r进行标题格式转换
strings.ToUpper(s)|返回一个新的字符串，对原s进行字母大写转换
strings.ToUpperSpecial(r, s)|返回一个新的字符串，按照指定的优先规则对原s中的相应的Unicode字符进行大写转换
strings.Trim(s, t)|返回一个新的字符串，从s两端过滤掉t
strings.TrimFunc(s, f)|返回一个新的字符串，从s两端过滤掉f返回true的每一个字符
strings.TrimLeft(s, t)|返回一个新的字符串，从s左边开始过滤掉t
strings.TrimLeftFunc(s, f)|返回一个新的字符串，从s左边开始过滤掉f返回true的每一个字符
strings.TrimRight(s, t)|返回一个新的字符串，从s右边开始过滤掉t
strings.TrimRightFunc(s, f)|返回一个新的字符串，从s右边开始过滤掉f返回true的每一个字符
strings.TrimSpace(s)|返回一个新的字符串，从s两端过滤掉空格
#### 6.2 strconv包
> strconv包提供了许多可以在字符串和其它类型之间进行转换的函数。参数bs是一个[]byte切片，base是一个进制单位（2 ～ 36），bits是指其结果必须满足的比位数（对于int型的数据而言，可以是8， 16， 32， 64或者0 ，对于float64型的数据而言，可能使32或64），而s是一个字符串。

> **所有的strconv转换函数返回一个结果和error变量，如果转换成功的话error为nil**。

语法|含义/结果
--|--
strconv.AppendBool(bs, b)|根据布尔变量b的值，在bs后追加”true“或者”false“字符
strconv.AppendFloat(bs, f, fmt, prec, bits)|在bs后面追加浮点数f，其它参数请参考strconv.Format.Float()函数
strconv.AppendInt(bs, i, base)|根据base指定的进制在bs后面追加int64数字
strconv.AppendQuote(bs, s)|使用strconv.Quote()追加s到bs后面
strconv.AppendQuoteRune(bs, char)|使用strconv.QuoteRune(char)追加char到bs后面
strconv.AppendQuoteRuneToASCII(bs, char)|使用strconv.QuoteRuneToASCII(char)追加char到bs后面
strconv.AppendQuoteToASCII(bs, s)|使用strconv.QuoteToASCII()追加s到bs后面
strconv.AppendUint(bs, u, base)|根据base指定的进制在bs后面追加uint64数字
strconv.Atoi(s)|返回转换后的int类型值和一个error（出错时error不为空），可参考strconv.ParseInt()
strconv.CanBackquote(s)|检查s是否是一个符合Go语言语法的字符串常量，s中不能出现反引号
strconv.FormatBool(tr)|格式化布尔变量tr，返回”true“或”false“字符串
strconv.FormatFloat(f, fmt, prec, bits))|将浮点数f格式化成字符串，fmt是格式化动作，bits通常是64
strconv.FormatInt(i, base)|将整数i以base指定进制形式格式化成字符串
strconv.FormatUint(u, base)|将整数u以base指定进制形式格式化成字符串
strconv.IsPrint(c)|判断c是否为可打印字符
strconv..Itoa(i)|将十进制整数i转换成字符串，可参考strconv.FormatInt()
strconv.ParseBool(s)|如果s是"1"，"t"，"T"，"true"，"TRUE"则返回true和nil；如果s是"0"，"f"， "F"，"false"，"False"或"FALSE"则返回false和nil；否则返回false和一个error
strconv..ParseFloat(s, bits)|如果s能够转换成浮点数，则返回一个float64类型的值和nill；否则返回0和error。bits应该是64，但如果想转换成float32的话也可设置为32
strconv.ParseInt(s, base, bits)|如果s能够转换成整数，则返回一个int64类型的值和nill；否则返回0和error。如果base为0，则表示要从s中判断进制的大小（字符串开头是"0x"或者"0X"表示这是16进制的；开头只有"0"表示8进制；否则其它的都是10进制），或者在base中指定进制的大小（2~36）。如果需要转换成int的话bits应该为0，否则将会转换成带有长度的整型（如bits为16会转换成int16）
strconv.ParseUint(s, base, bits)|同上，唯一不同的是转换成无符号整数
strconv.Quote(s)|使用Go语言双引号字符串语法形式来表示一个字符串
strconv.QuoteRune(char)|使用Go语言单引号字符语法来表示一个rune类型的Unicode码字符
strconv.QuoteRuneToASCII(char)|同上，但对于非ASCII码字符进行转义
strconv.QuoteToASCII(s)|同strconv.Quote()，但对于非ASCII码字符进行转义
strconv..Unquote(s)|对于一个用Go语法如单引号、双引号、反引号等表示的字符或字符串，返回引号中的字符串和一个error值
strconv.UnquoteChar(s, b)|对引用字符串s的第一个字符或字节解码，返回4个值：一个rune（第一个字符），一个bool（表示第一个字符的UTF-8表示需要多个字节），一个string（剩下的字符串）以及一个error。如果b被设置为一个单引号或者双引号，那么引号必须要被转义
#### 6.3 utf8包
> unicode/utf8包中的函数主要用来查询和操作UTF-8编码的字符串或者字节切片。使用utf8包里的函数需要在程序中导入“unicode/utf”，变量b是一个[]byte类型的切片，s是字符串，c是一个rune类型的Unicode码点。

语法|含义/结果
--|--
utf8.DecodeLastRune(b)|返回b中最后一个rune和它占用的字节数，或者U+FFFD（Unicode替换字符？）和0，如果b的最后一个rune是非法的
utf8.DecodeLastRuneInString(s)|同上，但它输入的是字符串
utf8.DecodeRune(b)|返回b中第一个rune和它占用的字节数，或者U+FFFD（Unicode替换字符？）和0，如果b的第一个rune是非法的
utf8.DecodeRuneInString(s)|同上，但它输入的是字符串
utf8.EncodeRune(b, c)|将c作为一个UTF-8字符并返回写入的字节数（b必须有足够的存储空间）
utf8.FullRune(b)|如果b的第一个rune是UTF-8编码的话，返回true
utf8.FullRuneInString(s)|如果s的第一个rune是UTF-8编码的话，返回true
utf8.RuneCount(b)|返回b的rune个数，如果存在非ASCII字符的话这个只可能小于len(s)
utf8.RuneCountInString(s)|同上，但它输入的是字符串
utf8.RuneLen(c)|对c进行编码所需的字节数
utf8.RuneStart(x)|如果x可以作为rune的第一个字节的话，返回true
utf8.Valid(b)|如果b中的字节能正确表示一个UTF-8字符串，返回true
utf8.ValidString(s)|如果s中的字节能正确表示一个UTF-8字符串，返回true
#### 6.4 unicode包
> unicode包主要提供了一些用来检查Unicode码点是否符合主要标准的函数。 例如，判断一个字符是否是一个数字或者小写字母。
> 变量c是一个rune类型变量，表示一个Unicode码点。

语法|含义/结果
--|--
unicode.Is(table, c)|如果c在table中，返回true
unicode.IsControl(c)|如果c是一个控制字符，返回true
unicode.IsDigit(c)|如果c是一个十进制数字，返回true
unicode.IsGraphic(c)|如果c是一个“图形”字符，如字母，数字，标记，符号或者空格则返回true
unicode.IsLetter(c)|如果c是一个字母，返回true
unicode.IsLower(c)|如果c是一个小写字母，返回true
unicode.IsMark(c)|如果c是一个标记，返回true
unicode.IsOneOf(tables, c)|如果c在tables中的任何一个table中，返回true
unicode.IsPrint(c)|如果c是一个可打印字符，返回true
unicode.IsPunct(c)|如果c是一个标点符号，返回true
unicode.IsSpace(c)|如果c是一个空格，返回true
unicode.IsSymbol(c)|如果c是一个符号，返回true
unicode.IsTitle(c)|如果c是一个标题大写字符，返回true
unicode.IsUpper(c)|如果c是一个大写字符，返回true
unicode.SimpleFold(c)|在与c的码点等价的码点集中，该方法返回最小的大于等于c的码点；否者如果不存在与此等价的码点集，则返回的是最小的大于等于0的码点
unicode.To(case, c)|字符c的case版本，其中case可以使unicode.LowerCase、unicode.TitleCase或者inicode.UpperCase
unicode.ToLower(c)|返回字符c的小写形式
unicode.ToTitle(c)|返回字符c的标题形式
unicode.ToUpper(c)|返回字符c的大写形式
#### 6.5 regexp包
> regexp包是Russ Cox的RE2正则表达式的Go语言实现。这个引擎非常快而且是线程安全的。RE2引擎并不使用回溯，所以能够保证线性的执行时间O(n)，n是匹配字符串的长度。

**regexp包函数列表**
> 变量p和s都是字符串类型，p表示正则匹配的模式。

语法|含义/结果
--|--
regexp.Match(p, b)|如果[]byte类型的b和模式p匹配，返回true和nil
regexp.MatchReader(p, r)|如果从r中读取的数据和模式p匹配，返回true和nil，r是一个io.RuneReader
regexp.MatchString(p, s)|如果s和模式p匹配，返回true和nil
regexp.QuoteMeta(s)|用引号安全地括起来的与正则表达式元字符相匹配的字符串
regexp.Compile(p)|如果模式p编译成功，返回一个*regexp.Regexp和nil
regexp.CompilePOSIX(p)|如果模式p编译成功，返回一个*regexp.Regexp和nil
regexp.MustCompile(p)|如果模式p编译成功，返回一个*regexp.Regexp，否则发生异常
regexp.MustCompilePOSIX(p)|如果模式p编译成功，返回一个*regexp.Regexp，否则发生异常

**regexp包支持的转移符号**

语法|含义/结果
--|--
\c|原生字符c，例如\*表示 *是一个原生字符而不是一个量词
\000|表示一个八进制的码点
\xHH|表示指定的两个数字是十六进制
\x{HHHH}|表示给定的1~6个数字是十六进制的
\a|ASCII的响铃字符，等于\007
\f|ASCII的响铃字符，等于\014
\n|ASCII的换行符，等于\012
\r|ASCII的回车符，等于\015
\t|ASCII的制表符，等于\011
\v|ASCII的垂直制表符，等于\013
\Q...\E|原生匹配...中的所有字符即使它包含*

**regexp包支持的字符类**

语法|含义/结果
--|--