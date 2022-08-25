# Kerberos 工具

## KDC 节点

### kadmin.local（需要在KDC上使用）

- 进入 kadmin.local
  ```
  [root@hpg-admin01 ~]# kadmin.local
  Authenticating as principal hdfs/admin@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM with password.
  kadmin.local:
  ```
- 列出所有 principals
  ```
  kadmin.local:  list_principals
  ...
  carolus_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
  ......
  ```
- 添加 principal
  ```
  kadmin.local:  add_principal sam@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
  ```
- 重命名 principal
  ```
  kadmin.local:  rename_principal sam@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM sam_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
  ```
- 删除 principal
  ```
  kadmin.local:  delete_principal sam_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
  ```
- 修改密码
  ```
  kadmin.local:  change_password -pw hadoop ret_admin_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
  Password for "ret_admin_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM" changed.    (hadoop)
  ```
- 向 keytab 添加条目
  ```
  kadmin: ktadd -k /tmp/foo-new-keytab host/foo.mit.edu
  Entry for principal host/foo.mit.edu@ATHENA.MIT.EDU with kvno 3,
     encryption type aes256-cts-hmac-sha1-96 added to keytab
     FILE:/tmp/foo-new-keytab
  ```
- 从 keytab 删除条目
  ```
  kadmin: ktremove kadmin/admin all
  Entry for principal kadmin/admin with kvno 3 removed from keytab
     FILE:/etc/krb5.keytab
  ```
- 退出
  ```
  kadmin.local:  quit
  ```

## 客户端节点

### 登录

- 使用 keytab
  ```
  Kinit -kt /opt/Kraken/conf/keytab/kraken.keytab carolus_K
  ```
- 使用密码
  ```
  [root@hpg-feeds01 ~]# kinit hdfs
  Password for hdfs@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM:
  ```

### 检查当前授权 Kerberos 用户

```
[root@hpg-feeds01 ~]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: carolus_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
Valid starting     Expires            Service principal
04/28/16 20:03:17  04/29/16 20:03:17  krbtgt/KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM
        renew until 05/05/16 20:03:17
```

### 退出当前 Kerberos 用户

```
[root@hpg-admin02 ~]# kdestroy
```

### ktutil

1. 生成 keytab
```
[root@hpg-app02 ~]# ktutil
ktutil:  add_entry -password -p ret_admin_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM -k 1 -e aes256-cts
Password for ret_admin_K@KRAKENNYBETA.CIS.HADOOP.INT.THOMSONREUTERS.COM:    (hadoop)
ktutil:   write_kt /opt/Kraken/conf/keytab/kraken_ret.keytab
```

## Reference

- [Kerberos Tools](https://confluence.refinitiv.com/display/KRAKEN/Kerberos+Tools)