#!/bin/bash

echo "Cleaning up Scenario 10..."

kubectl delete deployment api-deploy --ignore-not-found
echo "Cleanup complete."
