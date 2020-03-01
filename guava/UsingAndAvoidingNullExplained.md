## Using and avoiding null
> "Null sucks." - Doug Lea

> "I call it my billion-dollar mistake." - Sir C. A. R. Hoare, on his invention of the null reference

null的随意使用可能导致各种令人震惊的错误（bugs）。经过对Google代码的研究，我们发现约有95%的集合类不会接受null值，而且
当遇见null时，马上拒绝它而不是默默地接受它对开发者来说更有帮助。

另外，null会导致歧义，这令人相当不快。一个null返回值有明确含义的情况相当罕见--比如，Map.get(key)返回null可能因为map
中的key的对应值为null，也可能是因为map不含有这个key。null可能意味着成功，也可能意味着失败，甚至可以意味着任何东西。为了使
你的意图表达得更清楚，请不要使用null。

即便如此，Null确实也有合适和正确的使用场景。从内存和速度角度null是廉价的，在使用对象数组时null也是必须的。但相对于底层库来说，在应用级别的代码中，null往往是导致混乱，疑难问题和模糊语义的元凶，例如，Map.get返回一个null，它可能意味着没有这个值或者有这个值但值为null。最为关键的是，null对于null值代表什么意思不能提供任何指示。

基于以上原因，很多Guava工具类对null值都采用快速失败操作，除非工具类本身提供了针对null值的因变措施。另外Guava提供了很多设施来帮你在必须的场合更容易使用null，或者避免使用null。
### 具体案例(Specific Cases)
如果你想在Set中存储null或者在Map中使用null作为一个键－－请不要这样使用；在集合或映射的查找过程中对null显式特殊对待，会使得逻辑更清晰。

如果你想在Map中使用null作为一个值，略去这条记录；使用单独的Set存储非null键和null键。对于Map，以下两种情况很容易混淆：Map含有一个键值对其值为null，或者Map不含这个键。最好把这些键分离开来，并仔细考虑在你的应用中一个键对应的值为null意味着什么。

如果你在一个List中使用null，如果这个List有效值不多，或许你应该使用Map<Integer, E>？它实际上更有效率，而且可能实际上能更准确的匹配你的应用的需求。

考虑是否有一个自然的null对象可供使用－－不总是有，但有时候有。比如对一个枚举类型，你可以添加一个常量来代替null所代表的语义。又比如，java.math.RoundingMode有一个UNNECESSARY来表明“不做圆整，如果需要就抛出一个异常”。

如果你确实需要null，并且你受阻于对null不友好的集合实现，换一个实现。例如，用JDK中的Collections.unmodifiableList(Lists.newArrayList())代替Guava的ImmutableList。
### Optional
许多例子中程序员用null来表明某种不存在：或许存在某个值，或者值为none，或者不存在。例如，如果某个key对应的值不存在，Map.get就会返回null。

Optional<T>是一个用非null值来代替可以为null的T引用的方式。一个Optional或者包含一个非null的T引用（在这种情况下我们说引用存在），或者不包含任何引用（在这种情况下我们说引用缺位）。它永远不说包含null。
```
Optional<Integer> possible = Optional.of(5);
possible.isPresent(); // returns true
possible.get(); // returns 5
```
Optional无意直接模拟其他编程环境中的”可选（option）” or “可能（maybe）”语义，但它们的确有相似之处。

我们把一些最常用的Optional操作罗列如下：
#### Making an Optional
下面的每个都是Optional的静态方法

**Method**|**Description**
----------|---------------
[Optional.of(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#of-T-)|创建指定引用的Optional实例，若引用为null则快速失败
[Optional.absent()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#absent--)|创建引用缺失的Optional实例
[Optional.fromNullable(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#fromNullable-T-)|创建指定引用的Optional实例，若引用为null则表示缺失
#### Query methods
以下这些每个都是正对Optional<T>值的非静态方法

**Method**|**Description**
----------|---------------
[boolean isPresent()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#isPresent--)|如果Optional包含非null的引用（引用存在），返回true
[T get()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#get--)|返回Optional所包含的引用，若引用缺失，则抛出java.lang.IllegalStateException
[T or(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#or-T-)|返回Optional所包含的引用，若引用缺失，返回指定的值
[T orNull()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#orNull--)|返回Optional所包含的引用，若引用缺失，返回null
[Set<T> asSet()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#asSet--)|返回Optional所包含引用的单例不可变集，如果引用存在，返回一个只有单一元素的集合，如果引用缺失，返回一个空集合。

除了这些，Optional还提供了一些方便的工具方法，请查询JavaDoc以获取更多细节。
### 要点
除了给null命名从而提升了可读性，Optional最大的优势在于它是一种傻瓜式的防护。它强迫你为了让你的程序通过编译而主动思考值不存在的例子，因为你必须主动解封Optional并应对这样的例子。Null很容易使人忘掉某些例子，即使有FindBugs的帮助，我们也不认为它可以很好地处理这些异常情况。

当需要返回值表明存在或不存在时，这尤其相关。当你（或他人）实现other.method(a, b)你可能不会忘记a为null的情况，但你很可能会忘记other.method可能会返回null。返回Optional使调用者不可能忘记这个，因为调用者必须解封Optional来使代码通过编译。
### Convenience methods
无论何时你想用某个缺省值替换null，使用[MoreObjects.firstNonNull(T, T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/MoreObjects.html#firstNonNull-T-T-)。正如方法名标明的，如果两个输入值皆为null，它快速失败并抛出NullPointerException。如果你是用Optional，有更好的选择，比如first.or(second)。

Strings提供了一些方法来处理字符串null，特别地，我们提供了以下一些方法：
- [emptyToNull(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#emptyToNull-java.lang.String-)
- [isNullOrEmpty(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#isNullOrEmpty-java.lang.String-)
- [nullToEmpty(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#nullToEmpty-java.lang.String-)
  
我们再次强调这些方法主要用于这样一下API：它们把null字符串和空字符串同等对待。Guava团队会为每次你编码混淆null字符串和空字符串而伤心（把null字符串和空字符串看做不同的对象会更好，但把它们视为同样的对象来处理通常是一种令人惊讶的代码味道）。

## Reference
- [UsingAndAvoidingNullExplained](https://github.com/google/guava/wiki/UsingAndAvoidingNullExplained)