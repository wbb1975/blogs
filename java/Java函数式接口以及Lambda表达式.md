# Java函数式接口以及Lambda表达式

## 1. 为什么使用 Lambda 表达式

Lambda 表达式是一个 匿名函数，我们可以把 Lambda 表达式理解为是一段可以传递的代码（将代码像数据一样可以传递）。使用它可以写出更简洁、灵活的代码。

## 2. Lambda 表达式的本质与函数式接口

Lambda 表达式在 Java 中本质还是一个对象，它针对的是**函数式接口**，它可以产生**函数式接口的一个匿名实现类的实例**。

所以，**以前我们用匿名实现类实现的代码，都可以通过Lambda 表达式来更简单的书写**。

能够用Lambda 表达式实现的接口有一定的要求，就是**接口中只能有唯一的一个抽象方法**。正因为只有唯一的一个抽象方法需要去实现，所以Lambda 表达式不需要我们去指明到底是哪一个方法需要去实现。

而一个接口中，如果只声明了一个抽象方法，则此接口就称为**函数式接口**。

我们举两个例子来展示函数式接口长什么样：
```
@FunctionalInterface
public interface Runnable {
    /**
     * When an object implementing interface <code>Runnable</code> is used
     * to create a thread, starting the thread causes the object's
     * <code>run</code> method to be called in that separately executing
     * thread.
     * <p>
     * The general contract of the method <code>run</code> is that it may
     * take any action whatsoever.
     *
     * @see     java.lang.Thread#run()
     */
    public abstract void run();
}
```

```
@FunctionalInterface
public interface Comparator<T> {
    int compare(T o1, T o2);
}
```

我们也可以自己定义一个函数式接口玩一玩：
```
// @FunctionalInterface 这个注解加不加都不影响MyInterface是一个函数接口的事实
// 不加一样也可以使用我们后面即将讲到的 Lambda 表达式
// 此注解 仅仅起到检验的作用
@FunctionalInterface
public interface MyInterface<T> {
	public abstract void method(T o);
}
```

我们可以在一个函数式接口上使用 @FunctionalInterface 注解，这样做可以检验它是否是一个函数式接口。同时，javadoc 也会包含一条声明，说明该接口是一个函数式接口。

在 `java.util.function` 包下，定义了丰富的函数式接口，注意下图中'函数型接口' 和我们之前一直提到的'函数式接口' 的差异。

函数式接口|方法名|输入参数|输出参数|参数/吃草 返回/挤奶
--------|--------|--------|--------|--------
消费型接口Consumer\<T>|void accept(T t)|T|void|只吃草不挤奶
供给型接口Supplier\<T>|T get（）|void|T|只挤奶不吃草
函数型接口Function<T, R>|R apply（T t）|T|R|又吃草又挤奶
断言型接口Predicate\<T>|boolean test（T t）|T|boolean|Boolean类型

其它接口：

函数式接口|参数类型|返回类型|用途
--------|--------|--------|--------
BiFunction<T, U, R>|T, U|R|对类型为 T, U 的参数应用操作，返回 R 类型的结果。包含方法为：**R apply（T, U）**
UnaryFunction\<T>（Function子接口）|T|T|对类型为 T 的对象进行一元计算，并返回 T 类型的结果。包含方法为：**T apply（T）**
BinaryFunction\<T>（BiFunction子接口）|T, T|R|对类型为 T 的对象进行二元计算，并返回 T 类型的结果。包含方法为：**T apply（T t1, T t2）**
BiConsumer<T, U>|T, U|void|对类型为 T, U 的参数应用操作。包含方法为：**void accept（T, U）**
BiPredicate<T, U>|T, U|boolean|包含方法为：**void test（T, U）**
ToIntFunction\<T> ToLongFunction\<T> ToDoubleFunction\<T>|T|int, long double|分别为 int，long，double 类型的参数
IntFunction\<R> LongFunction\<R> DoubleFunction\<R>|int long double|R|参数分别 int，long，double 值的参数

## 3. Lambda 表达式的使用

0. `(parameters) -> expression 或 (parameters) -> { statements; }`
1. 举例：` (o1, o2) -> Integer.compare(o1, o2);`
2. 格式：

    + ->：Lambda操作符 或 箭头操作符
    + ->左侧 ：Lambda形参列表 （其实就是接口中抽象方法的形参列表）
    + ->右侧 ：Lambda体 （其实就是重写的抽象方法的方法体）

### (1) 无参，且无返回值

```
// 匿名内部类写法
Runnable r1 = new Runnable() {	// 父类引用指向子类对象
    @Override
    public void run() {
        while (true) {
            System.out.println("线程正在执行中~~~");
        }
    }
};

// 等价于
Runnable r2 = () -> {	// lambda 方法体
    while (true) {
        System.out.println("线程正在执行中~~~");
    }
};
```

### (2) 一个参数，无返回值

```
// 消费型接口：只接收参数，但是无返回值
Consumer<String> consumer = new Consumer<String>() { // 父类引用指向子类对象
    @Override
    public void accept(String s) {
        System.out.println(s);
    }
};

// 等价于
Consumer<String> consumer = (String s) -> {
    System.out.println(s);
};
```

### (3) 形参的数据类型可以省略，编译器可以由编译类型推断得出

```
// 类型推断，可以省略参数
Consumer<String> consumer = (String s) -> {
    System.out.println(s);
};

// 等价于
Consumer<String> consumer = (s) -> {
    System.out.println(s);
};

// 类型推断不仅Lambda表达式中有，讲集合的时候也用到过
ArrayList<String> list = new ArrayList<String>();
// 可以直接写为
ArrayList<String> list = new ArrayList<>();
```

### (4) 形参若只需要一个参数时，参数的小括号可以省略

```
// 参数唯一时，可以省略小括号
Consumer<String> consumer = (s) -> {
    System.out.println(s);
};

// 等价于
Consumer<String> consumer = s -> {
     System.out.println(s);
};

```

### (5) 两个或两个以上参数，多条执行语句，并且可以有返回值

```
Comparator<Integer> comparator = new Comparator<Integer>() {
    @Override
    public int compare(Integer o1, Integer o2) {
        System.out.println(o1);
        System.out.println(o2);	// 模拟通用情况，有多条语句
        return o1.compareTo(o2);
    }
};

// 等价于
Comparator<Integer> comparator = (o1, o2) -> {
    System.out.println(o1);
    System.out.println(o2);	// 模拟通用情况，有多条语句
    return o1.compareTo(o2);
};
```

### (6) 当 Lambda体 只有一条语句时，关键字return 和 方法体的大括号都可以省略

```
// 例子1：
Comparator<Integer> comparator = (o1, o2) -> {
    return o1.compareTo(o2);
};

// 等价于（return和{}要么同时不写，要么同时写）
Comparator<Integer> comparator = (o1, o2) -> o1.compareTo(o2);
```

```
// 例子2：
Consumer<String> consumer = s -> {
    System.out.println(s);
};

// 等价于
Consumer<String> consumer = s -> System.out.println(s);
```

### 小结：Lambda 表达式使用的总结

+ -> 左侧：Lambda形参列表的参数类型可以省略（编译类型自动推断）；如果Lambda形参列表只有一个参数，其()可以省略；
+ -> 右侧：Lambda体应该使用一对{}进行包裹；如果Lambda体只有一条执行语句（可能是return语句），可以省略{}和return关键字。

## 4. 函数式接口与Lambda表达式结合的示例

### 4.1 消费型接口的使用

```
public class Main {
    @Test
    public void testOldWay() {    // 匿名实现类的方式
        spendMoney(500, new Consumer<Double>() {
            @Override
            public void accept(Double money) {
                System.out.println("消费了 " + money + " 元。");
            }
        });
    }

    @Test
    public void testNewWay() { // 使用Lambda 表达式的方式
        spendMoney(500, money -> System.out.println("消费了 " + money + " 元。"));
    }

    public void spendMoney(double money, Consumer<Double> consumer) {
         consumer.accept(money);
    }
}
```

### 4.2 断定型接口的使用

```
public class Main {
    private List<String> list = Arrays.asList("北京", "南京", "天津", "吴京", "普京");
    @Test
    public void testOldWay() {	// 传统匿名实现类的方式，筛选含"京"的字符串
        List<String> newStrs = filterString(list, new Predicate<String>() {
            @Override
            public boolean test(String s) {
                return s.contains("京");
            }
        });
    }

    @Test
    public void testNewWay() {	// 使用Lambda 表达式的方式，筛选含"京"的字符串
        List<String> newStrs = filterString(list, s -> s.contains("京"));
    }

    // 根据传入的规则，过滤集合中的字符串。此规则由Predicate接口的实现类决定
    public List<String> filterString(List<String> list, Predicate<String> predicate) {
        ArrayList<String> newList = new ArrayList<>();
        for (String s : list) {
            if (predicate.test(s)) {
                newList.add(s);
            }
        }
        return newList;
    }
}
```

## Reference
- [Java的函数式接口以及Lambda表达式](https://blog.csdn.net/ban__yue/article/details/124997073)
- [Java8新特性-Lambda表达式与函数式接口](https://blog.csdn.net/m0_46680603/article/details/121175862)