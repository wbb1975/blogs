## Spring Boot - Profile不同环境配置
###  Profile是什么
Profile我也找不出合适的中文来定义，简单来说，Profile就是Spring Boot可以对不同环境或者指令来读取不同的配置文件。
### Profile使用
假如有开发、测试、生产三个不同的环境，需要定义三个不同环境下的配置。
#### 基于properties文件类型
你可以另外建立3个环境下的配置文件：
+ applcation.properties
+ application-dev.properties
+ application-test.properties
+ application-prod.properties

然后在 `applcation.properties` 文件中指定当前的环境 `spring.profiles.active=test`，这时候读取的就是 `application-test.properties` 文件。
#### 基于yml文件类型
只需要一个applcation.yml文件就能搞定，推荐此方式：
```
spring:
  profiles: 
    active: prod
---
spring: 
  profiles: dev
server: 
  port: 8080
---
spring: 
  profiles: test  
server: 
  port: 8081
---
spring.profiles: prod
spring.profiles.include:
  - proddb
  - prodmq
server: 
  port: 8082
---
spring:
  profiles: proddb
db:
  name: mysql   
---
spring: 
  profiles: prodmq
mq:
  address: localhost
```
此时读取的就是 `prod` 的配置，`prod` 包含 `proddb`，`prodmq`，此时可以读取 `proddb`，`prodmq`下的配置。

也可以同时激活三个配置：
```
spring.profiles.active: prod,proddb,prodmq
```
### 基于Java代码
在 Java 配置代码中也可以加不同 `Profile` 下定义不同的配置文件，`@Profile` 注解只能组合使用 `@Configuration` 和 `@Component` 注解：
```
@Configuration
@Profile("prod")
public class ProductionConfiguration
{
    // ...
}
```
### 指定Profile
- main方法启动方式：
  ```
  // 在Eclipse Arguments里面添加
  --spring.profiles.active=prod
  ```
- 插件启动方式：
  ```
  spring-boot:run -Drun.profiles=prod
  ```
- jar运行方式：
  ```
  java -jar xx.jar --spring.profiles.active=prod
  ```
除了在配置文件和命令行中指定 `Profile`，还可以在启动类中写死指定，通过 `SpringApplication.setAdditionalProfiles` 方法：SpringApplication.class
```
public void setAdditionalProfiles(String... profiles) {
    this.additionalProfiles = new LinkedHashSet<String>(Arrays.asList(profiles));
}
```

## Reference
- [Spring Boot - Profile不同环境配置](https://mp.weixin.qq.com/s/K0kdQwoo2t5FDsTUJttSAA)