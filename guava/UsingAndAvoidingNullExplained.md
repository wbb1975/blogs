# Using and avoiding null
##### [原文地址](https://github.com/google/guava/wiki/UsingAndAvoidingNullExplained)
> "Null sucks." -Doug Lea

> "I call it my billion-dollar mistake." - Sir C. A. R. Hoare, on his invention of the null reference

null的随意使用可能导致各种令人震惊的错误（bugs）。经过对Google代码的研究，我们发现约有９５％的集合假设不会包含null，而且
当遇见null时，马上拒绝它而不是静静地接受它对开发者来说更有帮助。

另外，null会导致歧义，这令人相当不快。一个null返回值有明确含义的情况相当罕见--比如，Map.get(key)可能返回null可能因为map
中的key的对应值值为null,也可能是因为map不含有这个key。null可能意味着成功，也可能意味着失败，甚至可以意味着任何东西。为了使
你的意图表达得更清楚，请不要使用null。

即便如此，有一些情况下null是合适的选择。从内存和速度角度null是廉价的，在使用对象数组时它也是必须的。但在应用代码中，与库代码相反，
null是各种混淆，怪异艰难的缺陷以及令人不快的歧义的主要源头，例如，Map.get返回一个null，它可能意味着没有这个值或者有这个值但值为null。
最为关键的是，null对于null值代表什么意思不能提供任何指示。

基于以上原因，许多Guava的工具被设计为在遇到null时如果有null有好的变通方案则尽快失败而不是允许null被使用。另外Guava提供了很多设施
来帮你在必须的场合更容易使用null，或者避免使用null。

### 具体案例(Specific Cases)
如果你想在Set中存储null或者在Map中使用null作为一个键－－请不要这样使用；在集合或映射的查找过程中对null显式特殊对待，会使得逻辑更清晰。

如果你想在Map中使用null作为一个值，略去这条记录；使用单独的Set存储非null键或null键。对于Map，以下两种情况很容易混淆：Map含有一个键
值对其值为null，或者Map不含这个键。最好把这些键分离开来，并仔细考虑在你的应用中一个键对应的值为null意味着什么。

如果你在一个List中使用null，如果这个List有效值不多，或许你应该使用Map<Integer, E>？它实际上更有效率，而且可能实际上能更准确的匹配
你的应用的需求。

考虑假如有有一个自然的null对象可供使用－－不总是有，但有时候有。比如一个枚举类型，添加一个常量来代替null所代表的语义。又比如，java.math.RoundingMode有一个UNNECESSARY来表明“不做圆整，如果需要就抛出一个异常”。

如果你确实需要null，并且你受阻于对null不友好的集合实现，换一个实现。例如，用Collections.unmodifiableList(Lists.newArrayList())
代替ImmutableList。

### Optional
许多例子中程序员用null来表明某种不存在：或许存在某个值，或者none，或者不存在。例如，如果某个key对应的值不存在，Map.get就会返回null。

Optional<T>是一个用非null值来代替以为null的T引用的方式。一个Optional或者拥有一个非null的T引用（在这种情况下我们说引用存在），或者
不拥有任何引用（在这种情况下我们说引用缺位）。它永远不说拥有null。
```
Optional<Integer> possible = Optional.of(5);
possible.isPresent(); // returns true
possible.get(); // returns 5
```

Optional并非用于任何现有可选"option"的直接近似物，也并非直接从其它编程环境构造而来，虽然可能有一些相似性。
我们把一些最常用的Optional操作罗列如下：

###＃ Making an Optional

下面的每个都是Optional的静态方法

**Method**|**Description**
----------|---------------
[Optional.of(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#of-T-)|Make an Optional containing the given non-null value, or fail fast on null.
[Optional.absent()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#absent--)|Return an absent Optional of some type.
[Optional.fromNullable(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#fromNullable-T-)|Turn the given possibly-null reference into an Optional, treating non-null as present and null as absent.

###＃ Query methods

以下这些每个都是正对Optional<T>值的非静态方法

**Method**|**Description**
----------|---------------
[boolean isPresent()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#isPresent--)|Returns true if this Optional contains a non-null instance.
[T get()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#get--)|Returns the contained T instance, which must be present; otherwise, throws an IllegalStateException.
[T or(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#or-T-)|Returns the present value in this Optional, or if there is none, returns the specified default.
[T orNull()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#orNull--)|Returns the present value in this Optional, or if there is none, returns null. The inverse operation of fromNullable.
[Set<T> asSet()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Optional.html#asSet--)|Returns an immutable singleton Set containing the instance in this Optional, if there is one, or otherwise an empty immutable set.

除了这些，Optional还提供了一些方便的工具方法，请查询JavaDoc以获取更多细节。

### 要点
除了给null命名从而提升了可读性，Optional最大的优势在于它的简单简单易解。它强迫你为了让你的程序通过编译而主动思考值不存在的例子，因为你必须主动解封Optional并应对这样的例子。Null很容易使人忘掉某些例子，即使有FindBugs的帮助，我们也不认为可以很好地处理这些。

当需要返回值表明存在或不存在时，这尤其相关。当你实现other.method(a, b)而a为null的时候，你很可能会忘记other.method可能会返回null。返回Optional使调用者不可能忘记这个，因为调用者必须解封Optional来使代码通过编译。

### Convenience methods
无论何时你想用某个缺省值替换null，使用[MoreObjects.firstNonNull(T, T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/MoreObjects.html#firstNonNull-T-T-)。
正如方法名标明的，如果两个输入值皆为null，它快速失败并抛出NullPointerException。如果你是用Optional，有更好的选择，比如first.or(second)。

Strings提供了一些方法来处理字符串null，特别地，我们提供了以下一些方法：
- [emptyToNull(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#emptyToNull-java.lang.String-)
- [isNullOrEmpty(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#isNullOrEmpty-java.lang.String-)
- [nullToEmpty(String)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/base/Strings.html#nullToEmpty-java.lang.String-)
  
我们再次强调这些方法主要用于这样一下API：它们把null字符串和空字符串同等对待。Guava团队会为每次你编码合并null字符串和空字符串而伤心（把null字符串和空字符串看做不同的对象会更好，但把它们视为同样的对象来处理通常是一种令人惊讶的代码味道）。