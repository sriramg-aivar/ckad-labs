#!/bin/bash

echo "=== Cleaning up Scenario 01 ==="

kubectl delete deploy api-server -n default --ignore-not-found
kubectl delete secret db-credentials -n default --ignore-not-found

echo "=== Cleanup complete ==="
