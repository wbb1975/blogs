## Using JNA to Access Native Dynamic Libraries

### 1.简介

在这篇教程中，我们将看到入俄使用 `Java Native Access` 库（简称 JNA）来访问本地库而不需要编写任何 [JNI (Java Native Interface)](https://www.baeldung.com/jni) 代码。

### ２.为什么选择 JNA

许多年来 Java 和其它基于 JVM 的语言极大程度上尽力实现其“一次编写，到处运行”的目标。但是，有时候我们需要使用本地代码来实现某些功能。

- 复用遗留 C/C++ 代码或者能够创建本地服务的其它语言
- 访问对标准 Java 运行时不肯用的系统特定功能
- 对给定应用的特定部分优化速度及内存使用

最初，这种需求意味着我们不得不求助　JNI – Java Native Interface．虽然有效，这种方式也有缺陷，由于下面的问题应该避免使用：

- 需要开发者编写 C/C++　胶水代码来桥接 Java 和本地代码
- 需要每个目标平台的完整编译连接工具链
- 序列化／反序列化出入 JVM 的值是一个繁琐且容易出错的任务
- 混用 Java 及本地代码的法律及支持问题

JNA 能够解决使用 JNI 的大部分复杂性，尤其是不需要创建任何 JNI 代码既可以使用位于动态库中的本地代码，这使得整个过程更加简单。

当然，它需要一些权衡：

- 我们不能直接使用静态库
- 速度比使用手写 JNI 代码慢一些

但对大多数应用，JNA　的这种简化带来的收益已经超过了其不利之处．很公平地讲，除非我们有特别特殊的需求，今天 JNA 是从 Java 或其它基于 JVM 的语言中访问本地代码的最佳选择，

### ３.JNA 项目设置

使用 JNA 的第一件事情就是在项目 `pom.xml` 中添加依赖：

```
<dependency>
    <groupId>net.java.dev.jna</groupId>
    <artifactId>jna-platform</artifactId>
    <version>5.6.0</version>
</dependency>
```

[jna-platform](https://search.maven.org/search?q=g:net.java.dev.jna%20a:jna-platform) 的最新版本可以从 `Maven` 中央仓库下载。

### ４.使用 JNA

使用 JNA 需要两步：

- 首先，我们要创建一个扩展 JNA 库的 Java 接口以描述调用目标本地代码使用的方法及类型。
- 接下来，我们将该接口传给 JNA，它返回一个该接口的一个具体实现，我们可以用它来调用本地代码。

#### ４.1 调用 C 标准库中的方法

对我们的第一个示例，让我们使用 JNA 来调用 C 标准库的 [cosh](https://man7.org/linux/man-pages/man3/cosh.3.html)函数，它在大多数系统上都可用。该方法需要一个 double 参数并计算其 [hyperbolic cosine](https://en.wikipedia.org/wiki/Hyperbolic_functions)。一个 Ｃ 程序通过包含 `<math.h>` 即可使用该函数。

```
#include <math.h>
#include <stdio.h>
int main(int argc, char** argv) {
    double v = cosh(0.0);
    printf("Result: %f\n", v);
}
```

让我们创建一个 Java 接口来调用该方法：

```
public interface CMath extends Library { 
    double cosh(double value);
}
```

接下来，我们使用 JNA 的[本地类](https://java-native-access.github.io/jna/5.6.0/javadoc/com/sun/jna/Native.html)来创建该接口的一个具体实现，如此我们才能调用我们的 API：

```
CMath lib = Native.load(Platform.isWindows()?"msvcrt":"c", CMath.class);
double result = lib.cosh(0);
```

这里真正有趣的部分就是对 `load()` 方法的调用。它需要两个参数：动态库名字以及一个描述我们调用方法的 Java 接口。**它返回一个该接口的具体实现，允许我们调用接口的任何方法**。

现在动态库名字通常是依赖系统的，C 标准库也没有例外：在大部分基于 Linux 的系统中是 `libc.so`，Windows 是 `msvcrt.dll`。这就是我们使用　`Platform`　帮助类的原因所在，它被 JNA 包括以检查我们运行的平台并选择合适的库名字。

记住我们并不需要添加 `.so` 或 `.dll`　扩展名。对于基于 Linux 的系统我们不需要指定 “lib” 前缀－－这是共享库的标准。

**从 Java 观点看动态库行为模式就像一个单例，一个常见的实践就是添加一个 INSTANCE 字段作为接口声明的一部分**。

```
public interface CMath extends Library {
    CMath INSTANCE = Native.load(Platform.isWindows() ? "msvcrt" : "c", CMath.class);
    double cosh(double value);
}
```

#### ４.2 基本类型映射

在我们最初的例子中，我们仅仅使用了基本类型作为函数参数及返回值。当从 C 类型转换时，JNA 自动处理这些。通常使用 Java 的对等类型。

- char => byte
- short => short
- wchar_t => char
- int => int
- long => com.sun.jna.NativeLong
- long long => long
- float => float
- double => double
- char * => String

这里一个稍显奇怪的映射是原生　long　类型。这是因为在 `C/C++` 中，long 可以用 32-位 或 64-位值表示，取决于我们运行在 32-位 或 64-位系统上。

为了解决这个问题，JNA 提供了 `NativeLong` 类型，它提供了依赖于系统架构的合适类型。

#### ４.3 结构体和联合

一个常见的场景是处理原生代码 API，它期待某些指向结构体和联合的指针。当创建Java接口来访问它时，对应的参数和返回值类型必须是一个扩展自 `Structure` 或 `Union` 的 Java 类型。

例如，我们有如下的 C 结构体：

```
struct foo_t {
    int field1;
    int field2;
    char *field3;
};
```

它的对应 Java 类型如下：

```
@FieldOrder({"field1","field2","field3"})
public class FooType extends Structure {
    int field1;
    int field2;
    String field3;
};
```

JNA 需要 `@FieldOrder` 注解，如此它才能在传递实参到目标方法之前将其序列化至内存缓冲区。

可选地，我们可以覆盖 `getFieldOrder()` 方法以达到同样效果。当只有单一目标架构／平台时，前面的方法已经足够好。我们可以使用后者来处理跨平台对齐问题，这有时候需要添加某些额外的对齐填充字段。

Unions 以同样的方式工作，除了一些例外：

- 没有必要使用 `@FieldOrder` 注解，也不必实现 `getFieldOrder()`
- 我们必须在调用原生方法前调用 `setType()`

让我们用一个简单的例子来看看如何实现：

```
public class MyUnion extends Union {
    public String foo;
    public double bar;
};
```

现在，让我们以一个假设的库一起来使用 `MyUnion`：

```
MyUnion u = new MyUnion();
u.foo = "test";
u.setType(String.class);
lib.some_method(u);
```

如果 `foo` 和 `bar` 属于同一类型，我们不得不使用其名字作为替代：

```
u.foo = "test";
u.setType("foo");
lib.some_method(u);
```

#### ４.4 使用 指针

JNA 提供了一个 [Pointer](https://java-native-access.github.io/jna/5.6.0/javadoc/com/sun/jna/Pointer.html) 抽象来处理声明有无类型指针的API，特别是 `void *`。**这个类提供了对底层原生内存缓存的读写访问，这带有非常明显的风险**。

在开始使用这个类之前，我们必须确保我们清晰地理解了每次谁拥有指向的内存。如果你不能，那么将极易产生诸如内存泄漏，非法访问等极难调式的问题。

假设我们知道我们在做什么，让我们来看我们如何利用 JNA 来使用著名的 `malloc()` 和 `free()` 方法－－它们常被用来分配和释放内存。首先，让我们再次创建我们的包装接口：

```
public interface StdC extends Library {
    StdC INSTANCE = // ... instance creation omitted
    Pointer malloc(long n);
    void free(Pointer p);
}
```

现在，让我们使用它来分配一块缓存并使用它：

```
StdC lib = StdC.INSTANCE;
Pointer p = lib.malloc(1024);
p.setMemory(0l, 1024l, (byte) 0);
lib.free(p);
```

`setMemory()` 将利用一个常量值（本例为零）填充底层缓存。注意 Pointer 并不知道它底层指向什么，也不知道其大小。**这意味着我们很容易使用它的方法破坏我们的堆**。

稍后我们将看到如何利用 JNA 的崩溃保护特性来缓解此类错误。

#### ４.5 处理 Errors

旧版本的 C 标准库使用全局 `errno` 变量来存储特定调用失败的原因。例如，下面是一个典型的 C 语言中 `open()` 调用如何使用全局变量：

```
int fd = open("some path", O_RDONLY);
if (fd < 0) {
    printf("Open failed: errno=%d\n", errno);
    exit(1);
}
```

当然，在现代多线程应用中这段代码将不能工作。但是，归功于 C 的预处理器开发者仍可以向上面那样写代码，并且也能够正常工作。它证明了在今天 `errno` 是一个宏且被扩展成一个方法调用：

```
// ... excerpt from bits/errno.h on Linux
#define errno (*__errno_location ())

// ... excerpt from <errno.h> from Visual Studio
#define errno (*_errno())
```

现在，这种方式在编译代码时能够正常工作。但在使用 JNA 时没有此类功能。我们可以在我们的包装类中声明一个扩展方法并显式调用它，但 JNA 提供了一个更好的替代 [LastErrorException](https://java-native-access.github.io/jna/5.6.0/javadoc/com/sun/jna/LastErrorException.html)。

在包装接口中声明的任何方法如果带有 `throws LastErrorException` 声明将会自动在一个原生调用后添加一个 `error` 检测。如果它报告了一个错误，JNA 将抛出一个 `LastErrorException`，它包含了最初的错误码。

让我们添加一些方法到我们曾经使用过的 `StdC` 包装接口，并展示这个特性：

```
public interface StdC extends Library {
    // ... other methods omitted
    int open(String path, int flags) throws LastErrorException;
    int close(int fd) throws LastErrorException;
}
```

现在我们可以在一个 `try/catch` 语句中使用 `open()`：

```
StdC lib = StdC.INSTANCE;
int fd = 0;
try {
    fd = lib.open("/some/path",0);
    // ... use fd
}
catch (LastErrorException err) {
    // ... error handling
}
finally {
    if (fd > 0) {
       lib.close(fd);
    }
}
```

在这个 `catch` 块，我们可以使用 `LastErrorException.getErrorCode()` 老获取最初的错误码并使用它作为错误处理逻辑的一部分。

#### ４.6 处理访问违规

正如上面提到的，JNA 并不为我们误用一个给定的 API 提供保护，尤其是在与原生代码交互式传递的处理内存缓存。在正常情况下，此类错误导致访问非法并终止 JVM。

一定程度上，JNA 支持一个方法其允许 Java 代码来处理访问非法错误。有两种方法来激活它：

- 设置 `jna.protected` 系统属性为 `true`
- 调用 `Native.setProtected(true)`

一旦我们已经激活了保护模式，JNA 将捕捉访问非法错误，它通常会导致一个崩溃并抛出一个 `java.lang.Error` 异常。我们可以使用向一个用非法地址初始化过的 `Pointer` 写数据来验证保护模式已能工作：

```
Native.setProtected(true);
Pointer p = new Pointer(0l);
try {
    p.setMemory(0, 100*1024, (byte) 0);
}
catch (Error err) {
    // ... error handling omitted
}
```

**但是，正如文档所说，这个特性应仅仅用于调试／开发目的**。

### ５.结论

在本文中，我们展示了相比 JNI 如何使用 JNA 来更容易地访问本地代码。像平常一样，所有代码可以从 [GitHub](https://github.com/eugenp/tutorials/tree/master/java-native) 获取。

## Reference
- [Using JNA to Access Native Dynamic Libraries](https://www.baeldung.com/java-jna-dynamic-libraries)
- [Guide to JNI (Java Native Interface)](https://www.baeldung.com/jni)
- [Java Native Access: A Cleaner Alternative to JNI?](https://levelup.gitconnected.com/java-native-access-a-cleaner-alternative-to-jni-954b53b77398)