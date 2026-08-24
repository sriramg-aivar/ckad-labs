#!/bin/bash
# Cleanup for Scenario 06 – Canary Deployment
echo "Cleaning up Scenario 06..."

kubectl delete deploy web-app --ignore-not-found -n default
kubectl delete deploy web-app-canary --ignore-not-found -n default
kubectl delete svc web-service --ignore-not-found -n default

echo "Cleanup complete."
