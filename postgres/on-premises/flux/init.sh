kubectl create secret generic discord --from-file=address=discord.txt
sudo yum install -y git
git clone https://github.com/MOUAK-Ayoub/gitops-flux.git
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
kustomize create --autodetect --recursive
kubectl get providers.notification.toolkit.fluxcd.io
kubectl get alerts.notification.toolkit.fluxcd.io

# put the public key generated  in the github repo as a deploy key with allowing write access
flux create secret git k8s-auth-github \
   --url=https://github.com/MOUAK-Ayoub/kubernetes.git \
   --username=ayoub.mouak.2015@gmail.com \
   --password='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' \
   --namespace=default

mkdir {sources,kustomizations}
flux create source git  no-helm-temp-source \
   --url=https://github.com/MOUAK-Ayoub/kubernetes.git \
   --branch=master \
   --namespace=default \
   --username=ayoub.mouak.2015@gmail.com \
   --password='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' \
   --export > sources/no-helm-temp-deployment.yaml

flux create kustomization   no-helm-temp-kustom \
   --source=no-helm-temp-source.default \
   --path=no-helm-temp \
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



