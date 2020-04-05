# Apache HBase I/O – HFile
## 简介
Apache HBase是Hadoop下一套开源分布式带版本功能存储管理系统，非常适合随机实时读写访问。

等等？随机实时读写访问？我没听错？

这怎么可能？Hadoop不是顺序读写的批处理系统吗？

是的，我们在谈论同一个事情，在下一章节，我将解释如何HBase如何实现随机读写，它如何存储数据，以及HBase的HFile的格式演变。
## Apache Hadoop I/O 文件格式
Hadoop提供了[顺序文件](https://clouderatemp.wpengine.com/blog/2011/01/hadoop-io-sequence-map-set-array-bloommap-files/)格式，你可以向它添加键值对，但也是由于它的“append-only”能力，这种文件格式不支持对已插入记录的修改和删除。唯一允许的操作就收添加（append），如果你想查找特定键，你就不得不遍历整个文件直到找到它。

如你所见，你被迫遵守顺序读写模式，但如何才可能在其上构建想HBase一样的随机，低延迟读写访问系统呢？

为了帮你解决这个问题，Hadoop提供了另一种文件格式，即MapFile，一种顺序文件的扩展。MapFile实际上是一个目录，它包含两个文件，数据文件“/data”和索引文件“/index”。MapFile允许你添加排序过的键值对。每个N个键（N是一个可配置的间隔），键和位置偏移将被存到索引文件中。这支持快速查询，因为它不需要遍历所有的记录，你可以扫描少的多的索引文件。一旦你找到了你的数据块，你可以直接跳到数据文件中去读取目标数据。

MapFile是很好--你可以快速查询你的键值对，但它还是有下面的两个问题：
- 如何删除或替换一个键值对
- 如果我的输入无序，那么我将无法使用MapFile
## HBase & MapFile
HBase键包括：行键（rowKey），列族, 列（column qualifier），时间戳和类型。

![HBase Key](HBase-Key.png)

为了解决删除键值对的问题，一种思路是使用“类型（type）”字段来标记键已被删除（墓碑标记，tombstone markers）。解决替换一个键值对仅仅需要选取较新的时间戳（正确值靠近文件末尾，append-only意味着上次插入肯定靠近文件末尾）。

为了解决“无序”的键的问题，我们把最后添加的键值对保存在内存中，当其达到一个阀值时，HBase将其刷写到一个MapFile。通过这种方式，你将有序键值对加入到了MapFile中。

确切来说HBase这样运作：当你用table.put()添加一个值时，你的键值对被添加到MemStore（MemStore之下其实是一个有序的ConcurrentSkipListMap）。当达到一个MemStore的阀值（hbase.hregion.memstore.flush.size）或者一个RegionServer为MemStore使用了太多内存时(hbase.regionserver.global.memstore.upperLimit)，数据就被刷写到磁盘上形成一个MapFile。

每次刷写的结果都是一个新的MapFile，这意味着为了找到某个键你可能不得不搜寻多个文件。这将消耗更多资源，可能潜在地变慢。

每次一个get或Scan发出，HBase将遍历每个文件来来查询结果。为避免查询更多文件，专门有一个线程来探测文件数已经达到某个阀值（hbase.hstore.compaction.max），接下来它将在一个被称为“compaction”的过程中合并多个文件，结果将形成一个新的较大文件。

HBase拥有两种类型的“compaction”：“minor compaction”仅仅将两个或多个小文件合成一个大文件；“major compaction”将选择一个Region中所有文件，合并它们并执行一些清理工作。在“major compaction” 中，删除的键值对将被移除，新文件将不再含有墓碑标记；所有重复的键值对（值替换操作）也被删除。

在2.0版本之前，HBase一直使用MapFile格式来存储数据；但自0.20版本开始一种HBase特有的Mapfile文件格式被引入（HBASE-61）。

## Reference
- [Apache HBase I/O – HFile](https://blog.cloudera.com/apache-hbase-i-o-hfile/)
- [Hadoop I/O: Sequence, Map, Set, Array, BloomMap Files](https://clouderatemp.wpengine.com/blog/2011/01/hadoop-io-sequence-map-set-array-bloommap-files/)
- [Apache HBase Write Path](https://clouderatemp.wpengine.com/blog/2012/06/hbase-write-path/)