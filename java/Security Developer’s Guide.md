# Security Developer’s Guide

## 10 Java SASL API Programming and Deployment Guide

简单认证和安全层，或称为 SASL 是一个互联网标准（[RFC 2222](http://www.ietf.org/rfc/rfc2222.txt)），它指定了在客户端和服务器端之间进行授权或可选地建立一个安全层的协议。 SASL 定义了认证数据如何交互，但它自身并不指定认证数据的内容。它是一个框架，指定了认证数据的内容和语义的特定认证机制能够适配它。

SASL 被许多协议如[轻量级目录访问协议版本3(LDAP v3)](http://www.ietf.org/rfc/rfc2251.txt)，[互联网消息访问协议版本4 (IMAP v4)](http://www.ietf.org/rfc/rfc2060.txt)等用于启用可插拔认证。LDAP v3 和 IMAP v4 使用 SASL 来执行认证，因此可以通过多种 SASL 机制来开启认证，从而在协议中避免硬编码一种认证方法。

互联网协会已经为各种级别的安全和开发场景定义了许多标准 SASL 机制，它们涵盖从无安全需求（例如匿名认证）至最高安全需求（例如 Kerberos 认证）的各种级别安全需求。

### The Java SASL API

### 什么时候使用 SASL

### Java SASL API 简介

### SASL 机制如何被安装及被选中

### SunSASL 提供者

### JdkSASL 提供者

### 调试和监控

### 实现一个 SASL 安全提供者

## Reference

- [Security Developer’s Guide](https://docs.oracle.com/en/java/javase/21/security/index.html)
- [10 Java SASL API Programming and Deployment Guide](https://docs.oracle.com/en/java/javase/21/security/java-sasl-api-programming-and-deployment-guide1.html)