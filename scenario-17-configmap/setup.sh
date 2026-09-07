#!/bin/bash
set -e

echo "Setting up Scenario 17 – ConfigMap consumed by Deployment..."

# Ensure any leftover configmap is gone so BEFORE-state is correct
kubectl delete configmap app-config -n default --ignore-not-found >/dev/null 2>&1 || true

# Create a plain deployment WITHOUT the configmap wiring (that's the task)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-config
  namespace: default
  labels:
    app: web-config
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-config
  template:
    metadata:
      labels:
        app: web-config
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

echo "Waiting for deployment to be ready..."
kubectl rollout status deploy/web-config -n default --timeout=90s || true

echo ""
echo "Setup complete! Your task:"
echo "  1. Create ConfigMap 'app-config' (APP_COLOR=blue, APP_MODE=production)"
echo "  2. Wire it into deployment 'web-config' container 'web' via envFrom"
echo "  3. Also mount it as a volume at /etc/appconfig"
