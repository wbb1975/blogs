{
	"registry-mirrors": [
		"https://registry.docker-cn.com"
	],
     "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"

}

sudo systemctl daemon-reload
sudo systemctl restart docker


ExecStart=/usr/bin/dockerd-current \
          --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current \
          --default-runtime=docker-runc \
          --authorization-plugin=rhel-push-plugin \
          --exec-opt native.cgroupdriver=systemd \
          --userland-proxy-path=/usr/libexec/docker/docker-proxy-current \
          --init-path=/usr/libexec/docker/docker-init-current \
          --seccomp-profile=/etc/docker/seccomp.json \
          $OPTIONS \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY \
          $REGISTRIES

https://zhuanlan.zhihu.com/p/138554103
https://www.cnblogs.com/architectforest/p/13153053.html
kubeadm join 192.168.0.114:6443 --token x1jvjy.hryo0sf4eoa7hwo5 --discovery-token-ca-cert-hash sha256:93f8642a6fb52891e780e83fac9e077bdef577b9c583854a3bd985ea653733f5
