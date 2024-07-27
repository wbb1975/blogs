# Installing KDCs

## 术语

术语|翻译|解释
-------|-------|--------
KDC|密钥分发中心|KDC具有分发 ticket 的功能，被称为密钥分发中心(Key Distribution Center)，或者简称为 KDC。因为它整个在一个物理的服务器上，其中包含三个组件：**principal 数据库;认证服务器(Authentication Server);票据分发服务器(Ticket Granting Server)**
realm|认证管理域|每一个 realm 都有着不同的认证方案。这个认证方案使用 /var/kerberos/krb5kdc/kdc.conf 来配置。realm 的名字是大小写敏感的。
principal|（身份）标识|一个 Principal 代表着唯一的身份标识，KDC 中数据库中存储的数据就是 Principal。**一个Principal可以代表一个特定realm的用户或者服务**。
Ticket Granting Ticket|票据授予票据|TGT：这是 KDC 中的 Authentication Server(简称AS) 产生的，TGT 是向 Ticket Granting Server(TGS) 用于表明自己真实身份的东西
Service Ticket|服务授予票据|这是 KDC 中的 Ticket Granting Server(简称TGS) 产生的，Service Ticket 是用于向应用服务器表明自己身份的东西


## 前言

当在一个产品环境设置 Kerberos 时，最好除一个主 KDC 外部署多个 KDC 副本以确保 Kerberos 化服务的高可用性。每个 KDC 包含一套 Kerberos 数据库。主 KDC 包含 realm 数据库的一个可写拷贝，它被定期同步到副本 KDC 上。所有数据库修改（例如密码变化）在主 KDC 上做出。副本 KDC 提供 Kerberos 票据授予服务（ticket-granting services），但不包括数据库管理，当主 KDC 不可用时，MIT 建议你将所有 KDC 安装为主 KDC 或一个副本 KDC。这使在必要（参见[切换主 KDC 和副本 KDC](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html#switch-primary-replica)）时切换主 KDC 到一个副本 KDC 上时变得容易。

> 警告：
> - Kerberos 系统依赖正确时间信息的可用性。确保主 KDC 和所有副本 KDC 拥有正确同步的时钟。
> - 最好在一个安全且专用硬件上安装和运行 KDC，该硬件应该拥有受限访问权限，如果你的 KDC 还是一个文件服务器，FTP 服务器, Web server, 甚至它还是一个客户端机器，一旦有人通过上述邻域的安全漏洞获取到了 root 访问权限，那它潜在就可能获取了 Kerberos 数据库的访问权限。
>

## 安装并配置主 KDC（Install and configure the primary KDC）

从操作系统提供的包或从源代码（参见[从单一源代码树构建](https://web.mit.edu/kerberos/krb5-devel/doc/build/doing_build.html#do-build)）安装 Kerberos。

> 注意：
> 基于本文目的，我们将使用下面的名字：
> 
> kerberos.mit.edu    - primary KDC
> 
> kerberos-1.mit.edu  - replica KDC
> 
> ATHENA.MIT.EDU      - realm name
> 
> .k5.ATHENA.MIT.EDU  - stash file
> 
> admin/admin         - admin principal
>
> 参见[MIT Kerberos 默认值](https://web.mit.edu/kerberos/krb5-devel/doc/mitK5defaults.html#mitk5defaults)可了解本主题相关文件的默认名字和位置。调整名字和路径以适应你的系统环境。

### 编辑 KDC 配置文件

修改配置文件 [krb5.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/krb5_conf.html#krb5-conf-5) 和 [kdc.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/kdc_conf.html#kdc-conf-5) 以反映你的 realm 的正确信息（如域名 realm 的映射，Kerberos 服务器名字），参见[MIT Kerberos 默认值](https://web.mit.edu/kerberos/krb5-devel/doc/mitK5defaults.html#mitk5defaults)可了解这些文件的推荐默认位置。

配置里的大部分标签拥有可良好工作于大部分站点的默认值。但在 [krb5.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/krb5_conf.html#krb5-conf-5) 有一些标签必须显式指定值--这一章节将解释这些。

如果这些配置文件位于与默认值不同的位置，设置 **KRB5_CONFIG** 和 **KRB5_KDC_PROFILE** 环境变量来分别指向 `krb5.conf` 和 `kdc.conf`，例如：

```
export KRB5_CONFIG=/yourdir/krb5.conf
export KRB5_KDC_PROFILE=/yourdir/kdc.conf
```

#### krb5.conf

如果你不打算使用 DNS TXT records（参见[将主机名映射为Kerberos realms](https://web.mit.edu/kerberos/krb5-devel/doc/admin/realm_config.html#mapping-hostnames)），你必须在 [libdefaults] 节里指定 default_realm。如果你不使用DNS URI or SRV records (参见 [KDCs 主机名](https://web.mit.edu/kerberos/krb5-devel/doc/admin/realm_config.html#kdc-hostnames) 和 [KDC 发现](https://web.mit.edu/kerberos/krb5-devel/doc/admin/realm_config.html#kdc-discovery)), 你必须在 [realms] 节为每一个realm 指定 kdc tag。为了与每一个 realm 的 kadmin server 通信，必须在 [realms] 节里指定 admin_server 标签。

一个 krb5.conf 实例：

```
[libdefaults]
    default_realm = ATHENA.MIT.EDU

[realms]
    ATHENA.MIT.EDU = {
        kdc = kerberos.mit.edu
        kdc = kerberos-1.mit.edu
        admin_server = kerberos.mit.edu
    }
```

#### kdc.conf

kdc.conf 用于控制 KDC 和 kadmind 的监听端口，也包括 realm 特定默认配置，数据库类型及位置，以及日志。

一个 kdc.conf 示例：

```
[kdcdefaults]
    kdc_listen = 88
    kdc_tcp_listen = 88

[realms]
    ATHENA.MIT.EDU = {
        kadmind_port = 749
        max_life = 12h 0m 0s
        max_renewable_life = 7d 0h 0m 0s
        master_key_type = aes256-cts
        supported_enctypes = aes256-cts:normal aes128-cts:normal
        # If the default location does not suit your setup,
        # explicitly configure the following values:
        #    database_name = /var/krb5kdc/principal
        #    key_stash_file = /var/krb5kdc/.k5.ATHENA.MIT.EDU
        #    acl_file = /var/krb5kdc/kadm5.acl
    }

[logging]
    # By default, the KDC and kadmind will log output using
    # syslog.  You can instead send log output to files like this:
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
```

将 `ATHENA.MIT.EDU` 和 `kerberos.mit.edu` 分别替换为你的 Kerberos realm 和服务器名字。

> 注意：你必须对 **database_name**, **key_stash_file**, 和 **acl_file** 文件所在目录（这些目录必须存在）有可写权限。

## 创建 KDC 数据库

你将使用主 KDC 上的[kdb5_util](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kdb5_util.html#kdb5-util-8) 命令来创建 Kerberos 数据库及可选的 [stash 文件](https://web.mit.edu/kerberos/krb5-devel/doc/basic/stash_file_def.html#stash-definition)。

> 注意：如果你选择不安装 stash 文件，KDC 在其每次启动时都要提示输入 master key。这意味着 KDC 不能自动启动，比如在一次系统重启后。

[kdb5_util](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kdb5_util.html#kdb5-util-8) 将提示你输入用于 Kerberos 数据库的master 密码。这个密码可以是任意字符串。一个好的密码是你能够记得，但别的人却不能猜到。坏的密码的例子包括字典里的单词，任何常见和流行的名字，尤其是一个名人（或卡通人物），任何形式的你的名字（例如顺序，倒序，重复两次等），这篇手册里的任意密码等。没有出现在本手册里的一个好的密码示例是 “MITiys4K5!”，它代表句子 “MIT is your source for Kerberos 5!” (它是每个单词的首字母，将单词 “for” 用数字 “4” 代替并在最后加上了叹号)。

下面是一个在主 KDC 上使用[kdb5_util](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kdb5_util.html#kdb5-util-8) 命令创建Kerberos 数据库和 stash 文件的例子。将 ATHENA.MIT.EDU 替换为你的 Kerberos realm 名字：

```
shell% kdb5_util create -r ATHENA.MIT.EDU -s

Initializing database '/usr/local/var/krb5kdc/principal' for realm 'ATHENA.MIT.EDU',
master key name 'K/M@ATHENA.MIT.EDU'
You will be prompted for the database Master Password.
It is important that you NOT FORGET this password.
Enter KDC database master key:  <= Type the master password.
Re-enter KDC database master key to verify:  <= Type it again.
shell%
```

这将在 **LOCALSTATEDIR/krb5kdc**（或者在 kdc.conf 中指定的位置） 下创建五个文件：

- 两个 Kerberos 数据库文件，principal, 和 principal.ok
- Kerberos 管理数据库文件，principal.kadm5
- 管理数据库锁文件，principal.kadm5.lock
- stash 文件, 本例中为 .k5.ATHENA.MIT.EDU。如果你不想要一个 stash 文件, 不要 -s 选项运行上面的命令。

关于管理 Kerberos 数据库的更多信息，参见 [Kerberos 数据库操作](https://web.mit.edu/kerberos/krb5-devel/doc/admin/database.html#db-operations)。 

## 向 ACL 文件添加管理员

接下来，你需要创建一个访问控制列表(ACL) 文件，并添加至少一个管理员的 Kerberos principal。这个文件被 [kadmind](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kadmind.html#kadmind-8) 守护进程用于控制谁可以查看并对 Kerberos 数据库文件做特权修改。ACL 文件名由 [kdc.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/kdc_conf.html#kdc-conf-5) 中的 `acl_file` 变量确定，默认为 `LOCALSTATEDIR/krb5kdc/kadm5.acl`。

关于 Kerberos ACL 文件的详细信息，请参见 [kadm5.acl](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/kadm5_acl.html#kadm5-acl-5)。

## 添加 Kerberos 数据库管理员

接下来你需要添加 Kerberos 数据库管理员 principals（例如，被允许管理 Kerberos 数据库的 principals）。现在你必须至少添加一个 principals 以允许 Kerberos 管理守护进程 kadmind 和 kadmin 程序的相互网络通信以便于进一步管理。为了实现这个，在主 KDC 上使用 `kadmin.local` 工具。 `kadmin.local` 被设计为在主 KDC 主机上运行无需使用对管理服务器的 Kerberos 认证。作为替代，它必须拥有对本地文件系统之上的 Kerberos 数据库的读写权限。

你创建的管理员 principals 应该是你添加到 ACL 文件的那个（参见[向 ACL 文件添加管理员](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html#admin-acl)）。

在下面的例子中，管理员 principals `admin/admin` 被创建：

```
shell% kadmin.local

kadmin.local: addprinc admin/admin@ATHENA.MIT.EDU

No policy specified for "admin/admin@ATHENA.MIT.EDU";
assigning "default".
Enter password for principal admin/admin@ATHENA.MIT.EDU:  <= Enter a password.
Re-enter password for principal admin/admin@ATHENA.MIT.EDU:  <= Type it again.
Principal "admin/admin@ATHENA.MIT.EDU" created.
kadmin.local:
```

## 在主 KDC 上启动 Kerberos 守护进程

在这个点上我们可以在主 KDC 上启动 Kerberos KDC ([krb5kdc](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/krb5kdc.html#krb5kdc-8)) 和管理守护进程了。为了实现这个，输入下面的内容：

```
shell% krb5kdc
shell% kadmind
```

每个服务器守护进程将 fork 并在后台运行。

> 注意：如果你期待这些守护进程在系统启动时自动运行，你可以将它们添加到主 KDC 的 `/etc/rc` 或 `/etc/inittab` 文件。你需要有一个 [stash 文件](https://web.mit.edu/kerberos/krb5-devel/doc/basic/stash_file_def.html#stash-definition) 以实现这个需求。

你可以从 [krb5.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/krb5_conf.html#krb5-conf-5) (see [logging](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/kdc_conf.html#logging)) 定义的日志位置检查它们的启动信息来验证它们是正常启动了。例如：

```
shell% tail /var/log/krb5kdc.log
Dec 02 12:35:47 beeblebrox krb5kdc[3187](info): commencing operation
shell% tail /var/log/kadmin.log
Dec 02 12:35:52 beeblebrox kadmind[3189](info): starting
```

守护进程启动中遇到的任何错误也会被打印到日志输出中。一个额外的验证，使用 [kinit](https://web.mit.edu/kerberos/krb5-devel/doc/user/user_commands/kinit.html#kinit-1) 检查你在之前步骤（[添加 Kerberos 数据库管理员](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html#addadmin-kdb)）创建的 principals 能否成功，运行：

```
shell% kinit admin/admin@ATHENA.MIT.EDU
```

## 安装副本 KDCs

现在你可以开始配置你的副本 KDC 了。

> 注意：假设你已经设置了主 KDCs 如此你可以很容易在主 KDC 和你的任一副本 KDC 之间切换。你应该把在主 KDC 上执行的步骤在副本 KDC 上再执行一遍，除非这些指令被显式告知不需执行。

### 为副本 KDC 创建主机 keytabs

每个 KDC 在  Kerberos 需要一个 `host` key。这些键用于在将主 KDC 的数据库转储文件传播到 secondary KDC 服务器的过程中的相互认证。

在主 KDC 上，连接到管理界面并为每个 KDC 的 `host` 服务创建 host principal。例如，如果主 KDC 称之为 kerberos.mit.edu，并且你拥有一个副本 KDC 名为 kerberos-1.mit.edu，你应该输入下面的内容：

```
shell% kadmin
kadmin: addprinc -randkey host/kerberos.mit.edu
No policy specified for "host/kerberos.mit.edu@ATHENA.MIT.EDU"; assigning "default"
Principal "host/kerberos.mit.edu@ATHENA.MIT.EDU" created.

kadmin: addprinc -randkey host/kerberos-1.mit.edu
No policy specified for "host/kerberos-1.mit.edu@ATHENA.MIT.EDU"; assigning "default"
Principal "host/kerberos-1.mit.edu@ATHENA.MIT.EDU" created.
```

严格来讲，主 KDC 服务器并不需要出现在 Kerberos 数据库中，但它在切换主从 KDC 时会带来便利。

接下来，为所有需要传播的 KDC 抽取 `host` 随机 key，并将它们存储到每个主机的默认 keytab 文件中。理想地你应该从自己的 KDC 上本地抽取 keytab 文件。如果这不可行，你应该使用一个加密会话跨网络传送它们。在一个叫做 `kerberos-1.mit.edu` 的副本 KDC 上直接抽取 keytab 文件，你将执行下面的命令：

```
kadmin: ktadd host/kerberos-1.mit.edu
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type aes256-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type aes128-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type aes256-cts-hmac-sha384-192 added to keytab FILE:/etc/krb5.keytab.
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type arcfour-hmac added to keytab FILE:/etc/krb5.keytab.
```

如果你是在主 KDC 上为名为 `kerberos-1.mit.edu` 的副本 KDC 抽取 keytab 文件，你应该使用一个专用临时 keytab 文件。

```
kadmin: ktadd -k /tmp/kerberos-1.keytab host/kerberos-1.mit.edu
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type aes256-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
Entry for principal host/kerberos-1.mit.edu with kvno 2, encryption
    type aes128-cts-hmac-sha1-96 added to keytab FILE:/etc/krb5.keytab.
```

在主机 `kerberos-1.mit.edu` 上 `/tmp/kerberos-1.keytab` 可以被安装为 `/etc/krb5.keytab`。

### 配置副本 KDCs （Configure replica KDCs）

数据库传播拷贝主 KDC 数据库的内容，但并不传播配置文件。stash 文件以及 `kadm5 ACL` 文件。下面的文件必须被手动拷贝到每个副本上（参见 [MIT Kerberos 默认值](https://web.mit.edu/kerberos/krb5-devel/doc/mitK5defaults.html#mitk5defaults)以了解本这些文件的默认位置）：

- krb5.conf
- kdc.conf
- kadm5.acl
- master key stash file

将这些文件移到合适的目录下，要和主 KDC 上的一样。`kadm5.acl` 只有在允许当前副本 KDC 与主 KDC 互换角色时才需要。

数据库通过 [kpropd](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kpropd.html#kpropd-8) 守护进程从主 KDC 传播到副本 KDC。你必须显式指定一个 principals，它允许在副本 KDC 上为 Kerberos 新的数据库提供转储更新。在 `KDC state` 目录下创建一个名为 `kpropd.acl` 的文件包含每个 KDC 的 `host principals`。

```
host/kerberos.mit.edu@ATHENA.MIT.EDU
host/kerberos-1.mit.edu@ATHENA.MIT.EDU
```

> 注意：如果你期待主从 KDC 能够在同一时间点切换，在所有 KDC 上的 `kpropd.acl` 文件中理出所有参与的 KDC 的 `host principals`。否则，你只需要在副本 KDC 的 `kpropd.acl` 中列出主 KDC 的 `host principals`。

然后，在每个 KDC（调整o kpropd 路径） 上添加下面的命令到 /etc/inetd.conf：

```
krb5_prop stream tcp nowait root /usr/local/sbin/kpropd kpropd
```

如果它们不存在（假设默认端口被使用），你还需要将下面的行添加到每个 KDC 的 `/etc/services` 中：

```
krb5_prop       754/tcp               # Kerberos replica propagation
```

重启 inetd 守护进程。

可选地，将 [kpropd](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kpropd.html#kpropd-8) 作为一个独立守护进程启动。当增量传播开启时这是需要的。

现在副本 KDC 可以接受数据库传播，你需要从主 KDC 传播数据库。

> 注意：现在请不要启动副本 KDC；因此你现在有没有主数据库的拷贝。

### 传播数据库到每个副本 KDC（Propagate the database to each replica KDC）

首先，在主 KDC 上创建一个数据库转储文件，如下所示：

```
shell% kdb5_util dump /usr/local/var/krb5kdc/replica_datatrans
```

加下来，收到将数据库传播到每个副本 KDC 上，如下所示：

```
shell% kprop -f /usr/local/var/krb5kdc/replica_datatrans kerberos-1.mit.edu

Database propagation to kerberos-1.mit.edu: SUCCEEDED
```

你将需要一个脚本来转储和传播数据库，下面是一个包含了该功能的 bash 脚本。

> 注意：记得你需要将 `/usr/local/var/krb5kdc` 替换为 `KDC state` 目录的名字。

```
#!/bin/sh

kdclist = "kerberos-1.mit.edu kerberos-2.mit.edu"

kdb5_util dump /usr/local/var/krb5kdc/replica_datatrans

for kdc in $kdclist
do
    kprop -f /usr/local/var/krb5kdc/replica_datatrans $kdc
done
```

你需要设置一个定时任务在一个你决定的规定间隔的早些时候运行这个脚本（参见[数据库传播](https://web.mit.edu/kerberos/krb5-devel/doc/admin/realm_config.html#db-prop)）。

现在副本 KDC 拥有了 Kerberos 数据库的一份拷贝，你可以启动 krb5kdc 守护进程：

```
shell% krb5kdc
```

和主 KDC 一样，你可能想将这个命令添加到 `/etc/rc` 或 `/etc/inittab` 文件，如此它们将在系统启动时自动启动 krb5kdc 守护进程。

### 传播失败

你可能遇到下面的错误消息，关于可能原因及解决方案的详细讨论，请点击错误链接，它们将被导向到[错误诊断](https://web.mit.edu/kerberos/krb5-devel/doc/admin/troubleshoot.html#troubleshoot)章节。

1. [kprop: No route to host while connecting to server](https://web.mit.edu/kerberos/krb5-devel/doc/admin/troubleshoot.html#kprop-no-route)
2. [kprop: Connection refused while connecting to server](https://web.mit.edu/kerberos/krb5-devel/doc/admin/troubleshoot.html#kprop-con-refused)
3. [kprop: Server rejected authentication (during sendauth exchange) while authenticating to server](https://web.mit.edu/kerberos/krb5-devel/doc/admin/troubleshoot.html#kprop-sendauth-exchange)

## 添加数据库 Kerberos principals

一旦你的 KDC 已经建立并正常运行，你已经准备好使用 [kadmin](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kadmin_local.html#kadmin-1) 来为你的用户，主机，或其它服务向你的 Kerberos 数据库里添加 principals。这一过程在 [Principal](shttps://web.mit.edu/kerberos/krb5-devel/doc/admin/database.html#principals) 被详细描述。 

你可能偶尔期待把你的一个副本 KDC 当主 KDC 使用，比如，当你升级你的主 KDC 时，或者你的主 KDC 磁盘崩溃了。参考下面的章节以了解详细指令。

## 切换主从 KDCs

你可能偶尔期待把你的一个副本 KDC 当主 KDC 使用，这可能当你升级你的主 KDC 时，或者你的主 KDC 磁盘崩溃了会呈现。

假设你已经配置好你所有的 KDC，它们或者作为一个主 KDC 或一个副本 KDC，你所有需要操作的步骤包括：

如果主 KDC 仍在运行，在老的主 KDC 上执行下面的操作：

1. 杀死 kadmind 进程
2. 禁用传播数据库的定时任务
3. 手动运行你的数据库传播脚本，确保副本 KDC 拥有了数据库的最新拷贝（参见[将数据库传播至每个副本 KDC](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html#kprop-to-replicas)）。

在新的 主 KDC 上：

1. 启动 [kadmind](https://web.mit.edu/kerberos/krb5-devel/doc/admin/admin_commands/kadmind.html#kadmind-8) 守护进程。
2. 设置定时任务去传播数据库（参见[将数据库传播至每个副本 KDC](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html#kprop-to-replicas)）
3. 切换新老 KDC 的 CNAMEs。如果你不做这个，你需要修改你的 Kerberos Realm 中的每个客户机器的 [krb5.conf](https://web.mit.edu/kerberos/krb5-devel/doc/admin/conf_files/krb5_conf.html#krb5-conf-5)。

## 增量数据库传播（Incremental database propagation）

如果你期待你的 Kerberos 数据库变得更大，你可能期待设置到副本 KDC 的增量传播。参考[增量数据库传播](https://web.mit.edu/kerberos/krb5-devel/doc/admin/database.html#incr-db-prop)以获得更多细节。


## Reference

- [Installing KDCs](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html)