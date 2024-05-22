#!/bin/bash

cd app
eval $(minikube docker-env) 
docker build -t time-app .

cd ../script
docker build -t fetcher .

cd ../k8s
kubectl apply -f time-deployment.yaml
kubectl apply -f fetcher-deployment.yaml

kubectl port-forward service/time-service 5000:5000

cd ..
