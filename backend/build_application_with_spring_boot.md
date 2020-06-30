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
像大多数Spring [入门指南](https://spring.io/guides)，你可以从头开始完成每一步，或跳过对你来讲很熟悉的基础设置步骤，每种方式你都可得到科工作的代码。

为了从头开始，请移步[Spring Initializr入门](https://spring.io/guides/gs/spring-boot/#scratch)。

为了跳过基础步骤，按下面的步骤操作：
+ [下载](https://github.com/spring-guides/gs-spring-boot/archive/master.zip)并解压本指南的代码库，货值使用git克隆：`git clone https://github.com/spring-guides/gs-spring-boot.git`
+ cd 到 gs-spring-boot/initial
+ 进入到[创建一个简单Web应用](https://spring.io/guides/gs/spring-boot/#initial)

当你完成后，你可以检查你的结果并与gs-spring-boot/complete中的代码比对。
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

![Initializr ](images/Initializr.png)

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
- `@ComponentScan`：告诉Spring去`com/example`下查询其它组件，配置和服务，让他找到控制器。

`main()`方法使用Spring Boot’的`SpringApplication.run()`方法来启动一个应用。你注意到没有一行XML吗？也没有`web.xml`。这个Web应用是100%纯Java，你不必应付配置的重担。

注意到`CommandLineRunner`被标记为`@Bean`，这将在启动时运行。它将检索你的应用创建的或Spring Boot自动添加的所有Beans，它将它们排序并打印。
## 运行应用




## Refrence
- [Building an Application with Spring Boot](https://spring.io/guides/gs/spring-boot/)