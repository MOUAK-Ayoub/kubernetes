export GITHUB_TOKEN='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'


flux bootstrap github --token-auth \
--owner=MOUAK-Ayoub --repository=gitops-flux \
--personal  --branch=main --reconcile  \
--components-extra=image-reflector-controller,image-automation-controller
kubectl get all --namespace flux-system
echo 'https://discord.com/api/webhooks/1229362152675217423/AoOuxcM-27gtTMNPbQG63RAO1i7y-0GxAi2vdhsRD269CiLZKZjyf7elIYcEMyDEmqwA' >> discord.txt
kubectl create secret generic discord --from-file=address=discord.txt
sudo yum install -y git

git clone  "https://$GITHUB_TOKEN@github.com/MOUAK-Ayoub/gitops-flux.git"
cd gitops-flux
mkdir -p notifications/{providers,alerts}
flux create alert-provider discord \
   --type=discord \
   --secret-ref=discord \
   --channel=gitops-flux \
   --username=flux-bot \
   --namespace=default \
   --export > notifications/providers/discord-provider.yaml


flux create alert alert-discord \
   --event-severity=info \
   --event-source=GitRepository/*,Kustomization/* \
   --provider-ref=discord \
   --namespace=default \
   --export > notifications/alerts/discord-alert.yaml

cd notifications
kustomize create --autodetect --recursive

# put the public key generated  in the github repo as a deploy key with allowing write access
#flux create secret git k8s-auth-github \
#  --url=https://github.com/MOUAK-Ayoub/kubernetes.git \
#   --username=ayoub.mouak.2015@gmail.com \
#   --password=$GITHUB_TOKEN \
#   --namespace=default

mkdir {sources,kustomizations}
flux create source git  no-helm-temp-source \
   --url=https://github.com/MOUAK-Ayoub/kubernetes.git \
   --branch=master \
   --namespace=default \
   --username=ayoub.mouak.2015@gmail.com \
   --password=$GITHUB_TOKEN \
   --export > sources/no-helm-temp-deployment.yaml

flux create kustomization   no-helm-temp-kustom \
   --source=no-helm-temp-source.default \
   --path=./postgres/on-premises/no-helm-temp \
   --prune=true \
   --target-namespace=default \
   --namespace=default \
   --export > kustomizations/no-helm-temp-kustom.yaml

cd sources
kustomize create --autodetect --recursive
cd ../kustomizations
kustomize create --autodetect --recursive
cd ..
git add .
git commit -am "commit sources and kustomizations"
git push


kubectl get providers.notification.toolkit.fluxcd.io
kubectl get alerts.notification.toolkit.fluxcd.io
kubectl get gitRepositories.source.toolkit.fluxcd.io
kubectl get kustomizations.kustomize.toolkit.fluxcd.io

postgres/on-premises/no-helm-tmp