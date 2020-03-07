## Preconditions

Guava提供了许多前置条件判断的实用方法，我们强烈推荐静态导入它们。

每个方法有三种变体：
1. 没有额外参数，任何抛出异常都没有错误消息。
2. 有一个参数Object，任何抛出的异常带有错误消息object.toString()
3. 一个String参数, 以及一些额外的Object参数。这种行为有点像printf，但为了GWT兼容性和效率考虑，它只允许%s指示符。
   > **注意：checkNotNull, checkArgument和checkState**拥有大量重载函数以各种原生（primitive）类型和Object的组合为参数而非可变数组－－
   这在绝大多数情况下可以防止以上调用的原生变量“装箱”及可变数组的分配成本。

第三种变体的一些例子：
```
checkArgument(i >= 0, "Argument was %s but expected nonnegative", i);
checkArgument(i < j, "Expected i < j, but %s >= %s", i, j);
```

**方法签名(不包括额外参数)**|**描述**|**检查失败时抛出的异常**  
----------|---------------|---------------
[checkArgument(boolean)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkArgument-boolean-)|检查boolean是否为true，用来检查传递给方法的参数。|IllegalArgumentException
[checkNotNull(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkNotNull-T-)|检查value是否为null，该方法直接返回value，因此可以内嵌使用checkNotNull|NullPointerException
[checkState(boolean)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkState-boolean-)|用来检查对象的某些状态，不依赖方法参数。例如，一个迭代器可以是用这个方法来检查在任何remove调用之前next是否被调用过。|IllegalStateException
[checkElementIndex(int index, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkElementIndex-int-int-)|检查index作为索引值对某个列表、字符串或数组是否有效。一个元素索引范围应改为[0， size)。你不用将列表，字符串或数组直接传入；但你需要传入其大小。返回索引值本身|IndexOutOfBoundsException
[checkPositionIndex(int index, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkPositionIndex-int-int-)|检查index作为索引值对某个列表、字符串或数组是否有效。一个元素索引范围应改为[0， size]。你不用将列表，字符串或数组直接传入；但你需要传入其大小。返回索引值本身|IndexOutOfBoundsException
[checkPositionIndexes(int start, int end, int size)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Preconditions.html#checkPositionIndexes-int-int-int-)|检查[start, end)表示的位置范围对某个列表、字符串或数组是否有效。它提供自己的错误消息|IndexOutOfBoundsException

我们偏向于使用我们的前置检查设施而不是一些类似的设施比如说Apache Commons，主要基于以下原因：
- 静态导入后，Guava的方法更清晰也更少歧义。checkNotNull能够更清楚表明它主要做什么，以及什么异常被抛出。
- checkNotNull在验证参数后返回其参数，这便于使用所谓的一行构造函数：`this.field = checkNotNull(field);`
- 简单可变参数像"printf-style" 的异常消息。（这点优势也是我们推荐使用checkNotNull而非Objects.requireNonNull的原因所在。）

我们推荐你把前置检查分散到多行，这可以帮你在调试代码时找到哪个前置条件失败了。另外，你应该提供有意义的错误消息，当检查一行一个检查时显得更简单。

## Reference
- [PreconditionsExplained](https://github.com/google/guava/wiki/PreconditionsExplained)
