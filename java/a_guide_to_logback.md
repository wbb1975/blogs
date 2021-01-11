# logback教程
## 1. 简介
[logback](https://logback.qos.ch/)是Java社区最广泛使用的日志框架之一。它是[对其前任Log4j的替代](https://logback.qos.ch/reasonsToSwitch.html)。Logback提供了比Log4j更快的实现，提供了更多配置选项，也提供了归档旧的日志文件时更多的弹性。

本文介绍了Logback的结构，并向你展示如何使用它才能使你的应用更好。
## 2. Logback 架构
3个类组成了 `Logback` 的主体架构：`Logger`, `Appender`, 和 `Layout`。

`logger` 是打印消息的上下文。这是应用主要交互的类，用来创建日志消息。

`Appenders` 将日志消息发送到它们的最终目的地。一个 `Logger`可以拥有多个 `Appenders`。我们通常认为 `Appender` 附加到文本文件上，但 `Logback` 可以做到更多。

`Layout` 准备消息用于输出。`Logback` 支持创建自定义类来格式化消息，也支持对现有类的健壮的配置选项。
## 3. 安装
### 3.1 Maven依赖
`Logback`使用Simple Logging Facade for Java (SLF4J)作为它的原生接口。在我们能够开始记录消息之前，我们需要将 Logback 和 Slf4j 添加到我们的 `pom.xml` 里:
```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-core</artifactId>
    <version>1.2.3</version>
</dependency>
 
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-api</artifactId>
    <version>1.7.30</version>
    <scope>test</scope>
</dependency>
```
Maven 中央存储库拥有[`Logback Core`的最新版本](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22ch.qos.logback%22%20AND%20a%3A%22logback-core%22)和 [slf4j-api的最新版本](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22org.slf4j%22%20AND%20a%3A%22slf4j-api%22)。
### 3.2 类路径（Classpath）
`Logback`也要求 [logback-classic.jar](https://search.maven.org/classic/#search%7Cga%7C1%7Clogback-classic)在其运行类路径上。

我们将它加到`pom.xml`中作为测试依赖：
```
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>
```
## 4. 基本示例和配置
让我们开始一个在应用中使用 `Logback` 的快速实例。

首先，我们需要一个配置文件，我们创建了一个名为 `logback.xml` 的文本文件，并把它放在类路径下：
```
<configuration>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>
 
  <root level="debug">
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
```
接下来，我们需要一个带有 `main` 方法的简单类：
```
public class Example {
 
    private static final Logger logger 
      = LoggerFactory.getLogger(Example.class);
 
    public static void main(String[] args) {
        logger.info("Example log from {}", Example.class.getSimpleName());
    }
}
```
这个类创建了一个 `Logger` ，并调用其 `info()` 方法来产生一条日志信息。

当I运行这个示例时，你会看到我们的消息呗打印到终端上：
`20:34:22.136 [main] INFO Example - Example log from Example`

很容易看到为什么`Logback` 这么流行：我们只需几分钟就可以把它运行起来。

配置文件和代码给了我们一些它如何工作的提示：
- 我们拥有一个名为 `STDOUT的`的`Appendar`，它引用类 `ConsoleAppender`
- 有一个模式 `pattern` 描述了我们的日志消息的格式
- 我们的代码创建了一个 `Logger`，我们把我们的消息通过 `info()` 方法传递给它。

现在我们已经了解了基础部分，接下来让我们就近观察它。
## 5. Logger上下文
### 5.1 创建一个上下文
为了打印一条消息到`Logback`，我们从`SLF4J` 或 `Logback`初始化一个`Logger`：
```
private static final Logger logger 
  = LoggerFactory.getLogger(Example.class);

```
接下来并使用它：
```
logger.info("Example log from {}", Example.class.getSimpleName()
```
这是我们的日志上下文。当我们创建它时，我们向 `LoggerFactory`传递我们的类。这给了logger一个名字（有一个重载函数接受字符串参数）。

日志上下文以一种层级形式存在，看上去非常想Java对象层级体系：
- 一个 logger当其名字和“.”是一个后继 logger 名字的前缀时，它就是后者的祖先（ancestor）。
- 一个 logger如果在它及其子logger之间没有额外级别，它就是一个父亲级别，

例如，下面的`Example`类位于`com.baeldung.logback`包中，而另外一个类`ExampleAppender`位于`com.baeldung.logback.appenders`包中。
- ExampleAppender的logger属于Example logger的儿子。
- 所有的loggers都是预定义根logger的子孙。

一个`logger`拥有一个日志级别，可以通过配置文件或`Logger.setLevel()`方法设定。代码中的级别设定将覆盖配置文件中的设定。

可能的日志级别按顺序为：`TRACE`, `DEBUG`, `INFO`, `WARN` 和 `ERROR`。每个级别有一个对应的方法，我们使用它来记录对应级别的消息。

如果一个logger没有显式设定日志级别，它会从离其最近的祖先中继承。根logger缺省级别为DEBUG，下面我们将看到如何改变它。
### 5.2 使用上下文
让我们创建一个示例应用来展示在日志层级中应用上下文：
```
ch.qos.logback.classic.Logger parentLogger = 
  (ch.qos.logback.classic.Logger) LoggerFactory.getLogger("com.baeldung.logback");
 
parentLogger.setLevel(Level.INFO);
 
Logger childlogger = 
  (ch.qos.logback.classic.Logger)LoggerFactory.getLogger("com.baeldung.logback.tests");
 
parentLogger.warn("This message is logged because WARN > INFO.");
parentLogger.debug("This message is not logged because DEBUG < INFO.");
childlogger.info("INFO == INFO");
childlogger.debug("DEBUG < INFO");
```
当我们运行它时，我们会看到下面的消息：
```
20:31:29.586 [main] WARN com.baeldung.logback - This message is logged because WARN > INFO.
20:31:29.594 [main] INFO com.baeldung.logback.tests - INFO == INFO
```
我们从检索一个名为`com.baeldung.logback`的 logger 开始，将其转型为一个`ch.qos.logback.classic.Logger`。一个 `Logback` 上下文在下面的语句中需要设置日志级别，`SLF4J`的抽象 logger 没有实现`setLevel()`。

我们把上下文的日志级别设置为`INFO`，接下来我们创建了另一个logger名为`com.baeldung.logback.tests`。

我们用每个上下文发送了两条消息来演示层级结构。Logback 打印了`WARN`, 和 `INFO`消息，但滤过了`DEBUG`消息。

现在，让我们使用根logger：
```
ch.qos.logback.classic.Logger logger = 
  (ch.qos.logback.classic.Logger)LoggerFactory.getLogger("com.baeldung.logback");
logger.debug("Hi there!");
 
Logger rootLogger = 
  (ch.qos.logback.classic.Logger)LoggerFactory.getLogger(org.slf4j.Logger.ROOT_LOGGER_NAME);
logger.debug("This message is logged because DEBUG == DEBUG.");
 
rootLogger.setLevel(Level.ERROR);
 
logger.warn("This message is not logged because WARN < ERROR.");
logger.error("This is logged.");
```
当我们执行上面的代码片段是我们会看到下面的消息：
```
20:44:44.241 [main] DEBUG com.baeldung.logback - Hi there!
20:44:44.243 [main] DEBUG com.baeldung.logback - This message is logged because DEBUG == DEBUG.
20:44:44.243 [main] ERROR com.baeldung.logback - This is logged.
```
总结一下，我们以一个 Logger 上下文开始，并打印了一条 `DEBUG` 消息。

然后我们使用根 logger 的静态定义名字检索它并将其日志级别设置为 `ERROR`。

然后最后我们演示了 Logback 过滤了所有级别低于 `ERROR` 的消息。
### 5.3 参数化消息
不像上面的简单代码片段中的消息，大多数有用的日志消息需要添加字符串。这意味着内存分配，序列化对象，拼接字符串，以及潜在地在稍后做垃圾清理。

考虑下面的消息：
`log.debug("Current count is " + count);`

我们的成本是构建这条消息--无论logger是否打印这条消息。

Logback提供了一种可选方案即参数化消息：
`log.debug("Current count is {}", count);`

这个 `{}` 将接受任何对象，只有在验证过接受这条消息之后才会调用其`toString()`方法构建消息。

让我们试试不同的参数：
```
String message = "This is a String";
Integer zero = 0;
 
try {
    logger.debug("Logging message: {}", message);
    logger.debug("Going to divide {} by {}", 42, zero);
    int result = 42 / zero;
} catch (Exception e) {
    logger.error("Error dividing {} by {} ", 42, zero, e);
}
```
这段代码将产生：
```
21:32:10.311 [main] DEBUG com.baeldung.logback.LogbackTests - Logging message: This is a String
21:32:10.316 [main] DEBUG com.baeldung.logback.LogbackTests - Going to divide 42 by 0
21:32:10.316 [main] ERROR com.baeldung.logback.LogbackTests - Error dividing 42 by 0
java.lang.ArithmeticException: / by zero
  at com.baeldung.logback.LogbackTests.givenParameters_ValuesLogged(LogbackTests.java:64)
...
```
我们看到了字符串，整形数，整形包装类型是如何作为参数传递的。

同时，当一个`Exception`作为`logging`方法的最后一个参数被传递时，`Logback` 将为我们打印堆栈轨迹。
## 6. 详细配置
在上面的例子中，我们使用一个近11行的配置文件来将日志信息打印到终端上。这是 Logback 的默认行为；如果它不能找到一个配置文件，它将创建一个`ConsoleAppender`并将它附加到根 logger 上。
### 6.1 定位配置信息
一个配置文件可被放置于类路径下，并命名为ogback.xml 或 logback-test.xml。

下面是Logback 尝试找到配置数据的方式：
1. 在类路径下顺序查找名为`logback-test.xml`, `logback.groovy`, 或 `logback.xml` 的文件。
2. 如果库找不到上面的文件，它会尝试利用Java的[ServiceLoader](https://docs.oracle.com/javase/6/docs/api/java/util/ServiceLoader.html)来定位一个`com.qos.logback.classic.spi.Configurator`的实现。
3. 配置自己直接打印输出到终端。

注意，当前版本Logback 并不支持Groovy配置，原因在于没有一个与Java 9兼容的Groovy版本。
### 6.2 基本配置
让我们近距离查看我们的[示例配置](https://www.baeldung.com/logback#example)。

整个文件位于configuration标签中。

**我们看到声明一个类型为ConsoleAppender的Appender的标签，并命名它为STDOUT。在该标签下嵌套的是编码器（encoder）。它拥有一个模式，看起来像sprintf-style的转义代码**。
```
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
        <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
</appender>
```
最后，我们看到了一个`root`标签，该标签设置设置根logger日志级别为DEBUG，并将其输出关联到名为`STDOUT`的`Appendar`上：
```
<root level="debug">
    <appender-ref ref="STDOUT" />
</root>
```
### 6.3 配置问题定位
Logback 配置文件可能变得很复杂，因此有几个内建的机制帮助定位错误。

为了看到Logback 处理配置时的DEBUG信息，你可以打开DEBUG日志：
```
<configuration debug="true">
  ...
</configuration>
```
当Logback处理配置时将把状态信息打印到终端上：
```
23:54:23,040 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Found resource [logback-test.xml] 
  at [file:/Users/egoebelbecker/ideaProjects/logback-guide/out/test/resources/logback-test.xml]
23:54:23,230 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - About to instantiate appender 
  of type [ch.qos.logback.core.ConsoleAppender]
23:54:23,236 |-INFO in ch.qos.logback.core.joran.action.AppenderAction - Naming appender as [STDOUT]
23:54:23,247 |-INFO in ch.qos.logback.core.joran.action.NestedComplexPropertyIA - Assuming default type 
  [ch.qos.logback.classic.encoder.PatternLayoutEncoder] for [encoder] property
23:54:23,308 |-INFO in ch.qos.logback.classic.joran.action.RootLoggerAction - Setting level of ROOT logger to DEBUG
23:54:23,309 |-INFO in ch.qos.logback.core.joran.action.AppenderRefAction - Attaching appender named [STDOUT] to Logger[ROOT]
23:54:23,310 |-INFO in ch.qos.logback.classic.joran.action.ConfigurationAction - End of configuration.
23:54:23,313 |-INFO in ch.qos.logback.classic.joran.JoranConfigurator@5afa04c - Registering current configuration 
  as safe fallback point
```
如果在解析配置文件时遇到错误和警告，Logback将把状态信息写到终端。

还有第二个机制打印状态信息：
```
<configuration>
    <statusListener class="ch.qos.logback.core.status.OnConsoleStatusListener" />  
    ...
</configuration>
```
**StatusListener 拦截状态消息并在配置过程及运行过程中打印它们**。

从所有配置文件中的输出都被打印，它对定位类路径下的“流氓”配置文件是很有帮助的。
### 6.4 自动重载配置文件
在一个应用运行时自动重新加载日志配置文件是一个非常有用的问题定位工具。Logback 通过scan参数使其成为可能：
```
<configuration scan="true">
  ...
</configuration> 
```
默认行为是每60秒扫描整个配置文件以检查是否发生变化，添加`scanPeriod`以以修改这个间隔：
```
<configuration scan="true" scanPeriod="15 seconds">
  ...
</configuration>
```
我们可以指定值为 `milliseconds`, `seconds`, `minutes`, 或 `hours`。
### 6.5 修改Logger
在我们的实例文件中，我们设置了根logger 的日志级别并把它与面向终端的Appender联系在一起。

我们可以为任一logger设置日志级别：
```
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    <logger name="com.baeldung.logback" level="INFO" /> 
    <logger name="com.baeldung.logback.tests" level="WARN" /> 
    <root level="debug">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```
让我们把它放在类路径下并运行下面的代码：
```
Logger foobar = 
  (ch.qos.logback.classic.Logger) LoggerFactory.getLogger("com.baeldung.foobar");
Logger logger = 
  (ch.qos.logback.classic.Logger) LoggerFactory.getLogger("com.baeldung.logback");
Logger testslogger = 
  (ch.qos.logback.classic.Logger) LoggerFactory.getLogger("com.baeldung.logback.tests");
 
foobar.debug("This is logged from foobar");
logger.debug("This is not logged from logger");
logger.info("This is logged from logger");
testslogger.info("This is not logged from tests");
testslogger.warn("This is logged from tests");
```
我们看到下面的输出：
```
00:29:51.787 [main] DEBUG com.baeldung.foobar - This is logged from foobar
00:29:51.789 [main] INFO com.baeldung.logback - This is logged from logger
00:29:51.789 [main] WARN com.baeldung.logback.tests - This is logged from tests
```
不通过编程设定我们的logger日志级别，而是在配置文件设置它们，`com.baeldung.foobar`从根logger哪里继承了`DEBUG`级别。

Loggers 也从根logger哪里继承了 `appender-ref` ，正如我们下面将会看到的，我们可以覆盖它。
### 6.6 变量替代
Logback配置文件支持变量。我们在配置脚本里面或者外部定义变量，一个变量可在配置脚本的任何位置指定以替换变量。

例如，下面是一个 FileAppender的配置：
```
<property name="LOG_DIR" value="/var/log/application" />
<appender name="FILE" class="ch.qos.logback.core.FileAppender">
    <file>${LOG_DIR}/tests.log</file>
    <append>true</append>
    <encoder>
        <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
    </encoder>
</appender>
```
在配置顶部，我们定义了一个属性 `LOG_DIR`，然后在 `appender` 顶一种把它当作文件路径的一部分。

属性在配置脚本的<property>标签中声明，但它们也可从外部源中获取，例如系统属性。我们可以放弃例子中的属性声明，并在命令行上设置`LOG_DIR`的值：
`$ java -DLOG_DIR=/var/log/application com.baeldung.logback.LogbackTests`

我们用${propertyname}指定属性的值，Logback 用文本替换实现变量。变量替换可以在配置文件中的任何点指定，在该文件中其值也可能被指定。
## 7. Appenders
Loggers 传递`LoggingEvents` 给Appenders。Appenders从事实际的日志（logging ）功能。我们通常把日志（logging ）视为进入到文件或终端的某种东西，但Logback 可以做得更多。Logback-core提供了几种有用的appenders。
### 7.1 ConsoleAppender
我们已经看见过ConsoleAppender 的运行了，ConsoleAppender 将消息添加到System.out 或 System.err。

它使用OutputStreamWriter 来缓冲`I/O`，因此把它定向到 `System.err`并不会导致无缓冲的写入。
### 7.2 FileAppender
FileAppender 将消息添加到文件。它支持广泛的配置参数。让我们加一个文件appender 到我们的基础配置中去：
```
<configuration debug="true">
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <!-- encoders are assigned the type
             ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
 
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>tests.log</file>
        <append>true</append>
        <encoder>
            <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <logger name="com.baeldung.logback" level="INFO" /> 
    <logger name="com.baeldung.logback.tests" level="WARN"> 
        <appender-ref ref="FILE" /> 
    </logger> 
 
    <root level="debug">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```
FileAppender 通过 `<file>`配置文件名，`<append>` 标签指示Appender 将消息添加到一个已经存在的文件而无需截断它。如果我们运行测试多次，我们看到日志输出被添加到同一个文件。

如果我们从上面从新运行我们的测试，从 `com.baeldung.logback.tests` 来的消息将同时进入终端和名为 `tests.log` 的文件。**下层logger 继承根logger与ConsoleAppender 的关联，还有自己与FileAppender的关联：关联是累积的**。

我们可以覆盖该行为：
```
<logger name="com.baeldung.logback.tests" level="WARN" additivity="false" > 
    <appender-ref ref="FILE" /> 
</logger> 
 
<root level="debug">
    <appender-ref ref="STDOUT" />
</root>
```
设置additivity 为false将禁用缺省行为，Tests 将不会输出日志到终端，它的任何子logger也不会。
### 7.3 RollingFileAppender
通常，将消息添加到同一个文件并不是我们期待的行为，我们期待文件随时间，日志文件大小，或两者“滚动”。

为此，我们有RollingFileAppender：
```
<property name="LOG_FILE" value="LogFile" />
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>${LOG_FILE}.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <!-- daily rollover -->
        <fileNamePattern>${LOG_FILE}.%d{yyyy-MM-dd}.gz</fileNamePattern>
 
        <!-- keep 30 days' worth of history capped at 3GB total size -->
        <maxHistory>30</maxHistory>
        <totalSizeCap>3GB</totalSizeCap>
    </rollingPolicy>
    <encoder>
        <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
    </encoder>
</appender> 
```
一个RollingFileAppender 拥有`RollingPolicy`，在这个实例配置中，我们看到了一个`TimeBasedRollingPolicy`。

就像FileAppender：我们给appender 配置了一个文件名。我们声明了一个属性并用于此，因为我们下面将要重用该文件名。

我们在`RollingPolicy`中定义了一个`fileNamePattern` 。这个模式不是仅仅定义了文件的名字，也顶一了滚动它们的频率。`TimeBasedRollingPolicy` 检验该模式并以定义的期间滚动。

例如：
```
<property name="LOG_FILE" value="LogFile" />
<property name="LOG_DIR" value="/var/logs/application" />
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>${LOG_DIR}/${LOG_FILE}.log</file> 
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>${LOG_DIR}/%d{yyyy/MM}/${LOG_FILE}.gz</fileNamePattern>
        <totalSizeCap>3GB</totalSizeCap>
    </rollingPolicy>
```
轰动的日志文件是`/var/logs/application/LogFile`，该文件在每个月的开始滚动成 `/Current Year/Current Month/LogFile.gz`，`RollingFileAppender` 将创建一个新的文件。

当归档文件总大小超过3GB时，`RollingFileAppender`将基于 `first-in-first-out` 原则删掉旧的归档文件。

有代码指定week, hour, minute, second, 和甚至 millisecond的，Logback 有一个[参考](https://logback.qos.ch/manual/appenders.html#TimeBasedRollingPolicy)。

RollingFileAppender 内建对压缩文件的支持。由于文件命名为 `LogFile.gz`，它将压缩我们的滚动文件。

TimeBasedPolicy斌费我们滚动文件的唯一选择，Logback 也提供了 `SizeAndTimeBasedRollingPolicy`，它基于当前日志文件的大小和时间滚动。它还提供了`FixedWindowRollingPolicy`，它在每次logger 启动时滚动文件。

我们可以撰写自己的[RollingPolicy](https://logback.qos.ch/manual/appenders.html#onRollingPolicies)。
### 7.4 自定义Appender（Custom Appenders）
我们可以通过继承Logback 的基础appender 类来创建我们自己的Appenders，在[这里](https://www.baeldung.com/custom-logback-appender)有一个创建自定义Appender的教程。
## 8. Layouts
Layouts 格式化日志消息。就像Logback的其余部分，Layouts 是可扩展的，我们也可以[创建我们自己的](https://logback.qos.ch/manual/layouts.html#writingYourOwnLayout)。但是默认PatternLayout 提供了大部分应用需要的。

到目前为止我们在所有的示例中使用了PatternLayout ：
```
<encoder>
    <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
</encoder>
```
配置脚本包含了`PatternLayoutEncoder`的配置，我们传递 Encoder 给一个Appender，并且这个encoder使用这个 `PatternLayout` 来格式化消息。

`<pattern>`标签中的文本定义了消息如何格式化。PatternLayout 实现了一个巨大的可变风格的转换符，以及创建模式的格式化修饰符。

让我们分解它，PatternLayout 识别带一个 `%` 的转换字符，因此我们的模式中的转换将产生：
- %d{HH:mm:ss.SSS} – 一个带有时，分，秒及毫秒的时间戳
- [%thread] – 产生日志消息的线程名，以中括号包围
- %-5level – 日志事件的级别，补充到5个字符
- %logger{36} – logger名，截断到35个字符
- %msg%n – 日志消息后紧跟平台相关行分隔符

因此我们能看到像下面的消息：
`21:32:10.311 [main] DEBUG com.baeldung.logback.LogbackTests - Logging message: This is a String`
在[这里](https://logback.qos.ch/manual/layouts.html#conversionWord)可以找到转换付以及格式修饰符的完整列表。
## 9. 结论
在这个扩展教程里，我们讲述了在一个应用里使用Logback 的基础知识。

我们看到了Logback架构中的3个主要组件：loggers, appenders, 和 layout。Logback拥有强大的配置脚本，我们用它来控制组件过滤和格式化消息。我们也看到了两个使用最广泛的文件appenders以及如何创建，滚动，组织和压缩日志文件的。

像平常一样，代码片段可在[GitHub](https://github.com/eugenp/tutorials/tree/master/logging-modules/logback)上找到。

## Reference
- [A Guide To Logback](https://www.baeldung.com/logback)