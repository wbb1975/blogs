##  散列（Hashing） 
### 1. 概述（Overview）
Java内建的散列码[hash code]概念被限制为32位，并且没有分离散列算法和它们所作用的数据，因此很难用备选算法进行替换。此外，使用Java内建方法实现的散列码通常是劣质的，部分是因为它们最终都依赖于JDK类中已有的劣质散列码。

Object.hashCode往往很快，但是在预防碰撞上却很弱，也没有对分散性的预期。这使得它们很适合在散列表中运用，因为额外碰撞只会带来轻微的性能损失，同时差劲的分散性也可以容易地通过再散列来纠正（Java中所有合理的散列表都用了再散列方法）。然而，在简单散列表以外的散列运用中，Object.hashCode几乎总是达不到要求——因此，有了[com.google.common.hash](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/package-summary.html)包。
### 2. 散列包的组成（Organization）
在这个包的Java doc中，我们可以看到很多不同的类，但是文档中没有明显地表明它们是怎样 一起配合工作的。在介绍散列包中的类之前，让我们先来看下面这段代码范例：
```
HashFunction hf = Hashing.md5();
HashCode hc = hf.newHasher()
       .putLong(id)
       .putString(name, Charsets.UTF_8)
       .putObject(person, personFunnel)
       .hash();
```
#### 2.1 HashFunction
[HashFunction](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashFunction.html)是一个无状态的纯函数，它把任意的数据块映射到固定数目的字节位数，并且保证相同的输入一定产生相同的输出，不同的输入尽可能产生不同的输出。
#### 2.2 Hasher
HashFunction的实例可以提供有状态的[Hasher](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hasher.html)，Hasher提供了流畅的语法把数据添加到散列运算，然后获取散列值。Hasher可以接受所有原生类型、字节数组、字节数组的片段、字符序列、特定字符集的字符序列等等，或者任何给定了Funnel实现的对象。

Hasher实现了PrimitiveSink接口，这个接口为接受原生类型流的对象定义了fluent风格的API
#### 2.3 Funnel
[Funnel](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Funnel.html)描述了如何把一个具体的对象类型分解为原生字段值，从而写入PrimitiveSink。比如，如果我们有这样一个类：
```
class Person {
  final int id;
  final String firstName;
  final String lastName;
  final int birthYear;
}
```
它对应的Funnel实现可能是：
```
Funnel<Person> personFunnel = new Funnel<Person>() {
  @Override
  public void funnel(Person person, PrimitiveSink into) {
    into
        .putInt(person.id)
        .putString(person.firstName, Charsets.UTF_8)
        .putString(person.lastName, Charsets.UTF_8)
        .putInt(birthYear);
  }
};
```
> **注意**：putString(“abc”, Charsets.UTF_8).putString(“def”, Charsets.UTF_8)完全等同于putString(“ab”, Charsets.UTF_8).putString(“cdef”, Charsets.UTF_8)，因为它们提供了相同的字节序列。这可能带来预料之外的散列冲突。增加某种形式的分隔符有助于消除散列冲突。
#### 2.4 HashCode
一旦Hasher被赋予了所有输入，就可以通过[hash()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hasher.html#hash--)方法获取[HashCode](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashCode.html)实例（多次调用hash()方法的结果是不确定的）。HashCode可以通过[asInt()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashCode.html#asInt--)、[asLong()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashCode.html#asLong--)、[asBytes()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashCode.html#asBytes--)方法来做相等性检测，此外，[writeBytesTo(array, offset, maxLength)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/HashCode.html#writeBytesTo-byte%5B%5D-int-int-)把散列值的前maxLength字节写入字节数组。
### 3. 布隆过滤器（BloomFilter）
布隆过滤器是哈希运算的一项优雅运用，它不能简单地基于Object.hashCode()实现。简而言之，布隆过滤器是一种概率数据结构，它允许你检测某个对象是一定不在过滤器中，还是可能已经添加到过滤器中了。[布隆过滤器的维基页面](http://en.wikipedia.org/wiki/Bloom_filter)对此作了全面的介绍，同时我们推荐[github中的一个教程](http://llimllib.github.com/bloomfilter-tutorial/)。

Guava散列包有一个内建的布隆过滤器实现，你只要提供Funnel就可以使用它。你可以使用[create(Funnel funnel, int expectedInsertions, double falsePositiveProbability)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/BloomFilter.html#create-com.google.common.hash.Funnel-int-double-)方法获取[BloomFilter<T>](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/BloomFilter.html)，缺省误检率[falsePositiveProbability]为3%。BloomFilter<T>提供了[boolean mightContain(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/BloomFilter.html#mightContain-T-) 和[void put(T)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/BloomFilter.html#put-T-)，它们的含义都不言自明了。
```
BloomFilter<Person> friends = BloomFilter.create(personFunnel, 500, 0.01);
for (Person friend : friendsList) {
  friends.put(friend);
}
// 很久以后
if (friends.mightContain(dude)) {
  // dude不是朋友还运行到这里的概率为1%
  // 在这儿，我们可以在做进一步精确检查的同时触发一些异步加载
}
```
### 4. Hashing类（Hashing）
#### 4.1 提供的散列函数
Hashing类提供了若干散列函数，以及运算HashCode对象的工具方法。
- [md5()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#md5--)
- [murmur3_128()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#murmur3_128--)
- [murmur3_32()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#murmur3_32--)
- [sha1()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#sha1--)
- [sha256()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#sha256--)
- [sha512()](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#sha512--)
- [goodFastHash(int bits)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#goodFastHash-int-)
#### 4.2 HashCode运算
方法|描述
--------|--------
[HashCode combineOrdered( Iterable<HashCode>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#combineOrdered-java.lang.Iterable-)|以有序方式联接散列码，如果两个散列集合用该方法联接出的散列码相同，那么散列集合的元素可能是顺序相等的
[HashCode  combineUnordered( Iterable<HashCode>)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#combineUnordered-java.lang.Iterable-)|以无序方式联接散列码，如果两个散列集合用该方法联接出的散列码相同，那么散列集合的元素可能在某种排序下是相等的
[int   consistentHash( HashCode, int buckets)](http://google.github.io/guava/releases/snapshot/api/docs/com/google/common/hash/Hashing.html#consistentHash-com.google.common.hash.HashCode-int-)|为给定的”桶”大小返回一致性哈希值。当”桶”增长时，该方法保证最小程度的一致性哈希值变化。详见[一致性哈希](http://en.wikipedia.org/wiki/Consistent_hashing)。

## Reference
- [Hashing Explained](https://github.com/google/guava/wiki/StringsExplained)