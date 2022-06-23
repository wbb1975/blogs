## 方法引用
> 这个 Java 教程是为 JDK 8 写的。这个页面里描述的例子和实践并未利用之后的发布版本引入的改进，也可能利用了一些不再使用的技术。
> 参考 [Java 语言变化](https://docs.oracle.com/pls/topic/lookup?ctx=en/java/javase&id=java_language_changes) 以查看Java SE 9 机器后续发布引入的更新的语言特性总结。
> 参考 [JDK 发布指南](https://www.oracle.com/technetwork/java/javase/jdk-relnotes-index-2162236.html) 以获取所有 JDK 发布的新特性，增强，移除或标记为废弃选项的信息。

你使用 [lambda 表达式](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html) 来创建匿名方法。但是，有时候一个 lambda 表达式仅仅调用一个已经存在的方法。在这种情况下，通过名字引用已经存在的方法经常会更清晰。方法引用使你实现上述目标成为可能。它们是简洁的，针对方法名的易读的 lambda 表达式。

让我们再次考虑在[lambda 表达式](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html)一节引入的 [Person 类](https://docs.oracle.com/javase/tutorial/java/javaOO/examples/Person.java)：
```
public class Person {

    // ...
    
    LocalDate birthday;
    
    public int getAge() {
        // ...
    }
    
    public LocalDate getBirthday() {
        return birthday;
    }   

    public static int compareByAge(Person a, Person b) {
        return a.birthday.compareTo(b.birthday);
    }
    
    // ...
}
```

假设你的社交网络应用的成员放在一个数组里，你想对它们基于年纪排序。你可以使用下面的代码（从 [MethodReferencesTest](https://docs.oracle.com/javase/tutorial/java/javaOO/examples/MethodReferencesTest.java) 中摘取过来）：
```
Person[] rosterAsArray = roster.toArray(new Person[roster.size()]);

class PersonAgeComparator implements Comparator<Person> {
    public int compare(Person a, Person b) {
        return a.getBirthday().compareTo(b.getBirthday());
    }
}
        
Arrays.sort(rosterAsArray, new PersonAgeComparator());
```

`sort` 调用的方法签名如下：
```
static <T> void sort(T[] a, Comparator<? super T> c)
```

注意 Comparator 接口是一个函数式接口。因此，你应当使用一个 lambda 表达式代替定义一个实现了 `Comparator`　的类并创建其示例：
```
Arrays.sort(rosterAsArray,
    (Person a, Person b) -> {
        return a.getBirthday().compareTo(b.getBirthday());
    }
);
```

但是，这个比较两个 `Person` 实例的出生日期的方法已经存在：`Person.compareByAge`。你可以调用这个方法来代替 lambda 表达式的代码块：
```
Arrays.sort(rosterAsArray,
    (a, b) -> Person.compareByAge(a, b)
);
```

因为这个 lambda 表达式调用已经存在的方法，你可以使用一个方法引用而非 lambda 表达式：
```
Arrays.sort(rosterAsArray, Person::compareByAge);
```

方法引用 `Person::compareByAge` 语义上与 lambda 表达式 `(a, b) -> Person.compareByAge(a, b)` 一样。每个都拥有下面的特征：
- 它们的正是参数列表从 `Comparator<Person>.compare` 拷贝而来，它们是 `(Person, Person)`
- 内部都调用方法 `Person.compareByAge`

### 方法引用的种类
有四种方法引用：

种类|语法|示例
--------|--------|--------
静态方法引用|ContainingClass::staticMethodName|Person::compareByAge, MethodReferencesExamples::appendStrings
对特定对象实例方法的引用|containingObject::instanceMethodName|myComparisonProvider::compareByName, myApp::appendStrings2
对特定类型的任意实例方法的引用|ContainingType::methodName|String::compareToIgnoreCase, String::concat
对构造函数的引用|ClassName::new|HashSet::new

下面的例子，[MethodReferencesExamples](https://docs.oracle.com/javase/tutorial/java/javaOO/examples/MethodReferencesExamples.java)，包含方法引用前三种类型的例子：
```
import java.util.function.BiFunction;

public class MethodReferencesExamples {
    
    public static <T> T mergeThings(T a, T b, BiFunction<T, T, T> merger) {
        return merger.apply(a, b);
    }
    
    public static String appendStrings(String a, String b) {
        return a + b;
    }
    
    public String appendStrings2(String a, String b) {
        return a + b;
    }

    public static void main(String[] args) {
        
        MethodReferencesExamples myApp = new MethodReferencesExamples();

        // Calling the method mergeThings with a lambda expression
        System.out.println(MethodReferencesExamples.
            mergeThings("Hello ", "World!", (a, b) -> a + b));
        
        // Reference to a static method
        System.out.println(MethodReferencesExamples.
            mergeThings("Hello ", "World!", MethodReferencesExamples::appendStrings));

        // Reference to an instance method of a particular object        
        System.out.println(MethodReferencesExamples.
            mergeThings("Hello ", "World!", myApp::appendStrings2));
        
        // Reference to an instance method of an arbitrary object of a
        // particular type
        System.out.println(MethodReferencesExamples.
            mergeThings("Hello ", "World!", String::concat));
    }
}
```
所有 `System.out.println()` 语句输出同样的结果: `Hello World!`

[BiFunction](https://docs.oracle.com/javase/8/docs/api/java/util/function/BiFunction.html) 是 [java.util.function](https://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html) 包中的一个函数式接口。`BiFunction` 函数式接口可以代表一个接受两个参数并产生一个结果的 lambda 表达式和方法引用。

#### 静态方法引用

方法引用 `Person::compareByAge` 和 `MethodReferencesExamples::appendStrings` 都是对静态方法的引用。

#### 对特定对象实例方法的引用

下面是引用特定对象实例方法的例子：

```
class ComparisonProvider {
    public int compareByName(Person a, Person b) {
        return a.getName().compareTo(b.getName());
    }
        
    public int compareByAge(Person a, Person b) {
        return a.getBirthday().compareTo(b.getBirthday());
    }
}
ComparisonProvider myComparisonProvider = new ComparisonProvider();
Arrays.sort(rosterAsArray, myComparisonProvider::compareByName);
```

方法引用 `myComparisonProvider::compareByName` 调用了作为对象 `myComparisonProvider`　一部分的 `compareByName` 方法。JRE 推导了方法类型参数，其在本例中为 `(Person, Person)`。

类似地，方法引用 `myApp::appendStrings2` 调用了作为对象 `myApp` 一部分的 `appendStrings2` 方法。JRE 推导了方法类型参数，其在本例中为 `(String, String)`。

#### 对特定类型的任意实例方法的引用

下面是引用特定类型的任意对象实例方法的例子：

```
String[] stringArray = { "Barbara", "James", "Mary", "John",
    "Patricia", "Robert", "Michael", "Linda" };
Arrays.sort(stringArray, String::compareToIgnoreCase);
```

方法引用 `String::compareToIgnoreCase` 的对等 lambda 表达式将拥有正式参数列表 `(String a, String b)`，这里 `a` 和 `b` 是用于更好的描述这个实例任意名。这个方法引用将调用方法 `a.compareToIgnoreCase(b)`。

类似地，方法引用 `String::concat` 将调用方法 `a.concat(b)`。

#### 对构造函数的引用

通过使用名字 `new`，你可以像静态方法一样引用构造函数。下面的代码将元素从一个集合拷贝到另一个：

```
public static <T, SOURCE extends Collection<T>, DEST extends Collection<T>>
    DEST transferElements(
        SOURCE sourceCollection,
        Supplier<DEST> collectionFactory) {
        
    DEST result = collectionFactory.get();
    for (T t : sourceCollection) {
        result.add(t);
    }
    return result;
}
```

函数式接口 `Supplier` 包含一个方法 `get`，它不带任何参数但返回一个对象。接下来，你可以调用方法 `transferElements` 并如下传递一个 lambda 表达式：

```
Set<Person> rosterSetLambda = transferElements(roster, () -> { return new HashSet<>(); });
```

你可以如下使用构造函数引用代替 lambda 表达式：

```
Set<Person> rosterSet = transferElements(roster, HashSet::new);
```

Java 编译器推导出你想要创建一个 `HashSet` 集合，它包含 `Person` 类型的元素。可选地，你可以如下指定：

```
Set<Person> rosterSet = transferElements(roster, HashSet<Person>::new);
```

## Reference
- [Method References](https://docs.oracle.com/javase/tutorial/java/javaOO/methodreferences.html)
- [Method References in Java](https://www.baeldung.com/java-method-references)