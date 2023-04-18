# A Unit Testing Practitioner's Guide to Everyday Mockito
> 使用 Mockito 不是仅仅添加一个额外依赖的事情，它需要你在移除大量模板代码之余，改变你如何看待单元测试的问题。在本文中，我们将谈到多种 mock 接口，监听调用，匹配器（matcher），参数捕捉器（captors），我们也将直接查看 Mockito 如何使你的测试更干净而且易于理解。

[单元测试](https://www.toptal.com/unit-testing)在敏捷年代已经变成必须的了，有许多工具可用于帮助自动化测试。其中之一就是 Mockito，一个开源框架可以让你为你的测试创建和配置 mocked 对象。

在本文中，我们将谈到创建和配置 mocks，并使用它们来验证被测试系统的行为符合预期。我们也将设计一些 Mockito 的内部机制以帮我们更好的理解其设计及限制。我们将使用 [JUnit](https://www.toptal.com/java/getting-started-with-junit)作为[单元测试框架](https://www.toptal.com/java/getting-started-with-junit)，但由于 Mockito 未与 JUnit绑定， 因此即使使用不同的框架你仍然可以继续。

## 获取 Mockito

最近获取 Mockito 变得很容易。如果你在使用 Gradle，你只需在你的构建脚本中添加简单一行：

```
testCompile "org.mockito:mockito−core:2.7.7"
```

对于像我这样仍然喜欢 Maven 的人来说，如下添加 Mockito 到你的依赖：

```
<dependency> 
    <groupId>org.mockito</groupId> 
    <artifactId>mockito-core</artifactId> 
    <version>2.7.7</version> 
    <scope>test</scope> 
</dependency>
```

当然，这个世界不是只有 Maven 和 Gradle。你可以随意选择任何项目管理工具以从 [Maven 中央仓库](http://search.maven.org/#search%7Cga%7C1%7Ca%3A%22mockito-core%22)以获取 `Mockito jar` 部件。

## 走近 Mockito（Approaching Mockito）

[单元测试](https://www.toptal.com/unit-testing/unit-testing-benefits)设计用来测试特定类或方法在没有其它依赖的情况下的行为。因为我们在测试最小“单元”的代码，我们并不需要使用这些依赖的实际实现。更进一步，在测试不同行为时，我们将使用这些依赖稍微不同的实现。一种传统的比较知名的方式时创建“桩（stubs）”--适用于特定场景的一个接口的特定实现。这种实现通常拥有硬编码的逻辑。一个桩是一个测试实现，其它包括 `fakes`, `mocks`, `spies`, `dummies`,等。

我们将聚焦于两种测试部件（test double）：`mocks` 和 `spies`，因为它们被 Mockito 大量使用。

### Mocks

什么时 mocking？显然，这不是你取笑你的同伴之处。单元测试的 Mocking 创建一个对象以一种受控的方式来实现真实子系统的行为。总之，mocks 用作一个依赖的替代。

你可以使用 Mockito 来创建一个 mock，告诉 Mockito 在特定方法被调用时做什么，然后在你的测试中使用 mock 实例而不是真实对象。测试之后，你可以查询 mock 什么特定方法被调用过，或者检查状态变化呈现的调用的副作用。

默认情况下， Mockito 提供了 `mock` 对象的每一个方法的实现。

### Spies

一个 spy 是 Mockito 创建的另一个测试部件（test double）。与 mocks 相比，创建一个 spy 需要一个实例来监视。默认情况下，一个 spy 把所有方法调用委托给一个真实对象，并记录调用方法及其实际参数。这就是组成一个 spy 的实际内容：它监视一个真实的对象。

只要可能尽可能考虑用 mocks 代替 spies。Spies 可能对测试遗留代码有用，这些遗留代码不能被重新实现使得易于测试，但是需要使用 spy 来部分地 mock 一个类的需求表明这个类做了太多工作，违反了[单一职责原理](https://www.toptal.com/software/single-responsibility-principle)。

### 构建一个简单例子

让我们来看一个简单的演示，我们可以为其添加测试。假如我们有一个 `UserRepository` 接口，其有一个方法是通过识别码找到一个用户。我们拥有一个概念一个密码编码器用于将一个明文密码转变成密码哈希。 `UserRepository` 和 `PasswordEncoder` 都是 `UserService` 的通过构造函数注入的依赖（也被称为协作器 `collaborators`）。下面是我们的演示代码：

**UserRepository**：

```
public interface UserRepository {
   User findById(String id);
}
```

**User**：

```
public class User {

   private String id;
   private String passwordHash;
   private boolean enabled;

   public User(String id, String passwordHash, boolean enabled) {
       this.id = id;
       this.passwordHash = passwordHash;
       this.enabled = enabled;
   }
   ...
}
```

**PasswordEncoder**：

```
public interface PasswordEncoder {
   String encode(String password);
}
```

*UserService**：

```
public class UserService {
   private final UserRepository userRepository;
   private final PasswordEncoder passwordEncoder;

   public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
       this.userRepository = userRepository;
       this.passwordEncoder = passwordEncoder;
   }

   public boolean isValidUser(String id, String password) {
       User user = userRepository.findById(id);
       return isEnabledUser(user) && isValidPassword(user, password);
   }

   private boolean isEnabledUser(User user) {
       return user != null && user.isEnabled();
   }

   private boolean isValidPassword(User user, String password) {
       String encodedPassword = passwordEncoder.encode(password);
       return encodedPassword.equals(user.getPasswordHash());
   }
}
```

示例代码可以在 [GitHub](https://github.com/bitlama/mockito-demo) 上找到，因此你可以下载它们并随本文一起查阅。

## 应用 Mockito（Applying Mockito）

利用我们的示例代码，我们来如何应用 Mockito 并写一些测试。

### 创建 Mocks

利用 Mockito，创建一个 mock 仅仅需要调用一个静态方法 `Mockito.mock()`：

```
import static org.mockito.Mockito.*;
...
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
```

注意我们对 Mockito 的静态导入。在本文余下部分，我们会认为默认情况下这个导入已经添加。

在导入后，我们模仿了 `PasswordEncoder`。`Mockito` 不仅仅可以模仿接口，也可以模仿抽象类及实体非 final 类。开箱即用， Mockito 并不能模仿 final 类，final 或静态方法。但如果你真的需要它，[MockMaker](https://javadoc.io/static/org.mockito/mockito-core/4.5.1/org/mockito/plugins/MockMaker.html) 插件当前已经可用。

同时请注意 `equals()` 和 `hashCode()` 方法不能被模仿。

### 创建 Spies

为了创建一个 spy，我们需要调用 Mockito 的静态方法 `spy()` 并传递一个待监视的实例。返回对象的调用方法将会调用真实的方法，除非这些方法是存根方法。这些调用被记录下来，并且这些调用的事实可以被验证（请参看稍后 verify() 的描述）。让我们创建一个 `spy`：

```
DecimalFormat decimalFormat = spy(new DecimalFormat());
assertEquals("42", decimalFormat.format(42L));
```

创建一个 `spy` 与创建一个 `mock` 并没有什么太大的不同。更进一步，所有 Mockito 的用于配置一个 mock 方法也适用于配置一个 spy。

相对于 mocks，spies 用的较少，但你会发现对于不能重构的遗留代码的测试会很有用--这种测试需要部分 mocking。在这种情况下，你可以只创建一个 spy 并对某些方法打桩以得到你期待的行为。

### 默认返回值

调用 `mock(PasswordEncoder.class)` 将返回一个 `PasswordEncoder` 实例。我们甚至可以调用其方法，但是它们将会返回什么呢？默认情况下，一个 mock 将会返回 “未初始化” 或 “空的” 值，例如，数字类型（基本类型和装箱类型）的 `0`，布尔类型的 `false`，以及大多数其它类型的 `nulls` 。

考虑下面的接口：

```
interface Demo {
   int getInt();
   Integer getInteger();
   double getDouble();
   boolean getBoolean();
   String getObject();
   Collection<String> getCollection();
   String[] getArray();
   Stream<?> getStream();
   Optional<?> getOptional();
}
```

现在考虑下面你的代码片段，它初步展示了从一个 `mock` 对象的方法返回的期待的默认值：

```
Demo demo = mock(Demo.class);
assertEquals(0, demo.getInt());
assertEquals(0, demo.getInteger().intValue());
assertEquals(0d, demo.getDouble(), 0d);
assertFalse(demo.getBoolean());
assertNull(demo.getObject());
assertEquals(Collections.emptyList(), demo.getCollection());
assertNull(demo.getArray());
assertEquals(0L, demo.getStream().count());
assertFalse(demo.getOptional().isPresent());
```

### 打桩方法（Stubbing Methods）

全新的，未修改过的 mocks 仅仅极少情况下有用。通常我们会配置 mock 并定义当 mock 的特定方法被调用时做什么。这叫做打桩（stubbing）。

Mockito 提供了两种打桩方法。第一种方法就是 “当方法被调用时，就做某些事情”。考虑下面的代码片段：

```
when(passwordEncoder.encode("1")).thenReturn("a");
```

它读起来就和英语一样：“当 passwordEncoder.encode(“1”) 被调用时, 返回一个 a”。

第二种打桩方法读起来像 “当 mock 的方法以某些参数被调用时，做某些事情”。由于其原因在尾部指定，这种方式的打桩难于阅读。考虑：

```
doReturn("a").when(passwordEncoder).encode("1");
```

上述打桩代码片段应该读作：“返回 a，当 passwordEncoder 的 encode() 方法以参数 1 被调用时”。

通常倾向于第一种方式，因为它是类型安全的并更具可读性。但是，虽然罕见，你被迫使用第二种方式，例如当对一个 spy 的真实方法打桩时，因为调用它可能具有意想不到的副作用。

让我们来简单探索 Mockito 提供的打桩方法。我么将会把两种打桩方法都包在我们的示例中：

#### 返回值

`thenReturn` 或 `doReturn()` 用于当方法被调用时指定返回值。

```
//”when this method is called, then do something”
when(passwordEncoder.encode("1")).thenReturn("a");
```

或

```
//”do something when this mock’s method is called with the following arguments”
doReturn("a").when(passwordEncoder).encode("1");
```

你也可以指定当方法被连续调用时作为返回结果的多个值。最后一个值被用作继续调用的的结果。

```
//when
when(passwordEncoder.encode("1")).thenReturn("a", "b");
```

或

```
//do
doReturn("a", "b").when(passwordEncoder).encode("1");
```

下面的代码片段可以取得一样的效果：

```
when(passwordEncoder.encode("1"))
       .thenReturn("a")
       .thenReturn("b");
```

这种模式可以与其它方法一道来定义连续方法调用的结果。

#### 返回自定义回复（RETURNING CUSTOM RESPONSES）

`then()`, `thenAnswer()` 的别名，和 `doAnswer()` 做同样的事情，它用于当方法调用时设置一个自定义回复。例如：

```
when(passwordEncoder.encode("1")).thenAnswer(
       invocation -> invocation.getArgument(0) + "!");
```

或

```
doAnswer(invocation -> invocation.getArgument(0) + "!")
       .when(passwordEncoder).encode("1");
```

`thenAnswer()` 唯一获取的参数是一个 [Answer](https://static.javadoc.io/org.mockito/mockito-core/2.7.7/org/mockito/stubbing/Answer.html) 接口的实例。它拥有一个简单方法带有类型为 [InvocationOnMock](https://static.javadoc.io/org.mockito/mockito-core/2.7.7/org/mockito/invocation/InvocationOnMock.html) 的参数。

你也可以作为方法调用的结果抛出一个异常。

```
when(passwordEncoder.encode("1")).thenAnswer(invocation -> {
   throw new IllegalArgumentException();
});
```

或者调用一个类的真实方法（对接口不适用）：

```
Date mock = mock(Date.class);
doAnswer(InvocationOnMock::callRealMethod).when(mock).setTime(42);
doAnswer(InvocationOnMock::callRealMethod).when(mock).getTime();
mock.setTime(42);
assertEquals(42, mock.getTime());
```

如果你觉得这看起来很笨重，那么你是对的。Mockito 提供了 `thenCallRealMethod()` 和 `thenThrow()` 来流水化这种类型测试。

#### 调用真实方法

名如其意，`thenCallRealMethod()` 和 `doCallRealMethod()` 在一个 mock 对象上调用其真实方法。

```
Date mock = mock(Date.class);
when(mock.getTime()).thenCallRealMethod();
doCallRealMethod().when(mock).setTime(42);
mock.setTime(42);
assertEquals(42, mock.getTime());
```

调用真实方法在仅仅部分模拟的情况下可能有用，但需要确保调用方法没有意想不到的副作用，也不依赖于对象状态。如果它有，那么一个 spy 可能比一个 mock 要合适。

如果你创建了一个接口 mock 并试着配置打桩以调用一个真实方法，Mockito 将抛出一个带有丰富信息的异常。考虑下面的代码片段：

```
when(passwordEncoder.encode("1")).thenCallRealMethod();
```

Mockito 将会失败并打印如下消息：

```
Cannot call abstract real method on java object!
Calling real methods is only possible when mocking non abstract method.
  //correct example:
  when(mockOfConcreteClass.nonAbstractMethod()).thenCallRealMethod();
```

对于 Mockito 开发者，`Kudos` 可以提供类似的详细信息。

#### 抛出异常（THROWING EXCEPTIONS）

`thenThrow()` 和 `doThrow()` 配置一个模拟方法抛出一个异常：

```
when(passwordEncoder.encode("1")).thenThrow(new IllegalArgumentException());
```

或
```
doThrow(new IllegalArgumentException()).when(passwordEncoder).encode("1");
```

Mockito 确保抛出的异常对于特定的打桩方法是有效地，如果异常不在方法的检查型异常列表里，它将会抱怨。考虑下面的代码片段：

```
when(passwordEncoder.encode("1")).thenThrow(new IOException());
```

它将导致一个错误：
```
org.mockito.exceptions.base.MockitoException: 
Checked exception is invalid for this method!
Invalid: java.io.IOException
```

正如你看到的，Mockito 检测到方法 `encode()` 不能够抛出一个 `IOException`。

你也可以传递一个异常的类而不是传递异常的一个实例：

```
when(passwordEncoder.encode("1")).thenThrow(IllegalArgumentException.class);
```

或

```
doThrow(IllegalArgumentException.class).when(passwordEncoder).encode("1");
```

这意味着，Mockito 不能像验证一个异常类实例一样验证一个异常类。因此你必须遵守规则，不要传递非法类对象。例如，虽然 `encode()` 并不期待抛出一个检查型异常，下面的代码将抛出一个 `IOException`：

```
when(passwordEncoder.encode("1")).thenThrow(IOException.class);
passwordEncoder.encode("1");
```

#### 使用默认方法模拟接口（MOCKING INTERFACES WITH DEFAULT METHODS）

值得注意的是在为一个接口创建 mock 时， Mockito 模拟了该接口的所有方法。从 `Java 8` 起，接口可以带有默认方法以及抽象方法。这些方法也被模拟，因此你需要小心照顾以使得它们工作得像默认方法一样。

考虑下面的例子：

```
interface AnInterface {
   default boolean isTrue() {
       return true;
   }
}
AnInterface mock = mock(AnInterface.class);
assertFalse(mock.isTrue());
```

在这个例子中，`assertFalse()` 将会成功。如果这不是你所期待的，确保你使得 Mockito 调用了真实方法，比如：

```
AnInterface mock = mock(AnInterface.class);
when(mock.isTrue()).thenCallRealMethod();
assertTrue(mock.isTrue());
```

### 参数匹配器（Argument Matchers）

在前面的章节中，我们用精确的参数值配置了我们的模拟方法。在这些例子中，Mockito 仅仅在内部调用 `equals()` 以检查期待的值是否与实际值一致。

但有时候我们并不事先知道这些值。

可能我们并不关心被传为参数的这些实际值，或者我们可能想为一个更大范围的值定义一个反应。所有这些场景（或者更多）可以利用参数匹配来解决。想法很简单：代替提供一个精确的值，你为 Mockito 提供一个参数匹配器来匹配方法参数。

考虑下面的代码片段：

```
when(passwordEncoder.encode(anyString())).thenReturn("exact");
assertEquals("exact", passwordEncoder.encode("1"));
assertEquals("exact", passwordEncoder.encode("abc"));
```

因为我们在第一行使用了 `anyString()` 参数匹配器，因此无论你传递什么值给 `encode()`，你能够看到同样的结果。如果我们应用普通英语来重写这一行，它听起来应该像“当密码编码器被要求编码任何字符串时，返回字符串‘exact’”。

Mockito 要求你提供所有的参数或者通过参数匹配器或者通过精确值。因此如果一个方法拥有超过一个参数，并且你只想对其中一部分使用参数匹配器，忘记它。你不能像下面这样写代码：

```
abstract class AClass {
   public abstract boolean call(String s, int i);
}
AClass mock = mock(AClass.class);
//This doesn’t work.
when(mock.call("a", anyInt())).thenReturn(true);
```

为了修正这个错误，我们必须代替最后一行 -- 包括一个 `eq` 参数匹配器以代替 `a`，如下所示：

```
when(mock.call(eq("a"), anyInt())).thenReturn(true);
```

这里我们已经使用 `eq()` 和 `anyInt()` 参数匹配器，还有许多其它可用的。关于可用的参数匹配器的完整列表请参见 [org.mockito.ArgumentMatchers](https://static.javadoc.io/org.mockito/mockito-core/2.7.7/org/mockito/ArgumentMatchers.html) 类的文档。

重要提示你不能在验证或打桩之外使用参数匹配器。例如，你不能写如下的代码：

```
//this won’t work
String orMatcher = or(eq("a"), endsWith("b"));
verify(mock).encode(orMatcher);
```

Mockito 将检测到参数匹配器用错了位置，并抛出一个 `InvalidUseOfMatchersException` 异常。利用参数匹配器做验证应该像这样编写：

```
verify(mock).encode(or(eq("a"), endsWith("b")));
```

参数匹配器也不能用作返回值。Mockito 不能返回 `anyString()` 或者任意别的什么；打桩方法被调用时一个精确的值是必须的。

#### 自定义匹配器（CUSTOM MATCHERS）

当你需要一些当前 Mockito 不能提供的匹配逻辑，自定义匹配器来救场了。创建自定义匹配器的决定不能轻易做出，因为需要以非微小的方式匹配参数通常指示设计有问题或者一个测试变得太复杂了。

因此在你编写自定义匹配器之前，检查能否利用某些仁慈的参数匹配器如 `isNull()` 和 `nullable()` 等来简化测试是值得的。如果你觉得你仍需要编写参数匹配器，Mockito 提供了一套方法来做这个：

考虑下面的代码：

```
FileFilter fileFilter = mock(FileFilter.class);
ArgumentMatcher<File> hasLuck = file -> file.getName().endsWith("luck");
when(fileFilter.accept(argThat(hasLuck))).thenReturn(true);
assertFalse(fileFilter.accept(new File("/deserve")));
assertTrue(fileFilter.accept(new File("/deserve/luck")));
```

这里我们创建了 `hasLuck` 参数匹配器，并使用 `argThat()` 来将这个匹配器传递给模拟方法作为参数，打桩它当文件名以 “luck” 结尾时将会返回 `true`。你可以把 `ArgumentMatcher` 当作一个函数接口，并利用 lambda 来创建其实例。更精简的语法如下：

```
ArgumentMatcher<File> hasLuck = new ArgumentMatcher<File>() {
   @Override
   public boolean matches(File file) {
       return file.getName().endsWith("luck");
   }
};
```

如果你想创建工作于基本类型的参数匹配器，在 `org.mockito.ArgumentMatchers` 中有几个其它的方法：

- charThat(ArgumentMatcher<Character> matcher)
- booleanThat(ArgumentMatcher<Boolean> matcher)
- byteThat(ArgumentMatcher<Byte> matcher)
- shortThat(ArgumentMatcher<Short> matcher)
- intThat(ArgumentMatcher<Integer> matcher)
- longThat(ArgumentMatcher<Long> matcher)
- floatThat(ArgumentMatcher<Float> matcher)
- doubleThat(ArgumentMatcher<Double> matcher)

#### 组合匹配器（COMBINING MATCHERS）

当一个条件过于复杂不适合用基本的匹配器处理时，创建自定义匹配器并不总是值得的，有时候组合匹配器更适合。 Mockito 提供了参数匹配器来在匹配基本类型或非基本类型的参数匹配器实现公共逻辑操作 `(‘not’, ‘and’, ‘or’)`。这些匹配器在 [org.mockito.AdditionalMatchers](https://static.javadoc.io/org.mockito/mockito-core/2.7.7/org/mockito/AdditionalMatchers.html) 类里以静态方法的形式实现。

考虑下面的代码片段：

```
when(passwordEncoder.encode(or(eq("1"), contains("a")))).thenReturn("ok");
assertEquals("ok", passwordEncoder.encode("1"));
assertEquals("ok", passwordEncoder.encode("123abc"));
assertNull(passwordEncoder.encode("123"));
```

这里我们组合了两个参数匹配器的结果：`eq("1")` 和 `contains("a")`。最终的表达式 `or(eq("1"), contains("a"))`　可被解释为：参数字符串必须等于 `“1”` 或者包含 `“a”`。

注意 [org.mockito.AdditionalMatchers](https://static.javadoc.io/org.mockito/mockito-core/2.7.7/org/mockito/AdditionalMatchers.html) 类里还有一些不怎么常用的参数匹配器，如 `geq()`, `leq()`, `gt()` 和 `lt()`，它们用于值的比较，适用于基本类型和 `java.lang.Comparable` 类型的实例。

### 验证行为（Verifying Behavior）

一旦一个 mock 或 spy 被使用，我们可以验证特定的交互发生了。字面上讲，我们在说 “Hey，Mockito，确保这个方法被以这些参数调用”。

考虑下面的模拟示例：

```
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
when(passwordEncoder.encode("a")).thenReturn("1");
passwordEncoder.encode("a");
verify(passwordEncoder).encode("a");
```

这里我们设置了一个 mock 并调用其方法 `encode()`。最后一行验证 mock 的方法 `encode()` 被以特定的参数值 `a` 所调用。请注意验证打桩方法调用是冗余的；上面代码片段的目的是展示在某些交互发生后做验证。

如果我们在最后一行修改其调用参数为 `b`，前面的测试将会失败，Mockito 将会抱怨实际调用使用了不同的参数（`b` 而不是期待的 `a`）。

参数匹配器可被用作验证就如同验证打桩：

```
verify(passwordEncoder).encode(anyString());
```

默认地， Mockito 验证方法被调用了一次，但是你可以验证方法被调用了任意次数：

```
// verify the exact number of invocations
verify(passwordEncoder, times(42)).encode(anyString());

// verify that there was at least one invocation
verify(passwordEncoder, atLeastOnce()).encode(anyString());

// verify that there were at least five invocations
verify(passwordEncoder, atLeast(5)).encode(anyString());

// verify the maximum number of invocations
verify(passwordEncoder, atMost(5)).encode(anyString());

// verify that it was the only invocation and
// that there're no more unverified interactions
verify(passwordEncoder, only()).encode(anyString());

// verify that there were no invocations
verify(passwordEncoder, never()).encode(anyString());
```

`verify()` 一个极少应用的特性是其超时时失败的能力，其主要用于验证并发代码。例如，如果我们的密码编码器在另一个线程里以 `verify()` 并发调用，我们可能写出下面的测试代码：

```
usePasswordEncoderInOtherThread();
verify(passwordEncoder, timeout(500)).encode("a");
```

如果 `encode()` 被调用并在 500 毫秒以内完成，那么这个测试就会成功。如果你需要等待你指定的整个周期，使用 `after()` 而非 `timeout()`：

```
verify(passwordEncoder, after(500)).encode("a");
```

其它验证模式 `(times(), atLeast(), 等)` 可与 `timeout()` 和 `after()` 等组合组合来实现更复杂的测试：

```
// passes as soon as encode() has been called 3 times within 500 ms
verify(passwordEncoder, timeout(500).times(3)).encode("a");
```

除了 times() 外，支持的验证模式包括 `only()`, `atLeast()` 和 `atLeastOnce() (atLeast(1) 的别名)`。

Mockito 也允许你以 mock 组为单位验证调用顺序。这并不是经常使用的特性，但如果调用顺序很重要那它就很有用。考虑下面的例子：

```
PasswordEncoder first = mock(PasswordEncoder.class);
PasswordEncoder second = mock(PasswordEncoder.class);
// simulate calls
first.encode("f1");
second.encode("s1");
first.encode("f2");
// verify call order
InOrder inOrder = inOrder(first, second);
inOrder.verify(first).encode("f1");
inOrder.verify(second).encode("s1");
inOrder.verify(first).encode("f2");
```

如果我们重新安排打桩调用的顺序，测试将失败并抛出 `VerificationInOrderFailure`。

调用的缺席也可使用 `verifyZeroInteractions()` 验证。这个方法接受一个 mock 或 mocks 作为参数，如果传递 mocks 的任何方法被调用它都将失败。

`verifyNoMoreInteractions()` 方法也值得注意，它接受 mocks 作为参数，它用于检查这些 mocks 上的任何调用都被验证过。

#### 捕捉参数（CAPTURING ARGUMENTS）

除了验证方法被以特定参数调用，Mockito 允许你捕捉这些参数，如此之后你可以在其上运行自定义断言。换句话说，你在讲 “Hey, Mockito, 验证这个方法被调用了，给我该调用传递的参数”。

让我们创建 `PasswordEncoder的mock`，调用 `encode()`，捕捉其参数并验证其值：

```
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
passwordEncoder.encode("password");
ArgumentCaptor<String> passwordCaptor = ArgumentCaptor.forClass(String.class);
verify(passwordEncoder).encode(passwordCaptor.capture());
assertEquals("password", passwordCaptor.getValue());
```

正如你看到的，我们传递 `passwordCaptor.capture()` 作为 `encode()` 的验证参数；其内部将创建一个参数匹配器以保存参数。然后我们使用 `passwordCaptor.getValue()` 来检索捕捉到的参数，并使用`assertEquals()` 来检视之。

如果我们需要跨多个调用来捕捉一个参数，`ArgumentCaptor` 让你通过 `getAllValues()` 来检索所有的值，像下面：

```
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
passwordEncoder.encode("password1");
passwordEncoder.encode("password2");
passwordEncoder.encode("password3");
ArgumentCaptor<String> passwordCaptor = ArgumentCaptor.forClass(String.class);
verify(passwordEncoder, times(3)).encode(passwordCaptor.capture());
assertEquals(Arrays.asList("password1", "password2", "password3"),
             passwordCaptor.getAllValues());
```

同样的技术可用于捕捉可变数量的参数（也被称为可变参数（`varargs`））。

## 测试我们的简单例子（Testing Our Simple Example）

现在我们已经了解 Mockito 更多，是时候回到我们的演示了。让我们编写 `isValidUser` 方法测试。它可能看起来像下面这样：

```
public class UserServiceTest {

   private static final String PASSWORD = "password";

   private static final User ENABLED_USER =
           new User("user id", "hash", true);

   private static final User DISABLED_USER =
           new User("disabled user id", "disabled user password hash", false);
  
   private UserRepository userRepository;
   private PasswordEncoder passwordEncoder;
   private UserService userService;

   @Before
   public void setup() {
       userRepository = createUserRepository();
       passwordEncoder = createPasswordEncoder();
       userService = new UserService(userRepository, passwordEncoder);
   }

   @Test
   public void shouldBeValidForValidCredentials() {
       boolean userIsValid = userService.isValidUser(ENABLED_USER.getId(), PASSWORD);
       assertTrue(userIsValid);

       // userRepository had to be used to find a user with id="user id"
       verify(userRepository).findById(ENABLED_USER.getId());

       // passwordEncoder had to be used to compute a hash of "password"
       verify(passwordEncoder).encode(PASSWORD);
   }

   @Test
   public void shouldBeInvalidForInvalidId() {
       boolean userIsValid = userService.isValidUser("invalid id", PASSWORD);
       assertFalse(userIsValid);

       InOrder inOrder = inOrder(userRepository, passwordEncoder);
       inOrder.verify(userRepository).findById("invalid id");
       inOrder.verify(passwordEncoder, never()).encode(anyString());
   }

   @Test
   public void shouldBeInvalidForInvalidPassword() {
       boolean userIsValid = userService.isValidUser(ENABLED_USER.getId(), "invalid");
       assertFalse(userIsValid);

       ArgumentCaptor<String> passwordCaptor = ArgumentCaptor.forClass(String.class);
       verify(passwordEncoder).encode(passwordCaptor.capture());
       assertEquals("invalid", passwordCaptor.getValue());
   }

   @Test
   public void shouldBeInvalidForDisabledUser() {
       boolean userIsValid = userService.isValidUser(DISABLED_USER.getId(), PASSWORD);
       assertFalse(userIsValid);

       verify(userRepository).findById(DISABLED_USER.getId());
       verifyZeroInteractions(passwordEncoder);
   }

   private PasswordEncoder createPasswordEncoder() {
       PasswordEncoder mock = mock(PasswordEncoder.class);
       when(mock.encode(anyString())).thenReturn("any password hash");
       when(mock.encode(PASSWORD)).thenReturn(ENABLED_USER.getPasswordHash());
       return mock;
   }

   private UserRepository createUserRepository() {
       UserRepository mock = mock(UserRepository.class);
       when(mock.findById(ENABLED_USER.getId())).thenReturn(ENABLED_USER);
       when(mock.findById(DISABLED_USER.getId())).thenReturn(DISABLED_USER);
       return mock;
   }
}
```
 
## API之下（Diving beneath the API）

Mockito 提供了一套可读的，方便的 API，但让我们解释一些内部工作（原理）以了解其局限性并避免奇怪的错误。

让我们深入查看当下面的代码片段在运行时 Mockito 在做些什么：

```
// 1: create
PasswordEncoder mock = mock(PasswordEncoder.class);
// 2: stub
when(mock.encode("a")).thenReturn("1");
// 3: act
mock.encode("a");
// 4: verify
verify(mock).encode(or(eq("a"), endsWith("b")));
```

明显地，第一行创建了一个 mock。Mockito 使用 [ByteBuddy](http://bytebuddy.net/) 来创建一个给定类的子类。新的类对象拥有一个产生的类名如 `demo.mockito.PasswordEncoder$MockitoMock$1953422997`，它的 `equals()` 将检查唯一性（`identity`），`hashCode()` 将返回 `identity` 哈希码。一旦类被产生并加载，它的实例被使用 [Objenesis](http://objenesis.org/) 来创建。

让我们来看看下面的行：

```
when(mock.encode("a")).thenReturn("1");
```

顺序很重要。这里执行的第一个语句是 `mock.encode("a")`，它在 mock 上调用 `encode()`，其默认返回值为 `null`。因此实际上我们在传递 `null` 给 `when()` 作为其参数。Mockito 并不关注什么值传递给了 `when()`，其原因在于当方法被调用时，它存储该模拟方法的调用信息于所谓的 “ongoing stubbing”。稍后当我们调用 `when()`时，Mockito 拉取该 “ongoing stubbing” 对象并将其返回为 `when()` 的结果。然后我们爱返回的 “ongoing stubbing” 对象上调用 `thenReturn(“1”)`。

第三行 `mock.encode("a")`; 很简单：我们调用这个打桩方法。在内部，Mockito 保存该调用以用于稍后进一步验证，并返回打桩调用回复，在我们的例子中，它是字符串 `1`。

在第四行 `verify(mock).encode(or(eq("a"), endsWith("b")));` 我们让 Mockito 验证有一次带有特定参数的 `encode()` 调用发生。

`verify()` 首先执行，它将 Mockito 的内部状态转换为验证模式。理解 Mockito 将其状态保存在一个 `ThreadLocal` 中非常重要。它使得实现好的语法成为可能，另一方面，如果框架被不当使用（例如，如果你试着在验证或打桩之外使用参数匹配器），很可能导致奇怪的结果。

那么 Mockito 如何创建一个 `or` 匹配器？首先，`eq("a")` 被调用，`equals` 被加入到匹配器堆栈。第二步，`endsWith("b")` 被调用，一个 `endsWith` 匹配器被加入到堆栈。最后，`or(null, null)` 被调用--它使用了它从堆栈中弹出的两个匹配器，创建了 `or` 匹配器，并将其压入堆栈。最终 `encode()` 被调用。Mockito 然后验证方法被以特定参数调用了指定次数。

当参数匹配器不能被提取（因为它改变了调用顺序）赋值给一个变量时，它们可被提取为方法。这种操作保留了调用顺序并保持了堆栈的正常状态。

```
verify(mock).encode(matchCondition());
…
String matchCondition() {
   return or(eq("a"), endsWith("b"));
}
```

### 改变默认回复

在前面的章节中，我们以下面的方式创建我们的 mocks：当任何模拟方法被调用，它们返回一个 “empty” 值。这个行为可以配置。如果认为 Mockito 提供的不合适，你甚至可以提供自己的 `org.mockito.stubbing.Answer` 的实现，但这通常指示随着单元测试变得过于复杂，有一些错误做法。请记住 `KISS` 原则。

让我们来解释更多 Mockito 提供的预定义默认回复。

- `RETURNS_DEFAULTS` 是默认策略；当设置一个 mock 不值得显式提到。
- `CALLS_REAL_METHODS` 使得非打桩调用调用真实方法
- `RETURNS_SMART_NULLS` 当使用一个非打桩方法返回的对象时，通过返回 `SmartNull` 而非 `null` 以避免 `NullPointerException`。你仍会以 `NullPointerException` 失败，但 `SmartNull` 给了你更好的堆栈轨迹，包括非打桩方法调用的行号。这使得让 `RETURNS_SMART_NULLS` 成为 Mockito 的默认回复是值得的。
- `RETURNS_MOCKS` 首先试着返回常规 “empty” 值，然后如果可能 mocks，最后 `null`。空的标准与我们前面看到的有点不同。以 `RETURNS_MOCKS` 创建的 mocks 返回空的字符串或数组而非 `null`。
- `RETURNS_SELF` 在模拟 `builders` 时有用。基于这个设置，当一个方法被调用要求返回一个于模拟类相当或其超类的对象时 mock 返回自己。
- `RETURNS_DEEP_STUBS` 比 `RETURNS_MOCKS` 走得更远，他从能够返回 mock 的 mock 那里创建 mock。相较 `RETURNS_MOCKS`，空的规则在 `RETURNS_DEEP_STUBS` 是默认的，因此它为字符串或数组返回 `null`。

```
interface We { Are we(); }
interface Are { So are(); }
interface So { Deep so(); }
interface Deep { boolean deep(); }
...
We mock = mock(We.class, Mockito.RETURNS_DEEP_STUBS);
when(mock.we().are().so().deep()).thenReturn(true);
assertTrue(mock.we().are().so().deep());
```

### 命名一个模拟对象（NAMING A MOCK）

Mockito 允许你命名一个 mock，如果你的测试中拥有很多 mocks 并需要区分它们，那么这个特性就是很有用的。那也说明，需要命名 mocks 通常是不好设计的一个标记。考虑下面的例子：

```
PasswordEncoder robustPasswordEncoder = mock(PasswordEncoder.class);
PasswordEncoder weakPasswordEncoder = mock(PasswordEncoder.class);
verify(robustPasswordEncoder).encode(anyString());
```

Mockito 将会抱怨，但由于我们并未正式命名这些 mocks，我们并不知道哪个。

```
Wanted but not invoked:
passwordEncoder.encode(<any string>);
```

让我们在构造时传递一个字符串以命名它们：

```
PasswordEncoder robustPasswordEncoder = mock(PasswordEncoder.class, "robustPasswordEncoder");
PasswordEncoder weakPasswordEncoder = mock(PasswordEncoder.class, "weakPasswordEncoder");
verify(robustPasswordEncoder).encode(anyString());
```

现在错误消息友好多了，清晰地指向了 `robustPasswordEncoder`：

```
Wanted but not invoked:
robustPasswordEncoder.encode(<any string>);
```

### 实现多个模拟接口（IMPLEMENTING MULTIPLE MOCK INTERFACES）

有时候，你可能希望创建一个实现了多个接口的 mock，Mockito 很容易实现这点如下所示：

```
PasswordEncoder mock = mock(
       PasswordEncoder.class, withSettings().extraInterfaces(List.class, Map.class));
assertTrue(mock instanceof List);
assertTrue(mock instanceof Map);
```

### 监听调用（LISTENING INVOCATIONS）

一个 mock 可被配置为当它的一个方法被调用时，特定调用监听器也被调用。在监听器内部，你可以找到该调用产生了一个值或抛出了一个异常。

```
InvocationListener invocationListener = new InvocationListener() {
   @Override
   public void reportInvocation(MethodInvocationReport report) {
       if (report.threwException()) {
           Throwable throwable = report.getThrowable();
           // do something with throwable
           throwable.printStackTrace();
       } else {
           Object returnedValue = report.getReturnedValue();
           // do something with returnedValue
           System.out.println(returnedValue);
       }
   }
};
PasswordEncoder passwordEncoder = mock(
       PasswordEncoder.class, withSettings().invocationListeners(invocationListener));
passwordEncoder.encode("1");
```

在这个例子中，我们将返回值或者调用栈打印到系统标准输出上。我们的实现大致和 Mockito 的 `org.mockito.internal.debugging.VerboseMockInvocationLogger`（不要直接使用它，它是内部实现细节） 一致。如果打印调用是你需要的监听器的唯一特性，那么 Mockito 通过 `verboseLogging()` 设置提供了一个更干净的方式来表达你的意图。

```
PasswordEncoder passwordEncoder = mock(
       PasswordEncoder.class, withSettings().verboseLogging());
```

注意即使你调用打桩方法 Mockito 也会调用监听器。考虑下面的例子：

```
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class, withSettings().verboseLogging());
// listeners are called upon encode() invocation
when(passwordEncoder.encode("1")).thenReturn("encoded1");
passwordEncoder.encode("1");
passwordEncoder.encode("2");
```

上面的代码将会产生如下类似的输出：

```
############ Logging method invocation #1 on mock/spy ########
passwordEncoder.encode("1");
   invoked: -> at demo.mockito.MockSettingsTest.verboseLogging(MockSettingsTest.java:85)
   has returned: "null"

############ Logging method invocation #2 on mock/spy ########
   stubbed: -> at demo.mockito.MockSettingsTest.verboseLogging(MockSettingsTest.java:85)
passwordEncoder.encode("1");
   invoked: -> at demo.mockito.MockSettingsTest.verboseLogging(MockSettingsTest.java:89)
   has returned: "encoded1" (java.lang.String)

############ Logging method invocation #3 on mock/spy ########
passwordEncoder.encode("2");
   invoked: -> at demo.mockito.MockSettingsTest.verboseLogging(MockSettingsTest.java:90)
   has returned: "null"
```

记住第一个被记录的调用对应对 `encode()` 打桩的调用。下一个调用才真正对应打桩方法的调用。

### 其它设置（OTHER SETTINGS）

Mockito 提供了一些更多的设置以让你做下面的事情：

- 通过使用 withSettings().serializable() 来开启 mock 序列化
- 通过使用 withSettings().stubOnly() 来关闭记录方法调用以节省内存（这使得不能够验证）
- 通过使用withSettings().useConstructor() 创建实例时使用 mock 的构造函数。当模拟内部非静态类时，添加 outerInstance() 设置如下：withSettings().useConstructor().outerInstance(outerObject)

如果你想以一些自定义设置（例如自定义名字）创建一个 spy，有一个 `spiedInstance()` 设置，如此 Mockito 将会在你提供的实例上创建 spy，如下：

```
UserService userService = new UserService(
       mock(UserRepository.class), mock(PasswordEncoder.class));
UserService userServiceMock = mock(
       UserService.class,
       withSettings().spiedInstance(userService).name("coolService"));
```

当一个 spied 实例被指定，Mockito 将创建一个新的实例并将其内部非静态字段设置为来自原来对象的值。这就是为什么使用返回的对象重要的原因：只有它的方法调用可以被打桩和验证。

注意，当你创建一个spy，基本上你是在创建一个 mock 去调用真实方法：

```
// creating a spy this way...
spy(userService);
// ... is a shorthand for
mock(UserService.class,
    withSettings()
            .spiedInstance(userService)
            .defaultAnswer(CALLS_REAL_METHODS));
```

## 当 Mockito 看起来风格不太好（When Mockito Tastes Bad）

使我们的测试复杂且难于维护是我们的坏习惯而非 Mockito 的问题。例如，你可能觉得需要模拟一切。这种想法导致测试mocks 而非产品代码。模拟第三方 API 也是危险的，因为 API 的潜在修改可能破坏（已有的）测试。

虽然坏味道是个认知问题，Mockito 提供了一些有争议的特性可能使得你的测试更难于维护。有时候打桩不是小事，或者乱用依赖注入会使得为每个测试重新创建 mocks 困难，不合理且没有效率。

### 清理调用

Mockito 允许在保留打桩的情况下清理对 mocks 的调用，如下：

```
PasswordEncoder passwordEncoder = mock(PasswordEncoder.class);
UserRepository userRepository = mock(UserRepository.class);
// use mocks
passwordEncoder.encode(null);
userRepository.findById(null);
// clear
clearInvocations(passwordEncoder, userRepository);
// succeeds because invocations were cleared
verifyZeroInteractions(passwordEncoder, userRepository);
```

只有当重建 mock 导致重大负担或者依赖注入框架提供一个配置好的 mock 和打桩很重要时，才诉诸清理调用。

### 重设Mock

通过 `reset()` 重设一个 mock 是另一个有争议性的特性，应该仅仅在极少情况下使用，例如一个 mock 由容器注入，你不能在每个测试中重新创建它。

### 过度使用 Verify

另一个坏习惯是使用 Mockito 的 `verify()` 代替每一个 `assert`。重要的是清晰地理解什么被测试：协作者之间的交互可以利用 `verify()` 来检查，但是一个执行行动的可观测结果的验证则需通过 `asserts`。

## Mockito 是关于思维框架的（Is about Frame of Mind）

使用 Mockito 并不仅仅是添加了一个依赖，它需要你改变你在移除样本代码之外思考你的单元测试的方式。

拥有多种 mock 接口，监听调用（listening invocations），匹配器和参数捕捉器，我们已经看到了 Mockito 使你的测试更干净也更易于理解。但像其它任何工具一样，只有使用恰当它才有用。现在你拥有了 Mockito 的内部工作机制，你可以把你的单元测试带向一个更高级别。

## Reference

- [A Unit Testing Practitioner's Guide to Everyday Mockito](https://www.toptal.com/java/a-guide-to-everyday-mockito)
- [Mockito Tutorial](https://www.javatpoint.com/methods-of-mockito)