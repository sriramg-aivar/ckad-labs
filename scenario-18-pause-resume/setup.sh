#!/bin/bash
set -e

echo "Setting up Scenario 18 – Pause, update, and resume a Deployment..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rollout-app
  namespace: default
  labels:
    app: rollout-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: rollout-app
  template:
    metadata:
      labels:
        app: rollout-app
    spec:
      containers:
        - name: app
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF

echo "Waiting for deployment to be ready..."
kubectl rollout status deploy/rollout-app -n default --timeout=90s || true

# Make sure it starts un-paused
kubectl rollout resume deploy/rollout-app -n default >/dev/null 2>&1 || true

echo ""
echo "Setup complete! Deployment 'rollout-app' is running nginx:1.24 (4 replicas)."
echo "Your task:"
echo "  1. PAUSE the deployment rollout"
echo "  2. While paused, change image to nginx:1.26 AND set env RELEASE=canary"
echo "  3. Confirm NO new rollout happened yet (still paused)"
echo "  4. RESUME so both changes roll out together in ONE revision"
