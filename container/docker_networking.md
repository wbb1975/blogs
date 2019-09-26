# 容器联网
## Docker容器联网（Docker container networking）
本节提供Docker缺省联网行为的综述，包括创建网络的缺省类型，以及如何创建用户自定义网络。它也描述了在单个主机上或跨主机集群上创建网络所需资源。

关于在Linux主机上Docker与iptables交互的细节，请参阅[Docker and iptables](https://docs.docker.com/engine/userguide/networking/#docker-and-iptables)。
### 缺省网络（Default networks）
当你安装Docker时，它将自动安装三个网络。你可以用`docker network ls`命令打印这些网络。
```
wangbb@wangbb-ThinkPad-T420:~$ sudo docker network ls
[sudo] wangbb 的密码： 
NETWORK ID          NAME                DRIVER              SCOPE
5bbfcdd0f429        bridge              bridge              local
083182596fb9        host                host                local
7c7b0d8f8c22        none                null                local
```
这三种网络是内建于Docker中的。当你运行一个容器，你可以使用`--network`标记来指定你的容器将连接的网络。

`bridge`网络代表在Docker安装中存在的`docker0`网络，除非你使用`docker run --network=<NETWORK>`选项额外指定，Docker服务器（daemon）缺省会将这个容器连接到这个网络。在主机上使用`ip addr show`（或其简写形式`ip a`）可以看到`bridge`是网络堆栈的一部分。（ifconfig命令将被废弃。取决于你的系统，它可能工作，也可能给你一个`command not found`的错误。）
```
$ ip addr show

docker0   Link encap:Ethernet  HWaddr 02:42:47:bc:3a:eb
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:47ff:febc:3aeb/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:17 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1100 (1.1 KB)  TX bytes:648 (648.0 B)
```

## 参考
- [Configure networking](https://docs.docker.com/v17.09/engine/userguide/networking/)
  