# JSON Web Token 入门教程
JSON Web Token（缩写 JWT）是目前最流行的跨域认证解决方案，本文介绍它的原理和用法。
![JSON Web Token](images/JWT.jpg)
## 一、跨域认证的问题
互联网服务离不开用户认证。一般流程是下面这样：
1、用户向服务器发送用户名和密码。
2、服务器验证通过后，在当前对话（session）里面保存相关数据，比如用户角色、登录时间等等。
3、服务器向用户返回一个 session_id，写入用户的 Cookie。
4、用户随后的每一次请求，都会通过 Cookie，将 session_id 传回服务器。
5、服务器收到 session_id，找到前期保存的数据，由此得知用户的身份。

这种模式的问题在于，扩展性（scaling）不好。单机当然没有问题，如果是服务器集群，或者是跨域的服务导向架构，就要求 `session` 数据共享，每台服务器都能够读取 `session`。

举例来说，`A` 网站和 `B` 网站是同一家公司的关联服务。现在要求，用户只要在其中一个网站登录，再访问另一个网站就会自动登录，请问怎么实现？

一种解决方案是 `session` 数据持久化，写入数据库或别的持久层。各种服务收到请求后，都向持久层请求数据。这种方案的优点是架构清晰，缺点是工程量比较大。另外，持久层万一挂了，就会单点失败。

另一种方案是服务器索性不保存 `session` 数据了，所有数据都保存在客户端，每次请求都发回服务器。`JWT` 就是这种方案的一个代表。
## 二、JWT 的原理
JWT 的原理是，服务器认证以后，生成一个 `JSON` 对象，发回给用户，就像下面这样：
```
{
  "姓名": "张三",
  "角色": "管理员",
  "到期时间": "2018年7月1日0点0分"
}
```
以后，用户与服务端通信的时候，都要发回这个 `JSON` 对象。服务器完全只靠这个对象认定用户身份。为了防止用户篡改数据，服务器在生成这个对象的时候，会加上签名（详见后文）。

服务器就不保存任何 `session` 数据了，也就是说，服务器变成无状态了，从而比较容易实现扩展。
## 三、JWT 的数据结构
实际的 JWT 大概就像下面这样：
![JWT 的数据结构](images/jwt_structure.jpg)

它是一个很长的字符串，中间用点（.）分隔成三个部分。注意，JWT 内部是没有换行的，这里只是为了便于展示，将它写成了几行。

JWT 的三个部分依次如下：
- Header（头部）
- Payload（负载）
- Signature（签名）

写成一行，就是下面的样子：
```
Header.Payload.Signature
```
![Three Parts](images/jwt_three_parts.jpg)

下面依次介绍这三个部分：
### Header
### Payload
### Signature
## 四、JWT 的使用方式
## 五、JWT 的几个特点

## Reference
- [JSON Web Token 入门教程](http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html)
- [Introduction to JSON Web Tokens](https://jwt.io/introduction/)， by Auth0
- [Sessionless Authentication using JWTs (with Node + Express + Passport JS)](https://medium.com/@bryanmanuele/sessionless-authentication-withe-jwts-with-node-express-passport-js-69b059e4b22c), by Bryan Manuele
- [Learn how to use JSON Web Tokens](https://github.com/dwyl/learn-json-web-tokens/blob/master/README.md), by dwyl