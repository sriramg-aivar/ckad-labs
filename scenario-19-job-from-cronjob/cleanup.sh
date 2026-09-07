#!/bin/bash
set -e

echo "Cleaning up Scenario 19..."

kubectl delete job manual-report -n default --ignore-not-found
kubectl delete cronjob report-generator -n default --ignore-not-found

echo "Cleanup complete."
