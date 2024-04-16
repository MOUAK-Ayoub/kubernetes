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

git add .
git commit -am "add image policy and image repo"
git push
kubectl get imagerepositories.image.toolkit.fluxcd.io
kubectl get imagepolicies.image.toolkit.fluxcd.io