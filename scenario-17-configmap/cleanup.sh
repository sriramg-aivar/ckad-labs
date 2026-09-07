#!/bin/bash
set -e

echo "Cleaning up Scenario 17..."

kubectl delete deployment web-config -n default --ignore-not-found
kubectl delete configmap app-config -n default --ignore-not-found

echo "Cleanup complete."
