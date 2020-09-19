# 安装工具
#### kubectl
Kubernetes命令行工具`kubectl`允许你对`Kubernetes`集群发布命令。你可以使用kubectl部署应用，检视和管理你的集群资源，查看日志等。

参阅[安装和设置kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 以获取如何下载和安装kubectl并设置他以访问你的集群。

你也可以阅读[kubectl 引用文档](https://kubernetes.io/docs/reference/kubectl/)。
#### Minikube
[Minikube](https://minikube.sigs.k8s.io/)是一个让你本地运行Kubernetes的工具。Minikube运行一个安装在你的ＰＣ（包括Windows, macOS 和 Linux PC）上的单节点Kubernetes集群，如此你可以尝试Kubernetes，或用于日常开发工作。

你可以参考[官方入门指南](https://minikube.sigs.k8s.io/docs/start/)，如果你的关注点是安装工具，请参阅[安装Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)。

一旦你已经有可运行的Minikube，你可以使用它[运行一个示例应用](https://kubernetes.io/docs/tutorials/hello-minikube/)。
#### kind
就像Minikube，[kind](https://kind.sigs.k8s.io/docs/)让你在本地运行Kubernetes集群。但不像Minikube，kind仅仅工作于一个简单容器运行时：它需要你已经安装并配置好[Docker](https://docs.docker.com/get-docker/)。

[快速入门](https://kind.sigs.k8s.io/docs/user/quick-start/)需要如何做来设置并运行kind。
## 1. 安装并配置 kubectl
在 Kubernetes 上使用 Kubernetes 命令行工具 [kubectl](https://kubernetes.io/zh/docs/reference/kubectl/kubectl/) 部署和管理应用程序。使用 kubectl，你可以检查集群资源；创建、删除和更新组件；查看你的新集群；并启动实例应用程序。
### 1.1 准备开始
你必须使用与集群小版本号差别为一的 kubectl 版本。 例如，1.2 版本的客户端应该与 1.1 版本、1.2 版本和 1.3 版本的主节点一起使用。 使用最新版本的 kubectl 有助于避免无法预料的问题。
### 1.2 在 Linux 上安装 kubectl 
#### 在 Linux 上使用 curl 安装 kubectl 可执行文件
1. 使用下面命令下载最新的发行版本：
   ```
   curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
   ```

   要下载特定版本， `$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)`部分替换为指定版本。

   例如，要下载 Linux 上的版本 v1.19.0，输入：
   ```
   curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
   ```
2. 标记 kubectl 文件为可执行：
   ```
   chmod +x ./kubectl
   ```
3. 将文件放到 PATH 路径下：
   ```
   sudo mv ./kubectl /usr/local/bin/kubectl
   ```
4. 测试你所安装的版本是最新的：
   ```
   kubectl version --client
   ```
#### 使用原生包管理器安装
Ubuntu, Debian：

```
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Redhat， Centos：
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl
```
#### 使用其他包管理器安装
如果你使用 Ubuntu 或者其他支持 snap 包管理器的 Linux 发行版，kubeclt 可以作为 Snap 应用来安装：
```
snap install kubectl --classic

kubectl version --client
```
### 1.3 在 macOS 上安装 kubectl
### 1.4 在 Windows 上安装 kubectl
### 1.5 将 kubectl 作为 Google Cloud SDK 的一部分下载
kubectl 可以作为 Google Cloud SDK 的一部分进行安装。
1. 安装 [Google Cloud SDK](https://cloud.google.com/sdk/)
2. 运行以下命令安装 kubectl：
   ```
   gcloud components install kubectl
   ```
3. 测试以确保你安装的版本是最新的：
   ```
   kubectl version --client
   ```
### 1.6 验证 kubectl 配置
kubectl 需要一个 [kubeconfig 配置文件](https://kubernetes.io/zh/docs/concepts/configuration/organize-cluster-access-kubeconfig/) 使其找到并访问 Kubernetes 集群。 当你使用 `kube-up.sh` 脚本创建 Kubernetes 集群或者部署 Minikube 集群时，会自动生成 kubeconfig 配置文件。

通过获取集群状态检查 kubectl 是否被正确配置：
```
kubectl cluster-info
```
如果你看到一个 URL 被返回，那么 kubectl 已经被正确配置，能够正常访问你的 Kubernetes 集群。

如果你看到类似以下的信息被返回，那么 kubectl 没有被正确配置，无法正常访问你的 Kubernetes 集群。
```
The connection to the server <server-name:port> was refused - did you specify the right host or port?
```

例如，如果你打算在笔记本电脑（本地）上运行 Kubernetes 集群，则需要首先安装 minikube 等工具，然后重新运行上述命令。

如果 kubectl cluster-info 能够返回 URL 响应，但你无法访问你的集群，可以使用下面的命令检查配置是否正确：
```
kubectl cluster-info dump
```
### 1.7 可选的 kubectl 配置
#### 启用 shell 自动补全功能
kubectl 为 Bash 和 Zsh 支持自动补全功能，可以节省大量输入！

下面是设置 Bash 与 Zsh 下自动补齐的过程（包括 Linux 与 macOS 的差异）。

##### Linux上的Bash
用于 Bash 的 kubectl 自动补齐脚本可以用 `kubectl completion bash` 命令生成。 在 Shell 环境中引用自动补齐脚本就可以启用 kubectl 自动补齐。

不过，补齐脚本依赖于 [bash-completion](https://github.com/scop/bash-completion) 软件包， 这意味着你必须先安装 bash-completion（你可以通过运行 type _init_completion）来测试是否 你已经安装了这个软件）。

**安装 bash-completion**

很多包管理器都提供 bash-completion（参见[这里](https://github.com/scop/bash-completion#installation)）。 你可以通过 `apt-get install bash-completion` 或 `yum install bash-completion`来安装。

上述命令会创建 `/usr/share/bash-completion/bash_completion`，也就是 `bash-completion` 的主脚本。 取决于所用的包管理器，你可能必须在你的 `~/.bashrc` 中通过 `source` 源引此文件。

要搞清楚这一点，可以重新加载你的 Shell 并运行 `type _init_completion`。 如果命令成功，一切就绪；否则你就需要将下面的内容添加到你的 `~/.bashrc` 文件中：
```
source /usr/share/bash-completion/bash_completion
```

之后，重新加载你的 Shell 并运行 type _init_completion 来检查 bash-completion 是否已 正确安装。

**启用 kubectl 自动补齐**

你现在需要确定在你的所有 Shell 会话中都源引了 kubectl 自动补齐脚本。 实现这点有两种方式：
+ 在 `~/.bashrc` 文件中源引自动补齐脚本
  ```
  echo 'source <(kubectl completion bash)' >>~/.bashrc
  ```
+ 将自动补齐脚本添加到目录 `/etc/bash_completion.d`：
  ```
  kubectl completion bash >/etc/bash_completion.d/kubectl
  ```

如果你为 kubectl 命令设置了别名（alias），你可以扩展 Shell 补齐，使之能够与别名一起使用：
```
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
```
> **说明**： bash-completion 会自动源引 /etc/bash_completion.d 下的所有自动补齐脚本。

两种方法是等价的。重新加载 Shell 之后，kubectl 的自动补齐应该能够使用了。
## 2. 安装 Minikube
本页面讲述如何安装 [Minikube](https://kubernetes.io/zh/docs/tutorials/hello-minikube)，该工具用于在你电脑中的虚拟机上运行一个单节点的 Kubernetes 集群。
### 2.1 准备开始
若要检查你的 Linux 是否支持虚拟化技术，请运行下面的命令并验证输出结果是否不为空：
```
grep -E --color 'vmx|svm' /proc/cpuinfo
```
### 2.2 安装 minikube
#### 2.2.1 安装 kubectl
请确保你已正确安装 kubectl。你可以根据[安装并设置 kubectl](https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux) 的说明来安装 kubectl。
#### 2.2.2 安装 Hypervisor
如果还没有装过 hypervisor，请选择以下方式之一进行安装：
- [KVM](https://www.linux-kvm.org/)，KVM 也使用了 QEMU
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
Minikube 还支持使用一个 `--vm-driver=none` 选项，让 Kubernetes 组件运行在主机上，而不是在 VM 中。 使用这种驱动方式需要 [Docker](https://www.docker.com/products/docker-desktop) 和 Linux 环境，但不需要 hypervisor。

如果你在 Debian 系的 OS 中使用了 `none` 这种驱动方式，请使用 `.deb` 包安装 `Docker`，不要使用 `snap` 包的方式，Minikube 不支持这种方式。 你可以从 [Docker](https://www.docker.com/products/docker-desktop) 下载 `.deb` 包。

> **注意**： none VM 驱动方式存在导致安全和数据丢失的问题。 使用 --vm-driver=none 之前，请参考这个文档获取详细信息。

Minikube 还支持另外一个类似于 Docker 驱动的方式 vm-driver=podman。 使用超级用户权限（root 用户）运行 Podman 可以最好的确保容器具有足够的权限使用 你的操作系统上的所有特性。

> **注意**： Podman 驱动需要以 root 用户身份运行容器，因为普通用户帐户没有足够的权限 使用容器运行可能需要的操作系统上的所有特性。
#### 2.2.3 使用包安装 Minikube
Minikube 有 实验性 的安装包。你可以在 Minikube 在 GitHub 上的[发行版本](https://github.com/kubernetes/minikube/releases)找到 Linux (AMD64) 的包。

根据你的 Linux 发行版选择安装合适的包。
#### 2.2.4 直接下载并安装 Minikube
如果你不想通过包安装，你也可以下载并使用一个单节点二进制文件。

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
```

将 Minikube 可执行文件添加至 PATH：
```
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
```
#### 2.2.5 使用 Homebrew 安装 Minikube
你还可以使用 Linux [Homebrew](https://docs.brew.sh/Homebrew-on-Linux) 安装 Minikube：
```
brew install minikube
```
### 2.3 安装确认
要确认 hypervisor 和 Minikube 均已成功安装，可以运行以下命令来启动本地 Kubernetes 集群：
> **说明**： 若要为 minikube start 设置 --vm-driver，在下面提到 <驱动名称> 的地方， 用小写字母输入你安装的 hypervisor 的名称。 指定[VM 驱动程序](https://kubernetes.io/zh/docs/setup/learning-environment/minikube/#specifying-the-vm-driver)列举了 --vm-driver 值的完整列表。

> **说明**： 由于国内无法直接连接 k8s.gcr.io，推荐使用阿里云镜像仓库，在 minikube start 中添加 --image-repository 参数。

```
minikube start --vm-driver=<驱动名称>
# 或者在需要时
minikube start --vm-driver=<驱动名称> --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```

一旦 minikube start 完成，你可以运行下面的命令来检查集群的状态：`minikube status`

如果你的集群正在运行，minikube status 的输出结果应该类似于这样：
```
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

在确认 Minikube 与 hypervisor 均正常工作后，你可以继续使用 Minikube 或停止集群。要停止集群，请运行：`minikube stop`
### 2.4 清理本地状态
如果你之前安装过 Minikube，并运行了：
```
minikube start
```
并且 minikube start 返回了一个错误：
```
machine does not exist
```
那么，你需要清理 minikube 的本地状态：
```
minikube delete
```

## Reference
- [安装工具](https://kubernetes.io/zh/docs/tasks/tools/)
- [Install Tools](https://kubernetes.io/docs/tasks/tools/)
- [Minikube - Kubernetes本地实验环境](https://developer.aliyun.com/article/221687)