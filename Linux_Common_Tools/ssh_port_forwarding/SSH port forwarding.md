## SSH 端口转发 - 示例，命令， 服务器配置
### 什么是 SSH 端口转发以及 SSH 隧道？（What Is SSH Port Forwarding, aka SSH Tunneling）
SSH 端口转发是 [SSH](https://www.ssh.com/ssh/) 中为从客户端到服务器或者相反方向应用提供隧道的一种机制。它能被用于为遗留应用添加加密功能，穿越防火墙，一些系统管理员和 IT 专业人士用它来为从家里的机器访问公里内部网络开后门。它也可能被骇客及一些流氓软件利用从互联网上访问内部网络。参阅 [SSH 隧道](https://www.ssh.com/ssh/tunneling/)以得到更多信息。
### 本地转发（Local Forwarding）
本地转发用于将客户端机器额端口转发到服务端机器上。基本上，[SSH 客户端](https://www.ssh.com/ssh/client) 在一个配置的端口上监听连接，当它收到一个连接，它将此连接通过隧道连接到 [SSH 服务器](https://www.ssh.com/ssh/server)。服务器连接到一个配置好的端口，可以在一个与 SSH 服务器不同的机器上。

端口转发的典型用例包括：
- 通过[跳转服务器](https://www.ssh.com/iam/jump-server隧道化会话及文件传送)
- 从外部连接到内部网络的服务
- 连接到通过互联网共享的远程文件

许多入站SSH访问通过一个简单[跳转服务器](https://www.ssh.com/iam/jump-server)组织。这个服务器可呢个是一个标准 Linux/Unix 机器，通常有一些增强，入侵检测，日志等，它也可能是一台商业跳转服务器方案。

一旦连接已被认证，许多跳转服务器允许入站端口转发。这类端口转发是便捷的，因为他允许技术大拿们（tech-savvy users）十分透明第访问内部资源。例如，他们可能转发本机端口通讯到公司内部的Web 服务器，或者到内部邮件服务器的 [IMAP]( https://en.wikipedia.org/wiki/Internet_Message_Access_Protocol) 端口，到本地文件服务器的 `445` 和 `139` 端口，到一个打印机，一个版本控制仓库，或者内网里的其它任何系统。最常见地，端口被隧道化到一个内部机器的 SSH 端口。

在 [OpenSSH](https://www.ssh.com/ssh/openssh/), 本地端口转发使用 `-L` 选项配置:
```
ssh -L 80:intra.example.com:80 gw.example.com
```
这个示例打开了一个到跳转服务器 `gw.example.com` 的连接，然后转发任何到本机 `80` 端口的连接到 `intra.example.com` 的 `80` 端口。

默认情况下，任何人（甚至在不同机器上）都可以连接到 SSH 客户端机器的特定端口。然而，可以通过一个绑定地址来限定在相同机器上的程序：
```
ssh -L 127.0.0.1:80:intra.example.com:80 gw.example.com
```
[OpenSSH客户端配置文件](https://www.ssh.com/ssh/config/)中的本地端口转发选项可被配置而无需在命令行上指定。
### 远程转发（Remote Forwarding）
在 [OpenSSH](https://www.ssh.com/ssh/openssh/), 远程端口转发使用 `-R` 选项配置:
```
ssh -R 8080:localhost:80 public.example.com
```
它允许在远端服务器上的任何人连接到远程服务器的 TCP `8080` 端口，该连接然后通过隧道返回到客户端主机，接下来客户端就开启了一个到 `localhost` 端口 `80` 的连接。其它任何主机名或 IP 地址可被用于提到连接目标主机如 `localhost`。

这个特殊的示例对于开放内部 Web 服务器给外部是有用的。或者暴露内部 Web 服务到公共互联网。这个可以被居家工作的员工实施，也可能是一个骇客。

默认地，OpenSSH 仅仅允许从服务器主机上的远程端口转发连接。但是，OpenSSH服务器配置文件[sshd_config](https://www.ssh.com/ssh/sshd_config/)中的 `GatewayPorts` 选项可被用于控制这个。下面的选项是可能的：
```
GatewayPorts no
```
这阻止了这个远程服务器以外的机器连接到转发端口。
```
GatewayPorts yes
```
这允许任何人连接到转发端口。如果服务器在公共互联网上，在互联网上的任何人都可连接到该端口。
```
GatewayPorts clientspecified
```
这意味着客户端可以指定一个可以连接到该端口的IP地址。它的语法如下：
```
ssh -R 52.194.1.73:8080:localhost:80 host147.aws.example.com
```
在这个例子中，只有从 IP 地址 `52.194.1.73` 到 `8080` 的连接是允许的。

OpenSSH 允许转发远程端口被指定为 0。在这种情况下，服务器将动态分配一个端口并报告给客户。当使用 `-O` 转发选项，客户端将把分配的端口号打印到标准输出上。
### 在企业中开后门（Opening Backdoors into the Enterprise）
远程 SSH 端口转发被期望打开一个到公司内部的后门的员工广泛使用。例如，员工可以设置一个 [AWS 免费服务器](https://aws.amazon.com/free/)，从办公室登录到该服务器，从该服务器的一个端口指定一个远程转发到内部企业网络里的服务或一个应用。可以指定多个远程转发以访问多个应用。

员工可以设置 `GatewayPorts yes`（大多数员工在家里没有固定 IP 地址，因此他们不能限制 IP地址）。

例如，下面的例子开启了到内部 `Postgres` 数据库 `5432` 端口的连接，以及一个通过 `2222` 端口到内部 SSH 服务的连接：
```
ssh -R 2222:d76767.nyc.example.com:22 -R 5432:postgres3.nyc.example.com:5432 aws4.mydomain.net
```
### 服务端配置（Server-Side Configuration）
OpenSSH服务器配置文件[sshd_config](https://www.ssh.com/ssh/sshd_config/)中的 `AllowTcpForwarding` 选项在允许端口转发的服务器上必须被打开。默认地，端口转发是开启的。这个选项的可能值包括 `yes` 或 `all` 以允许所有的 TCP 端口转发，`no` 以阻止所有的端口转发，`local` 以允许本地端口转发，以及 `remote` 以允许远程端口转发。

另一个兴趣点是 `AllowStreamLocalForwarding`，它可被用于转发 Unix 域 socket。它允许和 `AllowTcpForwarding` 同样的设置值。默认值是 `yes`。

例如：
```
AllowTcpForwarding remote     AllowStreamLocalForwarding no
```

如上面所述 `GatewayPorts` 选项也影响远程端口转发。可能的值包括：no (仅仅允许来自服务器主机的本地连接；默认), yes (来自互联网的任何人可以连接到远程转发端口), 以及　clientspecified (客户可以指定允许连接的 IP 地址，以及任何人不显式指定也可访问的人)。
### 如何从防火墙规避设置中禁用 SSH 端口转发（How to Prevent SSH Port Forwarding from Circumventing Firewalls）
我们建议当不需要时端口转发应被显式禁用。留下端口转发将置你的组织于安全风险和后门之下。例如，如果一个仅仅提供 [SFTP](https://www.ssh.com/ssh/sftp/) 文件传送的服务器允许端口转发，这些转发设置可能被用于从内网获得对内部网络的非授权访问。

问题在于实践中端口转发仅仅可被覅武器或防火墙阻止。一个企业不能控制互联网昂上的所有服务器。基于防火墙的控制可能很微妙，因为许多组织在 Amazon AWS 及其它云服务上部署有服务器，而这些服务器通常通过 SSH 访问。
### SSH.COM 解决方案
[SSH.COM Tectia SSH Client/Server](https://www.ssh.com/products/tectia-ssh/) 是一套商业解决方案，它提供了安全的应用隧道，[SFTP](https://www.ssh.com/academy/ssh/sftp)，以及安全的企业远程访问。
### 深入的信息
- [关于SSH tunneling的更多信息](https://www.ssh.com/ssh/tunneling/)

## Reference
- [SSH port forwarding - Example, command, server config](https://www.ssh.com/academy/ssh/tunneling/example)
- [How to Use SSH Port Forwarding](https://phoenixnap.com/kb/ssh-port-forwarding)
- [How to Set up SSH Tunneling (Port Forwarding)](https://linuxize.com/post/how-to-setup-ssh-tunneling/)
- [A Guide to SSH Port Forwarding/Tunnelling](https://www.booleanworld.com/guide-ssh-port-forwarding-tunnelling/)