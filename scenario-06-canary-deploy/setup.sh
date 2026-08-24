#!/bin/bash
# Setup for Scenario 06 – Create Canary Deployment with Manual Traffic Split
set -e

echo "Setting up Scenario 06..."

# Create the web-app deployment with 5 replicas
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
      version: v1
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
        - name: nginx
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF

# Create the web-service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  selector:
    app: webapp
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
EOF

# Wait for deployment to be ready
echo "Waiting for web-app deployment to be ready..."
kubectl rollout status deploy web-app -n default --timeout=120s

echo ""
echo "Setup complete!"
echo "Resources created: Deployment/web-app (5 replicas), Service/web-service"
echo ""
echo "Your task: Create a canary deployment for a 80/20 traffic split."
