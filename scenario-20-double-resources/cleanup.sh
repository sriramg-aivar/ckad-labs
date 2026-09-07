#!/bin/bash
set -e

echo "Cleaning up Scenario 20..."

kubectl delete deployment compute-app -n default --ignore-not-found

echo "Cleanup complete."
