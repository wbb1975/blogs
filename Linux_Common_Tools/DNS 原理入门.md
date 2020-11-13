# DNS 原理入门
## 一、DNS 是什么？
DNS （Domain Name System 的缩写）的作用非常简单，就是根据域名查出IP地址。你可以把它想象成一本巨大的电话本。

举例来说，如果你要访问域名`math.stackexchange.com`，首先要通过DNS查出它的IP地址是`151.101.129.69`。

如果你不清楚为什么一定要查出IP地址，才能进行网络通信，建议先阅读阮一峰写的[《互联网协议入门》](http://www.ruanyifeng.com/blog/2012/05/internet_protocol_suite_part_i.html)。
## 二、查询过程
虽然只需要返回一个IP地址，但是DNS的查询过程非常复杂，分成多个步骤。

工具软件dig可以显示整个查询过程。
```
$ dig math.stackexchange.com
```
上面的命令会输出六段信息：
```
c005mkkbjde03:/data/ThomsonReuters/quantum_framework # dig www.google.com

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> www.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37202
;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 4, ADDITIONAL: 9

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.google.com.			IN	A

;; ANSWER SECTION:
www.google.com.		300	IN	A	172.217.212.104
www.google.com.		300	IN	A	172.217.212.103
www.google.com.		300	IN	A	172.217.212.99
www.google.com.		300	IN	A	172.217.212.106
www.google.com.		300	IN	A	172.217.212.105
www.google.com.		300	IN	A	172.217.212.147

;; AUTHORITY SECTION:
google.com.		170171	IN	NS	ns2.google.com.
google.com.		170171	IN	NS	ns1.google.com.
google.com.		170171	IN	NS	ns3.google.com.
google.com.		170171	IN	NS	ns4.google.com.

;; ADDITIONAL SECTION:
ns2.google.com.		170171	IN	A	216.239.34.10
ns2.google.com.		170171	IN	AAAA	2001:4860:4802:34::a
ns1.google.com.		170171	IN	A	216.239.32.10
ns1.google.com.		170171	IN	AAAA	2001:4860:4802:32::a
ns3.google.com.		170171	IN	A	216.239.36.10
ns3.google.com.		170171	IN	AAAA	2001:4860:4802:36::a
ns4.google.com.		170171	IN	A	216.239.38.10
ns4.google.com.		170171	IN	AAAA	2001:4860:4802:38::a

;; Query time: 11 msec
;; SERVER: 155.46.26.17#53(155.46.26.17)
;; WHEN: Tue Oct 27 00:59:24 UTC 2020
;; MSG SIZE  rcvd: 387
```
第一段是查询参数和统计：
```
; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> www.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37202
;; flags: qr rd ra; QUERY: 1, ANSWER: 6, AUTHORITY: 4, ADDITIONAL: 9
```
第二段是查询内容：
```
;; QUESTION SECTION:
;www.google.com.			IN	A
```
上面结果表示，查询域名`www.google.com`的A记录，A是`address`的缩写。

第三段是DNS服务器的答复：
```
;; ANSWER SECTION:
www.google.com.		300	IN	A	172.217.212.104
www.google.com.		300	IN	A	172.217.212.103
www.google.com.		300	IN	A	172.217.212.99
www.google.com.		300	IN	A	172.217.212.106
www.google.com.		300	IN	A	172.217.212.105
www.google.com.		300	IN	A	172.217.212.147
```
上面结果显示，`www.google.com`有六个`A`记录，即六个IP地址。`300`是`TTL`值（Time to live 的缩写），表示缓存时间，即`300`秒之内不用重新查询。

第四段显示`www.google.com`的`NS`记录（Name Server的缩写），即哪些服务器负责管理`www.google.com`的DNS记录：
```
;; AUTHORITY SECTION:
google.com.		170171	IN	NS	ns2.google.com.
google.com.		170171	IN	NS	ns1.google.com.
google.com.		170171	IN	NS	ns3.google.com.
google.com.		170171	IN	NS	ns4.google.com.
```
上面结果显示`www.google.com`共有四条`NS`记录，即四个域名服务器，向其中任一台查询就能知道`www.google.com`的IP地址是什么。

第五段是上面四个域名服务器的IP地址，这是随着前一段一起返回的：
```
;; ADDITIONAL SECTION:
ns2.google.com.		170171	IN	A	216.239.34.10
ns2.google.com.		170171	IN	AAAA	2001:4860:4802:34::a
ns1.google.com.		170171	IN	A	216.239.32.10
ns1.google.com.		170171	IN	AAAA	2001:4860:4802:32::a
ns3.google.com.		170171	IN	A	216.239.36.10
ns3.google.com.		170171	IN	AAAA	2001:4860:4802:36::a
ns4.google.com.		170171	IN	A	216.239.38.10
ns4.google.com.		170171	IN	AAAA	2001:4860:4802:38::a
```
第六段是DNS服务器的一些传输信息：
```
;; Query time: 11 msec
;; SERVER: 155.46.26.17#53(155.46.26.17)
;; WHEN: Tue Oct 27 00:59:24 UTC 2020
;; MSG SIZE  rcvd: 387
```
上面结果显示，本机的DNS服务器是155.46.26.17，查询端口是53（DNS服务器的默认端口），以及回应长度是387字节。

如果不想看到这么多内容，可以使用+short参数。
```
c005mkkbjde03:/data/ThomsonReuters/quantum_framework # dig +short www.google.com
108.177.111.99
108.177.111.105
108.177.111.104
108.177.111.147
108.177.111.103
108.177.111.106
```
上面命令只返回`www.google.com`对应的6个IP地址（即A记录）。
## 三、DNS服务器
下面我们根据前面这个例子，一步步还原，本机到底怎么得到域名`www.google.com`的IP地址。

首先，本机一定要知道DNS服务器的IP地址，否则上不了网。通过DNS服务器，才能知道某个域名的IP地址到底是什么。

![DNS Server List](images/dns_server.jpg)

DNS服务器的IP地址，有可能是动态的，每次上网时由网关分配，这叫做`DHCP`机制；也有可能是事先指定的固定地址。Linux系统里面，DNS服务器的IP地址保存在`/etc/resolv.conf`文件。

上例的DNS服务器是`192.168.1.253`，这是一个内网地址。有一些公网的DNS服务器，也可以使用，其中最有名的就是`Google`的`8.8.8.8`和`Level 3`的`4.2.2.2`。

本机只向自己的DNS服务器查询，dig命令有一个@参数，显示向其他DNS服务器查询的结果。
```
$ dig @4.2.2.2 math.stackexchange.com
```
上面命令指定向DNS服务器4.2.2.2查询。
## 四、域名的层级
DNS服务器怎么会知道每个域名的IP地址呢？答案是分级查询。

请仔细看前面的例子，每个域名的尾部都多了一个点。
```
;; QUESTION SECTION:
;www.google.com.			IN	A
```
比如，域名`www.google.com`显示为`www.google.com.`。这不是疏忽，而是所有域名的尾部，实际上都有一个根域名。

举例来说，`www.example.com`真正的域名是`www.example.com.root`，简写为`www.example.com.`。因为，根域名`.root`对于所有域名都是一样的，所以平时是省略的。

根域名的下一级，叫做"顶级域名"（top-level domain，缩写为TLD），比如`.com`、`.net`；再下一级叫做"次级域名"（second-level domain，缩写为SLD），比如`www.example.com`里面的.`example`，这一级域名是用户可以注册的；再下一级是主机名（host），比如`www.example.com`里面的`www`，又称为"三级域名"，这是用户在自己的域里面为服务器分配的名称，是用户可以任意分配的。

总结一下，域名的层级结构如下：
```
主机名.次级域名.顶级域名.根域名

# 即

host.sld.tld.root
```
## 五、根域名服务器
DNS服务器根据域名的层级，进行分级查询。

需要明确的是，每一级域名都有自己的NS记录，NS记录指向该级域名的域名服务器。这些服务器知道下一级域名的各种记录。

所谓"分级查询"，就是从根域名开始，依次查询每一级域名的NS记录，直到查到最终的IP地址，过程大致如下：
1. 从"根域名服务器"查到"顶级域名服务器"的NS记录和A记录（IP地址）
2. 从"顶级域名服务器"查到"次级域名服务器"的NS记录和A记录（IP地址）
3. 从"次级域名服务器"查出"主机名"的IP地址

仔细看上面的过程，你可能发现了，没有提到DNS服务器怎么知道"根域名服务器"的IP地址。回答是"根域名服务器"的NS记录和IP地址一般是不会变化的，所以内置在DNS服务器里面。

下面是内置的根域名服务器IP地址的一个例子:

![根域名服务器IP地址](images/root_dnsserver.png)

上面列表中，列出了根域名（`.root`）的三条NS记录`A.ROOT-SERVERS.NET`、`B.ROOT-SERVERS.NET`和`C.ROOT-SERVERS.NET`，以及它们的IP地址（即`A`记录）`198.41.0.4`、`192.228.79.201`、`192.33.4.12`。

另外，可以看到所有记录的TTL值是`3600000`秒，相当于1000小时。也就是说，每1000小时才查询一次根域名服务器的列表。

目前，世界上一共有十三组根域名服务器，从`A.ROOT-SERVERS.NET`一直到`M.ROOT-SERVERS.NET`。
## 六、分级查询的实例
dig命令的+trace参数可以显示DNS的整个分级查询过程。
```
$ dig +trace www.google.com
```

上面命令的第一段列出根域名.的所有NS记录，即所有根域名服务器：
```
c005mkkbjde03:/data/ThomsonReuters/quantum_framework # dig +trace www.google.com

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-16.P2.el7_8.6 <<>> +trace www.google.com
;; global options: +cmd
.			504669	IN	NS	g.root-servers.net.
.			504669	IN	NS	a.root-servers.net.
.			504669	IN	NS	c.root-servers.net.
.			504669	IN	NS	d.root-servers.net.
.			504669	IN	NS	k.root-servers.net.
.			504669	IN	NS	b.root-servers.net.
.			504669	IN	NS	m.root-servers.net.
.			504669	IN	NS	j.root-servers.net.
.			504669	IN	NS	l.root-servers.net.
.			504669	IN	NS	h.root-servers.net.
.			504669	IN	NS	e.root-servers.net.
.			504669	IN	NS	f.root-servers.net.
.			504669	IN	NS	i.root-servers.net.
;; Received 811 bytes from 155.46.26.17#53(155.46.26.17) in 0 ms
```
根据内置的根域名服务器IP地址，DNS服务器向所有这些IP地址发出查询请求，询问www.google.com的顶级域名服务器com.的NS记录。最先回复的根域名服务器将被缓存，以后只向这台服务器发请求。

接着是第二段：

![com NS records](images/top_dns_servers.png)

上面结果显示`.com`域名的13条NS记录，同时返回的还有每一条记录对应的IP地址。

然后，DNS服务器向这些顶级域名服务器发出查询请求，询问`math.stackexchange.com`的次级域名`stackexchange.com`的NS记录：

![次级域名服务器列表](images/secondary_dns_servers.png)
`
然后，DNS服务器向上面这四台NS服务器查询`math.stackexchange.com`的主机名。

![DNS记录列表](images/leaf_dns_server.png)

上面结果显示，`math.stackexchange.com`有4条A记录，即这四个IP地址都可以访问到网站。并且还显示，最先返回结果的NS服务器是`ns-463.awsdns-57.com`，IP地址为`205.251.193.207`。
## 七、NS 记录的查询
dig命令可以单独查看每一级域名的NS记录。
```
$ dig ns com
$ dig ns stackexchange.com
```

+short参数可以显示简化的结果。
```
$ dig +short ns com
$ dig +short ns stackexchange.com
```
## 八、DNS的记录类型
域名与IP之间的对应关系，称为"记录"（record）。根据使用场景，"记录"可以分成不同的类型（type），前面已经看到了有`A`记录和`NS`记录。

常见的DNS记录类型如下：
- A：地址记录（Address），返回域名指向的IP地址。
- NS：域名服务器记录（Name Server），返回保存下一级域名信息的服务器地址。该记录只能设置为域名，不能设置为IP地址。
- MX：邮件记录（Mail eXchange），返回接收电子邮件的服务器地址。
- CNAME：规范名称记录（Canonical Name），返回另一个域名，即当前查询的域名是另一个域名的跳转，详见下文。
- PTR：逆向查询记录（Pointer Record），只用于从IP地址查询域名，详见下文。

一般来说，为了服务的安全可靠，至少应该有两条`NS`记录，而`A`记录和`MX`记录也可以有多条，这样就提供了服务的冗余性，防止出现单点失败。

`CNAME`记录主要用于域名的内部跳转，为服务器配置提供灵活性，用户感知不到。举例来说，`facebook.github.io`这个域名就是一个`CNAME`记录。
```
$ dig facebook.github.io

...

;; ANSWER SECTION:
facebook.github.io. 3370    IN  CNAME   github.map.fastly.net.
github.map.fastly.net.  600 IN  A   103.245.222.133
```

上面结果显示，`facebook.github.io`的`CNAME`记录指向`github.map.fastly.net`。也就是说，用户查询`facebook.github.io`的时候，实际上返回的是`github.map.fastly.net`的IP地址。这样的好处是，变更服务器IP地址的时候，只要修改`github.map.fastly.net`这个域名就可以了，用户的`facebook.github.io`域名不用修改。

由于`CNAME`记录就是一个替换，所以域名一旦设置`CNAME`记录以后，就不能再设置其他记录了（比如`A`记录和`MX`记录），这是为了防止产生冲突。举例来说，`foo.com`指向`bar.com`，而两个域名各有自己的`MX`记录，如果两者不一致，就会产生问题。由于顶级域名通常要设置`MX`记录，所以一般不允许用户对顶级域名设置`CNAME`记录。

`PTR`记录用于从IP地址反查域名。dig命令的`-x`参数用于查询`PTR`记录：
```
$ dig -x 192.30.252.153

...

;; ANSWER SECTION:
153.252.30.192.in-addr.arpa. 3600 IN    PTR pages.github.com.
```
上面结果显示，192.30.252.153这台服务器的域名是pages.github.com。

逆向查询的一个应用，是可以防止垃圾邮件，即验证发送邮件的IP地址，是否真的有它所声称的域名。

dig命令可以查看指定的记录类型：
```
$ dig a github.com
$ dig ns github.com
$ dig mx github.com
```
## 九、其他DNS工具
除了dig，还有一些其他小工具也可以使用：
- host 命令
  `host`命令可以看作`dig`命令的简化版本，返回当前请求域名的各种记录：
  ```
  $ host github.com

  github.com has address 192.30.252.121
  github.com mail is handled by 5 ALT2.ASPMX.L.GOOGLE.COM.
  github.com mail is handled by 10 ALT4.ASPMX.L.GOOGLE.COM.
  github.com mail is handled by 10 ALT3.ASPMX.L.GOOGLE.COM.
  github.com mail is handled by 5 ALT1.ASPMX.L.GOOGLE.COM.
  github.com mail is handled by 1 ASPMX.L.GOOGLE.COM.

  $ host facebook.github.com

  facebook.github.com is an alias for github.map.fastly.net.
  github.map.fastly.net has address 103.245.222.133
  ```
  `host`命令也可以用于逆向查询，即从IP地址查询域名，等同于`dig -x <ip>`。
  ```
  $ host 192.30.252.153

  153.252.30.192.in-addr.arpa domain name pointer pages.github.com.
  ```
- nslookup 命令
  `nslookup`命令用于互动式地查询域名记录：
  ```
  $ nslookup

  > facebook.github.io
  Server:     192.168.1.253
  Address:    192.168.1.253#53

  Non-authoritative answer:
  facebook.github.io  canonical name = github.map.fastly.net.
  Name:   github.map.fastly.net
  Address: 103.245.222.133

  > 
  ```
- whois 命令
  `whois`命令用来查看域名的注册情况。
  ```
  $ whois github.com
  ```

## Reference
- [DNS 原理入门](http://www.ruanyifeng.com/blog/2016/06/dns.html)
- [DNS: The Good Parts](https://www.petekeen.net/dns-the-good-parts), by Pete Keen
- [DNS 101, by Mark McDonnell](http://www.integralist.co.uk/posts/dnsbasics.html)
- [在线域名检测](https://mxtoolbox.com/DnsLookup.aspx)