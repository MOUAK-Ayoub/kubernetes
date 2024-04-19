flux create source git  postgres-chart \
   --url=https://github.com/MOUAK-Ayoub/kubernetes.git \
   --branch=master \
   --namespace=default \
   --username=ayoub.mouak.2015@gmail.com \
   --password=$GITHUB_TOKEN \
   --export > sources/postgres-chart.yaml

cd sources
kustomize create --autodetect --recursive
cd ..

flux create helmrelease postgres-from-git \
  --interval=1m \
  --source=GitRepository/postgres-chart \
  --chart=./postgres/on-premises/my-postgres \
  --values=./my-values.yaml \
  --namespace=default \
  --export > helmreleases/postgres-helmrelease.yaml
cd helmreleases
kustomize create --autodetect --recursive
cd ..
