# Install helm
echo '***********************************************k8s_addson script begin*****************************************'


sudo -u ec2-user -i <<'EOF'
curl -LO https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar xzvf helm-v3.14.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

curl -s https://fluxcd.io/install.sh | sudo bash
export GITHUB_TOKEN='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'
echo "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" | flux bootstrap github

flux bootstrap github --token-auth \
--owner=MOUAK-Ayoub --repository=gitops-flux \
--personal  --branch=main --reconcile  \
--components-extra=image-reflector-controller,image-automation-controller

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/kustomize
echo 'https://discord.com/api/webhooks/1229362152675217423/AoOuxcM-27gtTMNPbQG63RAO1i7y-0GxAi2vdhsRD269CiLZKZjyf7elIYcEMyDEmqwA' >> discord.txt

EOF

echo '***********************************************k8s_addson script end*****************************************'
