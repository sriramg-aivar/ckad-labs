#!/bin/bash
set -e

echo "Setting up Scenario 13 – Create NodePort Service..."

# Start clean so re-running is safe (the Deployment selector is immutable, and
# other scenarios also use the name 'api-server', so we must delete first).
kubectl delete service api-nodeport -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl delete deployment api-server -n default --ignore-not-found >/dev/null 2>&1 || true

# Wait for the old deployment to be fully gone before recreating with a new selector.
kubectl wait --for=delete deployment/api-server -n default --timeout=60s >/dev/null 2>&1 || true

# Create deployment api-server: 2 replicas, label app=api, container port 9090.
# Declarative apply with the selector baked in — no immutable-field patching.
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: default
  labels:
    app: api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: nginx:latest
          ports:
            - containerPort: 9090
EOF

# Wait for deployment to be ready
echo "Waiting for deployment api-server to be ready..."
kubectl rollout status deployment/api-server -n default --timeout=90s

echo ""
echo "Setup complete! Your task:"
echo "  Create a NodePort Service named 'api-nodeport' that:"
echo "  - Type: NodePort"
echo "  - Selects pods with label app=api"
echo "  - Service port: 80, target port: 9090"
