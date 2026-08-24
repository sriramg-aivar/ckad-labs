#!/bin/bash
set -e

echo "Cleaning up Scenario 15..."

kubectl delete ingress api-ingress -n default --ignore-not-found
kubectl delete service api-svc -n default --ignore-not-found
kubectl delete deployment api-deploy -n default --ignore-not-found
rm -f /root/fix-ingress.yaml

echo "Cleanup complete."
