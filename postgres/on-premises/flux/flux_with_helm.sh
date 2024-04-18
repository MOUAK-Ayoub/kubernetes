flux create source helm postgres \
--url=http://5533aa4e261c.mylabserver.com:8080 \
--namespace=default \
--export > ./sources/helm-repo-postgres.yaml
cd sources
kustomize create --autodetect --recursive
cd ..

kubectl get helmrepositories.source.toolkit.fluxcd.io 

mkdir helmreleases
flux create helmrelease demo-postgres-flux \
--source=HelmRepository/postgres \
--chart=my-postgres \
--namespace=default \
--export > ./helmreleases/postgres.yaml
cd helmreleases
kustomize create --autodetect --recursive
cd ..

kubectl get helmreleases.helm.toolkit.fluxcd.io