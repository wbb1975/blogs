# 在 CDP 集群启用 Kerberos 手册

## 一. 文档编写目的

本文档讲述如何在 CDP 集群启用及配置 Kerberos，您将学习到以下知识：

- 如何安装及配置 KDC 服务
- 如何通过 CDP 启用 Kerberos
- 如何登录 Kerberos 并访问 Hadoop 相关服务

## 二. 文档内容

文档主要分为以下几步：

1. 安装及配置 KDC 服务
2. CDP 集群启用 Kerberos
3. Kerberos 使用

## 三. 假设前提

这篇文档将重点介绍如何在 CDP 集群启用及配置 Kerberos，并基于以下假设：

1. CDP 集群运行正常
2. 集群未启用 Kerberos
3. MySQL 5.1.73

## 四. 测试环境

以下是本次测试环境，但不是本操作手册的必需环境：

- 操作系统：CentOS 7.9
- CDP 版本为7.1.7.0
- CM 版本为7.4.4
- 采用 root 用户进行操作

## 五. Kerberos协议

Kerberos 协议主要用于计算机网络的身份鉴别(Authentication), 其特点是用户只需输入一次身份验证信息就可以凭借此验证获得的票据(ticket-granting ticket)访问多个服务，即 SSO(Single Sign On)。由于在每个 `Client` 和 `Service` 之间建立了共享密钥，使得该协议具有相当的安全性。

## 六. KDC 服务安装及配置

本文档中将 KDC 服务安装在 `Cloudera Manager Server` 所在[服务器](https://cloud.tencent.com/product/cvm?from=10680)上（KDC 服务可根据自己需要安装在其他服务器）

### 6.1 在 Cloudera Manager 服务器上安装 KDC 服务

```
[root@cdp-utility-1 ~]# yum -y install krb5-server krb5-libs krb5-auth-dialog krb5-workstation
```

#### 6.1.1 修改/etc/krb5.conf 配置

```
[root@cdp-utility-1 ~]# vim etc/krb5.conf

# Configuration snippets may be placed in this directory as well
includedir etc/krb5.conf.d/

[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
dns_lookup_realm = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = true       ## 特别注意，默认是false
pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
default_realm = ALIBABA.COM
# default_ccache_name = KEYRING:persistent:%{uid}  ## 特别注意，需要注释掉

[realms]
ALIBABA.COM = {
  kdc = cdp-utility-1.c-bd97232d18624d20
  admin_server = cdp-utility-1.c-bd97232d18624d20
}

[domain_realm]
.cdp-utility-1.c-bd97232d18624d20 = ALIBABA.COM
cdp-utility-1.c-bd97232d18624d20 = ALIBABA.COM
```

**说明**：

- **[logging]**：表示server端的日志的打印位置
- **[libdefaults]**：每种连接的默认配置，需要注意以下几个关键的小配置：
  + default_realm = ALIBABA.COM 默认的realm，必须跟要配置的realm的名称一致。
  + udp_preference_limit = 1 禁止使用udp可以防止一个Hadoop中的错误
  + ticket_lifetime 表明凭证生效的时限，一般为24小时。
  + renew_lifetime 表明凭证最长可以被延期的时限，一般为一个礼拜。当凭证过期之后，对安全认证的服务的后续访问则会失败。
- **[realms]**: 列举使用的realm
  + kdc：代表要kdc的位置。格式是 机器:端口
  + admin_server:代表admin的位置。格式是机器:端口
  + default_domain：代表默认的域名
- **[appdefaults]**: 可以设定一些针对特定应用的配置，覆盖默认配置

**标红部分为需要修改的信息**：

![krb5.conf 配置修改](images/modb_20210927_04607b96-1f63-11ec-95ce-00163e068ecd.png)

#### 6.1.2 修改 /var/kerberos/krb5kdc/kadm5.acl 配置

```
[root@cdp-utility-1 ~]# vim /var/kerberos/krb5kdc/kadm5.acl
*/admin@ALIBABA.COM    *
```

代表名称匹配 `*/admin@ALIBABA.COM` 都认为是 `admin`，权限是 `*`。代表全部权限。

### 6.1.3 修改 /var/kerberos/krb5kdc/kdc.conf 配置

```
[root@cdp-utility-1 ~]# vim var/kerberos/krb5kdc/kdc.conf

[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
ALIBABA.COM= {
  #master_key_type = aes256-cts
  max_renewable_life= 7d 0h 0m 0s
  acl_file = var/kerberos/krb5kdc/kadm5.acl
  dict_file = usr/share/dict/words
  admin_keytab = var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
}
```

**说明**：

- ALIBABA.COM: 是设定的 realms，名字随意。Kerberos 可以支持多个realms，会增加复杂度，本文不探讨。大小写敏感，一般为了识别使用全部大写。这个 realms 跟机器的 host 没有大关系。
- max_renewable_life = 7d 涉及到是否能进行 ticket 的 renew 必须配置。
- master_key_type:和supported_enctypes 默认使用 `aes256-cts`。由于 JAVA 使用 `aes256-cts` 验证方式需要安装额外的jar包(jce-policy)。
- acl_file: 标注了admin 的用户权限。文件格式是：
  + Kerberos_principal permissions [target_principal] [restrictions]支持通配符等。
  + admin_keytab:KDC 进行校验的keytab。后文会提及如何创建。
- supported_enctypes: 支持的校验方式。

**标红部分为需要修改的配置**：

![kdc.conf 配置修改](images/modb_20210927_04d1c94a-1f63-11ec-95ce-00163e068ecd.png)

#### 6.1.4 创建Kerberos数据库

```
[root@cdp-utility-1 ~]# kdb5_util create –r ALIBABA.COM -s
Loading random data
Initializing database '/var/kerberos/krb5kdc/principal' for realm 'ALIBABA.COM',
master key name 'K/M@ALIBABA.COM'
You will be prompted for the database Master Password.
It is important that you NOT FORGET this password.
Enter KDC database master key:
Re-enter KDC database master key to verify:
[root@cdp-utility-1 ~]#
```

此处需要输入Kerberos数据库的密码。

- 其中，[-s]表示生成 `stash file`，并在其中存储 `master server key（krb5kdc）`；还可以用 `[-r]` 来指定一个 `realm name` —— 当 `krb5.conf` 中定义了多个 realm 时才是必要的。
- 保存路径为 `/var/kerberos/krb5kdc` 如果需要重建数据库，将该目录下的 `principal` 相关的文件删除即可
- 在此过程中，我们会输入 database 的管理密码。这里设置的密码一定要记住，如果忘记了，就无法管理 `Kerberos server`。

当 `Kerberos database` 创建好后，可以看到目录 `/var/kerberos/krb5kdc` 下生成了几个文件：

```
kadm5.acl
kdc.conf
principal
principal.kadm5
principal.kadm5.lock
principal.ok
```

![Kerberos database files](images/modb_20210927_055f79de-1f63-11ec-95ce-00163e068ecd.png)

#### 6.1.5 创建Kerberos的管理账号

```
[root@cdp-utility-1 ~]# kadmin.local
Authenticating as principal root/admin@ALIBABA.COM with password.
kadmin.local:  addprinc admin/admin@ALIBABA.COM
WARNING: no policy specified for admin/admin@ALIBABA.COM; defaulting to no policy
Enter password for principal "admin/admin@ALIBABA.COM":
Re-enter password for principal "admin/admin@ALIBABA.COM":
Principal "admin/admin@ALIBABA.COM" created.
kadmin.local:  exit
[root@cdp-utility-1 ~]#
```

#### 6.1.6 添加自服务并启动

将Kerberos服务添加到自启动服务，并启动krb5kdc和kadmin服务：

```
[root@cdp-utility-1 cloudera-scm-server]# systemctl enable kadmin
Created symlink from /etc/systemd/system/multi-user.target.wants/kadmin.service to /usr/lib/systemd/system/kadmin.service.
[root@cdp-utility-1 cloudera-scm-server]# systemctl enable krb5kdc
[root@cdp-utility-1 cloudera-scm-server]# systemctl restart krb5kdc
[root@cdp-utility-1 cloudera-scm-server]# systemctl restart kadmin
[root@cdp-utility-1 cloudera-scm-server]#
```

#### 6.1.7 测试Kerberos的管理员账号

```
[root@cdp-utility-1 ~]# kinit admin/admin@ALIBABA.COM
Password for admin/admin@ALIBABA.COM:
[root@cdp-utility-1 ~]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: admin/admin@ALIBABA.COM


Valid starting       Expires              Service principal
2021-09-11T10:35:01  2021-09-12T10:35:01  krbtgt/ALIBABA.COM@ALIBABA.COM
  renew until 2021-09-18T10:35:01
[root@cdp-utility-1 ~]#
```

### 6.2 为集群安装所有 Kerberos 客户端，包括 `Cloudera Manager Server`

```
[root@cdp-master-1 ~]# yum -y install krb5-libs krb5-workstation
```

### 6.3 在 `Cloudera Manager Server` 服务器上安装额外的包

```
[root@cdp-utility-1 ~]# yum -y install openldap-clients
```

### 6.4 将 `KDC Server` 上的 `krb5.conf` 文件拷贝到所有 Kerberos 客户端

```
[root@cdp-utility-1 ~]# scp -r /etc/krb5.conf 192.168.2.26:/etc/krb5.conf
```

此处使用脚本进行拷贝：

```
[root@cdp-utility-1 ~]# for i in {26..29}; do scp -r /etc/krb5.conf 192.168.2.$i:/etc/krb5.conf ; done
krb5.conf                                  100%  705     2.2MB/s   00:00
krb5.conf                                  100%  705     1.6MB/s   00:00
krb5.conf                                  100%  705     2.0MB/s   00:00
krb5.conf                                  100%  705     2.0MB/s   00:00
[root@cdp-utility-1 ~]#
```

## 七. CDP 集群启用 Kerberos

## 八. Kerberos使用

## 九. 常见问题

## Reference

- [在 CDP 集群启用 Kerberos 手册](https://www.modb.pro/db/115753)
- [在 CDP 集群启用 Kerberos 手册](https://cloud.tencent.com/developer/article/1886263)
