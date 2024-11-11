# GNU Simple Authentication and Security Layer 2.2.1

## 1 介绍

1.1 SASL 概述

SASL 是一个框架，许多应用协议如 SMTP， IMAP使用它来提供认证支持。例如，当你访问一个 IAM 服务器来读取邮件时 SASL 用于向服务器证明你是谁。

SASL 框架并未指定执行认证的技术，那是每个 SASL 机制的职责。流行的 SASL 机制包括 `CRAM-MD5` 和 `GSSAPI (用于 Kerberos V5)`。

典型地一个 SASL 协商工作如下。首先客户请求认证（可能在连接到服务器时隐藏地）。服务端回复给出了一个支持的机制列表。客户端选择其中一种机制。然后客户端与服务端交换数据，一次一个往返，直至认证成功或者失败。之后客户端和服务端对于谁在通道两侧都了解得更多。

例如，一个 SMTP 通讯过程如下：

```
250-mail.example.com Hello pc.example.org [192.168.1.42], pleased to meet you
250-AUTH DIGEST-MD5 CRAM-MD5 LOGIN PLAIN
250 HELP
AUTH CRAM-MD5
334 PDk5MDgwNDEzMDUwNTUyMTE1NDQ5LjBAbG9jYWxob3N0Pg==
amFzIDBkZDRkODZkMDVjNjI4ODRkYzc3OTcwODE4ZGI5MGY3
235 2.0.0 OK Authenticated
```

这里头三行由服务器端发送，它包含了一个支持的机制的列表（如 DIGEST-MD5, CRAM-MD5，等）。下一行有客户端发送选择了 CRAM-MD5。服务器回复了一个挑战，它是一个可以通过调用 GNU SASL 函数产生的消息。客户端做了回复，它也是一个可以通过调用 GNU SASL 函数产生的消息。依赖于机制，可能有更多的通讯往返，所以不要假设所有的认证交换仅仅包含一条服务端消息和一条客户端消息。服务端接受了认证。在那个时间点它知道它正在与一个认证过的客户端交谈，然后应用协议可以继续。

重要的是，你的应用负责更具一个特定规范实现框架协议（例如 SMTP 或 XMPP）。应用使用 GNU SASL 来产生认证消息。

## 2 准备

## 3 使用库

## 4 属性

## 5 机制

## 6 全局函数

## 7 回调函数

## 8 属性函数

## 9 会话函数

## 10 实用工具

## 11 内存处理

## 12 错误出路

## 13 示例

## 14 声明

## 15 调用 gsasl

## Appendix A 协议澄清

## Appendix B 版权信息

## Reference

- [GNU Simple Authentication and Security Layer 2.2.1](https://www.gnu.org/software/gsasl/manual/html_node/index.html)
- [Introduction to Simple Authentication Security Layer (SASL)](https://docs.oracle.com/cd/E23824_01/html/819-2145/sasl.intro.20.html)