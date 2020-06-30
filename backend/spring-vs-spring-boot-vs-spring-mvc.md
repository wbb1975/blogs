# Spring vs. Spring Boot vs. Spring MVC
## Spring vs. Spring Boot
**Spring**：Spring框架是最流行的Java应用开发框架，Spring框架最主要的特性是依赖注入和控制反转。借助Spring框架的帮助，我们可以开发松耦合的应用。如果应用类型或特征已经很存粹地定义了， 那最好使用它。
**Spring Boot**：Spring Boot是Spring的一个模块。它允许我们构建最小配置甚至零配置的应用。如果我们想开发一个简单地基于Spring的应用或RESTful服务，那我们最好使用它。

Spring 和 Spring Boot的主要对比如下：
Spring|Spring Boot
--------|--------
Spring框架是构建应用广泛使用的Java EE框架|Spring Boot框架广泛用于开发REST APIs
简化Java EE开发，增进开发者生产率|旨在缩减代码规模，提供最简单的方式开发Web应用
Spring框架的主要特征是依赖注入|Spring Boot的主要特性是自动配置。它根据需求自动配置类。
允许我们开发松耦合应用，从而使得事情变得简单|它帮助创建带最小配置的独立应用
开发人员写了很多代码（模板代码）来完成极少的工作|它减少了模板代码
为了测试Spring项目，我们需要显式建立服务器|Spring Boot提供了嵌入式服务器如Tomcat，Jetty等
它不支持内存数据库|它提供了几个插件才与嵌入式内存数据库如H2互操作
开发人员为Spring项目在pom.xml中手动定义依赖|Spring Boot在pom.xml中提供了starter的概念，它内部将基于Spring Boot需求照顾下载依赖Jars
## Spring Boot vs. Spring MVC
**Spring Boot**：Spring Boot使得引导和开发一个基于Spring的应用容易，它提供了许多模板代码。它隐藏了许多复杂性，使得开发者可以很容易地起步开发基于Spring的应用。

**Spring MVC**：Spring MVC是一个构建Web应用的Web MVC框架，它为各种功能提供了许多配置文件。它是一个面向HTTP 的Web应用开发框架。

Spring Boot和Spring MVC为不同的目的而存在，它们之间的主要对比如下：

Spring Boot|Spring MVC
--------|--------
Spring Boot是一个Spring模块，它打包Spring应用并提供了许多有意义的缺省配置|Spring MVC是一个在Spring 框架下的基于模型-视图-控制器的Web框架
它提供了Spring框架应用的缺省配置|它提供了狗狗间Web应用的许多开箱机用特性
没必要手动构建配置项|需要手动构建配置项
部署描述符不是必须的|部署描述符是必须的
它避免了模板代码，将依赖整体打包在一个单元里|需要单独指定没一个依赖
它降低了开发时间，增进了生产率|它需要花费更多时间来达到同样的目标

# Spring Boot架构
Spring Boot是一个Spring模块，它用于以最小工作量创建独立的生产级别Spring应用。它是在核心Spring框架之上开发的。

Spring Boot 遵从一个分层架构，每一层与其直接上部或下部通信。

在理解Spring Boot架构之前，我们必须知道不同的层及其所属类。Spring Boot总共有四层，如下所示：
- 表现层（Presentation Layer）：表现层出路HTTP 请求，将JSON 参数转化为对象，认证请求并将其传送给逻辑层。简单来说，它包括视图，例如前端部分。
- 逻辑层（Business Layer）：逻辑层处理各种商业逻辑。它包含服务类并使用由数据访问层提供的服务。它也执行授权和验证。
- 持久层（Persistence Layer）：持久层包含所有的存储逻辑，在逻辑对象和数据库行之间互相转换
- 数据库层（Database Layer）：在数据库层，CRUD（新建，查询，更新，删除）操作将被实际执行。

![Spring Boot架构](images/spring-boot-architecture.png)
## Spring Boot流架构
![Spring Boot流架构](images/spring-boot-architecture2.png)
- 现在我们拥有了验证类，是视图和工具类
- Spring Boot使用所有的Spring模块--比如Spring MVC, Spring Data等。Spring Boot的架构与Spring MVC相同，除了在Spring Boot中没有DAO和DAOImpl。
- 创建一个数据访问层执行CRUD操作
- 客户端发起HTTP请求（PUT 或 GET）
- 请求到达控制器，控制器映射请求并处理它。之后，看情况调用逻辑层
- 在服务层，所有商业逻辑被执行。它在被映射到JPA 的模型类的数据上执行操作
- 如果没有错误发生，一个JSP页面被返回给用户。

## Reference
- [Spring vs. Spring Boot vs. Spring MVC](https://www.javatpoint.com/spring-vs-spring-boot-vs-spring-mvc)