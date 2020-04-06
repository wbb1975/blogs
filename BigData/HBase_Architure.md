# HBase架构指南
## 1. 简介
HBase是一个高可靠性，高性能，面向列的，可扩展的分布式存储系统，利用HBase技术可以在不贵的PC服务器上构建大规模结构化存储集群。HBase的目标是存储和处理大量的数据，尤其适合用用标准硬件配置来处理大量包含行和列的数据。

不同于MapReduce的离线批处理计算框架，HBase是随机访问存储和查询平台，它可以弥补HDFS不能随机访问数据的缺憾。

HBase适用于实用性要求不太高的商业场景--HBase存储字节数组，它并不关心数据类型，允许动态灵活的数据模型。

![Hadoop Ecosystem](images/Hadoop_Ecosystem.png)

上图描述了Hadoop 2.0生态中的各层系统--HBase位于结构化存储层。

HDFS为HBase提供了高可靠性的底层存储支持。

MapReduce为HBase提供高性能批处理处理能力。Zookeeper为HBase提供稳定的服务和failover机制。Pig和Hive为HBase提供数据统计处理的高级语言支持。Sqoop提供HDB来支持关系数据库导入功能，该功能使得把商业数据从传统数据库导入HBase变得方便。
## 2. HBase Architectural Components
物理上看，HBase是由3种类型的服务器组成的主从架构。Region Server服务于数据读写，当访问数据时，客户直接与HBase Region Server通讯。Region指派，DDL（创建，删除表）由HBase Master进程处理。Zookeeper，作为HDFS的一部分，维护活动集群状态。

Hadoop DataNode存储Region Server管理的数据。所有的HBase数据都存储在HDFS文件中。Region Servers和HDFS DataNodes驻留在同一节点上，这可以确保RegionServers服务的数据的本地性（将数据保存在需要它的地方）。HBase数据在刚写时是在本地的，但当一个region被移动后，它就不再具有本地性，直到compaction。

![Hbase Main Components](images/HBaseArchitecture-Main_Components.png)

![Hbase Basic Components](images/HBaseArchitecture-Basic_Components.png)

### 2.1 基本架构（Basic Architecture）
+ 客户（client）：使用HBase的RPC机制与HMaster和HRegionServer通讯，提交请求并获取结果。对管理操作，客户向HMaster提交RPC请求；对数据读写操作，向HRegionServer提交RPC请求。
+ Zookeeper：通过将集群中的每一个节点的信息注册到ZooKeeper中，HMaster可在任何时候感知到每个HRegionServer的健康状态，也能避免HMaster的单点问题。
+ HMaster：管理所有的HRegionServers，告诉它们哪些HRegions需要维护，并监控所有的HRegionServers的健康状态。当一个新的HRegionServer注册进HMaster，HMaster告诉它等待数据被分配给它。当一个HRegionServer死去，HMaster将把它负责维护的所有HRegions标记为未分配的，并把它们指派给其它HRegionServers。HMaster不存在单点问题。HBase可以启动多个HMaster，通过ZooKeeper的选举机制，总有一个HMaster实例在集群中运行，从而提高了集群的可用性。
+ HRegion：当表大小超过一个阀值，HBase会将该表分割成几个不同区域，每个区域含有表中所有行的一部分。对用户来说，表是一个数据集，由主键区分(RowKey)。物理上，表被分割成多个块，每个块是一个HRegion。我们使用表名 + 起始主键来区分每个HRegion。一个HRegion将保存一个表中一系列连续数据。一个完整的表数据存储在多个HRegions中。
+ HRegionServer：从底层来说HBase的所有数据都存储在HDFS里。用户可以通过一系列HRegionServers得到数据。一般集群的每个节点上之韵星一个HRegionServer实例，一个段的HRegion仅仅由一个HRegionServer负责维。HRegionServer主页负责根据用户的IO请求从HDFS文件系统读写数据，**它是HBase的核心模块**。HRegionServer内部管理了一系列的 HRegion 对象，每个HRegion对应本地表的一系列连续数据段。HRegion 由多个HStores组成，每个HStore代表本地表的一个列族的存储。它可被视为每个列族是一个中央存储单元。因此，为了提高操作效率，我们倾向于把具有相同IO特征的列放到同一个列族中。
+ HStore：**它是HBase存储的核心**，它由MemStore 和StoreFiles组成。MemStore是一个内存缓存，用户写入的数据首先被放置到MemStore中。当MemStore 满时， **一个StoreFile（其底层实现是HFile）将会被刷写**。当StoreFile 文件数增长到一个特定阀值时，一个Compact Merge操作就会被触发，多个StoreFiles 将会被合并成一个，合并过程中也会执行版本合并和数据删除。因此，可以视为HBase仅仅添加数据，所有的更新和删除操作将由后面的Compact 过程执行，因此用户的写入操作只要它进入了内存，就会马上返回，从而确保了HBase I/O的高性能。当StoreFiles文件Compact后，它将形成一个越来越大的文件。当单个StoreFile 文件的大小超过一个特定阀值时，一个切分（Split ）操作将会被触发，同时，当前HRegion 将会被切分成两个HRegions，父HRegion 将会下线。两个字HRegions 将会被HMaster指派给对应的HRegionServer ，如此原先的HRegion 的负载压力就会被分流到两个HRegions里。
+ HLog：每个HRegionServer 拥有一个HLog 对象，它是一个预写日志类用于实现Write Ahead Log（WAL）。每次用户写入数据到MemStore，它也将一份数据的拷贝写到HLog 文件。HLog 会定期滚动和删除，老文件将会被删除（数据已经被写入到StoreFile中）。当HMaster 通过ZooKeeper检测到一个HRegionServer 异常终止，HMaster 将会首先处理遗留HLog 文件，把不同HRegions的数据分割开，并把它们放至对应的HRegion目录下，然后再分发无效的HRegions。在加载HRegion的过程中，这些HRegions 的HRegionServer 将会找到是否有一个历史HLog 需要处理，因此在回放日志（Replay HLog）将会被传送到MemStore中，然后被刷写到StoreFiles 中以完成数据恢复。
### 2.2 Root and Meta
所有HBase的HRegion metadata存储在.META。 表中。当HRegion增长时，.META表中的数据随之增长，并被切分成多个HRegions。

为了在.META表中定位每个HRegion，.META表中的所有HRegions 的metadata 存储在-ROOT-表中。最终，-ROOT-表的位置信息被存储在ZooKeeper中。

在所有客户访问用户数据之前，他们需要访问Zookeeper 以获取-ROOT-的位置信息，进而获得.META表的位置，并最终根据.META表中的信息获得用户数据的位置信息，如下图所示：

![Hbase Metadata Table](images/system_tables.png)

-ROOT-表永远不会切分，它只有一个HRegion，这可以确保任何HRegion 可以在3跳内被定位。为了加速访问，.META表中的所有regions都被加载在内存中。

客户端缓存返回的位置信息，且该缓存不会主动失效。如果客户给予缓存信息不能访问数据，就向.META表的相关RegionServer发起查询以获取数据的位置信息。如果仍失败，查询-ROOT-以获取相关.META表在哪里。

最终，如果以前的信息全无效，HRegion的数据被ZooKeeper重新定位。因此如果客户端缓存全无效，你必须往返6次以获取正确的HRegion。 
## 3. HBase组件细说
### 3.1 Regions
HBase被行键（row key）范围水平切分成“Regions”。一个Region包含一个表中开始键和结束键范围内的所有行。Regions被指派给集群内的节点“RegionServers”，这些RegionServer服务于数据读写。一个RegionServer可以服务于1000个Region。

![Hbase Metadata Table](images/HBaseArchitecture-Regions.png)
### 3.2 HBase HMaster
Region指派，DDL（创建，删除表）操作由HBase HMaster处理。

一个master负责：
- 协调RegionServers
  + 在启动时指派Regions，为（灾难）回复或负载均衡重新指派Regions
  + 监控集群中所有的RegionServers（监听来自ZooKeeper的通知）
- 管理功能
  + 创建，删除，更新表的接口

![Hbase Metadata Table](images/HBaseArchitecture-HMaster.png)
### 3.3 ZooKeeper: 协调器
HBase使用ZooKeeper作为一个分布式协调服务来维护集群服务器状态。ZooKeeper维护哪些服务器活着且可用，并提供服务器失效通知。Zookeeper使用共识来确保公共共享状态。注意应该有3台或5台服务器以确保共识。

![Hbase Metadata Table](images/HBaseArchitecture-ZooKeepers.png)
## 4. 这些组件如何协同工作（How the Components Work Together）
Zookeeper常被用于协调分布式系统各成员间的共享状态信息。RegionServers和活动HMaster都维持了与ZooKeeper的会话。ZooKeeper则通过心跳机制为活动会话维护了临时节点。

![Hbase Metadata Table](images/HBaseArchitecture-Sessions.png)

每个RegionServer创建了一个临时节点，HMaster监控这些节点以发现可用的RegionServer，它同时监控节点服务失效。HMasters争夺创建临时节点，Zookeeper决定谁是第一个并确保它是为一活动的HMaster。活动的HMaster向ZooKeeper发送心跳，不活动的HMaster则监听活动HMaster失效通知。

如果一个RegionServer或活动HMaster发送心跳失败，会话将会过期，对应临时节点将会被删除。更新状态监听器将会被通知节点被删除了。活动HMaster 监听RegionServers，将会恢复失效的RegionServer。不活动的HMaster监听活动HMaster失效，如果活动HMaster失效，一个不活动的HMaster则成为新的活动HMaster。
### 4.1 HBase Meta Table
+ .META表是一个HBase表，持有集群中所有regions 的列表
+ .META就像一个树
+ .META表结构如下所示
  + 键：region开始键，region id
  + 值：RegionServer

![Hbase Metadata Table](images/HBaseArchitecture-Meta_Tables.png)
### 4.2 Region Server Components
RegionServer运行在HDFS DataNode上，它包含以下组件：
+ WAL：预写日志是分不是文件系统的一个文件。WAL通常用于存储还没写入持久存储的新数据；它用于在失效时恢复
+ BlockCache：读缓存。它在内存中保存被频繁读取的数据。但缓存满时最少使用数据被移除。
+ MemStore：写缓存。它用于存储还没写到磁盘上的新数据。在写到磁盘之前排序。每个Region的每个列族有一个MemStore。
+ Hfiles：将行按有序键值对存储到磁盘上。


![Hbase Metadata Table](images/HBaseArchitecture-RegionServer.png)
### 4.3 HBase Write Steps
### 4.4 HBase MemStore
### 4.5 HBase Region Flush
### 4.6 HBase HFile
### 4.7 HBase Read Merge
### 4.8 HBase Minor Compaction
### 4.9 HBase Major Compaction
### 4.10 Region Split
### 4.11 Read Load Balancing
## 5. HDFS Data Replication
## 6. HBase Crash Recovery

## References
- [HBase Working Principle: A part Hadoop Architecture](https://towardsdatascience.com/hbase-working-principle-a-part-of-hadoop-architecture-fbe0453a031b)
- [HBase Architecture In Depth](https://mapr.com/blog/in-depth-look-hbase-architecture/)
- [Apache HBase ™ Reference Guide](https://hbase.apache.org/book.html)
- [A Beginners Guide to HBase](https://medium.com/@pankaj.singhal/a-beginners-guide-to-hbase-1310f832aff7)
