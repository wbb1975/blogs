# gRPC (Core) 压缩食谱（Compression Cookbook）
## 介绍
本文档描述了gRPC C核心的压缩实现。参考[完全压缩规范](https://github.com/grpc/grpc/blob/master/doc/compression.md)来获得更多细节。
## 目标受众
包裹语言的开发人员，目的是与C核心交互支持压缩。
## GA可用标准
1. 可以在通道（channel）, 调用（call）和 消息（message）级别设置压缩。原则上API应基于压缩级别而非算法。
2. 单元测试可以覆盖到[规范中的所有用例] (https://github.com/grpc/grpc/blob/master/doc/compression.md#test-cases)
3. Jenkins上互操作性被实现并通过。两个相关的互操作性测试是[大型压缩一元调用](https://github.com/grpc/grpc/blob/master/doc/interop-test-descriptions.md#large_compressed_unary)和[服务端压缩流](https://github.com/grpc/grpc/blob/master/doc/interop-test-descriptions.md#server_compressed_streaming)。
## 总结流图（Summary Flowcharts）
下面的流程图描述了消息的演化，包含输入消息和输出消息，与调用的客户端服务端特性无关。客户端和服务端只见不对称的方面（比如[压缩级别的使用](https://github.com/grpc/grpc/blob/master/doc/compression.md#compression-levels-and-algorithms)）被显式标出。不同场景的详细文字描述将在下面的章节中提到。
### 输入消息
![输入消息](iamges/compression_cookbook_incoming.png)
### 输出消息
![输出消息](iamges/compression_cookbook_outgoing.png)
## 级别 vs 算法 （Levels vs Algorithms）
正如在[规范文档的相关讨论](https://github.com/grpc/grpc/blob/master/doc/compression.md#compression-levels-and-algorithms)中提到的，压缩级别是服务端压缩选择的主要机制。将来，在客户端也会如此。级别的使用把选择对端支持的具体压缩算法的复杂性拿走，从而帮开发人员移除了选择的负担。在写作本文时（2016年第二季度），客户端仅仅能够指定压缩算法。一旦自动重试/协商机制就位，客户端也会支持级别。
## 每通道设置（Per Channel Settings）
压缩可在通道创建时设置。这是一个方便的设施，可以避免不得不为每个调用重复配置压缩。注意单独调用或消息上的消息设置将覆盖通道的设置。

下面的属性可以在通道创建时通过通道参数配置：
### 禁用消息压缩
使用通道参数键`GRPC_COMPRESSION_CHANNEL_ENABLED_ALGORITHMS_BITSET`（源自grpc/impl/codegen/compression_types.h），传递一个32位bitset值。一个设置位意味着根据`grpc_compression_algorithm`的枚举值对应的算法被开启。例如，`GRPC_COMPRESS_GZIP`当前对应枚举值2。为给一个通道开启/禁用GZIP，你应该设置/清理第三LSB (比如 0b100 = 0x4)。注意设置/清理第0位，其对应`GRPC_COMPRESS_NONE`，没有任何效果，即没有压缩支持。输入消息压缩（如编码）带有禁用算法将导致吊用被关闭并返回`GRPC_STATUS_UNIMPLEMENTED`。
### 缺省压缩级别
（当前，2016第二季度，仅仅对服务端通道可用，客户端将忽略它。）使用通道参数键`GRPC_COMPRESSION_CHANNEL_DEFAULT_LEVEL`（源自grpc/impl/codegen/compression_types.h），并传递一个来自`grpc_compression_level` 的整形值。
### 缺省压缩算法
使用通道参数键`GRPC_COMPRESSION_CHANNEL_DEFAULT_ALGORITHM`（源自grpc/impl/codegen/compression_types.h），并传递一个来自`grpc_compression_algorithm` 的整形值。
## 每调用设置（Per Call Settings）
### 调用回复压缩级别
服务端通过初始元数据请求一个压缩级别。`send_initial_metadata` `grpc_op`包含一个`maybe_compression_level`字段，其有两个字段，`is_set`和`compression_level`。当主动选择一个级别时前者必须被设置以消除缺省值0（没有压缩）的歧义（与没有压缩时的主动选择）。

核心将接收请求的压缩级别，并基于它对对端的知识（与客户端通过`grpc-accept-encoding`头沟通。注意这个**头字段的缺失意味着客户端/对端不支持压缩**）自动选择一个压缩算法。
### 调用回复压缩算法
**服务端应该避免直接设置压缩算法**。请尽量设置压缩级别除非有一个强迫的理由来选择一个特定算法（基准测试，测试）。

选择一个具体压缩算法可通过添加一个（`GRPC_COMPRESS_REQUEST_ALGORITHM_KEY`, <algorithm-name>）键值对到初始化元数据中，这里`GRPC_COMPRESS_REQUEST_ALGORITHM_KEY`被定义在grpc/impl/codegen/compression_types.h中，<algorithm-name>是人可读的用于消息编码（如gzip, identity等）的算法（在[HTTP2规范](https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md)）。参考[`grpc_compression_algorithm_name`](https://github.com/grpc/grpc/blob/master/src/core/lib/compression/compression.c)来获取`grpc_compression_algorithm`枚举值和它们的文本表示的映射。
## 每消息设置（Per Message Settings）
为了禁用一个特定消息的压缩，`grpc_op`实例`GRPC_OP_SEND_MESSAGE`的`flags` 标志位必须设置`GRPC_WRITE_NO_COMPRESS`对应位，具体参见grpc/impl/codegen/compression_types.h。
## 写一个客户端与服务器端
### 产生客户端与服务端接口
```
$ protoc -I ../../protos/ --grpc_out=. --plugin=protoc-gen-grpc=grpc_cpp_plugin ../../protos/helloworld.proto
$ protoc -I ../../protos/ --cpp_out=. ../../protos/helloworld.proto
```
### 添加压缩功能
在客户端，通过通道参数可以为通道设置缺省压缩算法：
```
ChannelArguments args;
// Set the default compression algorithm for the channel.
args.SetCompressionAlgorithm(GRPC_COMPRESS_GZIP);
GreeterClient greeter(grpc::CreateCustomChannel(
    "localhost:50051", grpc::InsecureChannelCredentials(), args));
```
每次调用的压缩配置可以用客户端context覆盖：
```
// Overwrite the call's compression algorithm to DEFLATE.
context.set_compression_algorithm(GRPC_COMPRESS_DEFLATE);
```

在服务器端，通过服务器构建器（server builder）设置缺省压缩算法。
```
ServerBuilder builder;
// Set the default compression algorithm for the server.
builder.SetDefaultCompressionAlgorithm(GRPC_COMPRESS_GZIP);
```
每次调用的压缩配置可以用服务端context覆盖：
```
// Overwrite the call's compression algorithm to DEFLATE.
context->set_compression_algorithm(GRPC_COMPRESS_DEFLATE);
```

关于可工作的例子，请参见[greeter_client.cc](https://github.com/grpc/grpc/blob/master/examples/cpp/compression/greeter_client.cc) 和 [greeter_server.cc](https://github.com/grpc/grpc/blob/master/examples/cpp/compression/greeter_server.cc)。
### 编译运行
运行下面的命令来构建并运行（压缩）客户端与服务器端：
```
make
./greeter_server
```

```
./greeter_client
```

## Reference
- [gRPC (Core) Compression Cookbook](https://github.com/grpc/grpc/blob/master/doc/compression_cookbook.md)
- [gRPC Compression](https://github.com/grpc/grpc/blob/master/doc/compression.md)
- [gRPC C++ Message Compression Tutorial](https://github.com/grpc/grpc/tree/master/examples/cpp/compression)