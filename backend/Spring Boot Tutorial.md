# Spring Boot Tutorial
Spring Boot是一个建立于Spring框架之上的项目，它提供了一个更简单，更快速的方式来设立，配置和运行简单的应用和基于Web的应用。

它是一个Spring模块提供了对Spring框架的快速开发特性。它被用于创建独立的基于Spring的可运行的应用而只需要极小的Spring配置。
![What's sprint boot](images/what-is-spring-boot.png)

简单而言，Spring Boot是Spring框架和嵌入式服务器的组合。

在Spring Boot中没有XML配置文件（部署描述符）的需求，它使用惯例优于配置的软件设计模式来减少开发人员的工作量。

我们可以使用STS IDE或Spring Initializr来开发Spring Boot Java应用。
### 为什么我们要使用Spring Boot框架
我们基于以下原因使用Spring Boot框架：
- Spring Boot使用依赖注入方式
- 它具备强大的事务管理能力
- 它简化了与其它Java框架如JPA/Hibernate ORM, Struts等的集成
- 它降低了应用的成本和开发时间

与Spring Boot框架一起，众多其它Spring姐妹项目可用于创建项目解决现代商业需求。一些Sprint姐妹项目罗列如下：
- Spring Data： 它简化了关系数据库和NoSQL数据库的数据访问
- Spring Batch：它提供了强大的批处理能力
- Spring Security：它是一个安全框架给你的应用强健的安全支持
- Spring Social：它提供了与社交网络如LinkedIn的集成
- Spring Integration：它是一个企业集成模型的实现。它使用轻量级消息和声明式适配器来帮助与其它企业应用的集成。
### Spring Boot的优势
- 它创建了独立的Spring应用可以使用Java -jar启动
- 借助嵌入式HTTP服务器如Tomcat, Jetty等的帮助，很容易测试Web应用。我们不需要部署WAR文件。
- 它提供自用的'starter'POM来简化Maven 配置
- 它具有产品级的特性例如度量（metrics）, 健康检查和外部配置
- 不依赖XML配置文件
- 它提供了一个CLI工具以帮助开发和测试Spring Boot应用
- 它提供了许多插件
- 它最小化了编写多次模板代码（在其它许多地方包含，不需修改或很小修改的代码），XML配置及注解
- 它提升了生产率，减少了开发时间
### Spring Boot的限制
Spring Boot可能会使用应用中不会用到的一些依赖，这些依赖增加了应用的大小。
### Spring Boot的目标
Spring Boot的主要目标是降低开发，单元测试及集成测试的时间。
- 提供开箱即用的开发方式
- 避免定义更多的注解配置
- 避免写更多的import语句
- 避免XML配置

通过提供或避免以上点，Spring Boot框架减少了开发时间，开发人力，增加了生产率。
### Spring Boot的前提条件
为了创建Spring Boot应用，下面是其前提条件。在这个教程中，我们会使用Spring Tool Suite (STS) IDE。
- Java 1.8
- Maven 3.0+
- Spring Framework 5.0.0.BUILD-SNAPSHOT
- 推荐使用集成开发环境 (Spring Tool Suite)
### Spring Boot的特性
- Web开发
  它是一个非常适合Web应用开发的Spring模块。我们可以很容易地创建一个自包含的HTTP应用，它使用嵌入的服务器如Tomcat, Jetty, 或 Undertow。我们也可使用**spring-boot-starter-web**模块来快速开启并运行应用。
- SpringApplication
  SpringApplication是一个类，它提供了一个便捷的方式来引导Spring应用。它可以从main方法开始，我们可以调用一个静态run()方法来调用应用：
  ```
  public static void main(String[] args)  
  {    
      SpringApplication.run(ClassName.class, args);
  }  
  ```
- 应用事件和监听器
  Spring Boot使用事件来处理各种各样的任务。它允许你创建工厂文件用于添加监听器。我们使用ApplicationListener键来引用它。

  总是在META-INF目录下创建工厂文件，如META-INF/spring.factories。
- 管理特性
  Spring Boot提供设施来为应用开启管理相关特性。它用于远程访问和管理应用。我们可以利用**spring.application.admin.enabled**属性在Spring Boot应用中开启它。
- 外部化配置
  Spring Boot允许我们外部化我们的配置以使同样的应用运行于不同的环境。应用使用YAML文件来外部化配置。
- 属性文件
  Spring Boot提供了丰富的应用属性。因此，我们可以在我们的项目属性文件中利用它们。属性文件用于设置属性比如server-port =8082或许多其它属性。它帮助组织应用属性。
- YAML支持
  它提供了指定层级化配置的便利方式。它是JSON的一个超集。SpringApplication类自动支持YAML。它是属性文件的另一个选择。
- 类型安全配置
  它提供了强类型安全配置以治理和验证应用配置。应用配置总是一项关键任务，它应该是类型安全的。我们也可利用该库的注解。
- 日志
  Spring Boot提供公共日志用于内部日志。日志依赖缺省管理。如果没有定制需求，我们不应更该日志依赖。
- 安全
  Spring Boot应用也是基于spring 的Web应用。因此，它缺省是安全的--在所有HTTP端点上具有基础验证。一个安全的Spring Boot应用由许多端点可用。
### 学习前提
在开始学习Spring Boot之前，你必须拥有Spring框架的基础知识。
### 受众
我们的Spring Boot教程设计用于帮助初学者和专业人员。
### 问题
我们确信你不会发现本Spring Boot教程的问题，但如果由任何错误，请将问题投递到联系人表单中。

## Reference
- [Spring Boot Tutorial](https://www.javatpoint.com/spring-boot-tutorial)