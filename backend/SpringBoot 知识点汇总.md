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
### Redis 介绍
Redis 是目前业界使用最广泛的内存数据存储。相比 Memcached，Redis 支持更丰富的数据结构，例如 hashes, lists, sets 等，同时支持数据持久化。除此之外，Redis 还提供一些类数据库的特性，比如事务，HA，主从库。可以说 Redis 兼具了缓存系统和数据库的一些特性，因此有着丰富的应用场景。本文介绍 Redis 在 Spring Boot 中两个典型的应用场景。
### 如何使用
#### 1、引入依赖包
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>
```
Spring Boot 提供了对 Redis 集成的组件包：`spring-boot-starter-data-redis`，`spring-boot-starter-data-redis` 依赖于 `spring-data-redis` 和 `lettuce` 。Spring Boot 1.0 默认使用的是 Jedis 客户端，2.0 替换成 `Lettuce`，但如果你从 Spring Boot 1.5.X 切换过来，几乎感受不大差异，这是因为 `spring-boot-starter-data-redis` 为我们隔离了其中的差异性。

`Lettuce` 是一个可伸缩线程安全的 Redis 客户端，多个线程可以共享同一个 `RedisConnection`，它利用优秀 `netty NIO` 框架来高效地管理多个连接。
#### 2、添加配置文件
```
# Redis数据库索引（默认为0）
spring.redis.database=0  
# Redis服务器地址
spring.redis.host=localhost
# Redis服务器连接端口
spring.redis.port=6379  
# Redis服务器连接密码（默认为空）
spring.redis.password=
# 连接池最大连接数（使用负值表示没有限制） 默认 8
spring.redis.lettuce.pool.max-active=8
# 连接池最大阻塞等待时间（使用负值表示没有限制） 默认 -1
spring.redis.lettuce.pool.max-wait=-1
# 连接池中的最大空闲连接 默认 8
spring.redis.lettuce.pool.max-idle=8
# 连接池中的最小空闲连接 默认 0
spring.redis.lettuce.pool.min-idle=0
```
#### 3、添加 cache 的配置类
```
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport{
    
    @Bean
    public KeyGenerator keyGenerator() {
        return new KeyGenerator() {
            @Override
            public Object generate(Object target, Method method, Object... params) {
                StringBuilder sb = new StringBuilder();
                sb.append(target.getClass().getName());
                sb.append(method.getName());
                for (Object obj : params) {
                    sb.append(obj.toString());
                }
                return sb.toString();
            }
        };
    }
}
```
注意我们使用了注解：`@EnableCaching` 来开启缓存。

接下来就可以直接使用了：
```
@RunWith(SpringRunner.class)
@SpringBootTest
public class TestRedis {
    @Autowired
    private StringRedisTemplate stringRedisTemplate;
    @Autowired
    private RedisTemplate redisTemplate;

    @Test
    public void test() throws Exception {
        stringRedisTemplate.opsForValue().set("aaa", "111");
        Assert.assertEquals("111", stringRedisTemplate.opsForValue().get("aaa"));
    }
    
    @Test
    public void testObj() throws Exception {
        User user=new User("aa@126.com", "aa", "aa123456", "aa","123");
        ValueOperations<String, User> operations=redisTemplate.opsForValue();
        operations.set("com.neox", user);
        operations.set("com.neo.f", user,1, TimeUnit.SECONDS);
        Thread.sleep(1000);
        //redisTemplate.delete("com.neo.f");
        boolean exists=redisTemplate.hasKey("com.neo.f");
        if(exists){
            System.out.println("exists is true");
        }else{
            System.out.println("exists is false");
        }
       // Assert.assertEquals("aa", operations.get("com.neo.f").getUserName());
    }
}
```
以上都是手动使用的方式，如何在查找数据库的时候自动使用缓存呢，看下面。
#### 4、自动根据方法生成缓存
```
@RestController
public class UserController {

    @RequestMapping("/getUser")
    @Cacheable(value="user-key")
    public User getUser() {
        User user=new User("aa@126.com", "aa", "aa123456", "aa","123");
        System.out.println("若下面没出现“无缓存的时候调用”字样且能打印出数据表示测试成功");
        return user;
    }
}
```
其中 value 的值就是缓存到 Redis 中的 key。
### 共享 Session
分布式系统中，Session 共享有很多的解决方案，其中托管到缓存中应该是最常用的方案之一，
#### Spring Session 官方说明
Spring Session provides an API and implementations for managing a user’s session information.

Spring Session 提供了一套创建和管理 Servlet HttpSession 的方案。Spring Session 提供了集群 Session（Clustered Sessions）功能，默认采用外置的 Redis 来存储 Session 数据，以此来解决 Session 共享的问题。
#### 如何使用
##### 1、引入依赖
```
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
</dependency>
```
##### 2、Session 配置
```
@Configuration
@EnableRedisHttpSession(maxInactiveIntervalInSeconds = 86400*30)
public class SessionConfig {
}
```
> maxInactiveIntervalInSeconds: 设置 Session 失效时间，使用 Redis Session 之后，原 Spring Boot 的 server.session.timeout 属性不再生效。

好了，这样就配置好了，我们来测试一下
##### 3、测试
添加测试方法获取 sessionid
```
@RequestMapping("/uid")
String uid(HttpSession session) {
    UUID uid = (UUID) session.getAttribute("uid");
    if (uid == null) {
        uid = UUID.randomUUID();
    }
    session.setAttribute("uid", uid);
    return session.getId();
}
```
登录 Redis 输入 keys '*sessions*'
```
t<spring:session:sessions:db031986-8ecc-48d6-b471-b137a3ed6bc4
t(spring:session:expirations:1472976480000
```
其中 1472976480000 为失效时间，意思是这个时间后 Session 失效，db031986-8ecc-48d6-b471-b137a3ed6bc4 为 sessionId,登录 http://localhost:8080/uid 发现会一致，就说明 Session 已经在 Redis 里面进行有效的管理了。
#### 如何在两台或者多台中共享 Session
其实就是按照上面的步骤在另一个项目中再次配置一次，启动后自动就进行了 Session 共享。

**[示例代码-github](https://github.com/ityouknow/spring-boot-examples/tree/master/spring-boot-redis)**
### 参考
- [Redis的两个典型应用场景](http://emacoo.cn/blog/spring-redis)
- [SpringBoot应用之分布式会话](https://segmentfault.com/a/1190000004358410)
## 4. Thymeleaf 使用详解
### Thymeleaf 介绍
简单说，Thymeleaf 是一个跟 Velocity、FreeMarker 类似的模板引擎，它可以完全替代 JSP 。相较与其他的模板引擎，它有如下三个极吸引人的特点：
1. Thymeleaf 在有网络和无网络的环境下皆可运行，即它可以让美工在浏览器查看页面的静态效果，也可以让程序员在服务器查看带数据的动态页面效果。这是由于它支持 html 原型，然后在 html 标签里增加额外的属性来达到模板+数据的展示方式。浏览器解释 html 时会忽略未定义的标签属性，所以 Thymeleaf 的模板可以静态地运行；当有数据返回到页面时，Thymeleaf 标签会动态地替换掉静态内容，使页面动态显示。
2. Thymeleaf 开箱即用的特性。它提供标准和 Spring 标准两种方言，可以直接套用模板实现 JSTL、 OGNL表达式效果，避免每天套模板、改 Jstl、改标签的困扰。同时开发人员也可以扩展和创建自定义的方言。
3. Thymeleaf 提供 Spring 标准方言和一个与 SpringMVC 完美集成的可选模块，可以快速的实现表单绑定、属性编辑器、国际化等功能。
### 标准表达式语法
它们分为四类：
- 变量表达式
- 选择或星号表达式
- 文字国际化表达式
- URL 表达式
### 常用th标签都有那些？
### 几种常用的使用方法
### 使用 Thymeleaf 布局

## Reference
- [构建微服务：Spring boot 入门篇](https://www.cnblogs.com/ityouknow/p/5662753.html)
- [Spring Boot 面试，一个问题就干趴下了！](https://www.cnblogs.com/ityouknow/p/11281643.html)