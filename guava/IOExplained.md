## I/O工具
### 1. 字节流和字符流（ByteStreams and CharStreams）
Guava使用术语”流” 来表示可关闭的，并且在底层资源中有位置状态的I/O数据流。术语”字节流”指的是InputStream或OutputStream，”字符流”指的是Reader 或Writer（虽然他们的接口Readable 和Appendable被更多地用于方法参数）。相应的工具方法分别在[ByteStreams](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteStreams.html) 和[CharStreams](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharStreams.html)中。

大多数Guava流工具一次处理一个完整的流，并且/或者为了效率自己处理缓冲。还要注意到，接受流为参数的Guava方法不会关闭这个流：关闭流的职责通常属于打开流的代码块。

其中的一些工具方法列举如下：

ByteStreams|CharStreams
--------|--------
[byte[] toByteArray(InputStream)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteStreams.html#toByteArray-java.io.InputStream-)|[String toString(Readable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharStreams.html#toString-java.lang.Readable-)
N/A|[List<String> readLines(Readable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharStreams.html#readLines-java.lang.Readable-)
[long copy(InputStream, OutputStream)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteStreams.html#copy-java.io.InputStream-java.io.OutputStream-)|[long copy(Readable, Appendable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharStreams.html#copy-java.lang.Readable-java.lang.Appendable-)
[void readFully(InputStream, byte[])](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteStreams.html#readFully-java.io.InputStream-byte:A-)|N/A
[void skipFully(InputStream, long)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteStreams.html#skipFully-java.io.InputStream-long-)|[void skipFully(Reader, long)](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/io/CharStreams.html#skipFully(java.io.Reader,%20long))
[OutputStream nullOutputStream()](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/io/ByteStreams.html#nullOutputStream())|[Writer nullWriter()](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/io/CharStreams.html#nullWriter())

> 关于InputSupplier 和OutputSupplier要注意：
> 
> 在ByteStreams、CharStreams以及com.google.common.io包中的一些其他类中，某些方法仍然在使InputSupplier和OutputSupplier接口。这两个借口和相关的方法是不推荐使用的：它们已经被下面描述的source和sink类型取代了，并且最终会被移除。
### 2. 源与汇（Sources and sinks）
通常我们都会创建I/O工具方法，这样可以避免在做基础运算时总是直接和流打交道。例如，Guava有Files.toByteArray(File) 和Files.write(File, byte[] )。然而，流工具方法的创建经常最终导致散落各处的相似方法，每个方法读取不同类型的源或写入不同类型的汇\[sink\]。例如，Guava中的Resources.toByteArray(URL)和Files.toByteArray(File)做了同样的事情，只不过数据源一个是URL，一个是文件。

为了解决这个问题，Guava有一系列关于源与汇的抽象。源或汇指某个你知道如何从中打开流的资源，比如File或URL。源是可读的，汇是可写的。此外，源与汇按照字节和字符划分类型。

操作|字节|字符
--------|--------|--------
读|[ByteSource](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html)|[CharSource](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html)
写|[ByteSink](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSink.html)|[CharSink](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSink.html)

源与汇API的好处是它们提供了通用的一组操作。比如，一旦你把数据源包装成了ByteSource，无论它原先的类型是什么，你都得到了一组按字节操作的方法。
#### 2.1 创建源与汇
Guava提供了若干源与汇的实现：

字节|字符
--------|--------
[Files.asByteSource(File)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#asByteSource-java.io.File-)|[Files.asCharSource(File, Charset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#asCharSource-java.io.File-java.nio.charset.Charset-)
[Files.asByteSink(File, FileWriteMode...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#asByteSink-java.io.File-com.google.common.io.FileWriteMode...-)|[Files.asCharSink(File, Charset, FileWriteMode...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#asCharSink-java.io.File-java.nio.charset.Charset-com.google.common.io.FileWriteMode...-)
[MoreFiles.asByteSource(Path, OpenOption...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/MoreFiles.html#asByteSource-java.nio.file.Path-java.nio.file.OpenOption...-)|[MoreFiles.asCharSource(Path, Charset, OpenOption...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/MoreFiles.html#asCharSource-java.nio.file.Path-java.nio.charset.Charset-java.nio.file.OpenOption...-)
[MoreFiles.asByteSink(Path, OpenOption...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/MoreFiles.html#asByteSink-java.nio.file.Path-java.nio.file.OpenOption...-)|[MoreFiles.asCharSink(Path, Charset, OpenOption...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/MoreFiles.html#asCharSink-java.nio.file.Path-java.nio.charset.Charset-java.nio.file.OpenOption...-)
[Resources.asByteSource(URL)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Resources.html#asByteSource-java.net.URL-)|[Resources.asCharSource(URL, Charset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Resources.html#asCharSource-java.net.URL-java.nio.charset.Charset-)
[ByteSource.wrap(byte\[\])](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#wrap-byte:A-)|[CharSource.wrap(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#wrap-java.lang.CharSequence-)
[ByteSource.concat(ByteSource...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#concat-com.google.common.io.ByteSource...-)|[CharSource.concat(CharSource...)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#concat-com.google.common.io.CharSource...-)
[ByteSource.slice(long, long)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#slice-long-long-)|N/A
[CharSource.asByteSource(Charset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#asByteSource-java.nio.charset.Charset-)|[ByteSource.asCharSource(Charset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#asCharSource-java.nio.charset.Charset-)
N/A|[ByteSink.asCharSink(Charset)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSink.html#asCharSink-java.nio.charset.Charset-)

此外，你也可以继承这些类，以创建新的实现。

> **注意**：把已经打开的流（比如InputStream）包装为源或汇听起来是很有诱惑力的，但是应该避免这样做。源与汇的实现应该在每次openStream()方法被调用时都创建一个新的流。始终创建新的流可以让源或汇管理流的整个生命周期，并且让多次调用openStream()返回的流都是可用的。此外，如果你在创建源或汇之前创建了流，你不得不在异常的时候自己保证关闭流，这压根就违背了发挥源与汇API优点的初衷。
#### 2.2 使用源与汇
一旦有了源与汇的实例，就可以进行若干读写操作。
##### 2.2.1 通用操作
所有源与汇都有一些方法用于打开新的流用于读或写。默认情况下，其他源与汇操作都是先用这些方法打开流，然后做一些读或写，最后保证流被正确地关闭了。这些方法列举如下：
- openStream()：根据源与汇的类型，返回InputStream、OutputStream、Reader或者Writer。
- openBufferedStream()：根据源与汇的类型，返回InputStream、OutputStream、BufferedReader或者BufferedWriter。返回的流保证在必要情况下做了缓冲。例如，从字节数组读数据的源就没有必要再在内存中作缓冲，这就是为什么该方法针对字节源不返回BufferedInputStream。字符源属于例外情况，它一定返回BufferedReader，因为BufferedReader中才有readLine()方法。
##### 2.2.2 源操作
字节源|字符源
--------|--------
[byte[]   read()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#read--)|[String   read()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#read--)
N/A|[ImmutableList<String>   readLines()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#readLines--)
N/A|[String   readFirstLine()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#readFirstLine--)
[long   copyTo(ByteSink)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#copyTo-com.google.common.io.ByteSink-)|[long   copyTo(CharSink)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#copyTo-com.google.common.io.CharSink-)
[long   copyTo(OutputStream)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#copyTo-java.io.OutputStream-)|[long   copyTo(Appendable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#copyTo-java.lang.Appendable-) 
[Optional<Long> sizeIfKnown()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#sizeIfKnown--)|[Optional<Long> lengthIfKnown()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#lengthIfKnown--)
[long   size()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#size--)|[long length()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#length--)
[boolean   isEmpty()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#isEmpty--)|[boolean   isEmpty()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSource.html#isEmpty--)
[boolean   contentEquals(ByteSource)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#contentEquals-com.google.common.io.ByteSource-)|N/A
[HashCode   hash(HashFunction)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSource.html#hash-com.google.common.hash.HashFunction-)|N/A
##### 2.2.3 汇操作
字节汇|字符汇
--------|--------
[void write(byte[])](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSink.html#write-byte:A-)|[void write(CharSequence)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSink.html#write-java.lang.CharSequence-)
[long writeFrom(InputStream)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/ByteSink.html#writeFrom-java.io.InputStream-)|[long writeFrom(Readable)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSink.html#writeFrom-java.lang.Readable-)
N/A|[void writeLines(Iterable<? extends CharSequence>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSink.html#writeLines-java.lang.Iterable-)
N/A|[void writeLines(Iterable<? extends CharSequence>, String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/CharSink.html#writeLines-java.lang.Iterable-java.lang.String-)
#### 2.3 范例
```
// Read the lines of a UTF-8 text file
ImmutableList<String> lines = Files.asCharSource(file, Charsets.UTF_8)
    .readLines();

// Count distinct word occurrences in a file
Multiset<String> wordOccurrences = HashMultiset.create(
    Splitter.on(CharMatcher.whitespace())
        .trimResults()
        .omitEmptyStrings()
        .split(Files.asCharSource(file, Charsets.UTF_8).read()));

// SHA-1 a file
HashCode hash = Files.asByteSource(file).hash(Hashing.sha1());

// Copy the data from a URL to a file
Resources.asByteSource(url).copyTo(Files.asByteSink(file));
```
### 3. 文件操作（Files）
除了创建文件源和文件的方法，Files类还包含了若干你可能感兴趣的便利方法。

方法|描述
--------|--------
[createParentDirs(File)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#createParentDirs-java.io.File-)|必要时为文件创建父目录
[getFileExtension(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#getFileExtension-java.lang.String-)|返回给定路径所表示文件的扩展名
[getNameWithoutExtension(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#getNameWithoutExtension-java.lang.String-)|返回去除了扩展名的文件名
[simplifyPath(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#simplifyPath-java.lang.String-)|规范文件路径，并不总是与文件系统一致，请仔细测试
[fileTreeTraverser()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/io/Files.html#fileTraverser--)|返回TreeTraverser用于遍历文件树

## Reference
- [IO Explained](https://github.com/google/guava/wiki/IOExplained)