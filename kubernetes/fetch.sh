#!/bin/bash
images=(
kube-apiserver:v1.18.6
kube-controller-manager:v1.18.6
kube-scheduler:v1.18.6
kube-proxy:v1.18.6
pause:3.1
etcd:3.2.24
coredns:1.2.6
)
for imageName in ${images[@]} ; do
        docker pull registry.aliyuncs.com/google_containers/$imageName
        docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
        docker rmi registry.aliyuncs.com/google_containers/$imageName
done
