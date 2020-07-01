# gRPC核心概念，架构及生命周期
对关键的gRPC概念的一个介绍，对gRPC架构及RPC生命周期的一个简单概览。
## 概观
### 服务定义
像许多RPC系统，gRPC也基于定义一个服务的概念，指定了可被远程调用的方法及其参数和返回类型。缺省地，gRPC使用[protocol buffers](https://developers.google.com/protocol-buffers)作为描述服务接口以及负荷消息结构的接口描述语言。如果需要也可使用其它选择：
```
service HelloService {
  rpc SayHello (HelloRequest) returns (HelloResponse);
}

message HelloRequest {
  string greeting = 1;
}

message HelloResponse {
  string reply = 1;
}
```
gRPC让你定义四种服务方法：
- 一元RPC：客户发送单一请求给服务端，得到一个单一回复，就像一个正常函数调用:
  ```
  rpc SayHello(HelloRequest) returns (HelloResponse);
  ```
- 服务端流式RPC：客户端向服务端发送一个请求，可得到一个流，据此都会一系列消息。客户端从返回的流读取数据直到没有更多消息。gRPC保证一个单独RPC调用里的消息顺序。
    ```
  rpc LotsOfReplies(HelloRequest) returns (stream HelloResponse);
  ```
- 客户端流式RPC：客户端写了一系列消息并把它们发送给服务端，同样地使用一个提供的流。一旦客户写完数据，她3等待服务端读取它们并返回回复。同样地gRPC保证一个单独RPC调用里的消息顺序。
    ```
  rpc LotsOfGreetings(stream HelloRequest) returns (HelloResponse);
  ```
- 双向流式RPC：双方使用一个读写流来发送一系列消息。两个流独立运作，客户端和服务端可以任何它们喜欢的顺序读写：例如，服务端可以等到读取完所有的客户端消息再发送回复，或者它读一条消息，发送一条消息，或者其它读写组合。每个流里消息的顺序是保留的。
  ```
  rpc BidiHello(stream HelloRequest) returns (stream HelloResponse);
  ```
你可以在下面的RPC生命周期一节学习到更多各种RPC类型的信息。
### 使用API
从一个`.proto`文件里的服务定义开始，gRPC提供了protocol buffer编译器插件用于产生服务端和客户端代码。典型地，gRPC用户调用这些客户端APIs，再服务端实现这些API。
- 在服务端，服务器实现那些服务声明的方法病运行一个gRPC服务来处理客户调用。gRPC基础设施解码进入的请求，只性服务方法，编码服务回复。
- 在客户端，客户拥有一个本地对象叫stub，它将同样的方法实现为服务。接下来客户端在这些本地对象上调用方法，将调用参数封装成合适的pprotocol buffers消息类型--gRPC照看把请求发送到服务端，并返回服务端的pprotocol buffer回复。
### 同步异步
同步RPC调用将堵塞直到回复从服务端返回，这是与RPC渴望达成的过程调用抽象最接近的。另一方面，网络天然就是异步地，在许多场景下开始RPCs单并不堵塞当前线程是有用的。

gRPC编程API的大部分语言提供了同步异步两种方式。你可以在每种语言的教程和参考文档中找到更多。
## RPC生命周期


## Reference
- [gRPC核心概念，架构及生命周期](https://www.grpc.io/docs/what-is-grpc/core-concepts/)