# 利用Spring Boot构建应用
这篇指南提供了一个样例--[Sprint Boot](https://github.com/spring-projects/spring-boot)将加速你的应用开发。当你读到更多Spring入门指南，你将会看到更多的Spring Boot用例。本指南将给你一个Spring Boot的快速尝试。如果你想创建你自己的基于Spring Boot的项目，访问Spring Initializr](https://start.spring.io/)，填写你的项目细节，选中一些选项，将所有这些以一个zip文件形式下载。
## 你将会构建什么
你将会利用Spring Boot构建一个简单的web应用，并添加一些有用的服务。
## 你需要些什么
- 大约15分钟
- 一个你钟爱的文本编辑器或IDE
- [JDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/index.html) 或更新
- [Gradle 4+](http://www.gradle.org/downloads) or [Maven 3.2+](https://maven.apache.org/download.cgi)
- 你也可以将代码直接导入到IDE中
  + [Spring Tool Suite (STS)](https://spring.io/guides/gs/sts)
  + [IntelliJ IDEA](https://spring.io/guides/gs/intellij-idea/)
## 如何完成这个指南
像大多数Spring [入门指南](https://spring.io/guides)，你可以从头开始完成每一步，或跳过对你来讲很熟悉的基础设置步骤，每种方式你都可得到可工作的代码。

为了从头开始，请移步[Spring Initializr入门](https://spring.io/guides/gs/spring-boot/#scratch)。

为了跳过基础步骤，按下面的步骤操作：
+ [下载](https://github.com/spring-guides/gs-spring-boot/archive/master.zip)并解压本指南的代码库，货值使用git克隆：`git clone https://github.com/spring-guides/gs-spring-boot.git`
+ cd 到 gs-spring-boot/initial
+ 进入到[创建一个简单Web应用](https://spring.io/guides/gs/spring-boot/#initial)

当你完成后，你可以检查你的结果并与`gs-spring-boot/complete`中的代码比对。
## 从Spring Boot操作中学习
Spring Boot提供创建应用的快速通道。它看顾你的classpath和你配置的beans，合理假设你遗漏了某些东西，并添加进去。利用Spring Boot，你可以更加关注业务特性而非基础设施。

下面的例子演示了Spring Boot可以帮你做些什么：
- Spring MVC在classpath上吗？有几个特殊的beans是你必须使用的，Spring Boot自动添加了它们、一个Spring MVC也需要一个servlet容器，因此Spring Boot自动配置了嵌入的Tomcat
- Jetty在classpath上吗？如果在，你可能不期望Tomcat，取而代之你希望嵌入Jetty。Spring Boot可以为你处理这个。
- Thymeleaf在classpath上吗？如果在，那必须有一些Beans被添加到你的应用上下文中。Spring Boot会为你添加它们。

这些仅仅是Spring Boot提供的自动配置的一些例子。同时，Spring Boot并不干涉你的行为方式。例如，如果Thymeleaf 在你的路径上，Spring Boot自动添加一个`SpringTemplateEngine `到你的应用上下文。但如果你利用自己的设置定义了一个自己的`SpringTemplateEngine `，Spring Boot就不会添加它。这使你只需很小的努力就可控制它。
> Spring Boot并不为你的文件生成代码或修改它。相反，当你启动你的应用时，Spring Boot动态装配Beans及其设置，并将它们应用到你的应用上下文。
## Spring Initializr入门
对所有的Spring应用，你应该从[Spring Initializr](https://start.spring.io/)开始。Initializr提供了一个快速向你的应用中添加依赖的方式，并为你做了许多设置。这个例子仅仅需要Spring Web依赖，下面的图形显示了样本项目Initializr 设置。

![Spring Initializr](images/initializr.png)

下面的列表显示了当你选择Maven时产生的`pom.xml`
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>2.2.2.RELEASE</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>com.example</groupId>
	<artifactId>spring-boot</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>spring-boot</name>
	<description>Demo project for Spring Boot</description>

	<properties>
		<java.version>1.8</java.version>
	</properties>

	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
			<exclusions>
				<exclusion>
					<groupId>org.junit.vintage</groupId>
					<artifactId>junit-vintage-engine</artifactId>
				</exclusion>
			</exclusions>
		</dependency>
	</dependencies>

	<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
	</build>

</project>
```

下面的列表显示了当你选择Gradle时产生的`build.gradle`
```
plugins {
	id 'org.springframework.boot' version '2.2.2.RELEASE'
	id 'io.spring.dependency-management' version '1.0.8.RELEASE'
	id 'java'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-web'
	testImplementation('org.springframework.boot:spring-boot-starter-test') {
		exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
	}
}

test {
	useJUnitPlatform()
}
```
## 创建一个简单的Web应用
现在你可以为这个简单的Web应用创建Web controller，像下面的列表显示的（来自`src/main/java/com/example/springboot/HelloController.java`）：
```
package com.example.springboot;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class HelloController {
	@RequestMapping("/")
	public String index() {
		return "Greetings from Spring Boot!";
	}
}
```
这个类被标记为`@RestController`，意味着它已经准备好被Spring MVC用来处理Web请求。`@RequestMapping` 把 `/` 映射到 `index()`。当被从浏览器或命令行curl中调用时，方法返回纯文本。这是因为`@RestController`绑定了`@Controller`和`@ResponseBody`，两个注解导致Web请求返回数据而不是视图。
## 创建一个应用类
Spring Initializr为你创建了一个简单的应用类。但是，在本例中这个类太简单了。你需要修改代码以使得它看起来像下面这样（来源于`src/main/java/com/example/springboot/Application.java`）：
```
package com.example.springboot;

import java.util.Arrays;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

	@Bean
	public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
		return args -> {
			System.out.println("Let's inspect the beans provided by Spring Boot:");

			String[] beanNames = ctx.getBeanDefinitionNames();
			Arrays.sort(beanNames);
			for (String beanName : beanNames) {
				System.out.println(beanName);
			}
		};
	}
}
```
`@SpringBootApplication`是一个方便的注解，它添加了下面所有的内容：
- `@Configuration`：标记类作为应用上下文Beans定义的源
- `@EnableAutoConfiguration`：告诉Spring Boot基于classpath 开始添加Beans，其它beans，以及各种属性设置。例如，如果 `spring-webmvc`在classpath上，这个注解标记该应用为一个Web应用并激活关键行为，比如设置一个`DispatcherServlet`。
- `@ComponentScan`：告诉Spring去`com/example`下查询其它组件，配置和服务，让它找到控制器。

`main()`方法使用Spring Boot的`SpringApplication.run()`方法来启动一个应用。你注意到没有一行XML吗？也没有`web.xml`。这个Web应用是100%纯Java，你不必应付配置的重担。

注意到`CommandLineRunner`被标记为`@Bean`，这将在启动时运行。它将检索你的应用创建的或Spring Boot自动添加的所有Beans，它将它们排序并打印。
## 运行应用
为了运行一个应用，在终端窗口（在complete）目录中运行下面的命令：
```
./gradlew bootRun
```
如果你使用Maven，在终端窗口（在complete）目录中运行下面的命令：
```
./mvnw spring-boot:run
```
你应该看到与下面类似的输出：
```
Let's inspect the beans provided by Spring Boot:
application
beanNameHandlerMapping
defaultServletHandlerMapping
dispatcherServlet
embeddedServletContainerCustomizerBeanPostProcessor
handlerExceptionResolver
helloController
httpRequestHandlerAdapter
messageSource
mvcContentNegotiationManager
mvcConversionService
mvcValidator
org.springframework.boot.autoconfigure.MessageSourceAutoConfiguration
org.springframework.boot.autoconfigure.PropertyPlaceholderAutoConfiguration
org.springframework.boot.autoconfigure.web.EmbeddedServletContainerAutoConfiguration
org.springframework.boot.autoconfigure.web.EmbeddedServletContainerAutoConfiguration$DispatcherServletConfiguration
org.springframework.boot.autoconfigure.web.EmbeddedServletContainerAutoConfiguration$EmbeddedTomcat
org.springframework.boot.autoconfigure.web.ServerPropertiesAutoConfiguration
org.springframework.boot.context.embedded.properties.ServerProperties
org.springframework.context.annotation.ConfigurationClassPostProcessor.enhancedConfigurationProcessor
org.springframework.context.annotation.ConfigurationClassPostProcessor.importAwareProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.web.servlet.config.annotation.DelegatingWebMvcConfiguration
propertySourcesBinder
propertySourcesPlaceholderConfigurer
requestMappingHandlerAdapter
requestMappingHandlerMapping
resourceHandlerMapping
simpleControllerHandlerAdapter
tomcatEmbeddedServletContainerFactory
viewControllerHandlerMapping
```
你可以很清晰地看到`org.springframework.boot.autoconfigure` Beans。还有一个`tomcatEmbeddedServletContainerFactory`。现在用curl运行这个服务（在一个独立的终端窗口），运行下面的命令：
```
$ curl localhost:8080
Greetings from Spring Boot!
```
## 添加单元测试
你可能想给你新加的端点添加单元测试，Spring Test为此提供了一些机制：

如果你在使用Gradle，请把下面内容添加到你的`build.gradle`文件：
```
testImplementation('org.springframework.boot:spring-boot-starter-test') {
	exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
}
```
如果你使用Maven，请把下面内容添加到你的`pom.xml`文件：
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
	<exclusions>
		<exclusion>
			<groupId>org.junit.vintage</groupId>
			<artifactId>junit-vintage-engine</artifactId>
		</exclusion>
	</exclusions>
</dependency>
```
现在血一个简单的单元测试来模拟通过你的端点的servlet请求和回复，如下列表所示（来自`src/test/java/com/example/springboot/HelloControllerTest.java`）：
```
package com.example.springboot;

import static org.hamcrest.Matchers.equalTo;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

@SpringBootTest
@AutoConfigureMockMvc
public class HelloControllerTest {

	@Autowired
	private MockMvc mvc;

	@Test
	public void getHello() throws Exception {
		mvc.perform(MockMvcRequestBuilders.get("/").accept(MediaType.APPLICATION_JSON))
				.andExpect(status().isOk())
				.andExpect(content().string(equalTo("Greetings from Spring Boot!")));
	}
}
```
`MockMvc`来自于Spring Test，通过一系列方便的构建类，它让你发送HTTP请求到`DispatcherServlet`，并对结果做出断言。注意使用`@AutoConfigureMockMvc` 和 `@SpringBootTest`来注入`MockMvc`一个实例。使用`@SpringBootTest`，我们要求创建完整的应用上下文。另一个选项是请求Spring Boot仅仅通过`@WebMvcTest`创建上下文的Web层。在每一种示例中，Spring Boot主动尝试为你的应用定位主应用类，但你可覆盖这个行为或降低选择面。

像模拟HTTP 循环一样，你也可以使用Spring Boot来写一个简单的全栈集成测试。例如，替代模拟很早出现的测试，我们可以创建下面的测试（来自于`src/test/java/com/example/springboot/HelloControllerIT.java`）：
```
package com.example.springboot;

import static org.assertj.core.api.Assertions.*;

import java.net.URL;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HelloControllerIT {

	@LocalServerPort
	private int port;

	private URL base;

	@Autowired
	private TestRestTemplate template;

    @BeforeEach
    public void setUp() throws Exception {
        this.base = new URL("http://localhost:" + port + "/");
    }

    @Test
    public void getHello() throws Exception {
        ResponseEntity<String> response = template.getForEntity(base.toString(),
                String.class);
        assertThat(response.getBody()).isEqualTo("Greetings from Spring Boot!");
    }
}
```
由于`webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT`，嵌入式服务器在一个随机端口上启动，实际端口可用`@LocalServerPort`在运行时发现。
## 增加产品级服务
如果你在为你的生意添加Web Service，你可能需要添加一些管理服务。Spring Boot随[actuator模块](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/#production-ready)提供了几种此类服务（比如健康，审计，beans等）：
- 如果你在使用Gradle，请将以下依赖添加到你的`build.gradle`文件中
  ```
  implementation 'org.springframework.boot:spring-boot-starter-actuator'
  ```
- 如果你在使用Maven，请将以下依赖添加到你的`pom.xml`文件中
  ```
  <dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-actuator</artifactId>
  </dependency>
  ```

  然后重新启动应用。

- 如果你在使用Gradle，请在终端窗口上输入以下命令（在`complete` 目录中）：
  ```
  ./gradlew bootRun
  ```
- 如果你在使用Maven，请在终端窗口上输入以下命令（在`complete` 目录中）：
  ```
  ./mvnw spring-boot:run
  ```

你应该看到一些新的RESTful 端点被加到你的应用中。这些是Spring Boot提供的管理服务。下面列出了典型输出：
```
management.endpoint.configprops-org.springframework.boot.actuate.autoconfigure.context.properties.ConfigurationPropertiesReportEndpointProperties
management.endpoint.env-org.springframework.boot.actuate.autoconfigure.env.EnvironmentEndpointProperties
management.endpoint.health-org.springframework.boot.actuate.autoconfigure.health.HealthEndpointProperties
management.endpoint.logfile-org.springframework.boot.actuate.autoconfigure.logging.LogFileWebEndpointProperties
management.endpoints.jmx-org.springframework.boot.actuate.autoconfigure.endpoint.jmx.JmxEndpointProperties
management.endpoints.web-org.springframework.boot.actuate.autoconfigure.endpoint.web.WebEndpointProperties
management.endpoints.web.cors-org.springframework.boot.actuate.autoconfigure.endpoint.web.CorsEndpointProperties
management.health.status-org.springframework.boot.actuate.autoconfigure.health.HealthIndicatorProperties
management.info-org.springframework.boot.actuate.autoconfigure.info.InfoContributorProperties
management.metrics-org.springframework.boot.actuate.autoconfigure.metrics.MetricsProperties
management.metrics.export.simple-org.springframework.boot.actuate.autoconfigure.metrics.export.simple.SimpleProperties
management.server-org.springframework.boot.actuate.autoconfigure.web.server.ManagementServerProperties
management.trace.http-org.springframework.boot.actuate.autoconfigure.trace.http.HttpTraceProperties
```
actuator暴露了以下功能：
- 错误
- [actuator/health](http://localhost:8080/actuator/health)
- [actuator/info](http://localhost:8080/actuator/info)
- [actuator](http://localhost:8080/actuator)

> 实际上还有一个`/actuator/shutdown`端点，但是缺省地它只通过JMX可见。为了把它作为一个[HTTP端点开放](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/#production-ready-endpoints-enabling-endpoints)，把 `management.endpoints.web.exposure.include=health,info,shutdown` 添加到你的 `application.properties`文件。但是，你不应该在一个公开可用的应用上开启`shutdown`端点。

你可以利用下面的命令行来检测应用健康状态：
```
$ curl localhost:8080/actuator/health
{"status":"UP"}
```

你也可以利用curl来调用shutdown，先看看如果你没添加必要的行（如上例）到`application.properties`文件会发生什么：
```
$ curl -X POST localhost:8080/actuator/shutdown
{"timestamp":1401820343710,"error":"Method Not Allowed","status":405,"message":"Request method 'POST' not supported"}
```

关于这些REST端点的更详细信息，以及你如何在`application.properties`文件(在 src/main/resources)中调整这些设置，请参阅[关于端点的文档](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/#production-ready-endpoints)。
## 查看Spring Boot的Starters
你已经看到了一些[Spring Boot的Starters](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/#using-boot-starter), 你可以看到它们全部[代码形式](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-project/spring-boot-starters)
## JAR支持和Groovy支持
最后一个例子展示Spring Boot 如何让你撰写你没有意识到必须的Beans。它也展示了如何开启便利的管理服务。

但是，Spring Boot做得更多。它不仅支持传统的WAR文件部署，也可以让你打包成可执行JARs，感谢Spring Boot的加载模块。各种各样的指南演示了如何通过`spring-boot-gradle-plugin`和 `spring-boot-maven-plugin`来提供双重支持。

在此之上，Spring Boot还提供了Groovy 支持，让你可以以少至仅仅一个文件即可构建Spring MVC web应用。

创建一个文件`app.groovy`，并添加以下代码：
```
@RestController
class ThisWillActuallyRun {

    @RequestMapping("/")
    String home() {
        return "Hello, World!"
    }

}
```

接下来，安装[Spring Boot’s CLI](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/#getting-started-installing-the-cli)。

运行下面的命令行以启动Groovy应用：
```
$ spring run app.groovy
```
> 停止前面的应用以防止端口冲突。

从一个不同的终端窗口，运行下面的命令行（其输出也被打印）：
```
$ curl localhost:8080
Hello, World!
```
Spring Boot通过往你的代码中动态添加关键注解来实现此功能，它会利用[Groovy Grape](http://groovy.codehaus.org/Grape下载相关库來使得应用运行起来)。
## 总结
祝贺你！你利用Spring Boot创建了一个简单的Web应用，以及如何加快你的开发节奏。你也开启了一些称手的产品级服务。这只是Spring Boot 功能的一个极小部份展示。参看[Spring Boot在线文档](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle)以获取更多信息。

## Refrence
- [Building an Application with Spring Boot](https://spring.io/guides/gs/spring-boot/)
- [Securing a Web Application](https://spring.io/guides/gs/securing-web/)
- [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)