#!/bin/bash
set -e

echo "Setting up Scenario 11 - Security Context..."

# Create deployment secure-app with nginx image, container name 'app', no security context
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
        - name: app
          image: nginx
EOF

# Wait for deployment to be ready
echo "Waiting for deployment secure-app to be ready..."
kubectl rollout status deploy secure-app --timeout=120s

echo ""
echo "Setup complete! Deployment secure-app is running without any security context."
echo "Run 'cat TASK.md' to see your task."
