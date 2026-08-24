#!/bin/bash

echo "Cleaning up Scenario 11..."

kubectl delete deployment secure-app --ignore-not-found
echo "Cleanup complete."
