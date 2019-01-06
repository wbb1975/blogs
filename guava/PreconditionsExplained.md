# Preconditions
##### [原文地址](https://github.com/google/guava/wiki/PreconditionsExplained)

Guava提供了许多前提检查设施，我们强烈推荐静态倒入它们。

每个方法有三种变体：
1. 没有额外参数，任何抛出异常都没有错误消息。
2. 有一个参数Object，任何抛出的异常带有错误消息object.toString()
3. 一个String参数, 以及一些额外的Object参数。这种行为有点像printf，但为了GWT兼容性和效率考虑，它只允许%s指示符。
   > 注意：checkNotNull, checkArgument和checkState
