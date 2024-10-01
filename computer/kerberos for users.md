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

通常你的票据适合你的系统的默认票据生命周期，这在许多系统上是 10 个小时。你可以使用 **-l** 选项来指定一个不同的票据生命周期。添加 **s** 以指定单位为秒；**m** 为分钟, **h** 为小时, 或者 **d** 为天。例如，为给 `david@EXAMPLE.COM` 得到一个生命周期为三个小时的可转发票据，你可以如下输入：

```
shell% kinit -f -l 3h david@EXAMPLE.COM
Password for david@EXAMPLE.COM: <-- [Type david's password here.]
shell%
```

> 注意：你不能混用单位，指定一个 `3h30m` 的生命周期将导致错误。也要注意大多数系统指定一个最大票据生命周期。如果你指定一个更长的票据生命周期，它将被自动截短到最大生命周期。

### 使用 klist 查验票据


### 使用 kdestroy 销毁票据


## 用户配置文件

### kerberos

### .k5login

### .k5identity

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