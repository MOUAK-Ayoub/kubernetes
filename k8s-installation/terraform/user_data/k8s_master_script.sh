#!/bin/bash

# Steps:
# 1/  Forwarding IPv4 and letting iptables see bridged traffic
# 2/ Install containerd
# 3/ Install kubelet kubeadm kubectl
# 4/ Make interaction with cluster accessible to ec2-user without sudo
# 5/ add calico plugin for networking
# 6/ Create token, that will be used by other nodes to join the cluster
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

kubeadm init --pod-network-cidr 190.0.0.0/16 --kubernetes-version 1.27.0
#calico installation is added here to use the .kube/config of ec2 user else export KUBECONFIG=.../admin.conf or do the same as previous for the root user
sudo -u ec2-user -i <<'EOF'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

curl -LO https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar xzvf helm-v3.14.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add stable https://charts.helm.sh/stable
git clone https://github.com/MOUAK-Ayoub/kubernetes.git
EOF

kubeadm  token create ${token} --description "Default token to use to authenticate"
echo '*********************************************** Script end*****************************************'
