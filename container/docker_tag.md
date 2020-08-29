# docker tag
## 描述
创建一个 `TARGET_IMAGE` 标签指向 `SOURCE_IMAGE`。 
## 用法
```
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
```
## 扩展描述
一个镜像名由斜线分割组件组成，可选地包括仓库主机名。主机名必须遵从标注DNS规则，但不能包括下划线。如果主机名存在，它可能可选地包括一个端口号，格式如`:8080`。如果没有主机名，命令将默认使用Docker位于`registry-1.docker.io`的公共仓库。命名组件可能包括小写字母，数字及分隔符。分隔符被定义为一个点号，一个或两个下划线，一个或多个斜线。一个命名组件不能以分隔符开头或结尾。

一个标签名必须是有效的ASCII，可以包含小写或大写字母，数字，下划线，点号和连接线。一个标签不能以点号或连接线开头，最大包含128个字符。

你可以使用名字和标签把你的镜像组织在一个，然后把它们上传到[Docker Hub共享镜像](https://docs.docker.com/get-started/part3/)上。

管事使用该命令的例子，请参见下面的示例。
## 示例
### 给一个通过ID引用的镜像打标签
为了给一个ID为“0e5574283393”的本地镜像打进“fedora”仓库并给定标签名“version1.0”：
`$ docker tag 0e5574283393 fedora/httpd:version1.0`
### 给一个通过名字引用的镜像打标签
为了给一个名为 “httpd”的本地镜像打进“fedora”仓库并给定标签名为“version1.0”：
`$ docker tag httpd fedora/httpd:version1.0`
> **注意**：因为标签名未指定，对已有的本地版本的一个别名将会被创建：`httpd:latest`。
### 给一个通过名字和标签引用的镜像打标签
为了给一个名为 “httpd”，标签为“test”的本地镜像打进“fedora”仓库并给定标签名为“version1.0.test”：
`$ docker tag httpd:test fedora/httpd:version1.0.test`
### 为一个私有仓库的镜像打标签
为了讲一个镜像推送到一个私有仓库而非中央Docker仓库，你需要咯用仓库主机名和端口号（如果需要）给其打标签：
`$ docker tag 0e5574283393 myregistryhost:5000/fedora/httpd:version1.0`
## 父命令
命令|解释
--------|--------
[docker](https://docs.docker.com/engine/reference/commandline/docker)|Docker CLI基础命令

## Reference
- [docker tag](https://docs.docker.com/engine/reference/commandline/tag/)