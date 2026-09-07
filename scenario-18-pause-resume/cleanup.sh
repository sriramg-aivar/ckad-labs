#!/bin/bash
set -e

echo "Cleaning up Scenario 18..."

kubectl delete deployment rollout-app -n default --ignore-not-found

echo "Cleanup complete."
