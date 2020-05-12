# Redis协议规范
Redis客户端与Redis服务器通过一个叫做RESP (REdis Serialization Protocol)（Redis序列化协议）的协议通讯。虽然这个协议是为Redis特别设计的，它也可用于其它CS架构软件项目。

RESP是下列目标的妥协产物：
- 容易实现
- 快速解析
- 人可阅读

RESP可以序列化不同的数据类型如整型，字符串，数组等。还有一个特殊的类型用于表示错误。请求从客户端被发送到Redis服务端的，它以字符串数组的形式表示了执行的命令的参数。Redis回复的数据类型与命令相关。

RESP是二进制安全的，并不需要从一个进程到另一个进程的款数据传输的额外处理--它使用前缀长度来传输块数据。
> **注意**：这里简单描述的协议仅仅用于CS架构通讯。Redis集群用一种不同的二进制协议在节点间交换消息。
## 网络层
一个连接到Redis服务器的Redis客户端事实上创建了一个到端口6379的TCP连接。虽然RESP技术上是TCP无关的，在Redis的背景下该协议仅仅用于TCP连接（或同等面向流的连接，如Unix套接字）。
## 请求-回复模型（Request-Response model）
Redis接受由不同参数组成的命令。一旦一条命令被收到，它就会被处理并发回一条回复给客户。

这可能是最简单的模式，但有两个例外：
- Redis支持流水线（pipeline）（本文后面还会谈到）。因此客户可以一次发送多条命令，并随后等待回复。
- 当一个Redis客户订阅了一个Pub/Sub通道，协议将改变语义并变成一个推送（push）协议，即客户不再需要发送请求，因为只要有新消息到达，服务器会自动发送给它们（只有客户端订阅了的通道才会收到）。

排除上面两个意外，Redis协议是一个简单的请求-回复协议。
## RESP协议描述
RESP协议在Redis 1.2中引入，但是直到Redis 2.0它才变成与Redis服务器交谈的标准方式。这是在你的Redis客户端必须实现的协议。

RESP实际上是一个序列化协议，它支持以下数据类型：简单字符串，错误，整型，块字符串（Bulk Strings）和数组。

RESP在Redis中以下面的方式被用作请求-回复协议：
- 客户端以RESP 块字符串（Bulk Strings）数组的形式发送命令到Redis服务器
- 服务器根据命令的实现以一种RESP类型回复

在RESP中，一些数据的类型取决于第一个字节：
+ 对于简单字符串，回复的第一个字节是"+"
+ 对于错误，回复的第一个字节是"-"
+ 对于整数，回复的第一个字节是":"
+ 对于块字符串（ **Bulk Strings**），回复的第一个字节是"$"
+ 对于数组，回复的第一个字节是"*"

另外RESP可以用后面描述的块字符串或数组的一个特殊变体来表示一个空（Null）值。在RESP中协议的不同部分总是以"\r\n" (CRLF)终结。
## RESP简单字符串
简单字符串以下面的形式编码：一个"+"，后面跟随不包含CR 和 LF的字符串（换行符不被允许），以回车换行符终结（"\r\n"）。

简单字符串用于以最小负荷传送非二进制安全的字符串。例如许多Redis命令在成功时仅仅返回"OK"，它以RESP简单字符串的形式编码为如下5个字节：
```
+OK\r\n
```
为了发送二进制安全字符串，RESP块字符串可以代替。
当Redis回复一个简单字符串，客户端库应该向调用者返回一个字符串包含从 '+' 后的第一个字符直到简单字符串结尾（排除最后的CRLF）。
## RESP错误
RESP对错误有一个特殊的数据类型。实际上错误几乎和RESP简单字符串一样，除了第一个字符是减号'-' 而不是加号。RESP中简单字符串和错误的真正差别在于错误在客户端被当做异常处理，并且组成错误类型的字符串是错误消息本身。

基本的格式为：
```
"-Error message\r\n"
```
只有当某种异常发生时错误回复才会被发送，比如你在错误数据类型上执行操作，或者命令不存在，等等。当一个错误回复收到时客户端库应该抛出一个异常。

下面是错误回复示例：
```
-ERR unknown command 'foobar'
-WRONGTYPE Operation against a key holding the wrong kind of value
```
"-"后的首个单词，直到第一个空格或换行符，代表了返回的错误类型。这只是Redis的一个使用惯例，并非RESP错误格式的一部分。

例如，ERR是一个通用的错误，而WRONGTYPE则为一个更特殊的错误--它暗示客户在一个错误的数据类型上执行操作。这被称为错误前缀（Error Prefix），是一种让客户理解服务器返回的错误类型的方式，不需要依赖确切的错误消息，毕竟消息可以随时间而改变。

一个客户端实现对不同的错误可能返回不同的异常，也可能提供一种通用的方式捕获错误，即将错误名以字符串的形式直接提供给调用者。

但是，这种特性不应该被认为是重要的，因为它很少使用，很少量的客户实现可能简单地返回一个通用错误条件，例如false。
## RESP整型（Integers）
这个类型使用一个由回车换行符（CRLF）终结的字符串来代表整型数，以字节":"开头。例如，":0\r\n"或":1000\r\n" 都是整形回复。

许多Redis命令返回RESP整型数，像[INCR](https://redis.io/commands/incr)， [LLEN](https://redis.io/commands/llen)和[LASTSAVE](https://redis.io/commands/lastsave)等。

对于返回的整型数没有什么特殊的意义，对于[INCR](https://redis.io/commands/incr)它仅仅是一个增加后的值，对[LASTSAVE](https://redis.io/commands/lastsave)它是一个UNIX时间。但是，返回的整数确保位于一个64位有符号整数的范围之内。

整形返回值可被扩展用于表示true或alse，比如对于命令[EXISTS](https://redis.io/commands/exists)或[SISMEMBER](https://redis.io/commands/sismember)将返回1代表true，返回0代表false。

其它命令像[SADD](https://redis.io/commands/sadd)，[SREM](https://redis.io/commands/srem)和[SETNX](https://redis.io/commands/setnx)都在操作成功时返回1，失败时返回0.

下面的命令将返回一个整形回复值：[SETNX](https://redis.io/commands/setnx)，[DEL](https://redis.io/commands/del)，[EXISTS](https://redis.io/commands/exists)，[INCR](https://redis.io/commands/incr)，[INCRBY](https://redis.io/commands/incrby)，[DECR](https://redis.io/commands/decr)，[DECRBY](https://redis.io/commands/decrby)，[DBSIZE](https://redis.io/commands/dbsize)，[LASTSAVE](https://redis.io/commands/lastsave)，[RENAMENX](https://redis.io/commands/renamenx)，[MOVE](https://redis.io/commands/move)，[LLEN](https://redis.io/commands/llen)，[SADD](https://redis.io/commands/sadd)，[SREM](https://redis.io/commands/srem)，[SISMEMBER](https://redis.io/commands/sismember)，[SCARD](https://redis.io/commands/scard)。
## RESP块字符串（Bulk Strings）
块字符串用于代表一个简单的二进制安全的字符串，最多512M字节长度。

块字符串用下面的方法编码：
- 一个"$" 符后跟代表字符串长度的字节数（前缀长度）加回车换行符
- 实际字符串数据
- 一个结束用换车换行符
一次一个字符串"foobar" i将会被编码为：
```
"$6\r\nfoobar\r\n"
```
一个空字符串将会被编码为：
```
"$0\r\n\r\n"
```
RESP块字符串也可用一种特殊格式来代表一个不存在的值--用于代表Null值。在这种特殊格式中，长度为-1，并且没有实际数据，因此一个Null被编码为：
```
"$-1\r\n"
```
这被称为Null块字符串。

当服务器回复一个Null块字符串时，客户端库API不应该返回一个空字符串，而应返回一个nil对象。例如，Ruby库应该返回 'nil'，C库应该返回NULL（或者在返回的对象上设立特殊标记）等。
## RESP数组
客户使用RESP数组向Redis服务器发送命令。类似地一些返回元素集合给客户的Redis命令使用RESP数组作为返回类型。一个例子是[LRANGE](https://redis.io/commands/lrange)命令返回一个元素列表。

RESP数组使用下面的格式发送：
- 一个*字符作为其首字节，后跟一个十进制数字代表数组中的元素数目，再后跟随回车换行符。
- 一个额外的RESP类型代表RESP数组中的每个元素类型
因此一个空数组就像下面那样：
```
"*0\r\n"
```
代表两个块字符串"foo" 和 "bar"的数组被编码为：
```
"*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
```
你能看到在数组前缀`*数目CRLF`之后，组成数组的其它数据类型是一个一个串在一起的。例如三个整型的数组被编码为：
```
"*3\r\n:1\r\n:2\r\n:3\r\n"
```
数组可以包含混合类型，并不需要所有元素为同一类型。例如，一个包含四个整型树和一个块字符串的列表被编码为：
```
*5\r\n
:1\r\n
:2\r\n
:3\r\n
:4\r\n
$6\r\n
foobar\r\n
```
（为了清晰回复被分割为多行）

服务器发送的第一行为*5\r\n，其指定接下来总共有5行实际数据。接下来是组成多行块回复的每一个被传输。

Null数组的概念也存在，是指定Null值（通常会使用块字符串，但出于历史原因我们有两种格式）的一种可选方式。

例如当[BLPOP](https://redis.io/commands/blpop)命令超时时，它返回一个Null数组，其元素数目为-1，如下所示：
```
"*-1\r\n"
```
当Redis回复一个Null数组时，一个客户端库API应该返回一个null对象而非一个空数组。这对于区分一个空列表和一个不同的情形是有用的（例如[BLPOP](https://redis.io/commands/blpop)命令超时的情形）。

数组的数组在RESP中是可能的，例如包含两个数组的数组编码如下：
```
*2\r\n
*3\r\n
:1\r\n
:2\r\n
:3\r\n
*2\r\n
+Foo\r\n
-Bar\r\n
```
（为了更易读被分割为多行）

上面的RESP数据类型编码了两个元素为数组的数组，其所含第一个数组为包含3个整型数1，2，3的数组，第二个数组包含一个简单字符串和一个错误。
## 数组中的Null元素
一个数组中的简单元素可能为Null。这用于在Redis回复中表明有些元素缺失且不是空字符串。当使用SORT命令带GET模式时，如果一个特定键不存在，这种情况就会发生。一个含有Null元素的数组回复示例如下：
```
*3\r\n
$3\r\n
foo\r\n
$-1\r\n
$3\r\n
bar\r\n
```
第二个元素为空，客户端库应该返回如下内容：
```
["foo",nil,"bar"]
```
注意这并不是前面章节提到的异常，而是深入指定协议的一个例子。
## 向Redis服务器发送命令
现在你已经熟悉了RESP序列化格式，写一个Redis客户端库实现将会比较容易。我们可以更进一步指定Redis客户端和服务器之间的交互如何工作：
+ 客户端向Redis服务器仅仅发送包含块字符串的RESP数组
+ 服务器向客户端发送由任何有效RESP数据类型作为回复

因此例如，一个典型的交互可能如下所示：

客户端发送`LLEN mylist`命令期望得到键mylist对应的列表的长度，服务器回复一个整形数，如下所示（C: 为客户端，S: 为服务器）：
```
C: *2\r\n
C: $4\r\n
C: LLEN\r\n
C: $6\r\n
C: mylist\r\n

S: :48293\r\n
```
和平常一样我们为了简化我们使用新行符来分割协议的不同部分，但实际的交互是客户端发送如下整体回复：`*2\r\n$4\r\nLLEN\r\n$6\r\nmylist\r\n`
## 多个命令和管道化
一个客户端可以利用同一连接发送多个命令。管道化被支持，客户端可以用一个写操作发送多个命令，而不用等到读到上一个命令的回复之后再发送新的命令。所有的回复可以在最后读取。

更多信息，请参阅我们的关于[管道](https://redis.io/topics/pipelining)的页面。
## 内联命令
有时候你仅仅由telnet工具但你需要向Redis服务器发送命令。虽然Redis协议易于实现，但在交互式会话中却不理想，而且redis-cli并不总是可用。基于这个原因Redis也接受一种为人易读的特殊方式的命令，被称为**内联命令**格式。

下面是一个服务器/客户端交流使用内联命令的一个例子（C: 为客户端，S: 为服务器）：
```
C: PING
S: +PONG
```
下面是内联命令的又一个例子，返回一个整形数：
```
C: EXISTS somekey
S: :0
```
基本上你只要在一个telnet会话上写上空格分隔的命令参数。因为没有命令以*开头，而*主要用于同一请求协议，Redis能够检测到该情况并解析你的命令。
## 内高性能Redis协议解析器
一方面Redis协议适合人类阅读，易于实现，它可被实现得几乎和二进制协议一样高效。

RESP使用前缀长度来传输块数据，因此从来没有需要去扫描整个负荷去查找特殊字符，就像JSON所做的，也不需要把负荷用双引号括起来以发送给服务器。

块和多块的长度可被逐字符扫描回车键字符的代码处理，就像下面的C代码：
```
#include <stdio.h>

int main(void) {
    unsigned char *p = "$123\r\n";
    int len = 0;

    p++;
    while(*p != '\r') {
        len = (len*10)+(*p - '0');
        p++;
    }

    /* Now p points at '\r', and the len is in bulk_len. */
    printf("%d\n", len);
    return 0;
}
```
当第一个回车键被识别出来，它可随其后的换行符一起被跳过。然后块数据可被一个简单的读操作读取，并不需要以任何方式查验负荷。最后剩余的回车换行符被丢弃。

可与二进制协议的性能相比，Redis协议简单，大多数高级语言易于实现，极大地减少了软件缺陷。

## Reference
- [Redis Protocol Specification](https://redis.io/topics/protocol)