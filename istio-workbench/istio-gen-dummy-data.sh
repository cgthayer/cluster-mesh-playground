#!/bin/bash

POD=$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')
HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.clusterIP}')

max=30
echo -n "Sending ${max} requests: "
for i in $(seq 1 $max); do
    echo -n "$i "
    kubectl exec ${POD} -- curl -s -o /dev/null ${HOST}/productpage
done
echo

