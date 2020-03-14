## 原生类型
### 1. 概述
Java的原生类型就是指基本类型：byte、short、int、long、float、double、char和boolean。
> **注意**：在从Guava查找原生类型方法之前，可以先查查[Arrays](http://docs.oracle.com/javase/8/docs/api/java/util/Arrays.html)类，或者对应的基础类型包装类，如[Integer](http://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html)。

原生类型不能当作对象，也不能用作泛型的类型参数，这意味着许多通用工具都不能应用于它们。Guava提供了若干通用工具，包括与原生类型数组或集合API的交互，原生类型和字节数组的相互转换，以及对某些原生类型的无符号形式的支持。

原生类型|Guava工具类（都在com.google.common.primitives包）
--------------|----------------
byte|[Bytes](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Bytes.html), [SignedBytes](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/SignedBytes.html), [UnsignedBytes](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedBytes.html)
short|[Shorts](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Shorts.html)
int|[Ints](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInteger.html), [UnsignedInteger](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInteger.html), [UnsignedInts](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInts.html)
long|[Longs](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Longs.html), [UnsignedLong](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLong.html), [UnsignedLongs](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLongs.html)
float|[Floats](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Floats.html)
double|[Doubles](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Doubles.html)
char|[Chars](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Chars.html)
boolean|[Booleans](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/Booleans.html)

Bytes工具类没有定义任何区分有符号和无符号字节的方法，而是把它们都放到了SignedBytes和UnsignedBytes工具类中，因为字节类型的符号性比起其它类型要略微含糊一些。

int和long的无符号形式方法在UnsignedInts和UnsignedLongs类中，但由于这两个类型的大多数用法都是有符号的，Ints和Longs类按照有符号形式处理方法的输入参数。

此外，Guava为int和long的无符号形式提供了包装类，即UnsignedInteger和UnsignedLong，以帮助你使用类型系统，以极小的性能消耗对有符号和无符号值进行强制转换。

在本章下面描述的方法签名中，我们用Wrapper表示JDK包装类，prim表示原生类型。（Prims表示相应的Guava工具类。）
### 2. 原生类型数组工具
原生类型数组是处理原生类型集合的最有效方式（从内存和性能双方面考虑）。Guava为此提供了许多工具方法。

方法签名|描述|类似方法|可用性
-------|-------|-------|--------
List<Wrapper> asList(prim… backingArray)|把数组转为相应包装类的List|[Arrays.asList](http://docs.oracle.com/javase/8/docs/api/java/util/Arrays.html#asList-T...-)|符号无关*
prim[] toArray(Collection<Wrapper> collection)|把集合拷贝为数组，和collection.toArray()一样线程安全|[Collection.toArray()](http://docs.oracle.com/javase/8/docs/api/java/util/Collection.html#toArray--)|符号无关
prim[] concat(prim[]… arrays)|串联多个原生类型数组|[Iterables.concat](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Iterables.html#concat-java.lang.Iterable...-)|符号无关
boolean contains(prim[] array, prim target)|判断原生类型数组是否包含给定值|[Collection.contains](http://docs.oracle.com/javase/8/docs/api/java/util/Collection.html#contains-java.lang.Object-)|符号无关
int indexOf(prim[] array, prim target)|给定值在数组中首次出现处的索引，若不包含此值返回-1|[List.indexOf](http://docs.oracle.com/javase/8/docs/api/java/util/List.html#indexOf-java.lang.Object-)|符号无关
int lastIndexOf(prim[] array, prim target)|给定值在数组最后出现的索引，若不包含此值返回-1|[List.lastIndexOf](http://docs.oracle.com/javase/8/docs/api/java/util/List.html#lastIndexOf-java.lang.Object-)|符号无关
prim min(prim… array)|数组中最小的值|[Collections.min](http://docs.oracle.com/javase/8/docs/api/java/util/Collections.html#min-java.util.Collection-)|符号相关*
prim max(prim… array)|数组中最大的值|[Collections.max](http://docs.oracle.com/javase/8/docs/api/java/util/Collections.html#max-java.util.Collection-)|符号相关
String join(String separator, prim… array)|把数组用给定分隔符连接为字符串|[Joiner.on(separator).join](https://github.com/google/guava/wiki/StringsExplained#joiner)|符号相关
Comparator<prim[]>   lexicographicalComparator()|按字典序比较原生类型数组的Comparator|[Ordering.natural().lexicographical()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/collect/Ordering.html#lexicographical--)|符号相关

\*符号无关方法存在于Bytes, Shorts, Ints, Longs, Floats, Doubles, Chars, Booleans。而UnsignedInts, UnsignedLongs, SignedBytes, 或UnsignedBytes不存在。

\*\*符号相关方法存在于SignedBytes, UnsignedBytes, Shorts, Ints, Longs, Floats, Doubles, Chars, Booleans, UnsignedInts, UnsignedLongs。而Bytes不存在。
### 3. 通用工具方法
Guava为原生类型提供了若干JDK6没有的工具方法。但请注意，其中某些方法已经存在于JDK7中。

方法签名|描述|可用性
-------|-------|----------
int compare(prim a, prim b)|传统的Comparator.compare方法，但针对原生类型。JDK7的原生类型包装类也提供这样的方法|符号相关
prim checkedCast(long value)|把给定long值转为某一原生类型，若给定值不符合该原生类型，则抛出IllegalArgumentException|仅适用于符号相关的整型*
prim saturatedCast(long value)|把给定long值转为某一原生类型，若给定值不符合则使用最接近的原生类型值|仅适用于符号相关的整型

*这里的整型包括byte, short, int, long。不包括char, boolean, float, 或double。

> **注意**：com.google.common.math.DoubleMath提供了舍入double的方法，支持多种舍入模式。相见第12章的”[浮点数运算](https://github.com/google/guava/wiki/MathExplained)”。
### 4. 字节转换方法
Guava提供了若干方法，用来把原生类型按大尾数字节序与字节数组相互转换。所有这些方法都是符号无关的，此外Booleans没有提供任何下面的方法。

方法或字段签名|描述
--------|--------
int BYTES|常量：表示该原生类型需要的字节数
prim fromByteArray(byte[] bytes)|使用字节数组的前Prims.BYTES个字节，按大尾数字节序返回原生类型值；如果bytes.length <= Prims.BYTES，抛出IllegalArgumentException 
prim fromBytes(byte b1, …, byte bk)|接受Prims.BYTES个字节参数，按大尾数字节序返回原生类型值
byte[] toByteArray(prim value)|按大尾数字节序返回value的字节数组

### 5. 无符号支持
JDK原生类型包装类提供了针对有符号类型的方法，而UnsignedInts和UnsignedLongs工具类提供了相应的无符号通用方法。UnsignedInts和UnsignedLongs直接处理原生类型：使用时，由你自己保证只传入了无符号类型的值。

此外，对int和long，Guava提供了无符号包装类（[UnsignedInteger](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInteger.html)和[UnsignedLong](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLong.html)），来帮助你以极小的性能消耗，对有符号和无符号类型进行强制转换。
#### 5.1 无符号通用工具方法
JDK的原生类型包装类提供了有符号形式的类似方法。

方法签名|说明
--------|--------
[int UnsignedInts.parseUnsignedInt(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInts.html#parseUnsignedInt-java.lang.String-) [long UnsignedLongs.parseUnsignedLong(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLongs.html#parseUnsignedLong-java.lang.String-)|按无符号十进制解析字符串
[int UnsignedInts.parseUnsignedInt(String string, int radix)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInts.html#parseUnsignedInt-java.lang.String-int-)   [long UnsignedLongs.parseUnsignedLong(String string, int radix)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLongs.html#parseUnsignedLong-java.lang.String-int-)|按无符号的特定进制解析字符串
[String UnsignedInts.toString(int)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInts.html#toString-int-)  [String UnsignedLongs.toString(long)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLongs.html#toString-long-)|数字按无符号十进制转为字符串
[String UnsignedInts.toString(int value, int radix)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedInts.html#toString-int-int-) [String UnsignedLongs.toString(long value, int radix)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/primitives/UnsignedLongs.html#toString-long-int-)|数字按无符号特定进制转为字符串
#### 5.2 无符号包装类
无符号包装类包含了若干方法，让使用和转换更容易。

方法签名|说明
--------|--------
UnsignedPrim add(UnsignedPrim), subtract, multiply, divide, remainder|简单算术运算
UnsignedPrim valueOf(BigInteger)|按给定BigInteger返回无符号对象，若BigInteger为负或不匹配，抛出IAE
UnsignedPrim valueOf(long)|按给定long返回无符号对象，若long为负或不匹配，抛出IAE
UnsignedPrim asUnsigned(prim value)|把给定的值当作无符号类型。例如，UnsignedInteger.asUnsigned(1<<31)的值为231,尽管1<<31当作int时是负的
BigInteger bigIntegerValue()|用BigInteger返回该无符号对象的值
toString(),  toString(int radix)|返回无符号值的字符串表示

## Reference
- [Primitives Explained](https://github.com/google/guava/wiki/PrimitivesExplained)