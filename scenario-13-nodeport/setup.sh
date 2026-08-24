#!/bin/bash
set -e

echo "Setting up Scenario 13 – Create NodePort Service..."

# Create deployment api-server with 2 replicas, label app=api, container port 9090
kubectl create deployment api-server --image=nginx --replicas=2 --port=9090 -n default
kubectl label deployment api-server app=api -n default --overwrite

# Patch to ensure pod template has correct labels and containerPort
kubectl patch deployment api-server -n default --type='json' -p='[
  {"op": "replace", "path": "/spec/template/metadata/labels", "value": {"app": "api"}},
  {"op": "replace", "path": "/spec/selector/matchLabels", "value": {"app": "api"}},
  {"op": "replace", "path": "/spec/template/spec/containers/0/ports", "value": [{"containerPort": 9090}]}
]'

# Wait for deployment to be ready
echo "Waiting for deployment api-server to be ready..."
kubectl rollout status deployment/api-server -n default --timeout=60s

echo ""
echo "Setup complete! Your task:"
echo "  Create a NodePort Service named 'api-nodeport' that:"
echo "  - Type: NodePort"
echo "  - Selects pods with label app=api"
echo "  - Service port: 80, target port: 9090"
