# Java SPI(Service Provider Interface)

## 简介

Java 6 引入了一个新特性以发现并加载匹配给定接口的实现：服务提供者接口（SPI）。

在本教程中，我们将介绍 `Java SPI` 包含的组件，已经我们如何将其用于一个实际的用例。

## Java SPI 的术语与定义

Java SPI 定义了四个主要的组件：

### 2.1 服务（Service）

一套为众所知的编程接口和类，它们提供了对某些特定应用功能或特性的访问。

### 2.2 服务提供者接口（Service Provider Interface）

一个接口或抽象类用作访问服务的代理或端点。

如果服务是一个接口，那么它和服务提供者接口一致。

服务和服务提供者接口在 Java 生态中被称为 API。

### 2.3 服务提供者（Service Provider）

SPI 的一个特定实现。服务提供者包括实现或扩展了服务类型的一个或多个具体类。

服务提供者可被配置，并通过置于资源目录 `META-INF/services` 中的实现者配置文件被识别。文件名称是 SPI 的全限定名，其内容为 SPI 实现的全限定名。

服务提供者以扩展的形式安装，即一个置于应用类路径，Java扩展路径上或用户定义类路径上的 `jar` 文件。

### 2.4 服务加载器（ServiceLoader）

SPI 的核心是[ServiceLoader](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/ServiceLoader.html)类。它拥有发现和懒加载的角色。它使用上下文类路径来定位提供者实现并将它们放置于内部缓存中。

## 3. Java 生态中的 SPI 示例

Java 提供了许多 SPIs。这里是一些 SPI 以及它提供的服务的示例：

- [CurrencyNameProvider](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/spi/CurrencyNameProvider.html): 为 Currency 类提供本地化货币符号。
- [LocaleNameProvider](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/spi/LocaleNameProvider.html): 为Locale 类提供本地化名字
- [TimeZoneNameProvider](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/spi/TimeZoneNameProvider.html): 为 TimeZone  类提供本地时区名
- [DateFormatProvider](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/text/spi/DateFormatProvider.html): 为特定 locale 提供日期和时间格式
- [NumberFormatProvider](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/text/spi/NumberFormatProvider.html): 为 NumberFormat 类提供货币，整数以及百分比值。
- [Driver](https://docs.oracle.com/en/java/javase/17/docs/api/java.sql/java/sql/Driver.html): 从 4.0 开始, JDBC API 支持 SPI 模式。老版本使用 [Class.forName()](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Class.html#forName(java.lang.String)) 方法来加载驱动器。
- [PersistenceProvider](https://docs.oracle.com/javaee/7/api/javax/persistence/spi/PersistenceProvider.html): 提供 JPA API 实现。
- [JsonProvider](https://docs.oracle.com/javaee/7/api/javax/json/spi/JsonProvider.html): 提供 JSON 处理对象。
- [JsonbProvider](https://javaee.github.io/javaee-spec/javadocs/javax/json/bind/spi/JsonbProvider.html): 提供 JSON 绑定对象。
- [Extension](https://docs.oracle.com/javaee/7/api/javax/enterprise/inject/spi/Extension.html): 提供 CDI 容器扩展。
- [ConfigSourceProvider](https://openliberty.io/docs/20.0.0.7/reference/javadoc/microprofile-1.2-javadoc.html#package=org/eclipse/microprofile/config/spi/package-frame.html&class=org/eclipse/microprofile/config/spi/ConfigSourceProvider.html): 提供一个检索配置属性的源头。

## 4. Showcase: 一个汇率应用

现在我们理解了基础知识，让我们来描绘建立一个汇率应用所需步骤。

为了突出这些步骤，我们必须使用至少三个项目：`exchange-rate-api`, `exchange-rate-impl`, 和 `exchange-rate-app`。

在 4.1 小节，我们在模块 `exchange-rate-api` 中将讨论 服务，SPI 和 ServiceLoader；在 4.2 小节我们将在 `exchange-rate-impl` 模块中实现服务提供者；最后，我们将在 4.3 小节通过 `exchange-rate-app` 模块将所有组件结合在一起。

实际上，我们可以为服务提供者提供很多模块，并使它们在 `exchange-rate-app`` 模块的类路径上可用。

### 4.1 构建我们的 API

我们从创建 `Maven` 项目 `exchange-rate-api` 开始。虽然我们可以为项目取名任何名字，但以 api 结尾是个好的实践。

接下来我们创建一个模型类来代表汇率：

```
package com.baeldung.rate.api;

public class Quote {
    private String currency;
    private BigDecimal ask;
    private BigDecinal bid;
    private LocalDate date;
    ...
}
```

接下来我们通过创建接口 `QuoteManager` 来定义检索汇率的服务：

```
package com.baeldung.rate.api

public interface QuoteManager {
    List<Quote> getQuotes(String baseCurrency, LocalDate date);
}
```

接下来，我们为我们的服务创建一个 SPI：

```
package com.baeldung.rate.spi;

public interface ExchangeRateProvider {
    QuoteManager create();
}
```

最后，我们需要创建一个可悲客户端使用的工具类 `ExchangeRate.java`。这个类代理 `ServiceLoader`。

首先，我们调用静态工厂方法 `load()` 来得到一个 `ServiceLoader` 的实例：

```
ServiceLoader<ExchangeRateProvider> loader = ServiceLoader.load(ExchangeRateProvider.class);
```

然后我们调用 `iterate()` 方法来搜索并检索所有可用的实现。

```
Iterator<ExchangeRateProvider> = loader.iterator();
```

检索的结果被缓存，因此我们可以调用 `ServiceLoader.reload()` 来发现新安装的实现。

```
Iterator<ExchangeRateProvider> = loader.reload();
```

下面是我们的工具类：

```
public final class ExchangeRate {

    private static final String DEFAULT_PROVIDER = "com.baeldung.rate.spi.YahooFinanceExchangeRateProvider";

    //All providers
    public static List<ExchangeRateProvider> providers() {
        List<ExchangeRateProvider> services = new ArrayList<>();
        ServiceLoader<ExchangeRateProvider> loader = ServiceLoader.load(ExchangeRateProvider.class);
        loader.forEach(services::add);
        return services;
    }

    //Default provider
    public static ExchangeRateProvider provider() {
        return provider(DEFAULT_PROVIDER);
    }

    //provider by name
    public static ExchangeRateProvider provider(String providerName) {
        ServiceLoader<ExchangeRateProvider> loader = ServiceLoader.load(ExchangeRateProvider.class);
        Iterator<ExchangeRateProvider> it = loader.iterator();
        while (it.hasNext()) {
            ExchangeRateProvider provider = it.next();
            if (providerName.equals(provider.getClass().getName())) {
                return provider;
            }
        }
        throw new ProviderNotFoundException("Exchange Rate provider " + providerName + " not found");
    }
}
```

注意我们有一个服务可以得到所有安装的实现。在客户端代码中我们可以使用所有实现来扩展我们的应用或者仅选择我们偏爱的实现。

注意这个工具类对整个 API 项目并非必须。客户端代码可以选择自行调用 `ServiceLoader` 方法。

### 4.2 构建服务提供者

让我们创建一个名为 `exchange-rate-impl` 的 Maven 项目并将  API 作为依赖添加到 `pom.xml`。

```
<dependency>
    <groupId>com.baeldung</groupId>
    <artifactId>exchange-rate-api</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</dependency>
```

然后我们创建一个类实现了我们的 SPI：

```
public class YahooFinanceExchangeRateProvider 
  implements ExchangeRateProvider {
 
    @Override
    public QuoteManager create() {
        return new YahooQuoteManagerImpl();
    }
}
```

然后是 `QuoteManager` 接口的实现：

```
public class YahooQuoteManagerImpl implements QuoteManager {

    @Override
    public List<Quote> getQuotes(String baseCurrency, LocalDate date) {
        // fetch from Yahoo API
    }
}
```

为了被发现，我们创建了一个提供者配置文件：

```
META-INF/services/com.baeldung.rate.spi.ExchangeRateProvider
```

文件内容是 SPI 实现的全限定类型：

```
com.baeldung.rate.impl.YahooFinanceExchangeRateProvider
```

### 4.3 放在一起

最后，让我们创建客户端项目 `exchange-rate-app`，并将依赖 `exchange-rate-api` 添加到类路径上：

```
<dependency>
    <groupId>com.baeldung</groupId>
    <artifactId>exchange-rate-api</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</dependency>
```

现在，你可以从我们的应用中调用 SPI。

```
ExchangeRate.providers().forEach(provider -> ... );
```

### 4.4 运行应用

让我们专注于构建我们所有的模块。在 `java-spi` 模块的根目录下运行如下命令：

```
mvn clean package
```

然后我们使用 Java 命令运行我们的应用而无需考虑提供者。从 `java-spi` 模块的根目录下运行如下命令：

```
java -cp ./exchange-rate-api/target/exchange-rate-api-1.0.0-SNAPSHOT.jar:./exchange-rate-app/target/exchange-rate-app-1.0.0-SNAPSHOT.jar com.baeldung.rate.app.MainApp
```

由于发现不了提供者，上面的命令的结果将为空。

现在包括我们在 java.ext.dirs 扩展中的提供者，并再次运行我们的应用：

```
java -cp ./exchange-rate-api/target/exchange-rate-api-1.0.0-SNAPSHOT.jar:./exchange-rate-app/target/exchange-rate-app-1.0.0-SNAPSHOT.jar:./exchange-rate-impl/target/exchange-rate-impl-1.0.0-SNAPSHOT.jar:./exchange-rate-impl/target/depends/* com.baeldung.rate.app.MainApp
```

我们可以看到我们的提供者被加载，他会打印出 `ExchangeRate` 应用的输出。

注意: 为了在类路径中提供多个依赖，基于不同的操作系统你不得不提供不同的分隔符：

- 对 Linux分隔符是冒号(`:`).
- 对 Windows，分隔符是分号(`;`)。

## 5. 结论

现在我们已经通过良好定义的步骤探索了 Java SPI 运行机制，可以清楚地看到如何使用 Java SPI 来创建容易扩展和替换的模块。

虽然我们的例子使用了 `Yahoo exchange rate` 服务来展示了相比其它外部 API 插件的威力，产品系统并不需要依赖第三方 API 来创建伟大的 SPI 应用。

和往常一样，代码可以在 [Github](https://github.com/eugenp/tutorials/tree/master/core-java-modules/java-spi)上找到。

## Reference

- [Java Service Provider Interface](https://www.baeldung.com/java-spi)
- [SPI在Java中的实现与应用 | 京东物流技术团队](https://zhuanlan.zhihu.com/p/655096182)