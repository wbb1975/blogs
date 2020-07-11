# HTTP/2 with curl
[HTTP/2规范](https://www.rfc-editor.org/rfc/rfc7540.txt) [http2解析](https://daniel.haxx.se/http2/)
## 构建前提（Build prerequisites）
+ nghttp2
+ 一个足够新的版本的OpenSSL, libressl, BoringSSL, NSS, GnutTLS, mbedTLS, wolfSSL 或 Schannel
### [nghttp2](https://nghttp2.org/)
libcurl采用第三方库来作为自己的底层协议处理部分，原因在于HTTP/2在协议层比HTTP/1.1（这是我们自己实现的）要复杂得多，并且nghttp2是一个已经存在的工作良好的库，

我们要求至少版本1.12.0。
## 通过http:// URL
如果CURLOPT_HTTP_VERSION被设置为CURL_HTTP_VERSION_2_0，libcurl将在发给主机的初始请求中包含升级头部（upgrade），允许升级到HTTP/2。

稍后我们可能引入一个选项：如果libcurl无法升级则会失败。可能我们也会引入一个选项让libcurl通过http://会立即使用HTTP/2。
## 通过https:// URL
如果CURLOPT_HTTP_VERSION被设置为CURL_HTTP_VERSION_2_0，libcurl将会使用ALPN (或 NPN)来协商接下来将使用的协议。我们可能引入一个选项：如果libcurl无法使用HTTP/2则会失败。

在7.47.0中CURL_HTTP_VERSION_2TLS被加入，它会要求libcurl对HTTPS优选HTTP/2，但对老的HTTP链接则坚持使用缺省的1.1。

ALPN是一个TLS扩展，HTTP/2期待会使用。NPN扩展用于同样目的，但它早于ALPN，且主要被SPDY使用，因此在ALPN被大规模支持前，许多早起HTTP/2服务器使用NPN。

CURLOPT_SSL_ENABLE_ALPN 和 CURLOPT_SSL_ENABLE_NPN被提供以允许应用显式禁用ALPN或NPN。
## SSL库
挑战在于ALPN 和 NPN支持以及各种不同的SSL后端。你可能需要一个足够新的SSL版本以便于它提供了足够多的TLS特性。目前我们支持：
- OpenSSL: ALPN 和 NPN
- libressl: ALPN 和 NPN
- BoringSSL: ALPN 和 NPN
- NSS: ALPN 和 NPN
- GnuTLS: ALPN
- mbedTLS: ALPN
- Schannel: ALPN
- wolfSSL: ALPN
- Secure Transport: ALPN
## 多路复用（Multiplexing）
从7.43.0开始，libcurl完全支持HTTP/2多路复用，这个术语用于指代通过同一物理TCP连接进行多个独立的数据传送。

为了利用多路复用，你需要利用多接口（interface），并设置CURLMOPT_PIPELINING选项为CURLPIPE_MULTIPLEX。这个位被设置后，libcurl将会尝试复用已有的HTTP/2连接，并添加一个新的流用于稍后的并行请求。

当libcurl与一个HTTP服务器建立了连接后，有一段时间，如果你添加传送任务，libcurl并不知道它能够使用流水线（pipeline ）或多路复用（multiplexing）。利用新的CURLOPT_PIPEWAIT（7.43.0加入）选项，你可以要求传送等待，以检查进行中的与同一主机连接是否可以使用多路复用。它有助于降低连接总数，代价就在于需要更长时间才能开始真正的数据传送。
## 应用
我们隐藏了HTTP/2的二进制属性，并将收到的HTTP/2数据转换为HTTP 1.1风格的头。这允许应用不用修改就能工作。
### curl工具
curl提供了--http2命令行选项以启用HTTP/2

curl提供了--http2-prior-knowledge命令行选项以启用HTTP/2而无需借助HTTP/1.1升级。

从7.47.0开始，curl工具缺省地对HTTPS连接启用HTTP/2。
### curl工具限制
即使libcurl支持多路复用命令行工具也不会从事任何HTTP/2多路复用。仅仅因为curl工具并不是为了利用libcurl API的这些特行（多接口）而编写的。我们有一个很出色的针对这个特性的TODO项，你可以帮助我们实现它。

基于它不做多路复用同样的原因，命令行工具也不支持HTTP/2 服务器端推送。它需要使用多接口特性（multi interface）以支持多路复用。
### HTTP可选服务（HTTP Alternative Services）
可选服务是HTTP/2中对应框架（ALTSVC）的一个扩展，它告诉客户端关于源自你接收回复的服务器的同样内容的另一条路由。一个浏览器或一个长时运行的苦户端可以利用这个提示来异步创建一个新的连接。对于libcurl，我们可能会引入一种方式来将这个提示带入应用，让接下来的请求可以自动使用该可选路由。

## Reference
- [HTTP/2 with curl](https://curl.haxx.se/docs/http2.html)
- [HTTP/2 Frequently Asked Questions](https://http2.github.io/faq/)
- [http2讲解](https://github.com/bagder/http2-explained/tree/master/zh)