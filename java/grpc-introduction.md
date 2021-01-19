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
### 4.2 定义消息结构
### 4.3 定义服务约定
## 5. 代码生成
## 6. 创建服务端
## 7. 创建客户端
## 8. 结论

和往常一样，源代码可以在[GitHub](https://github.com/eugenp/tutorials/tree/master/grpc)上找到。

## Reference
- [Introduction to gRPC](https://www.baeldung.com/grpc-introduction)