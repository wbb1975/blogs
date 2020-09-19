https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
https://kubernetes.io/docs/setup/production-environment/container-runtimes/
https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_kubernetes/get_started_orchestrating_containers_with_kubernetes
https://www.howtoforge.com/tutorial/centos-kubernetes-docker-cluster/

sudo systemctl daemon-reload
sudo systemctl restart docker
journalctl -xeu kubelet

https://zhuanlan.zhihu.com/p/138554103
https://www.cnblogs.com/architectforest/p/13153053.html
kubeadm join 192.168.0.114:6443 --token x1jvjy.hryo0sf4eoa7hwo5 --discovery-token-ca-cert-hash sha256:93f8642a6fb52891e780e83fac9e077bdef577b9c583854a3bd985ea653733f5


https://linuxconfig.org/how-to-move-docker-s-default-var-lib-docker-to-another-directory-on-ubuntu-debian-linux

https://edu.aliyun.com/lesson_1651_16894#_16894
minikube start --vm-driver docker  --cpus=4 --memory=4096mb --image-mirror-country cn --registry-mirror=https://9cpn8tt6.mirror.aliyuncs.com

http://docs.kubernetes.org.cn/227.html
https://anoyi.com/cncf
http://docs.kubernetes.org.cn/   ==》作为索引
https://kubernetes.io/zh/docs/concepts/overview/  ==》查看详细内容

k8s.gcr.io 国内无法访问的替代解决方案
借助 Travis CI 让其每天自动运行，将所有用得到的 gcr.io 下的镜像同步到了 Docker Hub 使用方法 目前对于一个 gcr.io 下的镜像，可以*直接将 k8s.gcr.io 替换为 gcrxio *用户名，然后从 Docker Hub 直接拉取，以下为一个示例:
两个字，这大神，牛逼。
方法二：网友同步方案（推荐，直接使用）
```
# 原始命令
docker pull k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0
# 使用国内第三方（网友）同步仓库
docker pull gcrxio/kubernetes-dashboard-amd64:v1.10.0
docker pull anjia0532/kubernetes-dashboard-amd64:v1.10.0
```
方法三：https://github.com/anjia0532/gcr.io_mirror
k8s.gcr.io/{image}/{tag} <==> gcr.io/google-containers/{image}/{tag} <==> gcr.azk8s.cn/namespace/image_name:image_tag 