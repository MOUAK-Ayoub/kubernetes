mkdir imagerepos
flux create image repository nginxhello \
--image=docker.io/nbrown/nginxhello \
--interval=1m \
--namespace=default \
--export > imagerepos/image-repo.yaml

mkdir imagepolicies
flux create image policy nginxhello \
--image-ref=nginxhello \
--select-semver='>=1.20.x' \
--namespace=default \
--export > imagepolicies/image-policy-nginx.yaml

cd imagepolicies
kustomize create --autodetect --recursive
cd ..

mkdir imageupdate
flux create image update nginxhello \
--git-repo-ref=no-helm-temp-source \
--git-repo-path=./postgres/on-premises/no-helm-tmp \
--checkout-branch=master \
--push-branch=master \
--author-name=flux \
--author-email=flux@example.com \
--commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
--namespace=default \
--export > imageupdate/image-update-nginx.yaml

cd imageupdate
kustomize create --autodetect --recursive
cd ..
git add .
git commit -am "add image policy and image repo"
git push

kubectl get imagerepositories.image.toolkit.fluxcd.io
kubectl get imagepolicies.image.toolkit.fluxcd.io
kubectl get imageupdateautomations.image.toolkit.fluxcd.io
flux get images all --all-namespaces