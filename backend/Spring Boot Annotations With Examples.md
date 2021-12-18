# Spring Boot Annotations With Examples
## 1 注解基础
在讨论 “Spring Boot 注解及其实例”之前，让我们先讨论一些在解释注解时用到的一些基本术语。
- Bean： Spring Bean 时实例化，组装好且被 Spring 容器管理的 Java 对象。
### 1.1 什么是控制反转容器（What is The IoC container?）
简言之，在创建 Bean 时注入依赖的容器。`IoC`` 代表“控制反转”。借助控制反转容器，利用类的直接构造 bean 自己控制其依赖的实例化或定位，而非由我们（主动）创建对象。因此，这个过程被称为“控制反转”。有时候我们也简称之为 Spring 容器。

`org.springframework.beans` 和 `org.springframework.context` 包是 Spring Framework [控制反转容器](https://docs.spring.io/spring-framework/docs/3.2.x/spring-framework-reference/html/beans.html)的基础。[ApplicationContext](http://static.springsource.org/spring-framework/docs/current/javadoc-api/org/springframework/context/ApplicationContext.html) 是 `BeanFactory` 的子接口。
### 1.2 什么是 Spring Framework 的应用上下文（What is an Application Context in Spring Framework?）
当你使用 Spring 或 Spring Boot 创建一个项目，一个容器或包装器被创建出来以管理你的 beans。这就是应用上下文（Application Context）。但是 Spring 支持两种容器：`Bean Factory` 和 `Application Context`。简单来讲，`BeanFactory` 提供配置框架和基础功能。而 `ApplicationContext` 增加了许多企业级特性如：更易于与 `Spring AOP` 特性集成，消息资源处理（国际化中使用），事件发布，应用层特定上下文如 Web 应用中使用的 `WebApplicationContex`t。`ApplicationContext` 是 `BeanFactory` 的完整超集，在 本文描述 Spring 的控制反转容器时特地使用。Spring 框架推荐使用 `Application Context` 以获得框架的全部特性。而且，依赖注入和Bean 自动装配也是在 `Application Context` 中完成。

接口 `org.springframework.context.ApplicationContext` 代表 Spring 依赖反转容器，它管理了 beans 的初始化，配置以及装配的全过程。容器通过读取配置元数据来获取关于什么对象需要初始化，配置以及装配的指令。配置元数据表现为 XML文件，Java 注解以及 Java 代码。
### 1.3 什么是 Spring Bean 或 组件 （What is Spring Bean or Components?）
在应用启动过程中，Spring 初始化对象并将其添加到应用上下文（Application Context）。这些在应用上下文中的对象被称为 `Spring Beans` 或 `Spring Components`。由于它们由 Spring 管理，我们可以称呼它们为 `Spring-managed Bean`或 `Spring-managed Component`。
### 1.4 什么是组件扫描（What is Component Scanning?）
发现可作用于应用上下文的类的过程被称为组件扫描。在组建扫描过程中，如果 Spring 发现了一个类带有特殊的注解，它将考虑将其视为 Spring Bean/Component 的一个候选，并将其加入到应用上下文。借助 @ComponentScan 注解，Spring 显式将其视为 Spring bean 的候选。
### 1.5 在 Spring Boot 应用中什么时候使用组件扫描（When to use Component Scanning in a Spring Boot Application?）
默认地，@ComponentScan 注解將扫描当前包及其子包以查找组件。如果它是一个 Spring Boot 应用，包含主类（带 @SpringBootApplication 注解的类）的包下的所有包都会被隐式扫描。因此如果你的包不在包含主类的包的层级结构下，那么需要显式声明一个组件扫描。
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
通过这个方法创建一个对象的好处是你会仅仅拥有它的一个实例。当需要它时你不需要多次创建该对象。现在你可以在你的代码的任何地方调用它。
### 2.2 @Bean
我们在方法级别使用 @Bean 注解。如果你记得 Spring 的 XML 配置，它和 XML `<bean/>` 元素很相似。它创建 Spring Beans，且通常和 @Configuration 一起使用。正如之前提到的，一个带 @Configuration 注解的类（我们将其称为注解类）将拥有方法来实例化对象并配置依赖。这类方法将拥有 @Bean 注解。默认地，Bean 的名字与方法名相同。它实例化并返回实际的 Bean，注解方法产生一个由 Spring IoC 容器管理的 Bean。
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
这是一个相对老套的注解，指示该类时一个 Spring 管理的 bean/component。@Component 时一个类级别注解。其它注解是 @Component 的特化。在组件扫描过程中，Spring 框架自动发现带 @Component 注解的类，它将它们在应用上下文中以 Spring Bean 的形式注册。在一个类上应用 @Component 注解意味着我们将该类标记成 Spring 管理的 bean/component。例如，看看下面的代码：
```
@Component
class MyBean { }
```
当编写了一个如上所示的类时，Spring 将创建一个名为 myBean 的 Bean 实例。请记住，该类的 Bean 实例与该类拥有相同名字，输了首字母小写。然而，我们可以利用该注解一个可选阐述来为其制指定一个不同的名字，如下所示：
```
@Component("myTestBean")
class MyBean { }
```
### 2.4 @Controller
@Controller 告诉 Spring 框架以 @Controller 注解的类将用作 Spring MVC 项目中的控制器。
### 2.5 @RestController
@RestController 告诉 Spring 框架以 @RestController 注解的类将用作 Spring REST 项目中的控制器。
### 2.6 @Service
@Service 告诉 Spring 框架以 @Service 注解的类是服务层的一部分，它将包含该应用的商业逻辑。
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
加入我们有多个带有 `@Configuration` 注解的 Java 配置类。`@Import` 用于导入一个或多个 Java 配置类。更进一步，它可以把多个 Java 配置类组织起来。当一个 `@Configuration` 类逻辑地导入由另一个定义的 Bean 时，我们可以使用这个注解。例如：
```
@Configuration
@Import({ DataSourceConfig.class, TransactionConfig.class })
public class AppConfig extends ConfigurationSupport {
    // @Bean methods here that can reference @Bean methods in DataSourceConfig or TransactionConfig
} 
```
### 3.3 @PropertySource 
如果你[使用 IDE 或者 STS 创建了一个 Spring Boot 启动器项目](https://javatechonline.com/saving-data-into-database-using-spring-boot-data-jpa-step-by-step-tutorial/#Step_1_Creating_Starter_Project_using_STS)，默认地 `application.properties` 将会被在 `resources` 目录下生成。你可以更方便地通过 `@PropertySource` 提供属性文件（报假案名值对）的名字和位置，更进一步，这个注解提供了一个更方便以及声明式的机制以将一个 `PropertySource` 添加到 Spring 环境，例如：
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
> **注意：如果由任何名字冲突，比如相同属性名，最后的数据源将被选中**。
### 3.5 @Value
我们可以使用这个注解来向 Spring 管理的 Bean 的字段注入值。我们可以在字段，构造函数以及方法级别使用它。例如，让我们定义一个属性文件，然后使用 @Value 注入这些值。
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
现在是时候将我们的主题 “Spring Boot 注解及其实例” 扩展到 Spring Boot 特定的注解了。它们是由 Spring Boot Framework 自己发现的。但是，它们中的大多数内部使用 Spring Framework 提供的注解并做了扩展。
### 4.1 @SpringBootApplication (@Configuration + @ComponentScan + @EnableAutoConfiguration)
每个使用 Spring Boot 的人都使用过这个注解。当我们创建一个 Spring Boot 启动器项目时，我们会以礼物形式收到这个注解。这个注解应用在含有 main() 方法的 main 类上。Main 类在 Spring Boot 应用中有两个目的：`配置`和`启动`。事实上，@SpringBootApplication 是一个带有默认值的三个注解的集合。它们是 `@Configuration`, `@ComponentScan`, 和 `@EnableAutoConfiguration`。因此，我们可以说 `@SpringBootApplication` 是一个 三合一的注解。
- @EnableAutoConfiguration： 开启 Spring Boot 的自动配置特性
- @ComponentScan：开启 @Component 包级别扫描以在 Spring 应用上下中发现和注册组件成 Bean
- @Configuration：允许在上下文中注册额外的 Bean 或者导入额外的配置类。
### 4.2 @EnableAutoConfiguration
#### 4.2.1 Use of ‘exclude’ in @EnableAutoConfiguration 
#### 4.2.2 Use of ‘excludeName’ in @EnableAutoConfiguration 
### 4.3 @SpringBootConfiguration
### 4.4 @ConfigurationProperties
### 4.5 @EnableConfigurationProperties
### 4.6 @EnableConfigurationPropertiesScan
### 4.7 @EntityScan and @EnableJpaRepositories
## 5 其它注解的链接（Links to Other Annotations）
### 5.1 Spring Boot Bean Annotations With Examples
### 5.2 Spring Boot MVC & REST Annotations With Examples
### 5.3 Spring Boot Security, Scheduling and Transactions Annotations With Examples
### 5.4 Spring Boot Errors, Exceptions and AOP Annotations With Examples
## 6 我们能够在哪里使用注解？（Where can we use Annotations?）
### 6.1 Class instance creation expression
### 6.2 Type cast
### 6.3 implements clause
### 6.4 Thrown exception declaration

## Refrence
- [Spring Boot Annotations With Examples](https://javatechonline.com/spring-boot-annotations-with-examples/)
- [Annotations In Java](https://javatechonline.com/annotations-in-java/)
- [谈IOC--说清楚IOC是什么](https://blog.csdn.net/ivan820819/article/details/79744797)