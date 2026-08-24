#!/bin/bash
set -e

echo "=== Setting up Scenario 01: Create Secret from Hardcoded Variables ==="

# Clean up any existing resources
kubectl delete deploy api-server -n default --ignore-not-found 2>/dev/null
kubectl delete secret db-credentials -n default --ignore-not-found 2>/dev/null

# Create deployment with hardcoded env vars
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
        - name: api
          image: nginx:latest
          env:
            - name: DB_USER
              value: "admin"
            - name: DB_PASS
              value: "Secret123!"
EOF

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deploy api-server -n default --timeout=60s

echo ""
echo "=== Setup complete ==="
echo ""
echo "TASK: Deployment 'api-server' has hardcoded env vars DB_USER and DB_PASS."
echo "      Create a Secret 'db-credentials' and update the Deployment to use secretKeyRef."
echo ""
echo "See TASK.md for full instructions."
