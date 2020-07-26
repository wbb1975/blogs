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

minikube start --vm-driver docker --image-mirror-country cn --registry-mirror=https://9cpn8tt6.mirror.aliyuncs.com