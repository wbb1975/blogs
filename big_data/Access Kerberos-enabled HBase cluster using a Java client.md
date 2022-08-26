# 使用一个 Java 客户端访问开启了 Kerberos 的 HBase 集群

你可以使用一个 Java 客户端访问开启了 Kerberos 的 HBase 集群。

## 开始之前

- 开启了 Kerberos 的 HDP 集群
- 你工作于一个  Java 8, Maven 3 和 Eclipse 的工作环境
- 你拥有管理员权限可以访问 Kerberos KDC

执行下面的任务以使用 Java 客户端以连接 HBase 并对一个表执行简单的 Put 操作。

## 下载配置

遵循下面的步骤以下载必须的配置。

1. 从 Ambari 抽取  HBase 和 HDFS 文件到 conf 目录，这里将保存所有的配置细节。这些文件必须从 **\$HBASE_CONF_DIR** 目录抽取；**\$HBASE_CONF_DIR** 是保存 HBase 配置文件的目录，例如 `/etc/hbase/conf`。
2. 从 KDC 下载 krb5.conf 文件。
   ```
   includedir /etc/krb5.conf.d/

    [logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

    [libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    default_realm = HWFIELD.COM
    default_ccache_name = KEYRING:persistent:%{uid}

    [realms]
    HWFIELD.COM = {
        kdc = ambud-hdp-3.field.hortonworks.com
        admin_server = ambud-hdp-3.field.hortonworks.com
    }

    [domain_realm]
    .hwfield.com = HWFIELD.COM
    hwfield.com = HWFIELD.COM
   ```

## 设置客户端账户

遵循下面的步骤来为客户端创建一个 kerberos 账号并在 HBase 中给这个账号授权，如此你才能创建，读和写表。

1. 登录进 KDC
2. 切换到 root 目录
3. 运行 kadmin.local：
4. 将 keytab 文件拷贝到 conf 目录
5. 在 HBase 中授权。更多信息，请查看 ​Configure HBase for Access Control Lists (ACL)。

   ```
   klist -k /etc/security/keytabs/hbase.headless.keytab
   ```

   可选步骤：你应该确保你的 keytab 文件安全如此仅仅 HBase 进程能够访问它。下面这个命令可以达到这个目的：
   
   ```
   $>sudo chmod 700 /etc/security/keytabs/hbase.headless.keytab
   ```

   ```
   $ kinit -kt /etc/security/keytabs/hbase.headless.keytab hbase
   $ hbase shell
   hbase(main):001:0> status
   1 active master, 0 backup masters, 4 servers, 1 dead, 1.2500 average load
   ```

6. 授予这个用户 admin 权限。你也可以自定义权限仅仅只授予它最小权限。更多信息，请参见 http://hbase.apache.org/0.94/book/hbase.accesscontrol.configuration.html#d1984e4744。

**示例**：
```
hbase(main):001:0> grant 'myself', 'C'
```

## 创建 Java 代码

遵循下面的步骤以创建 Java 客户端。

1. 启动 Eclipse
2. 创建一个简单的 Maven 项目
3. 添加 hbase-client 和 hadoop-auth 依赖。
   
   客户端使用 Hadoop UGI 工具类利用 keytab 文件来执行 Kerberos 认证。它设置上下文，如此所有的操作在 hbase-user2 安全上下文中执行。接下来，它执行必须的 HBase 操作，即 检查 / 创建表以及 Put 即 Get 操作。

   ```
   <dependencies>
    <dependency>
      <groupId>org.apache.hbase</groupId>
      <artifactId>hbase-client</artifactId>
      <version>${hbase.version}</version>
      <exclusions>
        <exclusion>
          <groupId>org.apache.hadoop</groupId>
          <artifactId>hadoop-aws</artifactId>
        </exclusion>
      </exclusions>
    </dependency>
    <dependency>
      <groupId>org.apache.hadoop</groupId>
      <artifactId>hadoop-auth</artifactId>
      <version>${hadoop.version}</version>
    </dependency>
    <dependency>
      <groupId>org.apache.hadoop</groupId>
      <artifactId>hadoop-common</artifactId>
      <version>${hadoop.version}</version>
    </dependency>
    <dependency>
    ```

4. 从一个具有反向DNS解析能力的节点执行 HBase Java 客户端代码。这是　Kerberos 认证的一部分。因此，从一个未与 HDP 集群共享同一 DNS 基础设施的及其运行会导致认证失败。
5. 为了验证你的　Kerberos 认证 / keytab / principal 确实能够工作，你能够从 Java 代码执行一次简单的 Kerberos 认证。这能够帮助你了解　Java JAAS 和 Kerberos 是如何工作的。强烈建议你使用 Maven Shade 插件或 Maven Jar 来将一个依赖打进一个 fat-client JAR。

## Reference

- [Access Kerberos-enabled HBase cluster using a Java client](https://docs.cloudera.com/HDPDocuments/HDP3/HDP-3.1.0/authentication-with-kerberos/content/access_kerberos_enabled_hbase_cluster_using_a_java_client.html)