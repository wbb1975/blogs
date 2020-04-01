# Hadoop 数据类型与文件结构剖析 Sequence, Map, Set, Array, BloomMap Files
## 1. Hadoop’s SequenceFile
Hadoop的SequenceFile提供了对二进制键-值对的一种持久化数据结构，对比其它持久化键-值数据结构比如B树，你不能定位到特定键来编辑，添加或删除它，这种文件只能添加（append-only）。

SequenceFile 有三种压缩态：
1. Uncompressed – 未进行压缩的状态
2. Record Compressed - 对每一条记录的value值进行了压缩（文件头中包含上使用哪种压缩算法的信息）
3. Block-Compressed – 当数据量达到一定大小后，将停止写入进行整体压缩，整体压缩的方法是把所有的keylength,key,vlength,value 分别合在一起进行整体压缩
   
所有三中文件格式都有一个文件头（header），里面包含压缩状态标记：键值类名可利用反射实例化从而读文件，版本号和格式（是否压缩，是否块压缩），如果被压缩，则压缩编码类型名也被添加到文件头中。

SequenceFile也可能包含一个附加（secondary）的键值对列表用作Metadata数据。键值对列表可能仅仅是文本/文本对，它是在SequenceFile.Writer构造过程中初始化时就已经写入的，所以也是不能更改的。

你已经看到SequenceFile有三种格式，“Uncompressed” 和“Record Compressed”很相似。每次调用append()方法都将向SequenceFile添加一条记录，该记录包含整条记录的长度（key length + value length），键的长度，原始键和值数据。压缩和非压缩版本的区别在于原始值数据是否采用特定压缩编码压缩了。

相比之下“Block-Compressed”格式在压缩上更激进。数据在达到某个阀值前不会真正写入，当数据量到达某个阀值后，所有的键，值，键和值长度都将被一起压缩。

你可在左边图上看到，一个块记录包含一个VInt指示与多少条缓存记录，4个压缩块包含一个列表，该列表包含所有键的长度，以及键值；另一个列表包含所有值的长度和所有的值。每个块之前同步标记（sync marker）被写入。
## 2. MapFile, SetFile, ArrayFile 及 BloomMapFile
SequenceFile 是Hadoop 的一个基础数据文件格式，后续讲的 MapFile, SetFile, ArrayFile 及 BloomMapFile 都是基于它来实现的。
- MapFile：Mapfile是一个目录，它包含两个SequenceFile：数据文件（"/data"） 和索引文件 （"/index"）。数据文件中包含所有需要存储的key-value对，按key的顺序(非降序)排列。这个顺序在append()操作时检查，如果检查键失败，将抛出“Key out of order”的IOException。索引文件拥有键及一个LongWritable值用以指示该记录的开始字节位置。 索引文件并不包含所有的键，而只包含一部分key值，你可以使用setIndexInterval() 方法来指定索引间隔。索引被全部读入内存，所以如果你拥有一个大的映射，你可以设置一个索引调整值（index skip value）来让你仅仅加载一部分索引键值。
- SetFile：基于 MapFile 实现的，他只有键，值为NullWritable实例。
- ArrayFile：也是基于 MapFile 实现，他就像我们使用的数组一样，key值为序列化的数字（count + 1）。
- BloomMapFile：在 MapFile 的基础上增加了一个 /bloom 文件，包含的是二进制的过滤表（DynamicBloomFilter），在每一次写操作完成时，会更新这个过滤表。bloom文件在关闭时完整写入。

## Reference
- [Hadoop I/O: Sequence, Map, Set, Array, BloomMap Files](https://clouderatemp.wpengine.com/blog/2011/01/hadoop-io-sequence-map-set-array-bloommap-files/)
- [Hadoop 数据类型与文件结构剖析](https://blog.csdn.net/baiyunl/article/details/83910230)
