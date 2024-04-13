# Install helm
echo '***********************************************k8s_addson script begin*****************************************'


sudo -u ec2-user -i <<'EOF'
curl -LO https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar xzvf helm-v3.14.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add stable https://charts.helm.sh/stable
EOF

echo '***********************************************k8s_addson script end*****************************************'
