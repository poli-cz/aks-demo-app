ACR="lakmoosacr.azurecr.io"
APP="aks-demo-app"
TAG="1.0.0"

docker tag ${APP}:${TAG} ${ACR}/${APP}:${TAG}
docker push ${ACR}/${APP}:${TAG}
