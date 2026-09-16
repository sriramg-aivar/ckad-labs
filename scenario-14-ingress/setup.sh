#!/bin/bash
set -e

echo "Setting up Scenario 14 – Create Ingress Resource..."

# Start clean so re-running is safe (Deployment selector is immutable).
kubectl delete ingress web-ingress -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl delete service web-svc -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl delete deployment web-deploy -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl wait --for=delete deployment/web-deploy -n default --timeout=60s >/dev/null 2>&1 || true

# Create deployment web-deploy with label app=web (declarative — no immutable patching)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  namespace: default
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:latest
          ports:
            - containerPort: 80
EOF

# Create service web-svc with selector app=web, port 8080, targetPort 80
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: default
spec:
  selector:
    app: web
  ports:
    - port: 8080
      targetPort: 80
      protocol: TCP
EOF

# Wait for deployment to be ready
echo "Waiting for deployment web-deploy to be ready..."
kubectl rollout status deployment/web-deploy -n default --timeout=60s

echo ""
echo "Setup complete! Your task:"
echo "  Create an Ingress named 'web-ingress' that:"
echo "  - Routes host web.example.com"
echo "  - Path / with pathType Prefix"
echo "  - Backend service web-svc on port 8080"
