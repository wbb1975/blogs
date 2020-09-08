# statsD
一个运行在[Node.js](http://nodejs.org/)平台的网络服务，监听统计信息，如counters和timers。通过[TCP](http://en.wikipedia.org/wiki/Transmission_Control_Protocol)或[UDP](http://en.wikipedia.org/wiki/User_Datagram_Protocol)协议发送汇集信息到一个或多个可插拔后端服务（比如 [Graphite](http://graphite.readthedocs.org/)）。
## 关键概念
- 桶（buckets）
  每个统计点（stat）在其自己的“桶”内。它们不是到处预定义的。桶可被命名为可传递到Graphite（定期创建目录）的任何名字。
- 值（values）
  每个统计点都有一个值，它被如何解释依赖于其修饰符。通常值应改为整数。
- flush
- 在flush间隔超时后（由`config.flushInterval`定义，默认为10秒），统计点被汇集并被上传到后端服务。
## 安装和配置
### Docker
StatsD 以两种方式支持Docker：
- 在[docker hub](https://hub.docker.com/r/statsd/statsd)上的官方docker镜像
- 从一个附带的[Dockerfile](https://github.com/statsd/statsd/blob/master/Dockerfile)构建镜像
### 手动安装
- 安装Node.js ([所有当前和长期支持版本](https://nodejs.org/en/about/releases/)都支持)
- 克隆项目
- 创建一个配置文件，比如`exampleConfig.js`，并放置于合适的地方
- 运行服务：`node stats.js /path/to/config`
## 使用
基本的行协议期待指标以下面的格式发送：
`<metricname>:<value>|<type>`
因此如果你已经有一个StatsD运行在本地默认的UDP服务器上，最简单的从你的命令行发送指标的方式为：
`echo "foo:1|c" | nc -u -w0 127.0.0.1 8125`
## 更多特定主题
- [Metric Types](https://github.com/statsd/statsd/blob/master/docs/metric_types.md)
- [Graphite Integration](https://github.com/statsd/statsd/blob/master/docs/graphite.md)
- [Supported Servers](https://github.com/statsd/statsd/blob/master/docs/server.md)
- [Supported Backends](https://github.com/statsd/statsd/blob/master/docs/backend.md)
- [Admin TCP Interface](https://github.com/statsd/statsd/blob/master/docs/admin_interface.md)
- [Server Interface](https://github.com/statsd/statsd/blob/master/docs/server_interface.md)
- [Backend Interface](https://github.com/statsd/statsd/blob/master/docs/backend_interface.md)
- [Metric Namespacing](https://github.com/etsy/statsd/blob/master/docs/namespacing.md)
- [StatsD Cluster Proxy](https://github.com/etsy/statsd/blob/master/docs/cluster_proxy.md)
## 调试
有额外的配置变量可用于调试
- debug - 记录异常并打印更多诊断信息
- dumpMessages - 在消息到来时打印调试信息
更多信息，请查看`exampleConfig.js`。
## 历史
StatsD 最初由[Etsy](http://www.etsy.com/)编写，发布时同时有一篇[博文](https://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/)描述了它如何工作以及为什么要创建它。
## 灵感来源
StatsD灵感来自于Flickr同名项目。在博文[Counting and timing](http://code.flickr.com/blog/2008/10/27/counting-timing/)中Cal Henderson深入描述了它。Cal最近重新发布了代码：[Perl StatsD](https://github.com/iamcal/Flickr-StatsD)。
## 服务器实现
- [brubeck](https://github.com/github/brubeck) - Server in C
- [clj-statsd-svr](https://github.com/netmelody/clj-statsd-svr) — Clojure server
- [gographite](https://github.com/amir/gographite) — Server in Go
- [gostatsd](https://github.com/atlassian/gostatsd) — Server in Go
- [netdata](https://github.com/firehol/netdata) - Embedded statsd server in the netdata server, in C, with visualization
- [Net::Statsd::Server](https://github.com/cosimo/perl5-net-statsd-server) — Perl server, also available on [CPAN](https://metacpan.org/module/Net::Statsd::Server)
- [Py-Statsd](https://github.com/sivy/py-statsd) — Server and Client
- [Ruby-Statsdserver](https://github.com/fetep/ruby-statsdserver) — Ruby server
- [statsd-c](https://github.com/jbuchbinder/statsd-c) — Server in C
- [statsdaemon (bitly)](https://github.com/bitly/statsdaemon) — Server in Go
- [statsdaemon (vimeo)](https://github.com/vimeo/statsdaemon) — Server in Go
- [statsdcc](https://github.com/wayfair/statsdcc) - Server in C++
- [statsdpy](https://github.com/pandemicsyn/statsdpy) — Python/eventlet Server
- [Statsify](https://bitbucket.org/aeroclub-it/statsify) - Server in C#
- [statsite](https://github.com/armon/statsite.git) — Server in C
- [bioyino](https://github.com/avito-tech/bioyino) — High performance multithreaded server written in Rust
## 客户端实现
许多客户端库被贡献出来。
### Node
- lynx — Node.js client used by Mozilla, Nodejitsu, etc.
- Node-Statsd — Node.js client
- node-statsd-client — Node.js client
- node-statsd-instrument — Node.js client
- statistik - Node.js client with timers & CLI
- statsy - clean idiomatic statsd client
### Java
- [java-statsd-client](https://github.com/youdevise/java-statsd-client) — Lightweight (zero deps) Java client
- [Statsd over SLF4J](https://github.com/nzjess/statsd-over-slf4j) — Java client with SLF4J logging tie-in
- [play-statsd](https://github.com/vznet/play-statsd) — Play Framework 2.0 client for Java and Scala
- [statsd-netty](https://github.com/flozano/statsd-netty) — Netty-based Java 8 client
### Python
- [Py-Statsd](https://github.com/sivy/py-statsd) — Server and Client
- [Python-Statsd](https://github.com/WoLpH/python-statsd) — Python client
- [pystatsd](https://github.com/jsocol/pystatsd) — Python client
- [Django-Statsd](https://github.com/WoLpH/django-statsd) — Django client
### C
- [C client](https://github.com/romanbsd/statsd-c-client) — A trivial C client
### CPP
- [statsd-client-cpp](https://github.com/talebook/statsd-client-cpp) — StatsD Client in CPP
- [cpp-statsd-client](https://github.com/vthiery/cpp-statsd-client) — A header-only StatsD client implemented in C++
### Go
- [go-statsd](https://github.com/smira/go-statsd) - Go statsd client library with zero allocation overhead, great performance and reconnects
- [GoE](https://godoc.org/github.com/pascaldekloe/goe/metrics) — Minimal & Performant
- [go-statsd-client](https://github.com/cactus/go-statsd-client) — Simple Go client
- [g2s](https://github.com/peterbourgon/g2s)
- [StatsD](https://github.com/quipo/statsd)
- [statsd](https://github.com/alexcesaro/statsd) — A simple and very fast StatsD client
### Lua
- [lua-statsd](https://github.com/stvp/lua-statsd-client)
## 工具
- [statsd-tg](http://octo.it/statsd-tg) – StatsD 流量生成器；产生虚设流量来进行负载测试
- [statsd-vis](https://github.com/rapidloop/statsd-vis) – 内建Web UI的StatsD服务器，你可以可视化图形

## Reference
- [StatsD Home](https://github.com/statsd/statsd)
- [StatsD Metrics Export Specification v0.1](https://github.com/b/statsd_spec)
- [Dropwizard官方教程](https://www.jianshu.com/p/3bb308c9bbcb)