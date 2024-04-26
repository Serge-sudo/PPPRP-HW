APP_IMAGE_NAME="time-app"
FETCHER_IMAGE_NAME="fetcher"
ISTIO_VERSION="1.21.2"

set -e

eval $(minikube docker-env) 

cd app
docker build -t $APP_IMAGE_NAME:latest .

cd ../script
docker build -t $FETCHER_IMAGE_NAME:latest .

cd ..
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd istio-$ISTIO_VERSION
export PATH=$PWD/bin:$PATH
istioctl install --set profile=default --set values.global.proxy.autoInject=enabled -y
kubectl label namespace default istio-injection=enabled

cd ../k8s
kubectl apply -f time-app-gateway.yaml
kubectl apply -f time-app-virtualservice.yaml
kubectl apply -f worldtimeapi-serviceentry.yaml

kubectl apply -f time-deployment.yaml
kubectl apply -f fetcher-deployment.yaml

kubectl wait --for=condition=ready pod -l app=time --timeout=120s
kubectl wait --for=condition=ready pod -l app=fetcher --timeout=120s

kubectl port-forward svc/istio-ingressgateway 8080:80 -n istio-system
