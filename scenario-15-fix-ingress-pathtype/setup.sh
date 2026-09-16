#!/bin/bash
set -e

echo "Setting up Scenario 15 – Fix Ingress PathType..."

# Start clean so re-running is safe (Deployment selector is immutable).
kubectl delete ingress api-ingress -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl delete service api-svc -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl delete deployment api-deploy -n default --ignore-not-found >/dev/null 2>&1 || true
kubectl wait --for=delete deployment/api-deploy -n default --timeout=60s >/dev/null 2>&1 || true

# Create deployment api-deploy with label app=api (declarative — no immutable patching)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy
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
            - containerPort: 80
EOF

# Create service api-svc with port 8080, targetPort 80, selector app=api
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: default
spec:
  selector:
    app: api
  ports:
    - port: 8080
      targetPort: 80
      protocol: TCP
EOF

# Create the broken ingress YAML at /root/fix-ingress.yaml
cat > /root/fix-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: InvalidType
        backend:
          service:
            name: api-svc
            port:
              number: 8080
EOF

# Wait for deployment to be ready
echo "Waiting for deployment api-deploy to be ready..."
kubectl rollout status deployment/api-deploy -n default --timeout=60s

echo ""
echo "Setup complete! Your task:"
echo "  1. Try to apply /root/fix-ingress.yaml (it will fail)"
echo "  2. Fix the pathType to a valid value"
echo "  3. Apply the fixed manifest successfully"
