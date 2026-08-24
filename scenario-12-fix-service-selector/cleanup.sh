#!/bin/bash

echo "Cleaning up Scenario 12..."

kubectl delete deployment web-app --ignore-not-found
kubectl delete service web-svc --ignore-not-found
echo "Cleanup complete."
