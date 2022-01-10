# Intro to the Jackson ObjectMapper
## 1. 简介
本教程聚焦于 `Jackson ObjectMapper` 类，以及如何将 Java 对象序列化成 JSON 和如何将 JSON 字符串反序列化成 Java 对象。
## 2. 依赖
让我们首先将如下依赖加入到 `pom.xml`：
```
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.13.0</version>
</dependency>
```
这个依赖将会传递性地添加以下库到 `CLASSPATH` 里：
- jackson-annotations
- jackson-core

总是从 Maven 中央仓库选择最新版本 [jackson-databind](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22com.fasterxml.jackson.core%22%20AND%20a%3A%22jackson-databind%22)。
## 3. 用 ObjectMapper 读写
让我们从基础的读写开始。

ObjectMapper 的简单 `readValue` API 是一个好的入手点。我们可以使用它来解析或反序列化 JSON 内容成一个 Java 对象。

同时，我们可以使用 `writeValue` 来将一个 Java 对象序列化成 JSON 输出。

在本文中，我们将会使用下面的 带有两个字段的 Car 类序列化及反序列化。
```
public class Car {

    private String color;
    private String type;

    // standard getters setters
}
```
### 3.1. Java 对象至 JSON
让我们看看第一个例子，使用 ObjectMapper 的 `writeValue` 方法来把 Java 对象序列化成 JSON：
```
ObjectMapper objectMapper = new ObjectMapper();
Car car = new Car("yellow", "renault");
objectMapper.writeValue(new File("target/car.json"), car);
```
上面的输出在文件中将会如下所示：
```
{"color":"yellow","type":"renault"}
```
`ObjectMapper` 类的 `writeValueAsString` 和 `writeValueAsBytes` 方法从一个 Java 对象产生 JSON，并以字符串或字节数组的形式返回产生的 JSON。
```
String carAsString = objectMapper.writeValueAsString(car);
```
### 3.2. JSON 至 Java 对象
下面的例子使用 ObjectMapper 类将一个 JSON 字符串转化为一个 Java 对象：
```
String json = "{ \"color\" : \"Black\", \"type\" : \"BMW\" }";
Car car = objectMapper.readValue(json, Car.class);
```
readValue 方法也接受其它形式的输入，例如一个包含 JSON 字符串的文件：
```
Car car = objectMapper.readValue(new File("src/test/resources/json_car.json"), Car.class);
```
或 URL：
```
Car car = objectMapper.readValue(new URL("file:src/test/resources/json_car.json"), Car.class);
```
### 3.3. JSON 至 Jackson JsonNode
可选帝，一个 JSON 可倍解析成一个 JsonNode 对象并可被用于从一个特定的节点检索数据：
```
String json = "{ \"color\" : \"Black\", \"type\" : \"FIAT\" }";
JsonNode jsonNode = objectMapper.readTree(json);
String color = jsonNode.get("color").asText();
// Output: color -> Black
```
### 3.4. 从一个 JSON Array 字符串 创建一个 Java List
我们可以利用 TypeReference 来讲一个数字形式的 JSON 解析成一个 Java 对象列表：
```
String jsonCarArray = "[{ \"color\" : \"Black\", \"type\" : \"BMW\" }, { \"color\" : \"Red\", \"type\" : \"FIAT\" }]";
List<Car> listCar = objectMapper.readValue(jsonCarArray, new TypeReference<List<Car>>(){});
```
### 3.5. 从 JSON 字符串创建 Java Map
类似地，我们可以将一个 JSON 解析成一个 Java Map：
```
String json = "{ \"color\" : \"Black\", \"type\" : \"BMW\" }";
Map<String, Object> map = objectMapper.readValue(json, new TypeReference<Map<String,Object>>(){});
```
## 4. 高级特性
Jackson 库的最大的优势就在于它高度定制化的序列化/发序列化过程。在这一节，我们将讨论一些高级特性，在这些场景输入或输出的 JSON 回复不同于产生或消费这些回复的对象。
### 4.1. 配置序列化或反序列化特性
当将 JSON 对象转化为 Java 类时，当 JSON 字符串有新形的字段时，默认处理将会产生异常：
```
String jsonString = "{ \"color\" : \"Black\", \"type\" : \"Fiat\", \"year\" : \"1970\" }";
```
上面例子中的 JSON 字符串在默认的将其解析成 `Car` 类 Java 对象过程中将会产生 `UnrecognizedPropertyException` 异常。

**通过 configure 方法，我们可以扩展默认处理以忽略新字段**：
```
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
Car car = objectMapper.readValue(jsonString, Car.class);

JsonNode jsonNodeRoot = objectMapper.readTree(jsonString);
JsonNode jsonNodeYear = jsonNodeRoot.get("year");
String year = jsonNodeYear.asText();
```
另一个选项基于 `FAIL_ON_NULL_FOR_PRIMITIVES`，它定义了基本类型的 `null` 值是否允许：
```
objectMapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
```
类似地，`FAIL_ON_NUMBERS_FOR_ENUM` 控制枚举值是否允许被序列化/反序列化成数字：
```
objectMapper.configure(DeserializationFeature.FAIL_ON_NUMBERS_FOR_ENUMS, false);
```
你可以在[官方网站](https://github.com/FasterXML/jackson-databind/wiki/Serialization-Features)找到序列化/反序列化的更多详细例子。
### 4.2. 配置自定义序列化器或反序列化器
ObjectMapper 类的另一个重要特性是注册一个自定义[序列化器](https://www.baeldung.com/jackson-custom-serialization)和[反序列化器](https://www.baeldung.com/jackson-deserialization)。

自定义序列化器或反序列化器在某些情况下是很有用的：当 JSON 的输入和输出回复不同于它应该序列化或反序列化的 Java 类的结构。

下面是一个**自定义 JSON 序列化器**的例子：
```
public class CustomCarSerializer extends StdSerializer<Car> {

    public CustomCarSerializer() {
        this(null);
    }

    public CustomCarSerializer(Class<Car> t) {
        super(t);
    }

    @Override
    public void serialize(Car car, JsonGenerator jsonGenerator, SerializerProvider serializer) {
        jsonGenerator.writeStartObject();
        jsonGenerator.writeStringField("car_brand", car.getType());
        jsonGenerator.writeEndObject();
    }
}
```
自定义序列化器可以如下方式调用：
```
ObjectMapper mapper = new ObjectMapper();
SimpleModule module = new SimpleModule("CustomCarSerializer", new Version(1, 0, 0, null, null, null));
module.addSerializer(Car.class, new CustomCarSerializer());
mapper.registerModule(module);
Car car = new Car("yellow", "renault");
String carJson = mapper.writeValueAsString(car);
```
在客户端 Car（JSON 输入） 输出长成下面的样子：
```
var carJson = {"car_brand":"renault"}
```
下面是一个**自定义 JSON 反序列化器**的例子：
```
public class CustomCarDeserializer extends StdDeserializer<Car> {
    
    public CustomCarDeserializer() {
        this(null);
    }

    public CustomCarDeserializer(Class<?> vc) {
        super(vc);
    }

    @Override
    public Car deserialize(JsonParser parser, DeserializationContext deserializer) {
        Car car = new Car();
        ObjectCodec codec = parser.getCodec();
        JsonNode node = codec.readTree(parser);
        
        // try catch block
        JsonNode colorNode = node.get("color");
        String color = colorNode.asText();
        car.setColor(color);
        return car;
    }
}
```
自定义反序列化器可以如下方式调用：
```
String json = "{ \"color\" : \"Black\", \"type\" : \"BMW\" }";
ObjectMapper mapper = new ObjectMapper();
SimpleModule module = new SimpleModule("CustomCarDeserializer", new Version(1, 0, 0, null, null, null));
module.addDeserializer(Car.class, new CustomCarDeserializer());
mapper.registerModule(module);
Car car = mapper.readValue(json, Car.class);
```
### 4.3. 处理 Date 格式
默认的 java.util.Date 序列化产生一个数字，例如 epoch 时间戳（从 January 1, 1970, UTC 来的毫秒数）。但它对用户阅读起来并不友好，需要进一步转化为用户可读的格式。

让我们将我们一直使用的 Car 实例包装成一个带有 datePurchased 属性的 Request 类：
```
public class Request 
{
    private Car car;
    private Date datePurchased;

    // standard getters setters
}
```
为了控制一个 date 的字符串格式，并设置为 `yyyy-MM-dd HH:mm a z`，考虑下面的代码片段：
```
ObjectMapper objectMapper = new ObjectMapper();
DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm a z");
objectMapper.setDateFormat(df);
String carAsString = objectMapper.writeValueAsString(request);
// output: {"car":{"color":"yellow","type":"renault"},"datePurchased":"2016-07-03 11:43 AM CEST"}
```
为了了解更多 Jackson 序列化日期的细节，阅读[我们的深入文档](https://www.baeldung.com/jackson-serialize-dates)。
### 4.4. 处理集合
DeserializationFeature 类的另一个虽小但有用的特性是从 JSON 数组回复产生集合类型的能力。

例如，我们可以产生一个数组结果：
```
String jsonCarArray = "[{ \"color\" : \"Black\", \"type\" : \"BMW\" }, { \"color\" : \"Red\", \"type\" : \"FIAT\" }]";
ObjectMapper objectMapper = new ObjectMapper();
objectMapper.configure(DeserializationFeature.USE_JAVA_ARRAY_FOR_JSON_ARRAY, true);
Car[] cars = objectMapper.readValue(jsonCarArray, Car[].class);
// print cars
```
或者一个列表：
```
String jsonCarArray = 
  "[{ \"color\" : \"Black\", \"type\" : \"BMW\" }, { \"color\" : \"Red\", \"type\" : \"FIAT\" }]";
ObjectMapper objectMapper = new ObjectMapper();
List<Car> listCar = objectMapper.readValue(jsonCarArray, new TypeReference<List<Car>>(){});
// print cars
```
更过利用 Jackson 产生集合的例子请参见[这里](https://www.baeldung.com/jackson-collection-array)。
## 5. 结论
Jackson 是 JSON 中一个成熟可靠的 Java JSON 序列化/反序列化库。ObjectMapper API 提供了简单的方式以解析或生成 JSON 标识的对象，而且不失灵活性。本文讨论了这个库流行的一些主要特性。

本文对应代码可在 [Github](https://github.com/eugenp/tutorials/tree/master/jackson-simple) 上找到。

## Reference
- [Intro to the Jackson ObjectMapper](https://www.baeldung.com/jackson-object-mapper-tutorial)