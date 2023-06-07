## JavaBean

JavaBean 是一个[标准](http://www.oracle.com/technetwork/java/javase/documentation/spec-136004.html)。它是个一个常规 `Java 类`，除了它遵循一些规则：

- 所有属性私有（使用 [getters/setters](http://en.wikipedia.org/wiki/Mutator_method)）
- 一个[公开无参构造函数](http://en.wikipedia.org/wiki/Nullary_constructor)
- 实现 [Serializable](http://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html) 接口

### Mutator 方法


### Serializable 接口

一个类的序列化能力通过类实现  java.io.Serializable 接口开启。没有实现这个接口的类将不会拥有任何需要序列化或反序列化的状态。一个可序列化的所有子类型可自行决定是否支持序列化。序列化接口没有任何方法或字段，仅仅拥有标记这个类为可序列化这个语义。

为了让非序列化类的所有子类编程可序列化的，子类型将承担超类类型的 public, protected, 以及 (如果可访问) 包字段的状态的保存和恢复职责。只有当子类型继承的父类有一个可访问的无参构造函数可初始化其类状态时子类才可以承担这个职责。如果不满足这个条件，声明一个类可序列化的就是一个错误。这个错误将会在运行时被检测到。

在反序列化时，非序列化类的字段将会用该类的公开或保护无参构造函数初始化。一个无参构造函数必须对可序列化子类可访问。序列化子类的字段将会从流上回复。

当遍历一个图时，可能遇到一个对象不支持 Serializable 接口。在这种情况下一个 NotSerializableException 将会抛出并会识别出不可序列化对象的类。

在序列化和反序列化过程中需要特殊处理的类必须实现带有如下精确签名的特定方法。

```
private void writeObject(java.io.ObjectOutputStream out)
     throws IOException
 private void readObject(java.io.ObjectInputStream in)
     throws IOException, ClassNotFoundException;
 private void readObjectNoData()
     throws ObjectStreamException;
```

writeObject 方法负责输出特定类的对象的状态，如此对应的 readObject 方法可以恢复它。保存对象字段的默认机制可通过调用 out.defaultWriteObject 触发。方法无需担心自身超类及子类的状态。通过使用 writeObject 方法或者 DataOutput 支持的原始数据类型相关方法将各个字段写至 ObjectOutputStream 来保存状态。

readObject 方法负责从流读取并恢复类字段。它可能调用 in.defaultReadObject 来触发默认以恢复对象的非静态和非易变字段。defaultReadObject 方法使用流里的信息将流里的字段值赋值给当前对象的对应命名字段。这用于处理类经过演化添加了新字段的场景。方法无需担心自身超类及子类的状态。通过使用 writeObject 方法或者 DataOutput 支持的原始数据类型相关方法将各个字段写至 ObjectOutputStream 来保存状态。

当序列化流没有将一个类列为被反序列化的对象的超类时，readObjectNoData 方法负责初始化这个特定类的对象状态。当接收方使用一个一个不同于发送方的反序列化实例类的版本，并且接收方扩展了一个发送方未成扩展的类版本时，这类场景将会触发它。序列化流被篡改后也会出现这种情况；readObjectNoData 方法当出现恶意的或者不完全的流初始化反序列对象时有用的。

### Reference

- [JavaBean](https://stackoverflow.com/questions/3295496/what-is-a-javabean-exactly)