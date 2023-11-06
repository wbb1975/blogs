## Class and Object Attributes — Python

### 什么是类属性和对象属性？它们有什么区别？为什么？

在讨论这些区别以及类、对象属性示例之前，让我们首先定义它们：

- 类属性是一个属于特定类的属性，不属于一个特殊对象。这个类的每个实例共享同样的变量，这些属性通常在__init__构造函数之外定义。
- 实例或对象属性是一个属于一个（也仅仅）对象的属性。一类的每个对象都指向它自己的属性变量。这些属性通常在__init__构造函数里定义。

### 为什么有这种方式？

为什么我们需要有类属性和对象属性？

在一个平行世界里只有狗，每只狗拥有自己的名字和年纪。狗的总数必须总是保持最新的。所有这些必须定义在一个类里。这可能看起来像这样：

```
class Dog:
    dogs_count = 0
    def __init__(self, name, age):
        self.name = name
        self.age = age
        print("Welcome to this world {}!".format(self.name))
        Dog.dogs_count += 1
    def __del__(self):
        print("Goodbye {} :(".format(self.name))
        Dog.dogs_count -= 1
```

在这个类中，我们拥有一个类属性 `dogs_count`。这个变量追踪我们在狗的世界里的狗的数量。我们还有两个实例属性 `name` 和 `age`。这些属性对于每条狗都是唯一的（每个实例的属性拥有不同的内存位置）。每次 `__init__` 函数被执行时，`dogs_count` 递增。反之--每次一条狗死亡（不幸的是狗不可能永远活在这个世界上）时，调用 `__del__`，`dogs_count` 递减。

```
a = Dog("Max", 1)
print("Number of dogs: {}".format(Dog.dogs_count))
b = Dog("Charlie", 7)
del a
c = Dog("Spot", 4.5)
print("Number of dogs: {}".format(Dog.dogs_count))
del b
del c
print("Number of dogs: {}".format(Dog.dogs_count))
Output:
Welcome to this world Max!
Number of dogs: 1
Welcome to this world Charlie!
Goodbye Max :(
Welcome to this world Spot!
Number of dogs: 2
Goodbye Charlie :(
Goodbye Spot :(
Number of dogs: 0
```

啊哈，我们可以管理每个实例的所有属性，同时所有对象也可以包含一个共享变量。

### Reference

- [Class and Object Attributes — Python]()