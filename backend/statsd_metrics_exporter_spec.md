# StatsD指标导出规范 v0.1
本文描述了StatsD指标收集协议的不同化身的实现的当前实践.协议起源于Flickr，并由Etsy甲乙发展，接下来深受Coda Hale的指标系统的影响。本文初衷并不是要指定或强加一个规范，而是作为当前实现的一个快照，并作为帮助实现的一个指南。
## 术语
StatsD用于从基础设施收集指标。它是基于推送的：客户端向一个收集服务器导出指标，它接下来驱动汇集指标，并驱动图表系统如Graphite。关于数据如何处理或导出相关假设很少。

术语metrics和基础设施都被广泛定义。一个指标是一个测量，包含一个名字，一个值，一个类型，有时还包含额外信息描述指标应如何解释。基础设施可以是技术栈的任何部分，从数据中心的UPS 控制器，服务器上的温度传感器，到应用中的函数调用，甚至浏览器中的用户交互。

它可被结构化成下面指标类型中的一个，它能被StatsD消费：
## 指标类型和格式
导出指标的格式是UTF-8文本，指标间用新行符分割。指标通常是`<metric name>:<value>|<type>`的形式，比同的是下面将提到的指标类型。

协议允许整型数和浮点数值。大多数实现内部将值存储为 IEEE 754 double浮点数。但许多实现和图表系统仅仅支持整型数值。为了兼容性，所有的值应改为整型且范围为（-2^53^, 2^53^）。
### Gauges
一个gauge是一个值的瞬时测量。就像一辆汽车的汽油量。它与counter 不一样的地方在于它在客户端计算而非服务器端，有效的gauge 值范围为 [0, 2^64^)。
```
<metric name>:<value>|g
```
### Counters
一个counter 是在服务器端计算的gauge。客户端发送的指标增加或递减该gauge的值，而不是给予它当前值。Counters 可能有其伴生采样速率。以一个小数形式给出每个事件量的采样次数。例如，采样速率1/10并导出为0.1。有效的counter 值范围为(-2^63^, 2^63^)：
```
<metric name>:<value>|c[|@<sample rate>]
```
这是一个简单的counter。向"gorets" 桶中加1。在每个flush点当前count 值被发送并被置为0。通过设置`config.deleteCounters`（仅可用于graphite 后端），如果该counter在flush点时值为0，那么你可以选择对该counter不发送任何指标。在每次flush时StatsD将发送count及其速率。
### Timers
一个timer是两个时间点start和end之间流逝的毫秒（milliseconds ）数的度量，例如，为永固渲染完成一个页面的时间。有效的timer值范围为[0, 2^64^)：
```
<metric name>:<value>|ms
```
### Histograms
一个histogram是随时间流逝的timer值得分布的度量，服务器端计算。由于timers 和 histograms导出的数据一样，当前它是timer的一个别名。有效的histgrams值范围为[0, 2^64^):
```
<metric name>:<value>|h
```
### Meters
一个meter 随时间流逝的事件的速率，服务器端计算。它们可以被视为只增的counters。有效的meter 值范围为 [0, 2^64^)：
```
<metric name>:<value>|m
```
在至少一种实现中，下面是增加1的缩写：
```
<metric name>
```
虽然这很方便，我们应该显式使用全名指标。缩写形式记载这里仅仅是为了完整性。

## Reference
- [StatsD Metrics Export Specification v0.1](https://github.com/b/statsd_spec)
- [Flickr StatsD](http://code.flickr.com/blog/2008/10/27/counting-timing/)
- [Etsy StatsD](https://github.com/etsy/statsd)
- [Coda Hale's Metrics](http://metrics.codahale.com/)
- [metricsd](https://github.com/mojodna/metricsd)
- [Graphite](http://graphite.wikidot.com/)