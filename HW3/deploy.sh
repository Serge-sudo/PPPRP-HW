APP_IMAGE_NAME="time-app"
FETCHER_IMAGE_NAME="fetcher"
EXPORTER_IMAGE_NAME="prometheus-exporter"
ISTIO_VERSION="1.21.2"
OLM_VERSION="v0.27.0"
OLM_BASE_URL="https://github.com/operator-framework/operator-lifecycle-manager/releases/download"

set -e

eval $(minikube docker-env) 

cd app
docker build -t $APP_IMAGE_NAME:latest .

cd ../script
docker build -t $FETCHER_IMAGE_NAME:latest .


cd ../exporter
docker build -t $EXPORTER_IMAGE_NAME:latest .

cd ..
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
cd istio-$ISTIO_VERSION
export PATH=$PWD/bin:$PATH
istioctl install --set profile=default --set values.global.proxy.autoInject=enabled -y
kubectl label namespace default istio-injection=enabled

# INSTAL OLM
# curl -sL "${OLM_BASE_URL}/${OLM_VERSION}/install.sh" | bash -s -- "${OLM_VERSION}" "${OLM_BASE_URL}"
# kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml


kubectl wait --for=condition=available deployment --all -n olm --timeout=300s

cd ../k8s

kubectl apply -f time-app-gateway.yaml
kubectl apply -f time-app-virtualservice.yaml
kubectl apply -f worldtimeapi-serviceentry.yaml
kubectl apply -f time-deployment.yaml
kubectl apply -f fetcher-deployment.yaml
kubectl apply -f exporter-deployment.yaml
kubectl apply -f role.yaml
kubectl apply -f prometheus-config.yaml
kubectl apply -f service-monitor.yaml

kubectl wait --for=condition=ready pod -l app=time --timeout=120s
kubectl wait --for=condition=ready pod -l app=fetcher --timeout=120s
kubectl wait --for=condition=ready pod -l app=exporter --timeout=120s

# PORT FORWARDING
# kubectl port-forward svc/istio-ingressgateway 8080:80 -n istio-system
# kubectl port-forward svc/prometheus 9090
