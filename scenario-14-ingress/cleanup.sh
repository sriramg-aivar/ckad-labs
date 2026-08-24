#!/bin/bash
set -e

echo "Cleaning up Scenario 14..."

kubectl delete ingress web-ingress -n default --ignore-not-found
kubectl delete service web-svc -n default --ignore-not-found
kubectl delete deployment web-deploy -n default --ignore-not-found

echo "Cleanup complete."
