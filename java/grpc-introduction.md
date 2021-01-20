# gRPC 介绍
## 1. 介绍
**[gRPC](http://www.grpc.io/)是一款高性能的开源RPC框架，最早由Google开发**。它帮助消除模板代码，帮助在数据中心里或跨数据中心连接多语言服务，
## 2. 概览
该框架基于远程过程调用（RPC）的客户-服务器模式。**一个客户端应用可以直接调用在服务器上的方法，就像调用一个本地对象一样**。

本文将遵循下面的步骤通过gRPC来创建一个典型的客户端-服务端应用。
1. 在一个 .proto 文件中定义一个服务
2. 利用 protocol buffer 编译器来产生客户端和服务端代码
3. 创建服务端应用，实现产生的服务接口，创建 gRPC 服务器
4. 创建客户端应用，利用生成的 stubs 发起 RPC 调用。

让我们定义一个简单的 HelloService ，它交换名和姓来作为欢迎词返回。
## 3. Maven 依赖
让我们添加 [grpc-netty](https://search.maven.org/classic/#search%7Cga%7C1%7Ca%3A%22grpc-netty%22), [grpc-protobuf](https://search.maven.org/classic/#search%7Cga%7C1%7Ca%3A%22grpc-protobuf%22) and [grpc-stub](https://search.maven.org/classic/#search%7Cga%7C1%7Ca%3A%22grpc-stub%22)依赖：
```
<dependency>
    <groupId>io.grpc</groupId>
    <artifactId>grpc-netty</artifactId>
    <version>1.16.1</version>
</dependency>
<dependency>
    <groupId>io.grpc</groupId>
    <artifactId>grpc-protobuf</artifactId>
    <version>1.16.1</version>
</dependency>
<dependency>
    <groupId>io.grpc</groupId>
    <artifactId>grpc-stub</artifactId>
    <version>1.16.1</version>
</dependency>
```
## 4. 定义服务
我们从定义服务开始，**指定可以通过远程调用的方法及其对应参数与返回类型**。

这是在 .proto 文件中通过[protocol buffers](https://www.baeldung.com/google-protocol-buffer)实现的。它们也用于描述负载消息的结构。
### 4.1 基本配置
让我们为我们的示例HelloService创建一个HelloService.proto文件，我们从添加以下这些基本配置细节开始：
```
syntax = "proto3";
option java_multiple_files = true;
package org.baeldung.grpc;
```
第一行告诉编译器这个文件里将是用什么语法。默认地，编译器将所有产生的Java代码放置在一个文件里，第二行覆盖这一设置，所有的定义都将在单独的文件里产生。

最后，我们指定了我们将产生的Java类的包名。
### 4.2 定义消息结构
接下来我们订一下面的消息：
```
message HelloRequest {
    string firstName = 1;
    string lastName = 2;
}
```
这里定义了请求负载。消息里的每一个属性都有其自己的类型。

每个属性都有一个独一无二的数字，这被称为标记（tag）。**标记被 protocol buffer 用来代表该属性而不是属性名**。

因此，不像 JSON 每次我们都需要传递属性名 firstName，protocol buffer 将使用数字 1 来代表 firstName。回复负载定义与请求类似。

> **注意**：我们可以跨消息定义使用相同的标记。
```
message HelloResponse {
    string greeting = 1;
}
```
### 4.3 定义服务约定
最后，让我们来定义服务约定。对于我们的HelloService，我们定义了一个 hello() 操作：
```
service HelloService {
    rpc hello(HelloRequest) returns (HelloResponse);
}
```
hello() 方法接受一个单一请求并返回一个单一回复。gRPC 也支持在请求和回复前添加 `stream` 关键字来支持流式（请求和回复）。
## 5. 代码生成
现在我们把 `HelloService.proto` 文件传递给 protocol buffer 编译器 `protoc` 来产生 Java 文件。有多种方法来触发该操作。
### 5.1 使用 protocol buffer 编译器
首先，我们需要 protocol buffer 编译器。我们可以从[这里](https://github.com/protocolbuffers/protobuf/releases)选择许多预编译二进制文件。

另外，我们需要获取[gRPC Java 代码生成插件](https://github.com/grpc/grpc-java/tree/master/compiler)。

最后，我们可以使用下面的命令行产生代码：
```
protoc --plugin=protoc-gen-grpc-java=$PATH_TO_PLUGIN -I=$SRC_DIR 
  --java_out=$DST_DIR --grpc-java_out=$DST_DIR $SRC_DIR/HelloService.proto
```
### 5.2 使用 Maven 插件
作为一个开发者，你应该期待代码生成与你的构建系统紧密集成。gRPC 为Maven构建系统提供了一个[protobuf-maven-plugin](https://search.maven.org/classic/#search%7Cga%7C1%7Cg%3A%22org.xolstice.maven.plugins%22%20AND%20a%3A%22protobuf-maven-plugin%22)。
```
<build>
  <extensions>
    <extension>
      <groupId>kr.motd.maven</groupId>
      <artifactId>os-maven-plugin</artifactId>
      <version>1.6.1</version>
    </extension>
  </extensions>
  <plugins>
    <plugin>
      <groupId>org.xolstice.maven.plugins</groupId>
      <artifactId>protobuf-maven-plugin</artifactId>
      <version>0.6.1</version>
      <configuration>
        <protocArtifact>
          com.google.protobuf:protoc:3.3.0:exe:${os.detected.classifier}
        </protocArtifact>
        <pluginId>grpc-java</pluginId>
        <pluginArtifact>
          io.grpc:protoc-gen-grpc-java:1.4.0:exe:${os.detected.classifier}
        </pluginArtifact>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>compile</goal>
            <goal>compile-custom</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```
[os-maven-plugin](https://search.maven.org/classic/#search%7Cgav%7C1%7Cg%3A%22kr.motd.maven%22%20AND%20a%3A%22os-maven-plugin%22)扩展/插件产生各种各样平台的项目属性文件，比如${os.detected.classifier}。
### 5.3 使用 Gradle 插件
## 6. 创建服务端
无论你使用那种代码生成方法，下面这些关键文件都会被生成：
- HelloRequest.java - 包含 HelloRequest 类型定义
- HelloResponse.java - 包含 HelleResponse 类型定义
- HelloServiceImplBase.java - 包含抽象类 HelloServiceImplBase，它提供了服务接口里定义的操作的实现。
### 6.1 覆盖服务基础类
**抽象类 HelloServiceImplBase 的默认实现对于尉氏县的方法是抛出运行时异常** `io.grpc.StatusRuntimeException`。

我们应该扩展这个类并重写我们的服务定义里提到的 hello() 方法：
```
public class HelloServiceImpl extends HelloServiceImplBase {
    @Override
    public void hello(HelloRequest request, StreamObserver<HelloResponse> responseObserver) {

        String greeting = new StringBuilder()
          .append("Hello, ")
          .append(request.getFirstName())
          .append(" ")
          .append(request.getLastName())
          .toString();

        HelloResponse response = HelloResponse.newBuilder()
          .setGreeting(greeting)
          .build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }
}
```
如果我们与 HellService.proto 文件比较 hello() 的方法签名，我们将注意到它没有返回 HelloResponse。取而代之，它有了第二个参数 StreamObserver<HelloResponse>，它是一个回复观察者（response observer），一个服务器应用于回复的回调对象。

这种方式下客户端可以选择堵塞调用或非堵塞调用。

gRPC 使用构建器来创建对象。我们使用 HelloResponse.newBuilder() 并设置欢迎文本来构建一个 HelloResponse 对象。我们使用这个对象调用 responseObserver的 onNext() 方法并将其发送给客户。

最后，我们需要调用 onCompleted() 来指定我们完成了 RPC 处理，否则连接将被挂起，客户端将会等待更多信息返回。
### 6.2 运行 gRPC 服务
接下来，让我们启动 gRPC 服务来监听进入的请求：
```
public class GrpcServer {
    public static void main(String[] args) {
        Server server = ServerBuilder
          .forPort(8080)
          .addService(new HelloServiceImpl()).build();

        server.start();
        server.awaitTermination();
    }
}
```
这里我们再次使用构建器来创建 gRPC 服务器，并使其在8080 端口上监听，并添加我们定义的 HelloServiceImpl 服务。start() 将开启服务。在我们的例子中，我们将调用 awaitTermination() 保持运行在前端并堵塞提示。
## 7. 创建客户端
**gRPC 提供了一个 channel 构造来抽象底层细节**如连接，连接池，负载均衡等。

我们将使用ManagedChannelBuilder来创建一个channel。这里，我们指定服务器地址和端口。

我们将使用明文通讯没有加密：
```
public class GrpcClient {
    public static void main(String[] args) {
        ManagedChannel channel = ManagedChannelBuilder.forAddress("localhost", 8080)
          .usePlaintext()
          .build();

        HelloServiceGrpc.HelloServiceBlockingStub stub 
          = HelloServiceGrpc.newBlockingStub(channel);

        HelloResponse helloResponse = stub.hello(HelloRequest.newBuilder()
          .setFirstName("Baeldung")
          .setLastName("gRPC")
          .build());

        channel.shutdown();
    }
}
```
加下来，我们需要创建一个 `stub` ，我们就爱那个是用它来发起对 `hello()` 的远程调用。**stub 是客户端于服务端交互的主要方式**。当使用自动生成的stubs时，`stub` 拥有包覆 `channel` 的构造函数。

这里我们使用了一个堵塞/同步 `stub`，如此RPC调用就得等待服务器回复，将返回一个 `Response` 或抛出一个异常。gRPC 提供了两种类型的stubs ，这方便了非堵塞/异步调用.

最后，该到了 `hello()` RPC 调用的时间了。这里我们传入了 `HelloRequest` 对象。我们可以使用自动生成的设置器来设置 `HelloRequest` 对象的 `firstName`, `lastName` 属性。

我们得到了从服务器端返回的 `HelloResponse` 对象。
## 8. 结论
在本指南中，我们看到了我们可以使用 gRPC 来缓解开发两个服务件通信的难题，专注于定义服务，让 gRPC 帮我们处理那些模板代码。

和往常一样，源代码可以在[GitHub](https://github.com/eugenp/tutorials/tree/master/grpc)上找到。

## Reference
- [Introduction to gRPC](https://www.baeldung.com/grpc-introduction)