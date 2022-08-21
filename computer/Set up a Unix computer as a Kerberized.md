# Set up a Unix computer as a Kerberized application server

在 Kerberos 中，一个应用服务器可以通过几个公共网络协议支持 Kerberized 的访问，比如 [telnet](https://kb.iu.edu/d/aayd) 或 `rlogin`。利用一个 Kerberized 客户端，你可以安全地连接到一个一个应用服务器：你的密码并不需要通过网络传输，而且你能够加密你的会话。

> 注意：因为 [UITS](https://kb.iu.edu/d/ahaw) 并不建议新手去设置一个应用服务器，这个文档假设你习惯[Unix](https://kb.iu.edu/d/agat)。这些指令仅仅适用于 Kerberos 5。

为了在 Indiana 大学将一个 Unix 计算机设置为一个应用服务器：

1. 从 MIThttps://web.mit.edu/ 下载最新版本 Kerberos http://web.mit.edu/kerberos/www/。点击最新 Kerberos 发布链接，并阅读相关如何检索 Kerberos 源代码的指令。
2. 源代码以 tar 包的形式提供，包含 Kerberos 发布及其 PGP 签名。发布是一个以 GNU Zip 压缩的 tar 归档文件。
3. 解压压缩包并解包发布文件。这将创建一个名为 krb5-[version] 的目录，这里 [version] 是发布的 patch 号（例如，1.2.5）。
4. 为了查看安装 Kerberos 的指令，切换到 doc 目录（位于顶级发布目录）。安装指南拥有几种格式，包括 HTML 和 PostScript。
5. 创建 /etc/krb5.conf 文件和一个 /etc/krb5.keytab 文件。
6. 为了设置应用服务器，阅读安装指南。你很可能需要修改的两个文件是 /etc/services 和 /etc/inetd.conf。关于这个发布包含的 Kerberized 客户端如何工作的信息，参考用户指南，它与安装指南在同一目录下。

## Reference

- [Set up a Unix computer as a Kerberized application server](https://kb.iu.edu/d/ahkb)
- [Use a keytab](https://kb.iu.edu/d/aumh)