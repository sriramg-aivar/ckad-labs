#!/bin/bash
set -e

echo "Setting up Scenario 16 – Add Resource Requests and Limits to Pod..."

# Create namespace prod
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Create ResourceQuota in prod
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: prod
spec:
  hard:
    limits.cpu: "2"
    limits.memory: "4Gi"
    requests.cpu: "1"
    requests.memory: "2Gi"
EOF

echo "Waiting for ResourceQuota to be active..."
sleep 2

echo ""
echo "Setup complete! Your task:"
echo "  1. Check the ResourceQuota in namespace 'prod'"
echo "  2. Create a Pod named 'resource-pod' with:"
echo "     - Image: nginx:latest"
echo "     - CPU/memory limits set to HALF the quota limits"
echo "     - Requests: at least 100m CPU and 128Mi memory"
