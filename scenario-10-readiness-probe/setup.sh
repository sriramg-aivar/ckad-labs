#!/bin/bash
set -e

echo "Setting up Scenario 10 - Readiness Probe..."

# Create deployment api-deploy with nginx image, containerPort 8080, 2 replicas, container name 'api'
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-deploy
  template:
    metadata:
      labels:
        app: api-deploy
    spec:
      containers:
        - name: api
          image: nginx
          ports:
            - containerPort: 8080
EOF

# Wait for deployment to be ready
echo "Waiting for deployment api-deploy to be ready..."
kubectl rollout status deploy api-deploy --timeout=120s

echo ""
echo "Setup complete! Deployment api-deploy is running."
echo "Run 'cat TASK.md' to see your task."
