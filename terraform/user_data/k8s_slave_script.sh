#!/bin/bash

# Three steps
# 1/  Forwarding IPv4 and letting iptables see bridged traffic
# 2/ Install containerd
# 3/ Install kubelet kubeadm kubectl
echo '*********************************************** Script begin*****************************************'

# modules in /etc/modules-load.d are loaded when kernel boot
tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF

# here we load the 2 modules now
modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
tee /etc/sysctl.d/99-k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF


# Apply sysctl params without reboot
sysctl --system

# Install containerd
yum install -y containerd

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
swapoff -a

tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.27/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.27/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
'${kubeadm_join_command}'
echo '*********************************************** Script end*****************************************'