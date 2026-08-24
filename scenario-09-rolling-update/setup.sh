#!/bin/bash
set -e

echo "Setting up Scenario 09 - Rolling Update and Rollback..."

# Create deployment app-v1 with nginx:1.20, 3 replicas, container name 'web'
kubectl create deployment app-v1 --image=nginx:1.20 --replicas=3 --dry-run=client -o yaml | \
  sed 's/name: nginx/name: web/' | \
  kubectl apply -f -

# Add annotation to record the change cause for revision history
kubectl annotate deployment app-v1 kubernetes.io/change-cause="Initial deployment with nginx:1.20"

# Wait for deployment to be ready
echo "Waiting for deployment app-v1 to be ready..."
kubectl rollout status deploy app-v1 --timeout=120s

echo ""
echo "Setup complete! Deployment app-v1 is running with nginx:1.20"
echo "Run 'cat TASK.md' to see your task."
