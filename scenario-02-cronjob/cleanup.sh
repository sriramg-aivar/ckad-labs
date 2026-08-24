#!/bin/bash

echo "=== Cleaning up Scenario 02 ==="

kubectl delete cronjob backup-job -n default --ignore-not-found
kubectl delete jobs -l job-name=backup-job -n default --ignore-not-found 2>/dev/null

echo "=== Cleanup complete ==="
