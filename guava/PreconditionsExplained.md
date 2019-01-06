# Preconditions
##### [原文地址](https://github.com/google/guava/wiki/PreconditionsExplained)

Guava提供了许多前提检查设施，我们强烈推荐静态倒入它们。

每个方法有三种变体：
1. 没有额外参数，任何抛出异常都没有错误消息。
2. 有一个参数Object，任何抛出的异常带有错误消息object.toString()
3. 一个String参数, 以及一些额外的Object参数。这种行为有点像printf，但为了GWT兼容性和效率考虑，它只允许%s指示符。
   > 注意：checkNotNull, checkArgument和checkState拥有大量重载函数以各种初等类型和Object的组合为参数而非可变数组－－
   这在绝大多数情况下可以防止以上调用的初等变量“装箱”及可变数组的分配成本。

第三种变体的一些例子：
```
checkArgument(i >= 0, "Argument was %s but expected nonnegative", i);
checkArgument(i < j, "Expected i < j, but %s >= %s", i, j);
```

**Signature (not including extra args)**|**Description**|**Exception thrown on failure**  
----------|---------------|---------------
[checkArgument(boolean)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkArgument-boolean-)|Checks that the boolean is true. Use for validating arguments to methods.|IllegalArgumentException
[checkNotNull(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkNotNull-T-)|Checks that the value is not null. Returns the value directly, so you can use checkNotNull(value) inline.|NullPointerException
[checkState(boolean)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkState-boolean-)|Checks some state of the object, not dependent on the method arguments. For example, an Iterator might use this to check that next has been called before any call to remove.|IllegalStateException
[checkElementIndex(int index, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkElementIndex-int-int-)|Checks that index is a valid element index into a list, string, or array with the specified size. An element index may range from 0 inclusive to size exclusive. You don't pass the list, string, or array directly; you just pass its size. Returns index.|IndexOutOfBoundsException
[checkPositionIndex(int index, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkPositionIndex-int-int-)|Checks that index is a valid position index into a list, string, or array with the specified size. A position index may range from 0 inclusive to size inclusive. You don't pass the list, string, or array directly; you just pass its size.Returns index.|IndexOutOfBoundsException
[checkPositionIndexes(int start, int end, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkPositionIndexes-int-int-int-)|Checks that [start, end) is a valid sub range of a list, string, or array with the specified size. Comes with its own error message.|IndexOutOfBoundsException

我们偏向于使用我们的前置检查设施而不是一些类似的设施比如说Apache Commons，主要基于以下原因：
- 静态导入后，Guava的方法更清晰也更少歧义。checkNotNull能够更清楚表明它主要做什么，以及什么异常被抛出。
- checkNotNull在验证参数后返回其参数，这便于使用所谓的一行构早晚函数：  
  `this.field = checkNotNull(field);.`
- 简单可变参数像"printf-style" 的异常消息。（这点优势也是我们推荐使用checkNotNull而非Objects.requireNonNull的原因所在。）

我们推荐你把前置检查分散到多行，这可以帮你在调试代码时找到哪个前置条件失败了。另外，你应该提供有意义的错误消息，当检查一行一个时显得更简单。