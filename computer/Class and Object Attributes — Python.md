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

### 属性的继承

在开始这个主题之前，让我们看看 `__dict__` 这个内建属性。

```
class Example:
    classAttr = 0
    def __init__(self, instanceAttr):
        self.instanceAttr = instanceAttr
a = Example(1)
print(a.__dict__)
print(Example.__dict__)
Output:
{'instanceAttr': 1}
{'__module__': '__main__', '__doc__': None, '__dict__': <attribute '__dict__' of 'Example' objects>, '__init__': <function Example.__init__ at 0x7f8af2113f28>, 'classAttr': 0, '__weakref__': <attribute '__weakref__' of 'Example' objects>}
```

正如我们看到的，类和对象都有一个持有属性键值对的字典。类字典拥有多个对象不包含的内建属性。

```
b = Example(2)
print(b.classAttr)
print(Example.classAttr)
b.classAttr = 653
print(b.classAttr)
print(Example.classAttr)
Output:
0
0
653
0
```

喔喔。回到我早先写的，一个类的所有实例共享同样的类属性。这里发生了什么？我们修改了一个特定实例的类属性，但共享变量实际上并未改变。看看这些类、对象的字典将给我们深入的洞察。

```
b = Example(2)
print(b.__dict__)
print(Example.__dict__)
b.classAttr = 653
print(b.__dict__)
print(Example.__dict__)
Output:
{'instanceAttr': 2}
'__module__': '__main__', '__doc__': None, '__dict__': <attribute '__dict__' of 'Example' objects>, '__init__': <function Example.__init__ at 0x7f8af2113f28>, 'classAttr': 0, '__weakref__': <attribute '__weakref__' of 'Example' objects>}
{'instanceAttr': 2, 'classAttr': 653}
{'__module__': '__main__', '__doc__': None, '__dict__': <attribute '__dict__' of 'Example' objects>, '__init__': <function Example.__init__ at 0x7f8af2113f28>, 'classAttr': 0, '__weakref__': <attribute '__weakref__' of 'Example' objects>}
```

仔细看看，我们注意到 classAttr 被添加到对象的属性字典里了，带有其修改过的值。类字典里其值保持不变，这展示了类属性有时行为与对象属性类似。

### 结论

总而言之，类和对象属性是很有用的，但一起使用时可能引起混淆。当每个对象都需要共享一个变量时，比如计数器，类属性时有利的。当每个单独对象需要自己的值或者需要与其它对象区分时，对象属性具有优势。

### Reference

- [Class and Object Attributes — Python](https://medium.com/swlh/class-and-object-attributes-python-8191dcd1f4cf)
- [Python's property(): Add Managed Attributes to Your Classes](https://realpython.com/python-property/)