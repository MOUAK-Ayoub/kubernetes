# Install helm
echo '***********************************************k8s_addson script begin*****************************************'


sudo -u ec2-user -i <<'EOF'
curl -LO https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar xzvf helm-v3.14.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

curl -s https://fluxcd.io/install.sh | sudo bash

flux bootstrap github --token-auth \
--owner=MOUAK-Ayoub --repository=gitops-flux \
--personal  --branch=main --reconcile  \
--components-extra=image-reflector-controller,image-automation-controller

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/kustomize

EOF

echo '***********************************************k8s_addson script end*****************************************'
