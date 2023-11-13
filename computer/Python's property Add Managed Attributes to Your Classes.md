## Python 的 property(): 为你的类添加受控属性

### 1. 管理你的类中的属性

当你在一个[面向对象](https://en.wikipedia.org/wiki/Object-oriented_programming)语言中定义一个[类](https://realpython.com/python-classes/)时，你可能会定义很多实例及类[属性](https://realpython.com/python3-object-oriented-programming/#class-and-instance-attributes)。换句话说，你最终将获得一些通过示例，类或两者一起访问的变量，当然，取决于编程语言。属性代表或持有一个给定对象的内部[状态](https://en.wikipedia.org/wiki/State_(computer_science))，而该对象你经常访问或修改。

典型地，你至少有两种方式来管理属性。你可以直接访问或修改属性或使用方法。方法是绑定于给定类的函数。它们提供了行为或变化，对象可将它们用于内部数据或属性。

如果你将属性暴露给用户，它们将成为你的类的公开[API](https://realpython.com/python-api/)的一部分。你的用户将在代码中直接访问或修改它们，当你需要改变一个属性的内部实现时，问题出现了。

如果你在工作于一个类 Circle，最初的实现仅仅包含一个属性 `.radius`。你完成了你的类并发布给用户使用。他们开始在他们的代码中使用 `Circle` 创建了许多不可思议的项目和应用。完美的工作。

现在假设一个重要用户找到你并向你提出了一个新需求。他们不想 `Circle` 存储 `radius`。他们需要一个公开的 `.diameter` 属性。

在这个点，移除.radius并开始使用.diameter 可能破坏一些终端用户的代码。你需要管理这种状态而不是仅仅移除 .radius。

编程语言如 [Java](https://realpython.com/oop-in-python-vs-java/) 和 [C++](https://en.wikipedia.org/wiki/C%2B%2B) 鼓励你永远不要暴露你的属性以避免类似的问题。取而代之，你应该提供[设置器及读取器](https://realpython.com/python-getter-setter/)方法，也分别称之为[访问器](https://en.wikipedia.org/wiki/Accessor_method)和[修改器](https://en.wikipedia.org/wiki/Mutator_method)。这些方法提供了一种改变你的属性的内部实现而无需改变你的公开 API 的方法。

> 注意：设置器及读取器常被认为是[反模式](https://en.wikipedia.org/wiki/Anti-pattern)的，并且是贫乏的面向对象设计的一个信号。这个主张背后的主要争论是这些方法破坏了封装[proposition ](https://en.wikipedia.org/wiki/Encapsulation_(computer_programming))。它们允许你访问和修改你的对象里的组件。

最后，这些语言需要设置器及读取器，原因在于如果一个需求变化了，它们并未提供一个合适的方式来修改一个属性的内部实现。修改内部实现需要 API 修改，它可能破坏你的终端用户代码。

#### Python 中的设置器及读取器

技术上讲，没有什么可以阻止你在 Python 中继续使用设置器及读取器[方法](https://realpython.com/python3-object-oriented-programming/#instance-methods)。下面是这种方法的例子：

```
# point.py

class Point:
    def __init__(self, x, y):
        self._x = x
        self._y = y

    def get_x(self):
        return self._x

    def set_x(self, value):
        self._x = value

    def get_y(self):
        return self._y

    def set_y(self, value):
        self._y = value
```

在这个例子中，你创建了 Point，带有两个非公开的属性 `._x` 和 `._y` 以方便地持有一个笛卡尔坐标点。

> 注意：Python 没有[访问修饰符](https://en.wikipedia.org/wiki/Access_modifiers)记法如，**private**, **protected**, 和 **public** 来限制对属性和方法的访问。在 Python 中，只有公开和非公开类成员的区别。
>
> 如果你想标记一个给定属性和方法非公开，那么你不得不使用 Python [惯用法](https://www.python.org/dev/peps/pep-0008/#method-names-and-instance-variables)：以下划线开始一个名字。这是命名属性名为 `._x` 和 `._y` 的原因。
>
> 注意这仅仅是一个是惯用法。它不能阻止你和其他程序员使用 **.记法** 访问属性，即 **obj._attr**。但是，违反这些惯用法是一个坏的实践。

为了访问和修改 `._x` 或 `._y` 的值，你可以使用相应的设置器及读取器。接下来将上面 Point 的定义存为一个 Python [模块](https://realpython.com/python-modules-packages/)并在你的[交互式 shell](https://realpython.com/interacting-with-python/)中[导入](https://realpython.com/python-import/)该类。

你可以在你的代码中编写 Point 相关代码如下：

```
>>> from point import Point

>>> point = Point(12, 5)
>>> point.get_x()
12
>>> point.get_y()
5

>>> point.set_x(42)
>>> point.get_x()
42

>>> # Non-public attributes are still accessible
>>> point._x
42
>>> point._y
5
```

利用 `.get_x()` 和 `.get_y()`，你可以访问 `._x` 和 `._y` 的当前值。你可以使用设置器方法在相应管理的属性里存储新的值。从这个代码，你可以确认 Python 不限制对非公开属性的访问。是否这么做取决于你。

#### Pythonic 方式

即使你看到的示例使用了 Python 代码风格，他看起来并不 Pythonic。在这个例子中，设置器及读取器并未比 `._x` 和 `._y` 做更深入地处理。你可以以更简洁更具 Python 风格的方式重写 Point：

```
>>> class Point:
...     def __init__(self, x, y):
...         self.x = x
...         self.y = y
...

>>> point = Point(12, 5)
>>> point.x
12
>>> point.y
5

>>> point.x = 42
>>> point.x
42
```

代码揭示了一个基本的原则。在 Python 中把属性暴露给终端用户是正常且很常见的。你并不总是需要使用设置器及读取器方法从而使你的类杂乱，这听起来很酷。但是，你如何处理涉及到 API 修改的需求变化呢？

不像 Java 和 C++，Python 提供了趁手的工具以允许你修改属性的实现而无需更改你的公开 API。最流行的方式是将属性（attributes） 变成特性（properties）。

> 注意：管理属性的另一个常见方法是使用[描述符](https://realpython.com/python-descriptors/)。但在这个教程里，你将学到特性。

[Properties](https://en.wikipedia.org/wiki/Property_(programming))代表一个位于普通属性（字段）和方法之间的中间功能层。换句话说，它们允许你创建其行为像属性的方法。利用特性，无论何时你都可以修改你计算目标属性的方式。

例如，你可以将 `.x` 和 `.y` 修改为特性。这样修改之后，你可以继续通过属性的方式访问它们。你也会有一个潜在的方法持有 `.x` 和 `.y`，从而允许你修改内部实现，从而在你的用户访问或修改它们之前采取行动。

> 注意：特性并非 Python 特有。语言如 [JavaScript](https://realpython.com/python-vs-javascript/), [C#](https://en.wikipedia.org/wiki/C_Sharp_(programming_language)), [Kotlin](https://en.wikipedia.org/wiki/Kotlin_(programming_language)) 以及其它一些语言也提供了工具和技术来创建特性作为类成员。

Python 特性的主要优势在于它们允许你暴露你的属性作为你的公开 API 的一部分。如果你需要修改其底层实现，那么你可以在任何时候将其转为特性而无需付出太大代价。

在下面的章节，你将学习如何在 Python 中创建特性。

### 2. Python property() 入门

在你的代码中 Python [property](https://docs.python.org/3/library/functions.html#property()) 是避免设置器及读取器方法的 Pythonic 方式。这个功能允许你将[类属性](https://realpython.com/python3-object-oriented-programming/#class-and-instance-attributes)转变为特性或管理的属性。因为 property() 是一个内建功能，你不需要导入任何东西就可使用它们。另外，property() 以 C 实现以确保最优的性能。

> 注意：property() 常被称之为内建函数。然而 property 是一个类，它被设计为象一个函数而非一个普通类那样工作。这也是许多 Python 开发者将之称为函数的原因。这也是 property() 没有遵循 Python [命名类](https://www.python.org/dev/peps/pep-0008/#class-names)规则的原因。
>
> 本教程遵循通常实践将 property() 称之为一个函数而不是一个类。但是，在某些章节，你也将看到它被称之为一个类以帮助解释。

利用 property()，你可以将设置器及读取器附在给定的类属性上。通过这种方式，你就可以无需在你的 API 中暴露设置器及读取器方法而处理属性的内部实现。你也可以指定一种处理属性删除的方式，并为特性提供合适的[文档字符串](https://realpython.com/documenting-python-code/)。

这是 property() 的完整签名：

```
property(fget=None, fset=None, fdel=None, doc=None)
```

头两个参数为函数对象，它们将承担 `getter (fget)` 和 `setter (fset)` 的角色。下面是每个参数的综述：

参数|描述
----|----
fget|函数，用于返回被管理属性的值
fset|函数，用于设置被管理属性的值
fdel|函数，用于定义如何删除被管理属性的值
doc|字符串，代表属性文档字符串

property() 的返回值是被管理属性本身。如果你访问被管理属性，如 `obj.attr`，那么 Python 将会自动调用 `fget()`。如果你对这个属性赋新值，如 `obj.attr = value`，Python 将会使用输入值作为参数调用 `fset()`。最后， 如果你运行 `del obj.attr` 语句，Python 将自动调用 `fdel()`。

> 注意： property()的前三个参数是函数对象。你可以将函数对象视作函数名字，不包含调用括号对。

你可以使用 `doc` 来为你的属性提供一个合适的文档字符串。你和你的程序员小伙伴们可以通过 Python 的 [help()](https://docs.python.org/3/library/functions.html#help)来读取该文档字符串。当你使用支持文档字符串访问的[代码编辑器以及集成开发环境](https://realpython.com/python-ides-code-editors-guide/)时 `doc` 参数也是有用的。

你可以通过[函数](https://realpython.com/defining-your-own-python-function/) 或[装饰器](https://realpython.com/primer-on-python-decorators/) 来使用 property() 从而构建你的属性。在下面的两个章节，你将学会如何使用两种方式。但是，你的预先知道装饰器方式是在 Python 社区更流行的方式。

#### 2.1 使用 property() 创建特性（Creating Attributes With property()）

你可以通过调用 property() 并传递一套合适的参数来创建一个特性，将其返回值赋予给一个类属性。property() 的所有参数是可选的，但是，典型地你至少应该提供一个**设置器函数**。

下面的例子展示了如何创建 Circle 类并携带一个方便的特性以管理其半径：

```
# circle.py

class Circle:
    def __init__(self, radius):
        self._radius = radius

    def _get_radius(self):
        print("Get radius")
        return self._radius

    def _set_radius(self, value):
        print("Set radius")
        self._radius = value

    def _del_radius(self):
        print("Delete radius")
        del self._radius

    radius = property(
        fget=_get_radius,
        fset=_set_radius,
        fdel=_del_radius,
        doc="The radius property."
    )
```

在这个代码片段中，你创建了 `Circle`。类初始化器，`.__init__()` 接受半径作为参数并将其存储为一个非公开的属性 `._radius`。接下来你定义了三个非公开的方法：

- `._get_radius()` 返回当前 `._radius` 值
- `._set_radius()` 接收一个新值并将其赋给 `._radius`
- `._del_radius()` 删除类属性 `._radius`

如果你以上三个方法到位，你就可以创建一个类属性 `.radius` 以存储特性对象。为了初始化特性，你将三个方法作为参数传给 property()。你还为你的特性传递了一个文档字符串。

在这个例子中，你使用了[关键字参数](https://realpython.com/defining-your-own-python-function/#keyword-arguments)来提高代码可读性并防止混淆。这种方式，你将却知道哪个方法匹配了哪个参数。

为了试试 Circle，在 Python shell 中运行下面的代码：

```
>>> from circle import Circle

>>> circle = Circle(42.0)

>>> circle.radius
Get radius
42.0

>>> circle.radius = 100.0
Set radius
>>> circle.radius
Get radius
100.0

>>> del circle.radius
Delete radius
>>> circle.radius
Get radius
Traceback (most recent call last):
    ...
AttributeError: 'Circle' object has no attribute '_radius'

>>> help(circle)
Help on Circle in module __main__ object:

class Circle(builtins.object)
    ...
 |  radius
 |      The radius property.
```

`.radius` 特性隐藏了非公开实例属性 `._radius`， 在这个例子中它是你的一个受管理属性。你可以直接访问或修改 `.radius`。在内部，需要时 Python 自动调用 `._get_radius()` 和 `._set_radius()` 。当你执行 `del circle.radius` 时，Python 调用 `._del_radius()`，它删除底层 `._radius`。

Properties 是类属性用于管理实例属性。你可以将特性视为一个方法的集合。如果你仔细检视 `.radius`，那么你可以找到你提供的的原始方法如 `fget`, `fset`, 和 `fdel` 参数：

```
>>> from circle import Circle

>>> Circle.radius.fget
<function Circle._get_radius at 0x7fba7e1d7d30>

>>> Circle.radius.fset
<function Circle._set_radius at 0x7fba7e1d78b0>

>>> Circle.radius.fdel
<function Circle._del_radius at 0x7fba7e1d7040>

>>> dir(Circle.radius)
[..., '__get__', ..., '__set__', ...]
```

你可以通过对应 `.fget`, `.fset`, 和 `.fdel` 访问一个给定特性的 `getter`, `setter` 和 `deleter` 方法。

特性也覆盖了描述符。如果你使用 [dir()](https://realpython.com/python-scope-legb-rule/#dir)来检查一个特性的内部成员，那么你将在列表中发现 .`__set__()` 和 `.__get__()`。这些方法提供了[描述符协议](https://docs.python.org/3/howto/descriptor.html#descriptor-protocol)的默认实现。

> 注意： 如果你想更好的理解特性作为一个类的内部实现，你可以查阅文档描述的[纯粹Python property类](https://docs.python.org/3/howto/descriptor.html#properties)。

当你没提供自定义设置器方法时 `.__set__()` 的默认实现将会运行。在这个例子中，由于没有方法来设置底层特性，你将得到一个 `AttributeError` 异常。

#### 2.2 使用装饰器创建特性（Using property() as a Decorator）

装饰器在 Python 中随处可见。它们是函数，接受另一个函数作为参数，返回一个带有附加功能的的新函数。利用装饰器，你可以为一个已有函数附加事前和事后处理的操作。

当 [Python 2.2](https://docs.python.org/3/whatsnew/2.2.html#attribute-access) 引入 property() 时，装饰器语法还不可用。定义特性的唯一方法就是传递如你已经学过的 `getter`, `setter` 和 `deleter`。装饰器语法自 [Python 2.4](https://docs.python.org/3/whatsnew/2.4.html#pep-318-decorators-for-functions-and-methods) 引入，到现在，使用装饰器来实现 property() 已经成为 Python 社区最流行的实践。

装饰器语法包括在你要装饰的函数定义之前加上装饰器函数名字并饰之于 `@` 前缀：

```
@decorator
def func(a):
    return a
```

在上面的代码中，`@decorator` 可以是一个函数或一个类用以装饰 `func`。其语法实际与下面的等同：

```
def func(a):
    return a

func = decorator(func)
```

最后一行代码指定 `func` 名用于持有调用 `decorator(func)` 的结果。注意这是与上面你创建特性的语法一样。

Python 的 `property()` 可以用装饰器实现，因此你可以使用 `@property` 语法快速创建你的特性：

```
# circle.py

class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        """The radius property."""
        print("Get radius")
        return self._radius

    @radius.setter
    def radius(self, value):
        print("Set radius")
        self._radius = value

    @radius.deleter
    def radius(self):
        print("Delete radius")
        del self._radius
```

代码看上去与读取器设置器方式完全不同。Circle 现在看上去更 Pythonic 和干净。你不再需要使用方法名如 `._get_radius()`, `._set_radius()` 和 `._del_radius()`。现在你有三个方法带有同样的干净且极具描述性的像属性的名字。它是怎么实现的？

用装饰器方法创建特性需要为受管理属性使用公开名为其创建第一个方法，这个类中是 `.radius`。这个方法应该实现读取器逻辑，在上面的例子中，7 至 11 行实现了该方法。

13 至 16 行为 `.radius` 定义了设置器方法。在这个例子中，语法完全不同。取代再次使用 `@property`，你使用 `@radius.setter`。为什么你需要这样做？再次看看 `dir()` 的输出：

```
>>> dir(Circle.radius)
[..., 'deleter', ..., 'getter', 'setter']
```

除了 `.fget`, `.fset`, `.fdel`，以及其它特殊的属性和方法，特性也提供了 `.deleter()`, `.getter()` 和 `.setter()`。这三个函数每个都返回一个新的属性。

当你使用 `@radius.setter` (第 13 行) 来装饰第二个 `.radius()` 方法时，你创建了一个新的特性并重新赋给一个类级别名字 `.radius` (第 8 行) 去持有它。这个新的特性包括与第 8 行最初特性相同的方法集，增加了在第 14 行定义的 `setter` 方法。最后，装饰其语法重新指定新特性给 `.radius` 这个类级别名字。

定义 `deleter` 方法的机制一模一样。这一次，你需要使用 `@radius.deleter` 装饰器。当这个过程结束时，你得到一个成熟的带有 `getter`, `setter` 和 `deleter` 方法的特性。

最后，使用装饰器语法时你如何为你的特性的提供文档字符串？如果你再次检查 Circle，你会注意到你已经在第 9 行定义 `setter` 方法时通过添加一个文档字符串实现过了。

新的 Circle 实现可以如上面的例子一样工作：

```
>>> from circle import Circle

>>> circle = Circle(42.0)

>>> circle.radius
Get radius
42.0

>>> circle.radius = 100.0
Set radius
>>> circle.radius
Get radius
100.0

>>> del circle.radius
Delete radius
>>> circle.radius
Get radius
Traceback (most recent call last):
    ...
AttributeError: 'Circle' object has no attribute '_radius'

>>> help(circle)
Help on Circle in module __main__ object:

class Circle(builtins.object)
    ...
 |  radius
 |      The radius property.
```

你不需要使用一对括号像方法一样调用 `.radius()`。取而代之，你可以像访问一个常规属性一样访问 `.radius`，这是特性的主要用途。它们允许你想使用方法一样使用属性，并自动调用底层方法集。

这里是当你使用装饰器方式创建特性时的一些重点回顾：

-  `@property` 装饰器必须装饰 **getter** 方法。
-  文档字符串必须在 **getter** 方法里提供。
-   **setter 和 deleter** 方法必须以 `getter` 方法名加上 `.setter` 和 `.deleter` 分别装饰。

到这一点，你已经利用 `property()`` 通过函数或者装饰器的方式创建了受管理的属性。如果你检查到现在为止的 Circle 实现，那么你会注意到它们的 `getter` 和 `setter` 方法并没有在它们的属性之上做任何额外的实际工作。

基本上，你应该避免将需要额外处理的属性转化为特性。在这些情况下使用特性将使你的代码：

- 不必要的冗长
- 使其他开发者混淆
- 比基于常规属性的代码慢

除非你仅仅需要访问属性，否则不要使用特性。它们浪费 [CPU](https://en.wikipedia.org/wiki/Central_processing_unit) 时间，更重要的是，它们浪费你的时间。最终，你应该避免编写显式的 `getter` 和 `setter` 方法让后将其包装在特性里。取而代之，使用 `@property` 装饰器。这是当前大部分 Pythonic 方式的做法。

### 3. 提供只读属性

可能 property() 最初级的一个用途就是在你的类中提供只读属性。假如你需要提供一个[不可变](https://docs.python.org/3/glossary.html#term-immutable的Point) 类，它不允许用户修改坐标的原始值，`x` 和 `y`。为了实现这个目标，你可以如下面示例代码一样创建 Point 类：

```
# point.py

class Point:
    def __init__(self, x, y):
        self._x = x
        self._y = y

    @property
    def x(self):
        return self._x

    @property
    def y(self):
        return self._y
```

这里你将输入参数存储于属性 `.x` 和 `.y`。如你所知，名字中使用前缀下划线（_）告诉其他开发者它们不是公开属性，不应该使用点号句法访问它们，如 `point._x`。最终，你定义了两个读取器方法并用 `@property` 装饰它们。

现在你拥有两个只读特性，`.x` 和 `.y` 作为你的坐标：

```
>>> from point import Point

>>> point = Point(12, 5)

>>> # Read coordinates
>>> point.x
12
>>> point.y
5

>>> # Write coordinates
>>> point.x = 42
Traceback (most recent call last):
    ...
AttributeError: can't set attribute
```

这里，`point.x` 和 `point.y` 是只读属性基本示例。它们的行为依赖于特性提供的底层描述符。如你所见，当你没有定义一个合适的设置器方法时，默认的 `.__set__()` 实现抛出了一个 AttributeError 异常，

你可以稍稍修改一下 Point 的实现，提供一个显式的设置器方法抛出一个自定义异常，带有更精准和特定的消息。

```
# point.py

class WriteCoordinateError(Exception):
    pass

class Point:
    def __init__(self, x, y):
        self._x = x
        self._y = y

    @property
    def x(self):
        return self._x

    @x.setter
    def x(self, value):
        raise WriteCoordinateError("x coordinate is read-only")

    @property
    def y(self):
        return self._y

    @y.setter
    def y(self, value):
        raise WriteCoordinateError("y coordinate is read-only")
```

在这个例子中，你定义了一个称为 WriteCoordinateError 的异常。这个异常允许你自定义实现不可变 Point 类的实现方式。现在，设置器方法抛出自定义异常携带有更显式的消息。继续你改进过的 Point，试试吧！



### 4. 创建读写属性
### 5. 提供只写属性
### 6. Python property() 实战
#### 验证输入值
#### 提供计算属性
#### 缓存计算属性
#### 记录属性访问及变更
#### 管理属性删除
#### 创建后向兼容的类 API
### 7. 在子类中覆盖特性
### 8. 结论


### Reference

- [Class and Object Attributes — Python](https://medium.com/swlh/class-and-object-attributes-python-8191dcd1f4cf)
- [Python's property(): Add Managed Attributes to Your Classes](https://realpython.com/python-property/)