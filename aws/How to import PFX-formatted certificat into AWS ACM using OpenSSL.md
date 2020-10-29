# How to import PFX-formatted certificates into AWS Certificate Manager using OpenSSL
在本文中，我将向你展示如何利用OpenSSL将PFX格式的证书导入到[AWS Certificate Manager (ACM)](http://aws.amazon.com/acm) 中。

安全套接字层（Secure Sockets Layer）和传输层安全Transport Layer Security (SSL/TLS)证书是小型数据文件，它数字的把一对加密密钥与一个机构的字节绑定。密钥对（ key pair）用于安全网络通讯，为互联网和私有网络上的网站建立标识。证书通常由信任证书颁发机构（CA）颁发，一个CA像一个受信任的第三方那样运作--被证书所有者和证书的依赖方共同信任。这些证书的格式由 [X.509](https://en.wikipedia.org/wiki/X.509)或 [Europay, Mastercard, and Visa (EMV)](https://en.wikipedia.org/wiki/EMV#EMV_certificates) 标准指定。 由受信证书颁发机构发布的证书通常用个人信息交换（Personal Information Exchange (PFX)） 或个人强化邮件（Privacy-Enhanced Mail (PEM)）格式编码。



## Reference
- [How to import PFX-formatted certificates into AWS Certificate Manager using OpenSSL](https://aws.amazon.com/blogs/security/how-to-import-pfx-formatted-certificates-into-aws-certificate-manager-using-openssl/)
- [How to use *.pfx certificate for Amazon ELB SSL](https://stackoverflow.com/questions/36156917/how-to-use-pfx-certificate-for-amazon-elb-ssl)
- [SSL证书（SSL Certificates）]](https://www.aliyun.com/sswd/1110408-1.html)