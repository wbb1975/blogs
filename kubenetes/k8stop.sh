#!/bin/bash
systemctl start kube-proxy
systemctl start kubelet
systemctl start kube-scheduler
systemctl start kube-controller-manager
systemctl start kube-apiserver
systemctl start docker
systemctl start etcd
