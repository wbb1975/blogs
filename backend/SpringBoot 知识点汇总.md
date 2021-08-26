# SpringBoot 知识
## 1. 入门篇
### spingboot建议的目录结果结构如下：
root package结构：com.example.myproject
```
+- com
   +- example
     +- myproject
       +- Application.java
       |
       +- domain
       |  +- Customer.java
       |  +- CustomerRepository.java
       |
       +- service
       |  +- CustomerService.java
       |
       +- controller
       |  +- CustomerController.java
       |
```
1. Application.java 建议放到跟目录下面,主要用于做一些框架配置
2. domain目录主要用于实体（Entity）与数据访问层（Repository）
3. service 层主要是业务类代码
4. controller 负责页面访问控制
### 引入 Web 模块
```
@RestController
public class HelloWorldController {
    @RequestMapping("/hello")
    public String index() {
        return "Hello World";
    }
}
```
@RestController的意思就是controller里面的方法都以json格式输出。

启动主程序，打开浏览器访问http://localhost:8080/hello，就可以看到效果了。
## 2. Web 综合开发
Spring Boot Web 开发非常的简单，其中包括常用的 json 输出、filters、property、log 等
### json 接口开发
只需要类添加 @RestController 即可，默认类中的方法都会以 json 的格式返回。
```
@RestController
public class HelloController {
    @RequestMapping("/getUser")
    public User getUser() {
    	User user=new User();
    	user.setUserName("小明");
    	user.setPassWord("xxxx");
        return user;
    }
}
```
如果需要使用页面开发只要使用@Controller注解即可，下面会结合模板来说明。
### 自定义 Filter
我们常常在项目中会使用 filters 用于录调用日志、排除有 XSS 威胁的字符、执行权限验证等等。Spring Boot 自动添加了 OrderedCharacterEncodingFilter 和 HiddenHttpMethodFilter，并且我们可以自定义 doFilter。

两个步骤：
1. 实现 Filter 接口，实现 Filter 方法
2. 添加@Configuration 注解，将自定义Filter加入过滤链
```
@Configuration
public class WebConfiguration {
    @Bean
    public RemoteIpFilter remoteIpFilter() {
        return new RemoteIpFilter();
    }
    
    @Bean
    public FilterRegistrationBean testFilterRegistration() {

        FilterRegistrationBean registration = new FilterRegistrationBean();
        registration.setFilter(new MyFilter());
        registration.addUrlPatterns("/*");
        registration.addInitParameter("paramName", "paramValue");
        registration.setName("MyFilter");
        registration.setOrder(1);
        return registration;
    }
    
    public class MyFilter implements Filter {
		@Override
		public void destroy() {
			// TODO Auto-generated method stub
		}

		@Override
		public void doFilter(ServletRequest srequest, ServletResponse sresponse, FilterChain filterChain)
				throws IOException, ServletException {
			// TODO Auto-generated method stub
			HttpServletRequest request = (HttpServletRequest) srequest;
			System.out.println("this is MyFilter,url :"+request.getRequestURI());
			filterChain.doFilter(srequest, sresponse);
		}

		@Override
		public void init(FilterConfig arg0) throws ServletException {
			// TODO Auto-generated method stub
		}
    }
}
```
### 自定义 Property
在 Web 开发的过程中，我经常需要自定义一些配置文件，如何使用呢？答案是配置在 **application.properties** 中：
```
com.neo.title=纯洁的微笑
com.neo.description=分享生活和技术
```
自定义配置类：
```
@Component
public class NeoProperties {
	@Value("${com.neo.title}")
	private String title;
	@Value("${com.neo.description}")
	private String description;

	//省略getter settet方法
}
```
### log配置
配置输出的地址和输出级别：
```
logging.path=/user/local/log
logging.level.com.favorites=DEBUG
logging.level.org.springframework.web=INFO
logging.level.org.hibernate=ERROR
```
`path` 为本机的 log 地址，`logging.level` 后面可以根据包路径配置不同资源的 log 级别。
### 数据库操作
在这里我重点讲述 Mysql、spring data jpa 的使用，其中 Mysql 就不用说了大家很熟悉。Jpa 是利用 Hibernate 生成各种自动化的 sql，如果只是简单的增删改查，基本上不用手写了，Spring 内部已经帮大家封装实现了。
#### 1、添加相关 jar 包
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
 <dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
</dependency>
```
#### 2、添加配置文件
```
spring.datasource.url=jdbc:mysql://localhost:3306/test
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.driver-class-name=com.mysql.jdbc.Driver

spring.jpa.properties.hibernate.hbm2ddl.auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect
spring.jpa.show-sql= true
```
其实这个 hibernate.hbm2ddl.auto 参数的作用主要用于：自动创建，更新，验证数据库表结构,有四个值：
- create： 每次加载 hibernate 时都会删除上一次的生成的表，然后根据你的 model 类再重新来生成新表，哪怕两次没有任何改变也要这样执行，这就是导致数据库表数据丢失的一个重要原因。
- create-drop ：每次加载 hibernate 时根据 model 类生成表，但是 sessionFactory 一关闭,表就自动删除。
- update：最常用的属性，第一次加载 hibernate 时根据 model 类会自动建立起表的结构（前提是先建立好数据库），以后加载 hibernate 时根据 model 类自动更新表结构，即使表结构改变了但表中的行仍然存在不会删除以前的行。要注意的是当部署到服务器后，表结构是不会被马上建立起来的，是要等 应用第一次运行起来后才会。
- validate ：每次加载 hibernate 时，验证创建数据库表结构，只会和数据库中的表进行比较，不会创建新表，但是会插入新值。

`dialect` 主要是指定生成表名的存储引擎为 `InnoDBD`。

`show-sql` 是否打印出自动生成的 `SQL`，方便调试的时候查看。
#### 3、添加实体类和 Dao
```
@Entity
public class User implements Serializable {
	private static final long serialVersionUID = 1L;
	@Id
	@GeneratedValue
	private Long id;
	@Column(nullable = false, unique = true)
	private String userName;
	@Column(nullable = false)
	private String passWord;
	@Column(nullable = false, unique = true)
	private String email;
	@Column(nullable = true, unique = true)
	private String nickName;
	@Column(nullable = false)
	private String regTime;

	//省略getter settet方法、构造方法
}
```
dao 只要继承 `JpaRepository` 类就可以，几乎可以不用写方法，还有一个特别有尿性的功能非常赞，就是可以根据方法名来自动的生成 SQL，比如 `findByUserName` 会自动生成一个以 `userName` 为参数的查询方法，比如 `findAlll` 自动会查询表里面的所有数据，比如自动分页等等。

**Entity 中不映射成列的字段得加 @Transient 注解，不加注解也会映射成列**
```
public interface UserRepository extends JpaRepository<User, Long> {
    User findByUserName(String userName);
    User findByUserNameOrEmail(String username, String email);
}
```
#### 4、测试
```
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(Application.class)
public class UserRepositoryTests {
	@Autowired
	private UserRepository userRepository;

	@Test
	public void test() throws Exception {
		Date date = new Date();
		DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG);        
		String formattedDate = dateFormat.format(date);
		
		userRepository.save(new User("aa1", "aa@126.com", "aa", "aa123456",formattedDate));
		userRepository.save(new User("bb2", "bb@126.com", "bb", "bb123456",formattedDate));
		userRepository.save(new User("cc3", "cc@126.com", "cc", "cc123456",formattedDate));

		Assert.assertEquals(9, userRepository.findAll().size());
		Assert.assertEquals("bb", userRepository.findByUserNameOrEmail("bb", "cc@126.com").getNickName());
		userRepository.delete(userRepository.findByUserName("aa1"));
	}
}
```
当然 Spring Data Jpa 还有很多功能，比如封装好的分页，可以自己定义 SQL，主从分离等等，这里就不详细讲了。
### Thymeleaf 模板
Spring Boot 推荐使用 Thymeleaf 来代替 Jsp，Thymeleaf 模板到底是什么来头呢，让 Spring 大哥来推荐，下面我们来聊聊
#### 1. Thymeleaf 介绍
Thymeleaf 是一款用于渲染 XML/XHTML/HTML5 内容的模板引擎。类似 JSP，Velocity，FreeMaker 等，它也可以轻易的与 Spring MVC 等 Web 框架进行集成作为 Web 应用的模板引擎。与其它模板引擎相比，Thymeleaf 最大的特点是能够直接在浏览器中打开并正确显示模板页面，而不需要启动整个 Web 应用。

好了，你们说了我们已经习惯使用了什么 Velocity, FreMaker，beetle之类的模版，那么到底好在哪里呢？

比一比吧：
Thymeleaf 是与众不同的，因为它使用了自然的模板技术。这意味着 Thymeleaf 的模板语法并不会破坏文档的结构，模板依旧是有效的XML文档。模板还可以用作工作原型，Thymeleaf 会在运行期替换掉静态值。Velocity 与 FreeMarke r则是连续的文本处理器。 下面的代码示例分别使用 Velocity、FreeMarker 与 Thymeleaf 打印出一条消息：
```
Velocity: <p>$message</p>
FreeMarker: <p>${message}</p>
Thymeleaf: <p th:text="${message}">Hello World!</p>
```
**注意，由于 Thymeleaf 使用了 XML DOM 解析器，因此它并不适合于处理大规模的 XML 文件。**
#### 2. URL
URL 在 Web 应用模板中占据着十分重要的地位，需要特别注意的是 Thymeleaf 对于 URL 的处理是通过语法 @{...} 来处理的。Thymeleaf 支持绝对路径 URL：
```
<a th:href="@{http://www.thymeleaf.org}">Thymeleaf</a>
```
#### 3. 条件求值
```
<a th:href="@{/login}" th:unless=${session.user != null}>Login</a>
```
#### 4. for循环
```
<tr th:each="prod : ${prods}">
      <td th:text="${prod.name}">Onions</td>
      <td th:text="${prod.price}">2.41</td>
      <td th:text="${prod.inStock}? #{true} : #{false}">yes</td>
</tr>
```
#### 5. 页面即原型
在 Web 开发过程中一个绕不开的话题就是前端工程师与后端工程师的协作，在传统 Java Web 开发过程中，前端工程师和后端工程师一样，也需要安装一套完整的开发环境，然后各类 Java IDE 中修改模板、静态资源文件，启动/重启/重新加载应用服务器，刷新页面查看最终效果。

但实际上前端工程师的职责更多应该关注于页面本身而非后端，使用 JSP，Velocity 等传统的 Java 模板引擎很难做到这一点，因为它们必须在应用服务器中渲染完成后才能在浏览器中看到结果，而 Thymeleaf 从根本上颠覆了这一过程，通过属性进行模板渲染不会引入任何新的浏览器不能识别的标签，例如 JSP 中的 ，不会在 Tag 内部写表达式。整个页面直接作为 HTML 文件用浏览器打开，几乎就可以看到最终的效果，这大大解放了前端工程师的生产力，它们的最终交付物就是纯的 HTML/CSS/JavaScript 文件。
### Gradle 构建工具
Spring 项目建议使用 Maven/Gradle 进行构建项目，相比 Maven 来讲 Gradle 更简洁，而且 Gradle 更适合大型复杂项目的构建。Gradle 吸收了 Maven 和 Ant 的特点而来，不过目前 Maven 仍然是 Java 界的主流，大家可以先了解了解。
### WebJars
WebJars 是一个很神奇的东西，可以让大家以 Jar 包的形式来使用前端的各种框架、组件。
#### 1. 什么是 WebJars
WebJars 是将客户端（浏览器）资源（JavaScript，Css等）打成 Jar 包文件，以对资源进行统一依赖管理。WebJars 的 Jar 包部署在 Maven 中央仓库上。
#### 2. 为什么使用
我们在开发 Java web 项目的时候会使用像 Maven，Gradle 等构建工具以实现对 Jar 包版本依赖管理，以及项目的自动化管理，但是对于 JavaScript，Css 等前端资源包，我们只能采用拷贝到 webapp 下的方式，这样做就无法对这些资源进行依赖管理。那么 WebJars 就提供给我们这些前端资源的 Jar 包形势，我们就可以进行依赖管理。
#### 3. 如何使用
1. [WebJars主官网](http://www.webjars.org/bower) 查找对于的组件，比如 `Vuejs`
```
<dependency>
    <groupId>org.webjars</groupId>
    <artifactId>vue</artifactId>
    <version>2.5.16</version>
</dependency>
```
2. 页面引入
```
<link th:href="@{/webjars/bootstrap/3.3.6/dist/css/bootstrap.css}" rel="stylesheet"></link>
```
就可以正常使用了！
## 3. Spring Boot 中 Redis 的使用
## 4. 

## Reference
- [构建微服务：Spring boot 入门篇](https://www.cnblogs.com/ityouknow/p/5662753.html)
- [Spring Boot 面试，一个问题就干趴下了！](https://www.cnblogs.com/ityouknow/p/11281643.html)