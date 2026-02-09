# Image Build & Push

## Build

docker build -t aks-demo-app:1.0.0 .

## Push

az acr login -n lakmoosacr

docker tag aks-demo-app:1.0.0 lakmoosacr.azurecr.io/aks-demo-app:1.0.0
docker push lakmoosacr.azurecr.io/aks-demo-app:1.0.0
