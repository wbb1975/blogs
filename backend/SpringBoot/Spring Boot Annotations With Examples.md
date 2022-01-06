# Spring Boot Annotations With Examples
## 1 注解基础
在讨论 “Spring Boot 注解及其实例”之前，让我们先讨论一些在解释注解时用到的一些基本术语。
- Bean：Spring Bean 时实例化，组装好且被 Spring 容器管理的 Java 对象。
### 1.1 什么是控制反转容器（What is The IoC container?）
简言之，在创建 Bean 时注入依赖的容器。`IoC` 代表“控制反转”。借助控制反转容器，利用类的直接构造 bean 自己控制其依赖的实例化或定位，而非由我们（主动）创建对象。因此，这个过程被称为“控制反转”。有时候我们也简称之为 Spring 容器。

`org.springframework.beans` 和 `org.springframework.context` 包是 Spring Framework [控制反转容器](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/beans.html)的基础。[ApplicationContext](http://static.springsource.org/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html) 是 `BeanFactory` 的子接口。
### 1.2 什么是 Spring Framework 的应用上下文（What is an Application Context in Spring Framework?）
当你使用 Spring 或 Spring Boot 创建一个项目，一个容器或包装器被创建出来以管理你的 beans。这就是应用上下文（Application Context）。但是 Spring 支持两种容器：`Bean Factory` 和 `Application Context`。简单来讲，`BeanFactory` 提供配置框架和基础功能。而 `ApplicationContext` 增加了许多企业级特性如：更易于与 `Spring AOP` 特性集成，消息资源处理（国际化中使用），事件发布，应用层特定上下文如 Web 应用中使用的 `WebApplicationContext`。`ApplicationContext` 是 `BeanFactory` 的完整超集，在 本文描述 Spring 的控制反转容器时特地使用。Spring 框架推荐使用 `Application Context` 以获得框架的全部特性。而且，依赖注入和 Bean 自动装配也是在 `Application Context` 中完成。

接口 `org.springframework.context.ApplicationContext` 代表 Spring 依赖反转容器，它管理了 beans 的初始化，配置以及装配的全过程。容器通过读取配置元数据来获取关于什么对象需要初始化，配置以及装配的指令。配置元数据表现为 XML文件，Java 注解以及 Java 代码。
### 1.3 什么是 Spring Bean 或 组件 （What is Spring Bean or Components?）
在应用启动过程中，Spring 初始化对象并将其添加到应用上下文（Application Context）。这些在应用上下文中的对象被称为 `Spring Beans` 或 `Spring Components`。由于它们由 Spring 管理，我们可以称呼它们为 `Spring-managed Bean`或 `Spring-managed Component`。
### 1.4 什么是组件扫描（What is Component Scanning?）
发现可作用于应用上下文的类的过程被称为组件扫描。在组建扫描过程中，如果 Spring 发现了一个类带有特殊的注解，它将考虑将其视为 Spring Bean/Component 的一个候选，并将其加入到应用上下文。借助 @ComponentScan 注解，Spring 显式将其视为 Spring bean 的候选。
### 1.5 在 Spring Boot 应用中什么时候使用组件扫描（When to use Component Scanning in a Spring Boot Application?）
默认地，@ComponentScan 注解将扫描当前包及其子包以查找组件。如果它是一个 Spring Boot 应用，包含主类（带 @SpringBootApplication 注解的类）的包下的所有包都会被隐式扫描。因此如果你的包不在包含主类的包的层级结构下，那么需要显式声明一个组件扫描。
### 1.6 Spring 注解对比 Spring Boot 注解（Spring Annotations vs Spring Boot Annotations）
我们都知道 Spring Boot 框架使用 Spring 框架库创建，并移除了 XML 配置方式。但是，所有 Spring 的注解仍适用于 Spring Boot。而且 Spring Boot 还提供了一些仅仅适用于 Spring Boot 的注解。在某些情况下，Spring Boot 在创建了一个 Spring 框架注解之后创建注解。这里，我们将学习常用注解，它是 Spring 框架或者 Spring Boot 的一部分。
## 2 创建 Bean的注解（Annotations to create a Bean）
让我们开始讨论我们的主题 “Spring Boot 注解及其实例”，从创建 Bean 的注解入手。无需细说，我们在 Spring Boot/Spring 上工作离不开创建 Bean。现在你可以想象它有多重要。
### 2.1 @Configuration
我们将这个注解应用到类上。当我们将其应用到类上，这个类将自配置。通常由 @Configuration 注解的类拥有 Bean 的定义，可用作 XML 配置中 `<bean/>` 标签的一个替代。它也代表使用 Java 类的一个配置。而且，该类有方法来实例化和配置其依赖。例如：
```
@Configuration
public class AppConfig { 
    @Bean
    public RestTemplate getRestTemplate() {
       RestTemplate restTemplate = new RestTemplate();
       return restTemplate();
    } 
}
```
通过这个方法创建一个对象的好处是**你会仅仅拥有它的一个实例**。当需要它时你不需要多次创建该对象。现在你可以在你的代码的任何地方调用它。
### 2.2 @Bean
我们在方法级别使用 @Bean 注解。如果你记得 Spring 的 XML 配置，它和 XML `<bean/>` 元素很相似。它创建 Spring Beans，且通常和 `@Configuration` 一起使用。正如之前提到的，一个带 @Configuration 注解的类（我们将其称为注解类）将拥有方法来实例化对象并配置依赖。这类方法将拥有 `@Bean` 注解。默认地，Bean 的名字与方法名相同。它实例化并返回实际的 Bean，注解方法产生一个由 Spring IoC 容器管理的 Bean。
> **注意**： Spring 上添加的 @Bean 注解都是**默认单例模式**。
```
@Configuration
public class AppConfig {
     @Bean 
     public Employee employee() {
         return new Employee();
     }
    @Bean
    public Address address() {
        return new Address();
     }
}

```
为了便于比较，上面的配置与下面的 Spring XML 完全相同：
```
<beans>
    <bean name="employee" class="com.dev.Employee"/>
    <bean name="address" class="com.dev.Address"/>
</beans>
```
注解支持大部分 `<bean/>` 提供的元素，比如：[init-method](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-lifecycle-initializingbean), [destroy-method](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-lifecycle-disposablebean), [autowiring](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-autowire), [lazy-init](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-lazy-init), [dependency-check](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-dependencies), [depends-on](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-dependson) 和 [scope](http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-scopes)。
### 2.3 @Component
这是一个相对老套的注解，指示该类是一个 Spring 管理的 bean/component。@Component 是一个类级别注解。其它注解（stereotypes）是 @Component 的特化。在组件扫描过程中，Spring 框架自动发现带 @Component 注解的类，它将它们在应用上下文中以 Spring Bean 的形式注册。在一个类上应用 @Component 注解意味着我们将该类标记成 Spring 管理的 bean/component。例如，看看下面的代码：
```
@Component
class MyBean { }
```
当编写了一个如上所示的类时，Spring 将创建一个名为 myBean 的 Bean 实例。请记住，**该类的 Bean 实例与该类拥有相同名字**，输了首字母小写。然而，我们可以利用该注解一个可选阐述来为其制指定一个不同的名字，如下所示：
```
@Component("myTestBean")
class MyBean { }
```
### 2.4 @Controller
@Controller 告诉 Spring 框架以 @Controller 注解的类将用作 Spring MVC 项目中的控制器。
> **注意**： Spring 上添加的 @Controller 注解都是**默认单例模式**。
### 2.5 @RestController
@RestController 告诉 Spring 框架以 @RestController 注解的类将用作 Spring REST 项目中的控制器。
### 2.6 @Service
@Service 告诉 Spring 框架以 @Service 注解的类是服务层的一部分，它将包含该应用的商业逻辑。
> **注意**： Spring 上添加的 @Service 注解都是**默认单例模式**。
### 2.7 @Repository
@Repository 告诉 Spring 框架以 @Repository 注解的类是数据访问层的一部分，它将包含从该应用的数据库访问数据的逻辑。
### 2.8 @Bean vs @Component
@Component 是一个类级别注解，@Bean 是一个方法级别注解且方法名用作 Bean 名。@Bean 必须用在一个以 @Configuration 注解的类里面。然而，@Component 不需要与 @Configuration 一起使用。@Component 利用类路径扫描来发现并配置 Bean，另一方面 @Bean 显式声明一个 Bean，而不是让 Spring 自动去做这个。
## 3 配置注解（Configuration Annotations）
我们的主题 “Spring Boot 注解及其实例” 下的另一类注解用于配置（Configurations）。因为 Spring 框架在配置上是健康的，我们不可避免要学习关于配置的注解。毫无疑问，它们可以节约我们大量的代码量。
### 3.1 @ComponentScan
Spring 容器借助 `@ComponentScan` 的帮助来检测 Spring 管理的组件。一旦你使用这个注解，你就告诉了 Spring 到哪里去查找 Spring 组件。当一个 Spring 应用启动时， Spring 容器需要一些信息来在应用上下文中定位并注册所有 Spring 组件。但是它能够从预定义的项目包里自动扫描以固定的注解例如 `@Component`, `@Controller`, `@Service`, 和 `@Repository` 标注的类。

`@ComponentScan` 注解与 `@Configuration` 注解一起使用，指示 Spring 扫描包以查找注解组件。`@ComponentScan` 也可使用 `@ComponentScan` 的 `basePackages` 或 `basePackageClasses` 属性来指定基础包或者基础包类，例如：
```
import com.springframework.javatechonline.example.package2.Bean1;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
@Configuration
@ComponentScan(basePackages = {"com.springframework.javatechonline.example.package1",
                                "com.springframework.javatechonline.example.package3",
                                "com.springframework.javatechonline.example.package4"},
                basePackageClasses = Bean1.class
                               )
public class SpringApplicationComponentScanExample {
               ....
}
```
这里 `@ComponentScan` 注解使用 `basePackages` 属性指定了 Spring 容器需要扫描的三个包及其子包。而且，注解还使用 `basePackageClasses` 属性声明了 `Bean1` 类，Spring Boot 也会扫描其包。

更进一步，在一个 Spring Boot 项目中，我们典型地在主应用上使用 `@SpringBootApplication` 注解。在其内部，`@SpringBootApplication` 是 `@Configuration` 和 `@ComponentScanableAutoConfiguration` 注解的组合。默认设置下，Spring Boot 将自动扫描当前包（包含主应用包）及其子包下的所有组件。
### 3.2 @Import
假如我们有多个带有 `@Configuration` 注解的 Java 配置类。`@Import` 用于导入一个或多个 Java 配置类。更进一步，它可以把多个 Java 配置类组织起来。当一个 `@Configuration` 类逻辑地导入由另一个类定义的 Bean 时，我们可以使用这个注解。例如：
```
@Configuration
@Import({ DataSourceConfig.class, TransactionConfig.class })
public class AppConfig extends ConfigurationSupport {
    // @Bean methods here that can reference @Bean methods in DataSourceConfig or TransactionConfig
} 
```
### 3.3 @PropertySource 
如果你[使用 IDE 或者 STS 创建了一个 Spring Boot 启动器项目](https://javatechonline.com/saving-data-into-database-using-spring-boot-data-jpa-step-by-step-tutorial/#Step_1_Creating_Starter_Project_using_STS)，默认地 `application.properties` 将会被在 `resources` 目录下生成。你可以更方便地通过 `@PropertySource` 提供属性文件（包含键值对）的名字和位置，更进一步，这个注解提供了一个更方便以及声明式的机制以将一个 `PropertySource` 添加到 Spring 环境，例如：
```
@Configuration
@PropertySource("classpath:/com/dev/javatechonline/app.properties")
public class MyClass {
}
```
### 3.4 @PropertySources (For Multiple Property Locations)
当然，如果你的的项目中有多个属性位置，我们也能使用 `@PropertySources` 注解以指定一个 `@PropertySource` 数组。
```
@Configuration 
@PropertySources({ 
              @PropertySource("classpath:/com/dev/javatechonline/app1.properties"), 
              @PropertySource("classpath:/com/dev/javatechonline/app2.properties") 
})
public class MyClass { }
```
但是，我们亦可以以如下另一种方式写出同样的代码。在 Java 8 的惯例中 `@PropertySource` 注解可以重复出现。因此，如果你在使用 Java 8 或更新版本，我们可以使用这个注解来定义多个属性位置。例如：
```
@Configuration 
@PropertySource("classpath:/com/dev/javatechonline/app1.properties")
@PropertySource("classpath:/com/dev/javatechonline/app2.properties") 
public class MyClass { }
```
> **注意：如果有任何名字冲突，比如相同属性名，最后的数据源将被选中**。
### 3.5 @Value
我们可以使用这个注解来向 Spring 管理的 Bean 的字段注入值。我们可以在**字段，构造函数以及方法参数级别**使用它。例如，让我们定义一个属性文件，然后使用 @Value 注入这些值。
```
server.port=9898
server.ip= 10.10.10.9
emp.department= HR
columnNames=EmpName,EmpSal,EmpId,EmpDept
```
现在使用 @Value 注入 server.ip 的值如下：
```
@Value("${server.ip}")
private String serverIP;
```
#### 3.5.1 @Value 用于默认值
如果你在属性文件中没有定义一个属性，那么我们可以为该属性提供一个默认值。下面是一个例子：
```
@Value("${emp.department:Admin}")
private String empDepartment;
```
这里 `Admin` 将会被注入属性 `emp.department`。但是，如果你已经在属性文件中定义了该属性，属性文件中的值将会覆盖它。
> **注意：如果同样的属性在系统属性以及一个属性文件中（同时）定义了，那么系统属性将会被选中**。
#### 3.5.2 @Value 用于多个值
有时候，我们需要注入一个属性的多个值，我们可以方便地在属性文件中将这个属性定义为一个逗号分隔的值。但是，我们可以简单地将属性值注入一个被定义为数组的属性。例如：
```
@Value("${columnNames}")
private String[] columnNames;
```
## 4 Spring Boot 特定注解
现在是时候将我们的主题 `“Spring Boot 注解及其实例”` 扩展到 Spring Boot 特定的注解了。它们是由 Spring Boot Framework 自己发现的。但是，它们中的大多数内部使用 Spring Framework 提供的注解并做了扩展。
### 4.1 @SpringBootApplication (@Configuration + @ComponentScan + @EnableAutoConfiguration)
每个使用 Spring Boot 的人都使用过这个注解。当我们创建一个 Spring Boot 启动器项目时，这个注解开箱即用。这个注解应用在含有 `main()` 方法的 main 类上。Main 类在 Spring Boot 应用中有两个目的：`配置`和`启动`。事实上，@SpringBootApplication 是一个带有默认值的三个注解的集合。它们是 `@Configuration`, `@ComponentScan`, 和 `@EnableAutoConfiguration`。因此，我们可以说 `@SpringBootApplication` 是一个 三合一的注解。
- @EnableAutoConfiguration： 开启 Spring Boot 的自动配置特性
- @ComponentScan：开启 `@Component` 包级别扫描以在 Spring 应用上下中发现和注册组件成 Bean
- @Configuration：允许在上下文中注册额外的 Bean 或者导入额外的配置类。

如果我们期待修改以上三种注解的行为，我们也可以使用它们来代替 `@SpringBootApplication` 注解。
### 4.2 @EnableAutoConfiguration
`@EnableAutoConfiguration` 开启 Spring Boot 应用类路径上的 Bean 的自动配置。简单来说，这个注解可以让 Spring Boot 自动配置应用上下文。因此，它自动创建和注册在我们的类路径上的 Jar文件中的 Bean，以及在我们的应用中由我们定义的 Bean。例如，当我们创建一个 Spring Boot 启动器项目时如果选择了在类路径中添加 `Spring Web` 和 `Spring Security` 依赖，Spring Boot 为我们自动配置 `Tomcat`，`Spring MVC` 和 `Spring Security`。

而且，Spring Boot 认为添加了 `@EnableAutoConfiguration` 注解的类的所在包为默认包。因此，如果我们在应用的根包上应用这个注解，所有的子包及类都会被扫描。最终，我们并不需要显式在包上添加 `@ComponentScan` 注解。

更进一步，`@EnableAutoConfiguration` 为我们提供了两个属性用以从自动配置中排除类。如果我们并不期待某些类被自动配置，我们可以利用排除属性来禁用它们。另一个属性是 `excludeName` 用以声明一系列完整路径的类。例如，下面是一些代码示例：
#### 4.2.1 Use of ‘exclude’ in `@EnableAutoConfiguration`
```
@Configuration
@EnableAutoConfiguration(exclude={WebSocketMessagingAutoConfiguration.class})
public class MyWebSocketApplication {
        public static void main(String[] args) {
            ...
        }
}
```
#### 4.2.2 Use of ‘excludeName’ in `@EnableAutoConfiguration`
```
@Configuration
@EnableAutoConfiguration(excludeName = {"org.springframework.boot.autoconfigure.websocket.servlet.WebSocketMessagingAutoConfiguration"})
public class MyWebSocketApplication {
        public static void main(String[] args) {
            ...
        }
}
```
### 4.3 @SpringBootConfiguration
这个注解是 Spring Boot 框架的一部分。但是，`@SpringBootApplication` 从它继承。因此，如果一个应用使用了 `@SpringBootApplication`，它已经使用了 `@SpringBootConfiguration`。而且，它可以用作 `@Configuration` 注解的替代。主要的区别在于 `@SpringBootConfiguration` 允许配置被自动发现。

`@SpringBootConfiguration` 指示类提供配置，它也应用到类级别。部分地，它在单元测试及集成测试中很有用。例如，检测下面的代码：
```
@SpringBootConfiguration
public class MyApplication {

     public static void main(String[] args) {
          SpringApplication.run(MyApplication.class, args);
     }
     @Bean
     public IEmployeeService employeeService() {
         return new EmployeeServiceImpl();
     }
}
```
### 4.4 @ConfigurationProperties
Spring 框架提供了各种方式来从属性文件中注入值。其中之一是使用 `@Value` 注解。另一种是在一个配置 Bean 上使用 `@ConfigurationProperties` 向一个 Bean 注入属性值。但两种方式有什么区别，使用 `@ConfigurationProperties` 的优势在哪里，你将在稍后得到答案。现在，让我们展示如何使用 `@ConfigurationProperties` 注解来从 `application.properties` 或其它任何你选择的属性文件注入属性值。

首先，让我们在 `application.properties` 文件中定义一些属性如下。让我们假设你在定义我们的开发工作环境的一些属性。因此，在属性名前加上前缀 “dev”。
```
dev.name=Development Application
dev.port=8090
dev.dburl=mongodb://mongodb.example.com:27017/
dev.dbname=employeeDB
dev.dbuser=admin
dev.dbpassword=admin
```
现在，创建一个带有`setter` 以及 `getter` 的 Bean 类并为其加上 `@ConfigurationProperties` 注解：
```
@ConfigurationProperties(prefix="dev")
public class MyDevAppProperties {
      private String name;
      private int port;
      private String dburl;
      private String dbname;
      private String dbuser;
      private String dbpassword;

    //getter and setter methods
}
```
这里，Spring 将自动绑定定义在我们的属性文件中的带前缀 “dev” 的属性，以及定义于 `MyDevAppProperties` 类中的同名字段。

接下来，使用 `@EnableConfigurationProperties` 注解来在你的 `@Configuration` 类中注册 `@ConfigurationProperties类`。
```
@Configuration
@EnableConfigurationProperties(MyDevAppProperties.class)
public class MySpringBootDevApp { }
```
最后创建一个 Test Runner 来测试这些属性值如下：
```
@Component
public class DevPropertiesTest implements CommandLineRunner {

      @Autowired
      private MyDevAppProperties devProperties;

      @Override
      public void run(String... args) throws Exception {
           System.out.println("App Name = " + devProperties.getName());
           System.out.println("DB Url = " + devProperties.getDburl());
           System.out.println("DB User = " + devProperties.getDbuser());
      }
}
```
我们也可以在 `@Bean` 注解的方法上 `@ConfigurationProperties` 注解。
### 4.5 @EnableConfigurationProperties
为了在我们的项目中使用注册类，我们需要将其注册为一个正规 Spring Bean。在这种情况下，`@EnableConfigurationProperties` 可以帮助我们。我们使用这个注解来在 Spring 上下文中注册我们的配置 Bean（一个 `@ConfigurationProperties` 注解类）。这是快速注册 `@ConfigurationProperties` 注解 Bean 的一种便利方式。而且，它严格地与 `@ConfiguratonProperties` 伴生。例如，你可以从前一章节引用 `@ConfigurationProperties`。
### 4.6 @EnableConfigurationPropertiesScan
`@EnableConfigurationPropertiesScan` 注解基于传给它的参数值来扫描包，并发现包里所有具有 `@ConfiguratonProperties` 注解的类。例如，检验下面的代码：
```
@SpringBootApplication
@EnableConfigurationPropertiesScan(“com.dev.spring.test.annotation”)
public class MyApplication { }
```
从上面的例子，`@EnableConfigurationPropertiesScan` 将会扫描包 `com.dev.spring.test.annotation` 里的所有 `@ConfiguratonProperties` 注解类并进而注册它们。
### 4.7 @EntityScan 和 @EnableJpaRepositories
Spring Boot 注解如 `@ComponentScan`, `@ConfigurationPropertiesScan` 甚至 `@SpringBootApplication` 使用包来定义扫描位置。类似地，`@EnityScan` 和 `@EnableJpaRepositories` 也使用包来定义扫描位置。这里我们使用 `@EntityScan`。

为了发现实体类（entity classes），另一方面通常 `@EnableJpaRepositories` 用于 JPA 存储库类（repository classes）。这些注解通常用于你的待发现类不位于根包下，也不在你的主应用的子包下。记住，`@EnableAutoConfiguration` (作为 `@SpringBootApplication` 的一部分) 扫描根包或你的主应用的子包下的所有类。因此，如果存储库类或其它实体类并未放在根包下也不在你的主应用的子包下，那么相关的包应该在你的主应用类中以 `@EntityScan` 和 `@EnableJpaRepositories` 注解做相应声明。例如，观察下面的代码：
```
@EntityScan(basePackages = "com.dev.springboot.examples.entity")

@EnableJpaRepositories(basePackages = "com.dev.springboot.examples.jpa.repositories")
```
## 5 其它注解的链接（Links to Other Annotations）
正如我们在 “Spring Boot 注解及其实例” 介绍章节所说，我们将讨论我们通常在 Spring Boot Web 应用中使用的注解。以下是 `“Spring Boot 注解及其实例”` 的后继文章：
- [Spring Boot Bean Annotations With Examples](https://javatechonline.com/spring-boot-bean-annotations-with-examples/)
- [Spring Boot MVC & REST Annotations With Examples](https://javatechonline.com/spring-boot-mvc-rest-annotations-with-examples/)
- [Spring Boot Security, Scheduling and Transactions Annotations With Examples](https://javatechonline.com/spring-boot-security-scheduling-transactions-annotations-with-examples/)
- [Spring Boot Errors, Exceptions and AOP Annotations With Examples](https://javatechonline.com/spring-boot-errors-and-aop-annotations-with-examples/)
## 6 我们能够在哪里使用注解？（Where can we use Annotations?）
我们可以将注解应用于一个应用的不同元素的声明上，比如类，字段，方法以及其它程序元素的声明。通常，我们在这些元素的前面应用这些注解。而且，随着 Java 8 的发布，我们也可将注解应用在类型上。例如，下面的代码片段展示了注解的应用。
### 6.1 Class instance creation expression
```
    new @Interned MyObject();
```
### 6.2 Type cast
```
myString = (@NonNull String) str;
```
### 6.3 implements clause
```
    class UnmodifiableList<T> implements
        @Readonly List<@Readonly T> { ... }
```
### 6.4 Thrown exception declaration
```
void monitorTemperature() throws
        @Critical TemperatureException { ... }
```
这种类型的注解被称为类型注解。更多信息，请参见类型注解及可插拔类型系统 https://docs.oracle.com/javase/tutorial/java/annotations/type_annotations.html。

但是，这些注解以前并不存在，以后我们会更多地看到它们在代码中出现。因此，我们必须至少对它们有个初步了解。

## Refrence
- [Spring Boot Annotations With Examples](https://javatechonline.com/spring-boot-annotations-with-examples/)
- [Annotations In Java](https://javatechonline.com/annotations-in-java/)
- [谈IOC--说清楚IOC是什么](https://blog.csdn.net/ivan820819/article/details/79744797)
- [Spring Boot Annotations](https://www.baeldung.com/spring-boot-annotations)
- [Spring Boot Reference Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Spring Boot Reference Guide](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/reference/html/)