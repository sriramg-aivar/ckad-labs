#!/bin/bash
set -e

echo "Cleaning up Scenario 13..."

kubectl delete deployment api-server -n default --ignore-not-found
kubectl delete service api-nodeport -n default --ignore-not-found

echo "Cleanup complete."
