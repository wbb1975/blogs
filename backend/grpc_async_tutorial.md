# gRPC 异步API指南
本指南告诉你如何使用 gRPC 的异步/非堵塞 APIs 来写C++版本的服务端和客户端应用。它假设你如同[基础指南](https://grpc.io/docs/languages/android/basics/)描述的已经对撰写同步 gRPC 代码非常熟悉。本指南使用的例子遵从[开始入门](https://grpc.io/docs/languages/cpp/quickstart/)里的[基础 Greeter 示例](https://github.com/grpc/grpc/tree/v1.34.1/examples/cpp/helloworld)，你可以在[grpc/examples/cpp/helloworld](https://github.com/grpc/grpc/tree/v1.34.1/examples/cpp/helloworld)找到代码以及其安装指令。
## 概览
gRPC 为异步操作使用了 [CompletionQueue](https://grpc.io/grpc/cpp/classgrpc_1_1_completion_queue.html) API，其基本工作流如下：
- 为一个RPC调用绑定一个CompletionQueue
- 做某些事情例如读或写，当前需要一个唯一void*标记。
- 调用CompletionQueue::Next等待操作完成。如果一个标记出现，它只是对应操作已经完成。
## 异步客户端
为了使用一个异步客户来调用一个远程方法，首先你需要创建一个channel 和 stub，就如你在[同步客户端](https://github.com/grpc/grpc/blob/v1.34.1/examples/cpp/helloworld/greeter_client.cc)里所做的一样。一旦你有了你的stub，你做下面的操作来进行一个异步调用：
- 初始化 RPC 并为其创建一个句柄。将该 RPC 绑定到一个 `CompletionQueue`：
  ```
  CompletionQueue cq;
  std::unique_ptr<ClientAsyncResponseReader<HelloReply> > rpc(
      stub_->AsyncSayHello(&context, request, &cq));
  ```
- 带有一个唯一标记请求回复和结束状态，
  ```
  Status status;
  rpc->Finish(&reply, &status, (void*)1);
  ```
- 等到完成队列返回下一个标记。一旦传进对应 `Finish()` 调用的唯一标记返回则回复和状态已经准备好。
  ```
  void* got_tag;
  bool ok = false;
  cq.Next(&got_tag, &ok);
  if (ok && got_tag == (void*)1) {
    // check reply and status
  }
  ```
你可以从[greeter_async_client.cc](https://github.com/grpc/grpc/blob/v1.34.1/examples/cpp/helloworld/greeter_async_client.cc)看到客户端示例的完整代码。
## 异步服务器
服务器实现带一个标记请求一个RPC 调用，然后等待完成对列返回该标记。异步处理一个 RPC 的基本流程如下：
- 构建一个服务器暴露异步服务
  ```
  helloworld::Greeter::AsyncService service;
  ServerBuilder builder;
  builder.AddListeningPort("0.0.0.0:50051", InsecureServerCredentials());
  builder.RegisterAsyncService(&service);
  auto cq = builder.AddCompletionQueue();
  auto server = builder.BuildAndStart();
  ```
- 请求一个RPC，提供一个唯一标记
  ```
  ServerContext context;
  HelloRequest request;
  ServerAsyncResponseWriter<HelloReply> responder;
  service.RequestSayHello(&context, &request, &responder, &cq, &cq, (void*)1);
  ```
- 等待完成对列返回该标记。一旦标记被检索到，则上下文，请求及应答器都已经准备好。
  ```
  HelloReply reply;
  Status status;
  void* got_tag;
  bool ok = false;
  cq.Next(&got_tag, &ok);
  if (ok && got_tag == (void*)1) {
    // set reply and status
    responder.Finish(reply, status, (void*)2);
  }
  ```
- 等待完成对列返回该标记。当标记返回时 RPC 已经结束。
  ```
  oid* got_tag;
  bool ok = false;
  cq.Next(&got_tag, &ok);
  if (ok && got_tag == (void*)2) {
    // clean up
  }
  ```
但是，这个基本流程并没有考虑服务器处理多个并发请求。为了处理这个，我们的完整异步服务器示例使用了一个 `CallData` 对象来维护每个 RPC 的状态，并使用这个对象的地址作为调用的唯一标记。
```
class CallData {
public:
  // Take in the "service" instance (in this case representing an asynchronous
  // server) and the completion queue "cq" used for asynchronous communication
  // with the gRPC runtime.
  CallData(Greeter::AsyncService* service, ServerCompletionQueue* cq)
      : service_(service), cq_(cq), responder_(&ctx_), status_(CREATE) {
    // Invoke the serving logic right away.
    Proceed();
  }

  void Proceed() {
    if (status_ == CREATE) {
      // As part of the initial CREATE state, we *request* that the system
      // start processing SayHello requests. In this request, "this" acts are
      // the tag uniquely identifying the request (so that different CallData
      // instances can serve different requests concurrently), in this case
      // the memory address of this CallData instance.
      service_->RequestSayHello(&ctx_, &request_, &responder_, cq_, cq_,
                                this);
      // Make this instance progress to the PROCESS state.
      status_ = PROCESS;
    } else if (status_ == PROCESS) {
      // Spawn a new CallData instance to serve new clients while we process
      // the one for this CallData. The instance will deallocate itself as
      // part of its FINISH state.
      new CallData(service_, cq_);

      // The actual processing.
      std::string prefix("Hello ");
      reply_.set_message(prefix + request_.name());

      // And we are done! Let the gRPC runtime know we've finished, using the
      // memory address of this instance as the uniquely identifying tag for
      // the event.
      responder_.Finish(reply_, Status::OK, this);
      status_ = FINISH;
    } else {
      GPR_ASSERT(status_ == FINISH);
      // Once in the FINISH state, deallocate ourselves (CallData).
      delete this;
    }
  }
}
```
为了简化为所有事件仅仅使用一个完成对列，在 `HandleRpcs` 中运行一个主循环来查询队列：
```
void HandleRpcs() {
  // Spawn a new CallData instance to serve new clients.
  new CallData(&service_, cq_.get());
  void* tag;  // uniquely identifies a request.
  bool ok;
  while (true) {
    // Block waiting to read the next event from the completion queue. The
    // event is uniquely identified by its tag, which in this case is the
    // memory address of a CallData instance.
    cq_->Next(&tag, &ok);
    GPR_ASSERT(ok);
    static_cast<CallData*>(tag)->Proceed();
  }
}
```
## 停止服务
我们使用一个完成对列来得到异步通知。当服务器也被停止之后我们必须小心停止该队列。

记住我们通过在 `ServerImpl::Run()`中运行 `cq_ = builder.AddCompletionQueue()` 来得到我们的完成对列实例 `cq_`。看看 `ServerBuilder::AddCompletionQueue` 的文档我们会发现：
> ……调用方需要在停止返回的完成对列之前停止服务器

参考 `ServerBuilder::AddCompletionQueue` 的完整文档来获得更多细节。它意味着爱我们的例子中 `ServerImpl` 的析构函数如下：
```
~ServerImpl() {
  server_->Shutdown();
  // Always shutdown the completion queue after the server.
  cq_->Shutdown();
}
```

服务器的完整源代码可在[greeter_async_server.cc](https://github.com/grpc/grpc/blob/v1.34.1/examples/cpp/helloworld/greeter_async_server.cc)找到。

## Reference
- [gRPC 异步API指南](https://grpc.io/docs/languages/cpp/async/)
