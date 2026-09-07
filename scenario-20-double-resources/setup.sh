#!/bin/bash
set -e

echo "Setting up Scenario 20 – Double the resource requests and limits..."

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: compute-app
  namespace: default
  labels:
    app: compute-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: compute-app
  template:
    metadata:
      labels:
        app: compute-app
    spec:
      containers:
        - name: worker
          image: nginx:1.25
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "250m"
              memory: "256Mi"
EOF

echo "Waiting for deployment to be ready..."
kubectl rollout status deploy/compute-app -n default --timeout=90s || true

echo ""
echo "Setup complete! Deployment 'compute-app' (container 'worker') currently has:"
echo "  requests: cpu=100m, memory=128Mi"
echo "  limits:   cpu=250m, memory=256Mi"
echo ""
echo "Your task: DOUBLE every request and limit value, then roll out."
echo "  Expected -> requests: cpu=200m, memory=256Mi | limits: cpu=500m, memory=512Mi"
