#!/bin/bash
# Cleanup for Scenario 08 – Fix Broken Deployment YAML
echo "Cleaning up Scenario 08..."

kubectl delete deploy broken-app --ignore-not-found -n default
rm -f /root/broken-deploy.yaml

echo "Cleanup complete."
