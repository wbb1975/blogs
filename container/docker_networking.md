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

## 参考
- [Configure networking](https://docs.docker.com/v17.09/engine/userguide/networking/)
  