# Spring指标
这个项目提供设施知道应用收集指标并与流行的第三方监控系统交互。选择你件使用的指标后端参考下面的应用来偷啊整你的应用：
## 快速开始
Pre-release版本发布的很频繁，但不要勇于产品用途。
在Gradle中：
```
compile 'org.springframework.metrics:spring-metrics:latest.release'
compile 'io.prometheus:simpleclient_common:latest.release'
```
在Maven中：
```
<dependency>
  <groupId>org.springframework.metrics</groupId>
  <artifactId>spring-metrics</artifactId>
  <version>${metrics.version}</version>
</dependency>
<dependency>
  <group>io.prometheus</group>
  <artifact>simpleclient_common</artifact>
  <version>${prom.version}</version>
</dependency>
```
在你的Spring Boot应用中通过`@EnablePrometheusMetrics`开启指标；
```
@SpringBootApplication
@EnablePrometheusMetrics
public class MyApp {
}

@RestController
@Timed
class PersonController {
    Map<Integer, Person> people = new Map<Integer, Person>();

    public PersonController(MeterRegistry registry) {
        // constructs a gauge to monitor the size of the population
        registry.mapSize("population", people);
    }

    @GetMapping("/api/people")
    public List<Person> listPeople() {
        return people;
    }

    @GetMapping("/api/person/")
    public Person findPerson(@PathVariable Integer id) {
        return people.get(id);
    }
}
```
`@EnablePrometheusMetrics` 也将 `@EnablePrometheusScraping` 应用于你的 Spring Boot应用，它将在 `/prometheus` 开启`Spring Boot Actuator`端点，它将把 Prometheus 刮取的结果以合适的格式呈现出爱。

这是加到`prometheus.yml`中的一个`scrape_config`实例：
```
scrape_configs:
  - job_name: 'spring'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['HOST:PORT']
```
在这个示例代码中，多维时间序列以多种指标的形式被创建：
1. 在控制器上加了 `@Time` 将创建一个名为 `http_server_requests` 的 `Timer` 时间序列，它默认包含多维数据如HTTP Response的状态，HTTP method，失败请求的异常类型，以及`pre-variable` 替代的参数化端点URL.
2. 在我们的meter注册器上调用 `collectionSize` 添加一个名为`population` 的 `Gauge`，当被一个 metrics 后端或exporter观察到时会改变。
3. 指标将会为JVM GC指标为发布
4. 如果你在使用logback，counts 将会为在每个级别为每个日志事件而收集

让我们来分解并详细介绍 instrumentation API 的关键件。
## Meters and Registries
## Dimensions/Tags
## 推荐方法（Recommended approach）

## Reference
- [Spring Metrics](https://docs.spring.io/spring-metrics/docs/current/public/prometheus)
