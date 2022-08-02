# A Unit Testing Practitioner's Guide to Everyday Mockito
> 使用 Mockito 不是仅仅添加一个额外依赖的事情，它需要你在移除大量模板代码之于，改变你如何看待单元测试的问题。在本文中，哦们将谈到多种 mock 接口，监听调用，匹配器（matcher），参数捕捉器（captors），我们也将直接查看 Mockito 如何使你的测试更干净而且易于理解。

单元测试在敏捷年代已经变成必须的了，有许多工具可用于帮助自动化测试。其中之一就是 Mockito，一个开源框架可以让你为你的测试创建和配置 mocked 对象。

在本文中，我们将谈到创建和配置 mocks，并使用它们来验证被测试系统的行为符合预期。我们也将设计一些 Mockito 的内部机制以帮我们更好的理解起设计及限制。我们将使用 [JUnit](https://www.toptal.com/java/getting-started-with-junit)作为单元测试框架，但由于 Mockito 未与 JUnit绑定， 因此即使使用不同的框架你仍然可以继续。

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

当然，这个世界不是只有 Maven 和 Gradle。你可以随意选择任何项目管理工具以从 [Maven 中央仓库](http://search.maven.org/#search%7Cga%7C1%7Ca%3A%22mockito-core%22)以获取 Mockito jar 部件。

## 走近 Mockito（Approaching Mockito）

单元测试设计用来测试特定类或方法在没有其它依赖的情况下行为。因为我们在测试最小“单元”的代码，我们并不需要使用这些依赖的实际实现。更进一步，在测试不同行为时，我们将使用这些依赖稍微不同的实现。一种传统的比较知名的方式时创建“桩（stubs）”--适用于特定场景的一个接口的特定实现。这种实现通常拥有硬编码的逻辑。一个桩是一个测试实现，其它包括 fakes, mocks, spies, dummies,等。

我们将聚焦于两种测试部件（test double）：‘mocks’ 和 ‘spies’，因为它们被 Mockito 大量使用。

### Mocks

什么时 mocking？显然，这不是你取笑你的同伴之处。单元测试的 Mocking 创建一个对象以一种受控的方式来实现真实子系统的行为。总之，mocks 用作一个依赖的替代。

你可以使用 Mockito 来创建一个 mock，告诉 Mockito 在特定方法被调用时做什么，然后在你的测试中使用 mock 实例而不是真实对象。测试之后，你可以查询 mock 什么特定方法被调用过，或者检查状态变化呈现的调用的副作用。

默认情况下， Mockito 提供了 mock 对象的每一个方法的实现。

### Spies

一个 spy 是 Mockito 创建的另一个测试部件（test double）。与 mocks 相比，创建一个 spy 需要一个实例来监视。默认情况下，一个 spy 把所有方法调用委托给一个真实对象，并记录调用方法及其实际参数。这就是组成一个 spy 的实际内容：它监视一个真实的对象。

只要可能尽可能考虑用 mocks 代替 spies。Spies 可能对测试遗留代码有用，这些遗留代码不能被重新实现使得易于测试，但是需要使用 spy 来部分地 mock 一个类的需求表明这个类做了太多工作，违反了单一职责原理。

### 构建一个简单例子

让我们来看一个简单的演示，我们可以为其添加测试。假如我们有一个 `UserRepository` 接口，其有一个方法是通过识别码找到一个用户。我们拥有一个概念一个密码编码器用于将一个明文密码转变成密码哈希。 `UserRepository` 和 `PasswordEncoder` 都是 `UserService` 的通过构造函数注入的依赖（也被称为协作器 `collaborators`）。下面是我们的演示代码：

UserRepository：
```
UserRepository
public interface UserRepository {
   User findById(String id);
}
```

User：
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

PasswordEncoder：
```
public interface PasswordEncoder {
   String encode(String password);
}
```

UserService：
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

再导入后，我们模仿了 `PasswordEncoder`。`Mockito` 不仅仅可以模仿接口，也可以模仿抽象类及实体非 final 类。开箱即用， Mockito 并不能模仿 final 类，final 或静态方法。但如果你真的需要它，Mockito 2 提供了实验性的 [MockMaker](https://github.com/mockito/mockito/blob/release/2.x/src/main/java/org/mockito/plugins/MockMaker.java) 插件。

同时请注意 `equals()` 和 `hashCode()` 方法不能被模仿。

### 创建 Spies

为了创建一个 spy，我们需要调用 Mockito 的静态方法 spy() 并传递一个待监视的实例。返回对象的调用方法将会调用真实的方法，除非这些方法是存根方法。这些调用被记录下来，并且这些调用的事实可以被验证（请参看稍后 verify() 的描述）。让我们创建一个 spy：

```
DecimalFormat decimalFormat = spy(new DecimalFormat());
assertEquals("42", decimalFormat.format(42L));
```

创建一个 spy 与创建一个 mock 并没有什么太大的不同。更进一步，所有 Mockito 的用于配置一个 mock 方法也适用于配置一个 spy。

相对于 mocks，spies 用的较少，但你会发现对于不能重构的遗留代码的测试会很有用--这种测试需要部分 mocking。在这种情况下，你可以紧急你创建一个 spy 并对有些方法打桩以得到你期待的行为。

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

现在考虑下面你的代码片段，它初步展示了从一个 mock 的方法返回的期待的默认值：

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

上述打桩代码片段应该读作：“返回 a， 当 passwordEncoder 的 encode() 方法以参数 1 被调用时”。

通常倾向于第一种方式，因为他是类型安全的并更具可读性。但是，虽然罕见，你被迫使用第二种方式，例如当对一个 spy 的真实方法打桩时，因为调用它可能具有意想不到的副作用。

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

`then()`, `thenAnswer()` 的别名，和 `doAnswer()` 做同样的事情，它用于当方法调用时设置一个自定义回答。例如：

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

如果你觉得这看起啦很本中，那么你是对的。Mockito 提供了 `thenCallRealMethod()` 和 `thenThrow()` 来流水化这种类型测试。

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

Mockito 将会失败并打印下买你的消息：

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

Mockito 确保抛出的异常对于特定的打桩方法是有效地，如果异常不在方法的检查型一场列表里，它将会抱怨。考虑下面的代码片段：

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

你也可以传递一个异常的类而不是传递一个异常的一个实例：

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

为了修正这个错误，我们必须代替最后一行－－包括一个 `eq` 参数匹配器以代替 `a`，如下所示：

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

参数匹配器也不能用作返回值。Mockito 不能返回 `anyString()` 或者任意别的什么；打桩方法被调用时一个精确的值时必须的。

#### 自定义匹配器（CUSTOM MATCHERS）

当你需要一些当前 Mockito 不能提供的匹配逻辑，自定义匹配器来救场了。创建自定义匹配器的决定不能轻易做出，因为需要以非微小的方式匹配参数通常指示设计有问题或者一个测试变得太复杂了。

因此在你编写自定义匹配器之前，检查能否利用某些仁慈的参数匹配器如 `isNull()` 和 `nullable()` 等来简化测试时值得的。如果你觉得你仍需要编写参数匹配器，Mockito 提供了一套方法从做这个：

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

### 验证行为（Verifying Behavior）

## 测试我们的简单例子（Testing Our Simple Example）

### API之下（Diving beneath the API）

## 当 Mockito 看起来风格不太好（When Mockito Tastes Bad）

## Mockito 是关于思维框架的（Is about Frame of Mind）

使用 Mockito 并不仅仅是添加了一个依赖，它需要你改变你在移除样本代码之外思考你的单元测试的方式。

拥有多种 mock 接口，监听调用（listening invocations），匹配器和参数捕捉器，我们已经看到了 Mockito 是你的测试更干净也更易于理解。但像其它任何工具一样，只有使用恰当它才有用。现在你拥有了 Mockito 的内部工作机制，你可以把你的单元测试带向一个更高级别。

## Reference
- [A Unit Testing Practitioner's Guide to Everyday Mockito](https://www.toptal.com/java/a-guide-to-everyday-mockito)
- [Mockito Tutorial](https://www.javatpoint.com/methods-of-mockito)