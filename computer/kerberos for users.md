# For users

## 密码管理

你的密码是 Kerberos 验证你的身份的唯一方式。如果某人得到了你的密码，他就可以伪装成你--以你的名义发送邮件，读取，编辑甚至删除你的文件，甚至以你的身份登陆服务器--没有人能够识别出来。基于这个原因，对你来说选择一个好的密码，并保证其机密性非常重要。如果你需要授予某人对你的账号的访问权限，你可以通过 Kerberos （参见[授权访问你的账号](https://web.mit.edu/kerberos/krb5-latest/doc/user/pwd_mgmt.html#grant-access)）实现，你不应该你的密码透露给任何人，包括你的系统管理员，无论基于何种原因。你应该频繁改变你的密码，尤其当你怀疑可能有人知晓了你的密码时。

### 修改你的密码

为了修改你的 Kerberos 密码，使用 [kpasswd](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kpasswd.html#kpasswd-1) 命令行工具。你将询问你旧密码（防止有人在你不在时，靠近你的计算机并修改你的密码），并提示你输入新密码两次。（让你输入两次的原因是确保你输入了正确的密码）。例如，用户 `david` 将会操作如下：

```
shell% kpasswd
Password for david:    <- Type your old password.
Enter new password:    <- Type your new password.
Enter it again:  <- Type the new password again.
Password changed.
shell%
```

如果 `david` 输入了错误的旧密码，他将得到如下错误信息：

```
shell% kpasswd
Password for david:  <- Type the incorrect old password.
kpasswd: Password incorrect while getting initial ticket
shell%
```

如果你犯了一个小错误没有输入两次同样的新密码，你将得到如下错误信息。`kpasswd` 将会要求你重试。

```
shell% kpasswd
Password for david:  <- Type the old password.
Enter new password:  <- Type the new password.
Enter it again: <- Type a different new password.
kpasswd: Password mismatch while reading password
shell%
```

一旦你修改了你的密码，新密码需要一定时间才能传播到整个系统。依赖于你的系统如何设置，这可能话费几分钟至一个小时甚至更长时间。如果你需要在修改密码之后得到一个新的 Kerberos 票据，试试你的新密码。如果新密码不能工作，那么再试试旧密码。

### 授权访问你的账号

如果你需要授权某人登录你的账号，你可以通过 Kerberos 实现，无需告诉他人你的密码。在你的主目录下创建一个名为 [.k5login](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_config/k5login.html#k5login-5) 的文件。该文件应该包括所有你想授予其访问你的账户权限的用户 Kerberos 凭证。每个凭证必须位于一个单独行。下面是一个示例 `.k5login` 文件：

```
jennifer@ATHENA.MIT.EDU
david@EXAMPLE.COM
```

这个文件将允许用户 `jennifer` 和 `david` 使用你的用户 ID，如果他们在其各自 realms 下拥有 Kerberos 票据。如果你跨网络登录到其它主机上，你应该在每个主机上你的 .k5login 文件中包含你自己的 Kerberos 凭证。

使用一个 `.k5login` 文件比把密码给与他人要安全得多，原因在于：

- 你可以随时通过从你的 `.k5login` 文件中移除凭证的方式撤销授权；
- 虽然在一个特定主机上一个用户拥有你的账号的全部权限（如果你的 `.k5login` 文件通过 NFS 共享，则相关主机都可以访问），但该用户不能继承你的网络特权。
- Kerberos 保留了一条谁获得票据的记录，因此如果需要，系统管理员可以发现在一个特定时间谁可以使用你的用户 ID。

一个常见应用就是在 root 的主目录下常见一个 `.k5login` 文件，从而授予该文件中的所有 Kerberos 凭证对该机器具有 root 的访问权限。这允许系统管理员允许用户变成本地 root，或者远程登陆为 root，而无需给与他们 root 密码，更无需跨网络输入 root 密码。

### 密码质量验证Password quality verification

待实现。

## 票据管理

在许多系统上，Kerberos 被构建进登陆程序，当你登录是将自动获取票据。其它程序，如 `ssh`，能够转发你的票据拷贝至远程主机。这些程序的大多数在退出时将会销毁你的票据。但是，麻省建议当你使用完它们时，确保显式销毁你的票据。一种确保销毁的方式是将 [kdestroy](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kdestroy.html#kdestroy-1) 命令置入你的 `.logout` 文件中。另外， 如果你将离开你的机器一会儿，且你担心有入侵者使用你的权限，最安全的方式要么销毁你的所有票据，或者使用一个屏保锁住你的屏幕。

### Kerberos 票据属性

Kerberos 票据可以拥有各种各样的的属性。

如果一个票据是**可转发的**，那么 KDC 可以基于可转发的票据发放一个新的票据（如果必要可以带有一个不同的网络地址）。这允许认证转发而无需重新输入密码。例如，如果一个带有可转发 TGT 的用户登录进一个远程系统，KDC 可为该用户发放一个携带远程系统的网络地址的新 TGT，这允许在该远程主机的认证过程像该用户在本地登陆一样工作。

当 KDC 基于一个可转发的票据创建新的票据时，它将为该新的票据设置一个**可转发**的标记。任何基于带有可转发标记票据创建的票据也将会设置该可转发标记。

**可代理**票据与可转发票据相似，原因在于它允许服务代理客户身份。但不像可转发票据，一个可代理票据仅仅为特定服务发放。换句话说，票据授予票据不能基于一个可代理但不是可转发的票据发放。

一个**代理票据**是给予一个可代理票据发放的票据。

一个**过期票据**是一个设置了无效标记的票据。在该票据携带的开始时间之后，它可被发送给 KDC 以获取一个有效票据。

一个带有**过期标记**的票据授予票据可被用于获取过期服务票据。

**可刷新票据**可用于获取新的会话关键字而无需用户重新输入其密码。一个可刷新票据有两个过期时间，第一个是特定票据过期的时间。另一个是居于这个可刷新票据发放的任意票据最近过期时间。

一个带有 **初始标记** 的票据基于认证协议发放，而非基于一个票据授予票据。希望确保用户的密钥最近被提交以验证的应用服务器可以指定这个标记以接受新的票据。

一个**无效**票据必须被应用服务器拒绝，过期票据通常也设置了这个标记，在它们被使用前必须被 KDC 验证。

一个**预验证**票据就是在在客户请求之后发放的票据，并已经向 KDC 作了认证，

一个**硬件认证**是一个票据上的标记，该票据需要硬件的接入以帮助认证。该硬件期待仅仅由请求该票据的用户拥有。

如果一个票据设置有 **传输策略**标记。那么发放该票据的 KDC 就实现了传输 realm 检查策略并检查了票据携带的 transited-realms 列表。一个 transited-realms 列表包含了一系列的位于发布首个票据的 KDC 和发布了当前票据的 KDC 之间可能的 realms 列表。如果这个标记设置了，那么应用服务器必须自己检查 transited realms 或拒绝该票据。

**代理可行**（okay as delegate）指示票据中指定的服务器适合作为由 realm 策略决定的代理。一些客户端应用使可能用这个标记来决定是否将这个票据转发到远端主机，但也有许多程序并不关心这个标记。

一个**匿名**票据是一种票据，其命名凭证是针对这个 realm 的一个通用凭证；它并不实际指定使用这个票据的个体。这个票据仅仅用于安全地分发会话键。 

### 使用 kinit 获取票据

如果你的站点已经将 Kerberos V5 集成进登录系统，那么当你登录进系统后，你将会自动获得 Kerberos 票据。否则，你可能需要使用 [kinith](ttps://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kinit.html#kinit-1) 程序显式获取你的 Kerberos 票据。类似的，如果你的 Kerberos 票据过期，使用 kinit 来得到一个新的。

为了使用 kinit 程序，简单键入 `kinit` 并在提示符后输入密码。例如，Jennifer（其用户名为 `jennifer`）为 Bleep 公司（一个虚拟的公司，其域名为 `mit.edu`，其 Kerberos 域为 `ATHENA.MIT.EDU`）工作，她应该输入：

```
shell% kinit
Password for jennifer@ATHENA.MIT.EDU: <-- [Type jennifer's password here.]
shell%
```

如果你没有正确输入密码，kinit 将会反馈与你如下错误消息：

```
shell% kinit
Password for jennifer@ATHENA.MIT.EDU: <-- [Type the wrong password here.]
kinit: Password incorrect
shell%
```

并且你将不会获得票据。

默认地，kinit 假设你会在你的默认 Kerberos 域中为你的用户名创建一个票据。假设 Jennifer 的朋友 David 正在参观，并且他想借一个窗口查阅他的邮件，David 需要为他自己获取一个位于其自己的域 EXAMPLE.COM 中的票据，他将输入：

```
shell% kinit david@EXAMPLE.COM
Password for david@EXAMPLE.COM: <-- [Type david's password here.]
shell%
```

现在 David 有了一个可以登录进他的机器的票据。注意他在 Jennifer 的机器上输入了自己的密码，但是这个过程没有通过网络。本地主机上的 Kerberos 执行了到其它域的 KDC 的认证。

如果你想转发你的票据到另一个主机，你需要请求一个可转发票据。你可通过指定 **-f** 来实现这个。

```
shell% kinit -f
Password for jennifer@ATHENA.MIT.EDU: <-- [Type your password here.]
shell%
```

注意 kinit 并未告知你获取了一个可转发票据；你可以使用 [klist](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/klist.html#klist-1) 命令来验证这个（参见[使用 klist 查验票据](https://web.mit.edu/kerberos/krb5-latest/doc/user/tkt_mgmt.html#view-tkt)）。

通常你的票据适合你的系统的默认票据生命周期，这在许多系统上是 `10` 个小时。你可以使用 **-l** 选项来指定一个不同的票据生命周期。添加 **s** 以指定单位为秒；**m** 为分钟, **h** 为小时, 或者 **d** 为天。例如，为给 `david@EXAMPLE.COM` 得到一个生命周期为三个小时的可转发票据，你可以如下输入：

```
shell% kinit -f -l 3h david@EXAMPLE.COM
Password for david@EXAMPLE.COM: <-- [Type david's password here.]
shell%
```

> 注意：你不能混用单位，指定一个 `3h30m` 的生命周期将导致错误。也要注意大多数系统指定一个最大票据生命周期。如果你指定一个更长的票据生命周期，它将被自动截短到最大生命周期。

### 使用 klist 查验票据

[klist](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/klist.html#klist-1) 命令用于列出你的票据。当你首先获取到票据时，你将仅仅拥有票据授予票据。列表将看起来如下所示：

```
shell% klist
Ticket cache: /tmp/krb5cc_ttypa
Default principal: jennifer@ATHENA.MIT.EDU

Valid starting     Expires            Service principal
06/07/04 19:49:21  06/08/04 05:49:19  krbtgt/ATHENA.MIT.EDU@ATHENA.MIT.EDU
shell%
```

票据缓存是你的票据文件所在位置。在上面的例子中，文件名为 `/tmp/krb5cc_ttypa`。默认凭证是你的 Kerberos 凭证。

“valid starting” 和 “expires” 字段描述了票据有效的时间期间。“service principal” 描述了每一条票据。票据授予票据拥有第一个组件 `krbtgt`，第二个组件是域名。

现在，如果 `jennifer` 连接到机器 `daffodil.mit.edu`，然后再输入 “klist”，她将得到如下结果：

```
shell% klist
Ticket cache: /tmp/krb5cc_ttypa
Default principal: jennifer@ATHENA.MIT.EDU

Valid starting     Expires            Service principal
06/07/04 19:49:21  06/08/04 05:49:19  krbtgt/ATHENA.MIT.EDU@ATHENA.MIT.EDU
06/07/04 20:22:30  06/08/04 05:49:19  host/daffodil.mit.edu@ATHENA.MIT.EDU
shell%
```

这里发生了什么：当 `jennifer` 使用 ssh 连接到主机 `daffodil.mit.edu`，ssh 程序将她的票据授予票据提交给 KDC 并请求一个针对 `daffodil.mit.edu` 的主机票据。KDC 发送回该主机票据，ssh 把它提交给主机 `daffodil.mit.edu`，她就可被允许登录而无需输入密码。

假设你的 Kerberos 票据允许你登陆到另一个域的主机，例如 `trillium.example.com`，它也在另一个 Kerberos 域 `EXAMPLE.COM` 中。如果你 ssh 到这个主机，你将收到一个针对 `EXAMPLE.COM` 域的票据授予票据，加上新的针对 `trillium.example.com` 的主机票据。klist 现在将显示：

```
shell% klist
Ticket cache: /tmp/krb5cc_ttypa
Default principal: jennifer@ATHENA.MIT.EDU

Valid starting     Expires            Service principal
06/07/04 19:49:21  06/08/04 05:49:19  krbtgt/ATHENA.MIT.EDU@ATHENA.MIT.EDU
06/07/04 20:22:30  06/08/04 05:49:19  host/daffodil.mit.edu@ATHENA.MIT.EDU
06/07/04 20:24:18  06/08/04 05:49:19  krbtgt/EXAMPLE.COM@ATHENA.MIT.EDU
06/07/04 20:24:18  06/08/04 05:49:19  host/trillium.example.com@EXAMPLE.COM
shell%
```

依赖于你的主机和域的配置，你可能看到一个带服务凭证 `host/trillium.example.com@` 的票据。如果是，这意味着你的主机并不知道 `trillium.example.com` 在哪个域中，因此它将查询 `ATHENA.MIT.EDU KDC`。下一次你连接到 `trillium.example.com` 时，这个看起来比较奇怪的条目用于避免重复查询。

你可以使用 **-f** 选项来查看适用于你的票据的标记。这些标记是：

- F Forwardable
- f forwarded
- P Proxiable
- p proxy
- D postDateable
- d postdated 
- R Renewable
- I Initial
- i invalid
- H Hardware authenticated
- A preAuthenticated
- T Transit policy checked
- O Okay as delegate
- a anonymous

这是一个示例列表。在这个例子中，用户 `jennifer` 获取到了她的初始票据 (I)，它是 forwardable (**F**) 和 postdated (**d**)， 但还不是验证过的 (**i**):

```
shell% klist -f
Ticket cache: /tmp/krb5cc_320
Default principal: jennifer@ATHENA.MIT.EDU

Valid starting      Expires             Service principal
31/07/05 19:06:25  31/07/05 19:16:25  krbtgt/ATHENA.MIT.EDU@ATHENA.MIT.EDU
        Flags: FdiI
shell%
```

在下面的例子中，用户 `david` 的票据对从别的主机到该主机是可转发的，票据可再次转发：

```
shell% klist -f
Ticket cache: /tmp/krb5cc_p11795
Default principal: david@EXAMPLE.COM

Valid starting     Expires            Service principal
07/31/05 11:52:29  07/31/05 21:11:23  krbtgt/EXAMPLE.COM@EXAMPLE.COM
        Flags: Ff
07/31/05 12:03:48  07/31/05 21:11:23  host/trillium.example.com@EXAMPLE.COM
        Flags: Ff
shell%
```

### 使用 kdestroy 销毁票据

你的 Kerberos 票据是你确实是你自己的证据，如果有人获得了票据所在机器的访问权限，那么你的票据可能会被窃取。如果这种情况发生，窃取票据的人可以伪装成您直至票据过期。基于这个原因，当你离开你的机器时你应该销毁你的 Kerberos 票据。

销毁你的票据很容易，仅仅需要输入 `kdestroy`：

```
shell% kdestroy
shell%
```

如果 [kdestroy](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kdestroy.html#kdestroy-1) 删除你的票据操作失败，它将会蜂鸣并打印一条错误消息。例如，如果 kdestroy 找不到任何票据以删除，它将给出下面的消息：

```
shell% kdestroy
kdestroy: No credentials cache file found while destroying cache
shell%
```

## 用户配置文件

这些文件在你的用户主目录下，它们适用于你的账号（除非他们被你的主机配置文件禁用），可以用于控制 Kerberos 的行为。

### kerberos

在网络环境下 Kerberos 认证单个用户。当你被 Kerberos 认证通过后，你可以使用启用了 Kerberos 的应用而无需提供密码或证书给应用。

如果你收到 [kinit](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kinit.html#kinit-1) 的如下反馈：

```
kinit: Client not found in Kerberos database while getting initial credentials
```

你没有注册为一个 Kerberos 用户，请咨询你的系统管理员。

一个 Kerberos 名字通常包括三个部分。第一部分是主干（primary），它通常是一个用户名或者服务名。第二部分为实例（instance），当指定一个用户时通常为 null。某些用户可能含有特权实例，比如 `root` 或 `admin`。当指定一个服务时，实例名为服务运行的机器的全域名，例如，有一个 ssh 服务运行于一个机器 `ABC` 上（ssh/ABC@REALM），它不同于运行于机器 `XYZ` (ssh/XYZ@REALM) 上的 ssh 服务。Kerberos 名字的第三部分为域（realm）。域对应提供凭证认证的 Kerberos 服务。域通常为全大写且匹配域中主机名的结尾部分（例如，host01.example.com 可能位于域 EXAMPLE.COM 中）。

当写下一个 Kerberos 名字时，凭证名是与实例名（如果不为null）是用斜杠分开的，域名（如果非本地域）则居于其后，由 **“@”** 符号标记。下面是有效 Kerberos 名字的一些例子：

```
david
jennifer/admin
joeuser@BLEEP.COM
cbrown/root@FUBAR.ORG
```

当你通过 Kerberos 认证，你得到一个 Kerberos 票据。（一个 Kerberos 票据是一条提供认证的加密协议消息）。Kerberos 在网络设施如 ssh 中使用这个票据。票据事务时透明处理的，因此你不需要担心他们的管理。

但是需要注意票据可以过期。管理员可能配置更多的特权票据，例如用于服务或实例的 `root` 或 `admin`，将会在几分钟内过期。另一方面，携带更多普通权限的票据适合几小时或一天内过期。如果你的登录会话超过了时间限制，你将不得不使用 [kinit](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kinit.html#kinit-1) 获取新的票据以向 Kerberos 重新认证。

有些票据在其初始生命周期之后是可刷新的。这意味着 `kinit -R` 可以扩展其生命周期而无需你重新认证。

如果你想删除你的本地票据，使用 [kdestroy](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kdestroy.html#kdestroy-1) 命令。

Kerberos 票据可以被转发。为了转发票据，你必须在运行 kinit 时请求可转发票据。一旦你拥有了可转发票据，大多数 Kerberos 程序拥有一个命令行选项将其转发至远程主机。这可能很有用，例如，在你的本地主机上运行 kinit 命令，然后 `sshing` 到另一个主机去工作。注意此类操作不应在不受信任的主机上进行，原因在于它们将会拥有你的票据。

#### 环境变量

开启 Kerberos 的应用受下面几个环境变量的影响。它们包括：

- **KRB5CCNAME**
  默认凭证缓存文件名，格式为 `TYPE:residual`。默认缓存的类型可能决定了一个缓存集合的可用性。`FILE` 不是一个集合类型；`KEYRING`, `DIR`, 和 `KCM` 是。

  如果没有设置，来自配置文件（参见 KRB5_CONFIG）的 **default_ccache_name** 值将会被使用。而如果 **default_ccache_name** 也未被设置，并且默认类型为 **FILE**，residual 为路径 `/tmp/krb5cc_*uid*`，这里 uid 是当前用户的数字用户 ID。

- **KRB5_KTNAME**
 
   指定默认 keytab 文件位置，格式为 `TYPE:residual`。如果没有指定类型，Kerberos 将会假设类型为 **FILE**，`residual` 将被解释为 keytab 文件的路径。如果这个环境变量未设定，[DEFKTNAME](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths) 将会被使用。 
- **KRB5_CONFIG**

  指定 Kerberos 配置文件位置。默认为 [SYSCONFDIR](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths)/krb5.conf。可以指定多个文件，用冒号分隔；设置的所有文件将会被读取。
- **KRB5_KDC_PROFILE**

  指定 KDC 配置文件位置，它包含额外的针对 KDC 守护进程和附带应用的配置指令。默认为 [LOCALSTATEDIR](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths)/krb5kdc/kdc.conf。
- **KRB5RCACHENAME**

  （release 1.18 中新添加）指定默认重放缓存的位置，格式为 `type:residual`。`file2` 类型且带有路径的 residual 在指定位置指定了了一个 `version-2` 格式的重放缓存文件。`none` 类型（residual 被忽略）禁用了重放缓存。`dfl` 类型（residual 被忽略）指示默认类型，它使用了一个临时目录下的 file2 重放缓存。默认为 `dfl` 类型。
- **KRB5RCACHETYPE**

  如果 **KRB5RCACHENAME** 未指定，则指定默认重放缓存的类型。没有指定 residual，因此 `none` 和 `dfl` 是仅有的可用类型。
- **KRB5RCACHEDIR**

  指定 `dfl` 重放缓存类型所使用的目录。默认值为环境变量 **TMPDIR** 的值。如果 **TMPDIR** 未设定，则为 `/var/tmp`。
- **KRB5_TRACE**

  指定一个输出 trace 日志的文件名。trace 日志可以帮助理解 Kerberos 库内部所有决策。例如，`env KRB5_TRACE=/dev/stderr kinit` 将会把 [kinit](https://web.mit.edu/kerberos/krb5-latest/doc/user/user_commands/kinit.html#kinit-1) 的 tracing 消息发送至 `/dev/stderr`。 默认配置是不会写任何 trace 日志至任何地方。 
- **KRB5_CLIENT_KTNAME**

  默认客户端 keytab 文件。如果未设置，[DEFCKTNAME](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths) 将会被使用。
- **KPROP_PORT**

  [kprop](https://web.mit.edu/kerberos/krb5-latest/doc/admin/admin_commands/kprop.html#kprop-8) 使用的端口号。默认为 **754**。
- **GSS_MECH_CONFIG**

  包含 GSSAPI 机制模块配置信息的文件名。默认将读取 [SYSCONFDIR](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths)/gss/mech 和 [SYSCONFDIR](https://web.mit.edu/kerberos/krb5-latest/doc/mitK5defaults.html#paths)/gss/mech.d 目录下所有带 `.conf` 后缀的文件。

对确定应用，大部分环境变量被禁用，例如登陆系统程序和 setuid 程序，这种设计是为了确保在非信任处理环境下的安全。

### .k5login

.k5login 文件位于用户主目录下，包括 Kerberos 凭证的一个列表。任何人拥有文件中的一个凭证票据，就可以实现主目录下含有该文件的在剧集访问，使用用户为该用户的 UID。一个常见应用是将一个 .k5login 放置于 root 主目录下，由此允许通过 Kerberos 的系统管理远程 root 访问。

#### 示例

假定用户 alice 在其主目录下有一个 .k5login 文件包含下面的行：

```
bob@FOOBAR.ORG
```

这将允许 bob 使用 Kerberos 网络应用，例如 ssh 来访问 `alice` 的账号 -- 使用 bob 的 Kerberos 票据。在默认配置（在 [krb5.conf](https://web.mit.edu/kerberos/krb5-latest/doc/admin/conf_files/krb5_conf.html#krb5-conf-5) 中 **k5login_authoritative** 设置为 true）下，.k5login 将不会允许 `alice` 使用这些网络应用来访问她的账号，因为她并未被列出来。如果没有 .k5login，或者 **k5login_authoritative** 设置为 false，默认规则将允许机器的默认域中的 alice 凭证访问 alice 账号。

让我们进一步假设 `alice` 是系统管理员，`alice` 和其它系统管理员在每一个主机的 root 的 `.k5login` 里都有其凭证：

```
alice@BLEEP.COM

joeadmin/root@BLEEP.COM
```

这将允许系统管理员使用 Kerberos 票据而不是输入 root 密码以登录进这些主机。注意由于 `bob` 为其自己的凭证保留了 Kerberos 票据，`bob@FOOBAR.ORG`，他将不会拥有任何需要 `alice` 票据的特权，比如访问任一主机的 root 账号，或修改 `alice` 的密码。

### .k5identity

.k5identity 文件位于用户的主目录下，包括一系列规则用于基于访问的服务选择客户凭证。这些规则用于当可能时从缓存集合里选择凭证缓存。

空行和以 # 开头的行将会被忽略。每一行拥有下面的格式：

```
principal field=value …
```

如果服务器凭证满足了所有的字段限制，品正将会被选择为客户端凭证。下面是可识别字段列表：

- realm

  如果服务器凭证的域不清楚，它必须匹配值，而值可能是一个使用 shell 通配符的模式。对基于主机的服务端凭证，仅仅只有在 [krb5.conf](https://web.mit.edu/kerberos/krb5-latest/doc/admin/conf_files/krb5_conf.html#krb5-conf-5) 的 [[domain_realm](https://web.mit.edu/kerberos/krb5-latest/doc/admin/conf_files/krb5_conf.html#domain-realm)] 节有一个 hostname 的 映射时域才是已知的。
- service
  
  如果服务器凭证是基于主机的凭证，它的服务组件必须匹配配置值，它可能是一个使用 shell 通配符的模式。
- host
  
  如果服务器凭证是基于主机的凭证，它的主机名组件转化为小写并匹配配置值，它可能是一个使用 shell 通配符的模式。

  如果服务器凭证匹配 .k5identity 文件中的多行限制，第一个匹配的凭证将会被使用。如果没有行匹配，将会基于别的方式选择凭证，例如启发式域名或当前主缓存。

#### 示例

下面的示例 .k5identity 文件在服务器凭证在域内时选择客户端凭证 alice@KRBTEST.COM；如果服务器主机位于服务器子域中则选择 alice/root@EXAMPLE.COM；当访问位于主机 mail.example.com 上的 IMAP 服务时选择 alice/mail@EXAMPLE.COM 。

```
alice@KRBTEST.COM       realm=KRBTEST.COM
alice/root@EXAMPLE.COM  host=*.servers.example.com
alice/mail@EXAMPLE.COM  host=mail.example.com service=imap
```

## 用户命令行

### kdestroy

### kinit

### klist

### kpasswd

### krb5-config

### ksu

### kswitch

### kvno

### sclient

## Reference

- [For users](https://web.mit.edu/kerberos/krb5-latest/doc/user/index.html)