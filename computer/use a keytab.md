# Use a keytab

## 介绍

> 重要: 从 2019-4-14 起，IU Kerberos 服务器停止对 DES 加密 kerberos 票据的支持。

一个 keytab 是一个包含了Kerberos princpals 和加密密钥（从Kerberos 密码派生而来）的一个文件。你可以使用 keytab 文件来认证各种各样的远程 Kerberos 系统而无需输入密码。但是，当你修改了你的 Kerberos 密码，你就需要重新生成你的所有 keytabs。

Keytab 文件常用于脚本通过 Kerberos 来自动化认证，不需要人机交互，也不需要访问存储在纯文本文件中的密码。之后脚本可以使用获取到的 credentials 来访问存储于远程系统上的文件。

> 重要: 对一个 keytab 文件拥有读权限的用户可以使用该文件中的所有密钥。为了防止误用，严格限制你创建的任何 keytab 文件的访问权限。关于相关指令，请参见[类UNIX系统的文件权限管理](https://kb.iu.edu/d/abdb)。

## 创建一个 keytab 文件

> 注意：为了使用本文中的指令和示例，你需要访问一个 Kerberos 客户端，可以通过一台私人工作站，也可以是一台 [IU 研究用超级计算机](https://kb.iu.edu/d/alde)。当参考本文中的示例时，严格按显示的命令输入。你可能需要修改你的 path 环境变量以包含 `ktutil` 的位置（例如, `/usr/sbin` 或 `/usr/kerberos/sbin`）。

你可以在任意安装了 Kerberos 客户端的计算机上创建 keytab 文件。Keytab 文件并不与创建它的系统绑定：你可以在一台计算机上创建一个 Keytab 文件，然后将其拷贝到另一台计算机上。

下面是一个使用 `MIT Kerberos` 创建 Keytab 文件的例子：

```
> ktutil
  ktutil:  addent -password -p username@ADS.IU.EDU -k 1 -e aes256-cts
  Password for username@ADS.IU.EDU: [enter your password]
  ktutil:  wkt username.keytab
  ktutil:  quit
```

下面时使用 `Heimdal Kerberos` 的例子：

```
> ktutil -k username.keytab add -p username@ADS.IU.EDU -e arcfour-hmac-md5 -V 1
```

如果 Heimdal 创建的 keytab 不能工作，可能原因在于你需要一个 `aes256-cts` 入口。这种情况下，你需要找到一台装有 `MIT Kerberos` 的计算机，并使用对应方法。

> 注意：对于 `ADS.IU.EDU Kerberos` realm 的更多信息，请参见[Current Kerberos realm at IU](https://kb.iu.edu/d/alje)

## 使用一个 keytab 来认证脚本

为了执行一个脚本并让其由一个有效的 `Kerberos credentials`，使用如下命令：

```
> kinit username@ADS.IU.EDU -k -t mykeytab; myscript
```

用你的用户名替换 `username`，用你的 keytab 文件名替换 `mykeytab`；并用你的脚本名替换 `myscript`。

## 列出一个 keytab 文件中的所有密钥

利用 `MIT Kerberos`，为了列出一个 keytab 文件中的内容，使用 `klist`（用你的 keytab 文件名替换 `mykeytab`）：

```
> klist -k mykeytab

version_number username@ADS.IU.EDU
version_number username@ADS.IU.EDU
```

输出包含两列：版本号和 `principal` 名。如果同一 `principal` 的多个密钥存在，那么仅仅拥有最大版本号的那个会被使用。

如果是 Heimdal Kerberos，可以使用 ktutil：

```
> ktutil -k mykeytab list
mykeytab:

Vno  Type         Prinicpal
1    des3-cbc-md5 username@ADS.IU.EDU
...
```

## 从一个 keytab 文件中删除一个密钥

如果你不再需要一个 keytab 文件，立即删除它。如果这个 keytab 文件包含多个密钥，你可以使用 `ktutil` 命令来删除特定密钥。你可以使用这个步骤来删除一个密钥的旧版本。下面是一个使用 `MIT Kerberos` 删除密钥的例子：

```
 > ktutil
  ktutil: read_kt mykeytab
  ktutil: list

  ...
  slot# version# username@ADS.IU.EDU        version#
  ...

  ktutil: delent slot#
```

用你的 keytab 文件名替换 `mykeytab`，用你的用户名替换 `username`，并用合适的版本号来替换 `version#`。

验证完旧版本已被删除，然后在 `ktutil` 中输入：

```
quit
```

为了使用 `Heimdal Kerberos` 实现同样的功能，如下：

```
> ktutil -k mykeytab list

...
version# type username@ADS.IU.EDU
...

> ktutil -k mykeytab remove -V version# -e type username@ADS.IU.EDU
```

## 合并 keytab 文件

如果你拥有多个 keytab 文件需要被放置于一处，你可以使用 `ktutil` 命令来合并它们。

利用 `MIT Kerberos` 来合并 keytab 文件，使用如下命令：

```
> ktutil
  ktutil: read_kt mykeytab-1
  ktutil: read_kt mykeytab-2
  ktutil: read_kt mykeytab-3
  ktutil: write_kt krb5.keytab
  ktutil: quit
```

用每个 keytab 文件名替换 `mykeytab-(number)`，最后合并出来的 keytab 文件名为 `krb5.keytab`。

为了验证合并结果，使用如下命令

```
klist -k krb5.keytab
```

利用 `Heimdal Kerberos` 来合并 keytab 文件，使用如下命令：

```
> ktutil copy mykeytab-1 krb5.keytab
  > ktutil copy mykeytab-2 krb5.keytab
  > ktutil copy mykeytab-3 krb5.keytab
```

为了验证合并结果，使用如下命令

```
ktutil -k krb5.keytab list
```

## 把一个 keytab 文件拷贝到另一台计算机上

keytab 文件独立于创建它的计算机，它的文件名，以及其在文件系统中的位置。一旦它被创建，你可以重命名它，将其移动至同一计算机的其它位置，或者迁移至另一台 Kerberos 计算机，它任然能够工作。keytab 文件是二进制文件，确保在传输过程中没有破坏其内容。

如果可能，使用 [SCP](https://kb.iu.edu/d/agye) 或其它安全方法在计算机之间传送 keytab 文件。如果你不得不使用 [FTP](https://kb.iu.edu/d/aerg)，确保你在传送文件前在你的 FTP 客户端中发出了 `bin` 命令。这将设置传送类型为二进制，从而不会破坏 keytab 文件内容。

## Reference

- [Use a keytab](https://kb.iu.edu/d/aumh)
- [Set up a Unix computer as a Kerberized application server](https://kb.iu.edu/d/ahkb)
