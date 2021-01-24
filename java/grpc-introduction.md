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
```
plugins {
    id 'java'
    id "com.google.protobuf" version "0.8.8"
}

repositories {
    mavenCentral()
}

dependencies {
   compile group: 'io.grpc', name: 'grpc-all', version: '1.19.0'
   compile "com.google.protobuf:protobuf-java:3.6.1"
}

sourceSets {
    main {
        java {
            srcDirs 'build/generated/source/proto/main/grpc'
            srcDirs 'build/generated/source/proto/main/java'
        }
    }
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:3.7.0"
    }
    plugins {
        grpc {
            artifact = "io.grpc:protoc-gen-grpc-java:1.19.0"
        }
    }
    generateProtoTasks {
        all()*.plugins {
            grpc {}
        }
    }
}
```
现在运行 `./gradlew clean build` 以产生 grpc 文件。你可以看到文件在路径 `build/generated/source/proto/main/grpc` 下。

**注意**：
- 你也可以选择从 `group: ‘io.grpc’` 中添加必须的依赖：
  + compile group: 'io.grpc', name: 'grpc-protobuf', version: '1.19.0'
  + compile group: 'io.grpc', name: 'grpc-stub', version: '1.19.0'
  + compile group: 'io.grpc', name: 'grpc-netty-shaded', version: '1.19.0'
  + compile group: 'io.grpc', name: 'grpc-netty', version: '1.19.0'
- 默认地 protobuf 插件将从系统环境变量搜寻 `protoc` 可执行文件。我建议你利用 maven 的预编译 `protoc` 发布文件，你也可以提供（本地 protoc）路径。更多细节请阅读 https://github.com/google/protobuf-gradle-plugin。
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
## Appendix
1. 同步 grpc C++ 服务器和异步 grpc java 客户端用于双向流式RPC（bidirectional streaming RPC）
**在服务器端使用同步API，而在客户端使用异步API并不会导致任何问题**。在 Android 客户端中使用异步API不会损害性能。
2. 并发连接（Connection concurrency）
   HTTP/2 连接典型地一次在一个连接上有一个限制即[最大并发流的限制数目（活动HTTP请求）](https://httpwg.github.io/specs/rfc7540.html#rfc.section.5.1.2)。默认地大部分服务器设置该限制为100个并发流（concurrent streams）。

   一个 `gRPC channel` 使用一个 `HTTP/2` 连接，并发调用在该连接上多路复用。当活动调用的数目达到连接流限制时，多余的调用在客户端排队等待。在它们被发送前，这些排队的调用需要等待活动调用完成。高负载应用，或长时间运行的流式 gRPC 调用，可能看到这种由于这种限制导致的性能问题。

   一些对这种问题的临时解决方案：
   + 对很高负载的应用创建创建单独的 `gRPC channels`。
   + 使用 `gRPC channels` 池，例如，创建一个 `gRPC channels` 列表。每次当一个 `gRPC channel` 需要时就从这个列表中随机选择一个。使用随机选择的方式可将调用均分到多个连接。

   > **重要**：在服务器上增加并发流限制的最大值是解决这个问题的另一种方式，它利用[MaxStreamsPerConnection](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.server.kestrel.core.http2limits.maxstreamsperconnection#Microsoft_AspNetCore_Server_Kestrel_Core_Http2Limits_MaxStreamsPerConnection)配置。但该方式不被推荐。在单个 `HTTP/2` 连接上的太多流可能引入新的性能问题：在往连接写时的流的线程竞争；连接丢包导致在TCP层面的所有调用堵塞。
3. 负载均衡
   某些负载均衡器不能有效地与 gRPC 一起工作。L4（传输层）负载均衡器在连接级别工作，并通过端点均分TCP连接。这种方式对于利用 HTTP/1.1 的负载均衡API调用工作很好。利用 HTTP/1.1 的并发调用被发送到不同的端点，从而允许调用跨端点负载均衡。

   因为 L4 负载均衡在连接层级工作，它们不能与gRPC很好的工作。gRPC 使用 HTTP/2，它在一个TCP连接上多路复用多个调用。通过该连接的所有gRPC调用最后发往同一个端点。

   由两种有效的 gRPC 负载均衡方式：
   + 客户端负载均衡
   + L7 （应用）代理负载均衡

   > **注意**：只有gRPC调用能在端点间负载均衡。一旦一个gRPC流式调用建立，所有发往该流的消息都最终发往一个端点。
4. 客户端负载均衡

## Reference
- [Introduction to gRPC](https://www.baeldung.com/grpc-introduction)
- [Generate java code from .proto file using gradle](https://medium.com/@DivyaJaisawal/generate-java-code-from-proto-file-using-gradle-1fb9fe64e046)
- [Config Gradle to generate Java code from Protobuf](https://dev.to/techschoolguru/config-gradle-to-generate-java-code-from-protobuf-1cla)
- [protobuf gradle-plugin](https://github.com/google/protobuf-gradle-plugin)
- [Performance best practices with gRPC](https://docs.microsoft.com/en-us/aspnet/core/grpc/performance?view=aspnetcore-5.0)
- [gRPC学习笔记](https://www.bookstack.cn/read/learning-grpc/README.md)
- [The complete gRPC course](https://www.youtube.com/playlist?list=PLy_6D98if3UJd5hxWNfAqKMr15HZqFnqf)
- [C++ Performance Notes](https://grpc.github.io/grpc/cpp/md_doc_cpp_perf_notes.html)