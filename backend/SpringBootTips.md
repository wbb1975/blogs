# Spring Boot Tips
## 将命令行参数参弟给Spring Boot应用
### 传递命令行参数（Passing Command-Line Arguments）
为了在利用Maven运行Spring Boot应用时将命令行参数传递给它，可以使用`-Dspring-boot.run.arguments`.

在下面的代码示例中，我将传递两个命令行参数：firstName 和 lastName。
```
mvn spring-boot:run -Dspring-boot.run.arguments="--firstName=Sergey --lastName=Kargopolov"
或
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.main.banner-mode=off,--customArgument=custom
```
或者
```
./gradlew bootRun -Pargs=--spring.main.banner-mode=off,--customArgument=custom
```
或者
```
mvn package
java -jar target/<FILENAME.JAR HERE> --firstName=Sergey --lastName=Kargopolov
```
### 读取命令行参数（Reading Command-Line Arguments）
你可以像在其它Java应用中一样读取命令行参数。在你的Spring Boot项目中，你可以找到一个Java类含有public static void main(String[] args)方法，在那里用下面的方式读取命令行参数：
```
package com.appsdeveloperblog.examples.commandlinearguments;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CommandLineArgumentsExampleApplication {

 public static void main(String[] args) {
  
    // Reading Command-Line arguments
      for(String arg:args) {
            System.out.println(arg);
      }

  SpringApplication.run(CommandLineArgumentsExampleApplication.class, args);
 }
}
```
### 更新application.properties值
当启动你的Spring Boot应用时，你可以使用命令行参数来更新你的application.properties文件中的值。例如，在你的application.properties文件中，你可能设置你的服务器端口为8080，你可以使用命令行参数来覆盖它为一个不同的端口号。

application.properties文件中的缺省值：
```
server.port=8080
```
应命令行参数覆盖端口号：
```
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081
```
或者
```
mvn package
java -jar target/<FILENAME.JAR HERE> --server.port=8081
```
### 持有命令行参数值
```
@SpringBootApplication
public class DemoApplication implements ApplicationRunner
{

    @Value("${person.name}")
    private String name;

    public static void main( String[] args )
    {
        SpringApplication.run( DemoApplication.class, args );
    }

    @Override
    public void run( ApplicationArguments args ) throws Exception
    {
        System.out.println( "Name: " + name );
    }
}
```
命令行为：
```
mvn spring-boot:run -Dspring-boot.run.arguments=--person.name=Test
```


## Reference
- [Pass Command-Line Arguments to Spring Boot Application](https://www.appsdeveloperblog.com/command-line-arguments-spring-boot/)