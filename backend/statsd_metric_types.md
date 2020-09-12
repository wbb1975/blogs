# StatsD指标类型（StatsD Metric Types）
## Counting
```
gorets:1|c
```
这是一个简单的counter。向"gorets" 桶中加1。在每个flush点当前count 值被发送并被置为0。通过设置`config.deleteCounters`（仅可用于graphite 后端），如果该counter在flush点时值为0，那么你可以选择对该counter不发送任何指标。在每次flush时StatsD将发送count及其速率。
## 采样（Sampling）
```
gorets:1|c|@0.1
```
告诉StatsD 这个counter 每十分之一时间就采样发送一次。
## Timing
```
glork:320|ms|@0.1
```
“glork“花费320ms 完成这次时间间隔。StatsD 为每个flush间隔计算百分比，平均值（mean），标准方差，和，上下边界等。百分比阀值可以使用`config.percentThreshold`微调。

百分比阀值可以是一个单一值，或者一个值的列表，并会为每个阀值产生如下统计列表：
```
stats.timers.$KEY.mean_$PCT
stats.timers.$KEY.upper_$PCT
stats.timers.$KEY.sum_$PCT
```
这里`$KEY`是你发送数据给StatsD时指定的`stats key`，而`$PCT`则是百分比阀值。

使用`config.histogram`配置来指示StatsD 来维护是时间变化的histograms 。指定哪个指标类匹配，以及一个对应非包含性`bins（class intervals）`的有序上限列表。（使用 `inf` 代表无限；低限为0）对每个`flushInterval`，对所有匹配的指标StatsD 将在每个 `bin (class interval)`里存储多少值（绝对频率）。例如：
- 默认地任何timer没有histograms ：[]
- histogram 只追踪提供的时间范围，为所有离散值利用不等的 class intervals 和 catchall:
   ```
   [ { metric: 'render', bins: [ 0.01, 0.1, 1, 10, 'inf'] } ]
   ```
- 为所有timer除了 'foo' 的histogram，为所有离散值利用相等的 class intervals 和 catchall:
  ```
   [ { metric: 'foo', bins: [] },
    { metric: '', bins: [ 50, 100, 150, 200, 'inf'] } ]
  ```

StatsD 也为每个 timer 指标维护一个counter，第三个字段指定了该counter的采样频率（本例中为`@0.1`）。还字段可选且默认为1.

注意：
+ 对指标第一个匹配胜出
+ bin 上线可能包含小数点
+ 指实际上比严格考虑过的histograms功能更强大，因为你可以使得bin 范围更广，例如，不同大小的class intervals。
## Gauges
StatsD 也支持gauges。一个gauge 可以接受指定给它的任何值，并且将维持该值直到下一次设置。
```
gaugor:333|g
```
如果一个gauge 在下一个flush点未被更新，它将发送上次的值。你可以通过设置`config.deleteGauges`选择不想该gauge发送任何值。

给一个gauge添加一个符号将改变其值，而不是设置其值：
```
gaugor:-10|g
gaugor:+4|g
```
因此如果gaugor 是`333`，上面的命令将设置它为`333 - 10 + 4`, 或 `327`.

> **注意**：这意味着你不能显式设置gauge 为负值而不首先设置其为0.
## Sets
StatsD 支持flush之间事件唯一发生的计数，使用一个Set 来存储所有发生的事件：
```
uniques:765|s
```
如果flush时该count为`0`，你可以选择通过设置`config.deleteSet`来不发送该set的指标。
## Multi-Metric Packets
StatsD 支持在一个包中接受多个指标--用换行符来分割它们。
```
gorets:1|c\nglork:320|ms\ngaugor:333|g\nuniques:765|s
```
小心不要让你的载荷总长超过网络MTU。没有一个很好的值来供你使用，但有一些对相同的网络场景有效的指南，
- 快速以太网（1432)：这对大多数Intranets成立
- 千兆网(8932) ：Jumbo Frames 能够更高效地利用该特性
- 民用互联网 (512) ：如果你在通过互联网发送一个值，该范围是合理的。

（这些负载数值考虑了醉倒IP和UDP 包头大小）。

## Reference
- [StatsD Metric Types](https://github.com/statsd/statsd/blob/master/docs/metric_types.md)