# SpringBoot 知识
## 第1章. 入门篇
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
## 第2章. Web 综合开发
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
## 第3章. Spring Boot 中 Redis 的使用
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
## 第4章. Thymeleaf 使用详解
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
## 第5章. Spring Boot Jpa 的使用
### 5.1 Spring Boot Jpa 介绍
#### 首先了解 Jpa 是什么？
Jpa (Java Persistence API) 是 Sun 官方提出的 Java 持久化规范。它为 Java 开发人员提供了一种对象/关联映射工具来管理 Java 应用中的关系数据。它的出现主要是为了简化现有的持久化开发工作和整合 ORM 技术，结束现在 Hibernate，TopLink，JDO 等 ORM 框架各自为营的局面。

值得注意的是，Jpa是在充分吸收了现有 Hibernate，TopLink，JDO 等 ORM 框架的基础上发展而来的，具有易于使用，伸缩性强等优点。从目前的开发社区的反应上看，Jpa 受到了极大的支持和赞扬，其中就包括了 Spring 与 EJB3. 0的开发团队。
> 注意:Jpa 是一套规范，不是一套产品，那么像 Hibernate,TopLink,JDO 他们是一套产品，如果说这些产品实现了这个 Jpa 规范，那么我们就可以叫他们为 Jpa 的实现产品。
#### Spring Boot Jpa
Spring Boot Jpa 是 Spring 基于 ORM 框架、Jpa 规范的基础上封装的一套 Jpa 应用框架，可使开发者用极简的代码即可实现对数据的访问和操作。它提供了包括增删改查等在内的常用功能，且易于扩展！学习并使用 Spring Data Jpa 可以极大提高开发效率！
> Spring Boot Jpa 让我们解脱了 DAO 层的操作，基本上所有 CRUD 都可以依赖于它来实现
### 5.2 基本查询
基本查询也分为两种，一种是 Spring Data 默认已经实现，一种是根据查询的方法来自动解析成 SQL。
#### 预先生成方法
Spring Boot Jpa 默认预先生成了一些基本的CURD的方法，例如：增、删、改等等。
1. 继承 JpaRepository
   ```
   public interface UserRepository extends JpaRepository<User, Long> {
   }
   ```
2. 使用默认方法
   ```
   @Test
    public void testBaseQuery() throws Exception {
        User user=new User();
        userRepository.findAll();
        userRepository.findOne(1l);
        userRepository.save(user);
        userRepository.delete(user);
        userRepository.count();
        userRepository.exists(1l);
        // ...
    }
   ```
#### 自定义简单查询
自定义的简单查询就是根据方法名来自动生成 SQL，主要的语法是findXXBy,readAXXBy,queryXXBy,countXXBy, getXXBy后面跟属性名称：
```
User findByUserName(String userName);
```
也使用一些加一些关键字And 、 Or：
```
User findByUserNameOrEmail(String username, String email);
```
修改、删除、统计也是类似语法：
```
Long deleteById(Long id);
Long countByUserName(String userName)
```
基本上 SQL 体系中的关键词都可以使用，例如： LIKE 、 IgnoreCase、 OrderBy：
```
List<User> findByEmailLike(String email);
User findByUserNameIgnoreCase(String userName);
List<User> findByUserNameOrderByEmailDesc(String email);
```
具体的关键字，使用方法和生产成SQL如下表所示：
Keyword|Sample|JPQL snippet
--------|--------|--------
And|findByLastnameAndFirstname|… where x.lastname = ?1 and x.firstname = ?2
Or|findByLastnameOrFirstname|… where x.lastname = ?1 or x.firstname = ?2
Is,Equals|findByFirstnameIs,findByFirstnameEquals|… where x.firstname = ?1
Between|findByStartDateBetween|… where x.startDate between ?1 and ?2
LessThan|findByAgeLessThan|… where x.age < ?1
LessThanEqual|findByAgeLessThanEqual|… where x.age ⇐ ?1
GreaterThan|findByAgeGreaterThan|… where x.age > ?1
GreaterThanEqual|findByAgeGreaterThanEqual|… where x.age >= ?1
After|findByStartDateAfter|… where x.startDate > ?1
Before|findByStartDateBefore|… where x.startDate < ?1
IsNull|findByAgeIsNull|… where x.age is null
IsNotNull,NotNull|findByAge(Is)NotNull|… where x.age not null
Like|findByFirstnameLike|… where x.firstname like ?1
NotLike|findByFirstnameNotLike|… where x.firstname not like ?1
StartingWith|findByFirstnameStartingWith|… where x.firstname like ?1 (parameter bound with appended %)
EndingWith|findByFirstnameEndingWith|… where x.firstname like ?1 (parameter bound with prepended %)
Containing|findByFirstnameContaining|… where x.firstname like ?1 (parameter bound wrapped in %)
OrderBy|findByAgeOrderByLastnameDesc|… where x.age = ?1 order by x.lastname desc
Not|findByLastnameNot|… where x.lastname <> ?1
In|findByAgeIn(Collection ages)|… where x.age in ?1
NotIn|findByAgeNotIn(Collection age)|… where x.age not in ?1
TRUE|findByActiveTrue()|… where x.active = true
FALSE|findByActiveFalse()|… where x.active = false
IgnoreCase|findByFirstnameIgnoreCase|… where UPPER(x.firstame) = UPPER(?1)
### 5.3 复杂查询
在实际的开发中我们需要用到分页、删选、连表等查询的时候就需要特殊的方法或者自定义 SQL。
#### 分页查询
分页查询在实际使用中非常普遍了，`Spring Boot Jpa` 已经帮我们实现了分页的功能，在查询的方法中，需要传入参数 `Pageable` ,当查询中有多个参数的时候 `Pageable` 建议做为最后一个参数传入。
```
Page<User> findALL(Pageable pageable);
Page<User> findByUserName(String userName,Pageable pageable);
```
`Pageable` 是 Spring 封装的分页实现类，使用的时候需要传入页数、每页条数和排序规则：
```
@Test
public void testPageQuery() throws Exception {
	int page=1,size=10;
	Sort sort = new Sort(Direction.DESC, "id");
    Pageable pageable = new PageRequest(page, size, sort);
    userRepository.findALL(pageable);
    userRepository.findByUserName("testName", pageable);
}
```
#### 限制查询
有时候我们只需要查询前N个元素，或者支取前一个实体。
```
User findFirstByOrderByLastnameAsc();
User findTopByOrderByAgeDesc();
Page<User> queryFirst10ByLastname(String lastname, Pageable pageable);
List<User> findFirst10ByLastname(String lastname, Sort sort);
List<User> findTop10ByLastname(String lastname, Pageable pageable);
```
#### 自定义SQL查询
其实 Spring Data 绝大部分的 SQL 都可以根据方法名定义的方式来实现，但是由于某些原因我们想使用自定义的 SQL 来查询，Spring Data 也是完美支持的；在 SQL 的查询方法上面使用 `@Query` 注解，如涉及到删除和修改在需要加上 `@Modifying`.也可以根据需要添加 `@Transactional` 对事务的支持，查询超时的设置等。
```
@Modifying
@Query("update User u set u.userName = ?1 where u.id = ?2")
int modifyByIdAndUserId(String  userName, Long id);
	
@Transactional
@Modifying
@Query("delete from User where id = ?1")
void deleteByUserId(Long id);
  
@Transactional(timeout = 10)
@Query("select u from User u where u.emailAddress = ?1")
User findByEmailAddress(String emailAddress);
```
#### 多表查询
多表查询 Spring Boot Jpa 中有两种实现方式，第一种是利用 Hibernate 的级联查询来实现，第二种是创建一个结果集的接口来接收连表查询后的结果，这里主要第二种方式。

首先需要定义一个结果集的接口类：
```
public interface HotelSummary {

	City getCity();

	String getName();

	Double getAverageRating();

	default Integer getAverageRatingRounded() {
		return getAverageRating() == null ? null : (int) Math.round(getAverageRating());
	}

}
```
查询的方法返回类型设置为新创建的接口：
```
@Query("select h.city as city, h.name as name, avg(r.rating) as averageRating "
		- "from Hotel h left outer join h.reviews r where h.city = ?1 group by h")
Page<HotelSummary> findByCity(City city, Pageable pageable);

@Query("select h.name as name, avg(r.rating) as averageRating "
		- "from Hotel h left outer join h.reviews r  group by h")
Page<HotelSummary> findByCity(Pageable pageable);
```
使用：
```
Page<HotelSummary> hotels = this.hotelRepository.findByCity(new PageRequest(0, 10, Direction.ASC, "name"));
for(HotelSummary summay:hotels) {
	System.out.println("Name" +summay.getName());
}
```
> 在运行中 Spring 会给接口（HotelSummary）自动生产一个代理类来接收返回的结果，代码汇总使用 getXX的形式来获取
### 5.4 多数据源的支持
#### 同源数据库的多源支持
日常项目中因为使用的分布式开发模式，不同的服务有不同的数据源，常常需要在一个项目中使用多个数据源，因此需要配置 Spring Boot Jpa 对多数据源的使用，一般分一下为三步：
1. 配置多数据源
2. 不同源的实体类放入不同包路径
3. 声明不同的包路径下使用不同的数据源、事务支持 
#### 异构数据库多源支持
比如我们的项目中，即需要对 mysql 的支持，也需要对 Mongodb 的查询等。

实体类声明@Entity 关系型数据库支持类型、声明@Document 为 Mongodb 支持类型，不同的数据源使用不同的实体就可以了：
```
interface PersonRepository extends Repository<Person, Long> {
 …
}

@Entity
public class Person {
  …
}

interface UserRepository extends Repository<User, Long> {
 …
}

@Document
public class User {
  …
}
```
但是，如果 User 用户既使用 Mysql 也使用 Mongodb 呢，也可以做混合使用：
```
interface JpaPersonRepository extends Repository<Person, Long> {
 …
}

interface MongoDBPersonRepository extends Repository<Person, Long> {
 …
}

@Entity
@Document
public class Person {
  …
}
```
也可以通过对不同的包路径进行声明，比如 A 包路径下使用 mysql,B 包路径下使用 MongoDB：
```
@EnableJpaRepositories(basePackages = "com.neo.repositories.jpa")
@EnableMongoRepositories(basePackages = "com.neo.repositories.mongo")
interface Configuration { }
```
### 5.5 其它
#### 使用枚举
使用枚举的时候，我们希望数据库中存储的是枚举对应的 String 类型，而不是枚举的索引值，需要在属性上面添加 @Enumerated(EnumType.STRING)  注解：
```
@Enumerated(EnumType.STRING) 
@Column(nullable = true)
private UserType type;
```
#### 不需要和数据库映射的属性
正常情况下我们在实体类上加入注解@Entity，就会让实体类和表相关连。如果其中某个属性我们不需要和数据库来关联，且只是在展示的时候做计算，只需要加上@Transient属性既可。
```
@Transient
private String  userName;
```
### [**示例代码-github**](https://github.com/ityouknow/spring-boot-examples/tree/master/spring-boot-jpa)
### 参考
[Spring Data JPA - Reference Documentation](http://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
[Spring Data JPA——参考文档 中文版](https://www.gitbook.com/book/ityouknow/spring-data-jpa-reference-documentation/details)
## 第9章. 定时任务
在我们开发项目过程中，经常需要定时任务来帮助我们来做一些内容， Spring Boot 默认已经帮我们实行了，只需要添加相应的注解就可以实现
### 1、pom 包配置
pom 包里面只需要引入 Spring Boot Starter 包即可：
```
<dependencies>
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter</artifactId>
	</dependency>
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-test</artifactId>
		<scope>test</scope>
	</dependency>
</dependencies>
```
### 2、启动类启用定时
在启动类上面加上@EnableScheduling即可开启定时：
```
@SpringBootApplication
@EnableScheduling
public class Application {
	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
}
```
### 3、创建定时任务实现类
- 定时任务1：
  ```
  @Component
  public class SchedulerTask {
    private int count=0;

    @Scheduled(cron="*/6 * * * * ?")
    private void process(){
        System.out.println("this is scheduler task runing  "+(count++));
    }
  }
  ```
- 定时任务2：
  ```
  @Component
  public class Scheduler2Task {
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");

    @Scheduled(fixedRate = 6000)
    public void reportCurrentTime() {
        System.out.println("现在时间：" + dateFormat.format(new Date()));
    }
  }
  ```

结果如下：
```
this is scheduler task runing  0
现在时间：09:44:17
this is scheduler task runing  1
现在时间：09:44:23
this is scheduler task runing  2
现在时间：09:44:29
this is scheduler task runing  3
现在时间：09:44:35
```
**参数说明**：
`@Scheduled` 参数可以接受两种定时的设置，一种是我们常用的 `cron="*/6 * * * * ?"`,一种是 `fixedRate = 6000`，两种都表示每隔六秒打印一下内容。

`fixedRate` 说明：
- `@Scheduled(fixedRate = 6000)` ：上一次开始执行时间点之后6秒再执行
- `@Scheduled(fixedDelay = 6000)` ：上一次执行完毕时间点之后6秒再执行
- `@Scheduled(initialDelay=1000, fixedRate=6000)` ：第一次延迟1秒后执行，之后按 fixedRate 的规则每6秒执行一次

[**示例代码-github**](https://github.com/ityouknow/spring-boot-examples/tree/master/spring-boot-scheduler)
## 第10章. 邮件服务
发送邮件应该是网站的必备功能之一，什么注册验证，忘记密码或者是给用户发送营销信息。最早期的时候我们会使用 JavaMail 相关 api 来写发送邮件的相关代码，后来 Spring 推出了 `JavaMailSender` 更加简化了邮件发送的过程，在之后 Spring Boot 对此进行了封装就有了现在的 `spring-boot-starter-mail` ,本章文章的介绍主要来自于此包。
### 10.1 简单使用
#### 1、pom 包配置
pom 包里面添加 `spring-boot-starter-mail` 包引用：
```
<dependencies>
	<dependency> 
	    <groupId>org.springframework.boot</groupId>
	    <artifactId>spring-boot-starter-mail</artifactId>
	</dependency> 
</dependencies>
```
#### 2、在 application.properties 中添加邮箱配置
```
spring.mail.host=smtp.qiye.163.com //邮箱服务器地址
spring.mail.username=xxx@oo.com //用户名
spring.mail.password=xxyyooo    //密码
spring.mail.default-encoding=UTF-8

mail.fromMail.addr=xxx@oo.com  //以谁来发送邮件
```
#### 3、编写 mailService，这里只提出实现类
```
@Component
public class MailServiceImpl implements MailService {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private JavaMailSender mailSender;

    @Value("${mail.fromMail.addr}")
    private String from;

    @Override
    public void sendSimpleMail(String to, String subject, String content) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(to);
        message.setSubject(subject);
        message.setText(content);

        try {
            mailSender.send(message);
            logger.info("简单邮件已经发送。");
        } catch (Exception e) {
            logger.error("发送简单邮件时发生异常！", e);
        }

    }
}
```
#### 4、编写 test 类进行测试
```
@RunWith(SpringRunner.class)
@SpringBootTest
public class MailServiceTest {

    @Autowired
    private MailService MailService;

    @Test
    public void testSimpleMail() throws Exception {
        MailService.sendSimpleMail("ityouknow@126.com","test simple mail"," hello this is simple mail");
    }
}
```
至此一个简单的文本发送就完成了。
### 10.2 加点料
但是在正常使用的过程中，我们通常在邮件中加入图片或者附件来丰富邮件的内容，下面讲介绍如何使用 Spring Boot 来发送丰富的邮件。
#### 1. 发送 html 格式邮件
其它都不变在 MailService 添加 sendHtmlMail 方法.
```
public void sendHtmlMail(String to, String subject, String content) {
    MimeMessage message = mailSender.createMimeMessage();

    try {
        //true表示需要创建一个multipart message
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setFrom(from);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(content, true);

        mailSender.send(message);
        logger.info("html邮件发送成功");
    } catch (MessagingException e) {
        logger.error("发送html邮件时发生异常！", e);
    }
}
```
在测试类中构建 html 内容，测试发送
```
@Test
public void testHtmlMail() throws Exception {
    String content="<html>\n" +
            "<body>\n" +
            "    <h3>hello world ! 这是一封Html邮件!</h3>\n" +
            "</body>\n" +
            "</html>";
    MailService.sendHtmlMail("ityouknow@126.com","test simple mail",content);
}
```
#### 2. 发送带附件的邮件
在 MailService 添加 sendAttachmentsMail 方法.
```
public void sendAttachmentsMail(String to, String subject, String content, String filePath){
    MimeMessage message = mailSender.createMimeMessage();

    try {
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setFrom(from);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(content, true);

        FileSystemResource file = new FileSystemResource(new File(filePath));
        String fileName = filePath.substring(filePath.lastIndexOf(File.separator));
        helper.addAttachment(fileName, file);

        mailSender.send(message);
        logger.info("带附件的邮件已经发送。");
    } catch (MessagingException e) {
        logger.error("发送带附件的邮件时发生异常！", e);
    }
}
```
> 添加多个附件可以使用多条 `helper.addAttachment(fileName, file)`

在测试类中添加测试方法：
```
@Test
public void sendAttachmentsMail() {
    String filePath="e:\\tmp\\application.log";
    mailService.sendAttachmentsMail("ityouknow@126.com", "主题：带附件的邮件", "有附件，请查收！", filePath);
}
```
#### 3. 发送带静态资源的邮件
邮件中的静态资源一般就是指图片，在 MailService 添加 sendAttachmentsMail 方法.
```
public void sendInlineResourceMail(String to, String subject, String content, String rscPath, String rscId){
    MimeMessage message = mailSender.createMimeMessage();

    try {
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setFrom(from);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(content, true);

        FileSystemResource res = new FileSystemResource(new File(rscPath));
        helper.addInline(rscId, res);

        mailSender.send(message);
        logger.info("嵌入静态资源的邮件已经发送。");
    } catch (MessagingException e) {
        logger.error("发送嵌入静态资源的邮件时发生异常！", e);
    }
}
```
在测试类中添加测试方法：
```
@Test
public void sendInlineResourceMail() {
    String rscId = "neo006";
    String content="<html><body>这是有图片的邮件：<img src=\'cid:" + rscId + "\' ></body></html>";
    String imgPath = "C:\\Users\\summer\\Pictures\\favicon.png";

    mailService.sendInlineResourceMail("ityouknow@126.com", "主题：这是有图片的邮件", content, imgPath, rscId);
}
```
> 添加多个图片可以使用多条 `<img src='cid:" + rscId + "' >` 和 `helper.addInline(rscId, res)` 来实现

到此所有的邮件发送服务已经完成了。
### 10.3 邮件系统
#### 1. 邮件模板
我们会经常收到这样的邮件：
```
尊敬的neo用户：
              
          恭喜您注册成为xxx网的用户,，同时感谢您对xxx的关注与支持并欢迎您使用xx的产品与服务。
          ...
```
其中只有 neo 这个用户名在变化，其它邮件内容均不变，如果每次发送邮件都需要手动拼接的话会不够优雅，并且每次模板的修改都需要改动代码的话也很不方便，因此对于这类邮件需求，都建议做成邮件模板来处理。模板的本质很简单，就是在模板中替换变化的参数，转换为 html 字符串即可，这里以thymeleaf为例来演示。
1. **pom 中导入 thymeleaf 的包**
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```
2. 在 `resorces/templates` 下创建 `emailTemplate.html`
   ```
   <!DOCTYPE html>
   <html lang="zh" xmlns:th="http://www.thymeleaf.org">
        <head>
            <meta charset="UTF-8"/>
            <title>Title</title>
        </head>
        <body>
            您好,这是验证邮件,请点击下面的链接完成验证,<br/>
            <a href="#" th:href="@{ http://www.ityouknow.com/neo/{id}(id=${id}) }">激活账号</a>
        </body>
   </html>
   ```
3. 解析模板并发送
```
@Test
public void sendTemplateMail() {
    //创建邮件正文
    Context context = new Context();
    context.setVariable("id", "006");
    String emailContent = templateEngine.process("emailTemplate", context);

    mailService.sendHtmlMail("ityouknow@126.com","主题：这是模板邮件",emailContent);
}
```
#### 2. 发送失败
因为各种原因，总会有邮件发送失败的情况，比如：邮件发送过于频繁、网络异常等。在出现这种情况的时候，我们一般会考虑重新重试发送邮件，会分为以下几个步骤来实现：
1. 接收到发送邮件请求，首先记录请求并且入库。
2. 调用邮件发送接口发送邮件，并且将发送结果记录入库。
3. 启动定时系统扫描时间段内，未发送成功并且重试次数小于3次的邮件，进行再次发送
#### 3. 异步发送
很多时候邮件发送并不是我们主业务必须关注的结果，比如通知类、提醒类的业务可以允许延时或者失败。这个时候可以采用异步的方式来发送邮件，加快主交易执行速度，在实际项目中可以采用MQ发送邮件相关参数，监听到消息队列之后启动发送邮件。

[**示例代码-github**](https://github.com/ityouknow/spring-boot-examples/tree/master/spring-boot-mail)

## Reference
- [构建微服务：Spring boot 入门篇](https://www.cnblogs.com/ityouknow/p/5662753.html)
- [Spring Boot 面试，一个问题就干趴下了！](https://www.cnblogs.com/ityouknow/p/11281643.html)