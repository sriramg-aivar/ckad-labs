#!/bin/bash
# Setup for Scenario 07 – Fix NetworkPolicy by Updating Pod Labels
set -e

echo "Setting up Scenario 07..."

# Create namespace
kubectl create namespace network-demo --dry-run=client -o yaml | kubectl apply -f -

# Create pods with WRONG labels
kubectl run frontend -n network-demo --image=busybox --labels="role=wrong-frontend" --command -- sleep 3600
kubectl run backend -n network-demo --image=nginx --labels="role=wrong-backend"
kubectl run database -n network-demo --image=busybox --labels="role=wrong-db" --command -- sleep 3600

# Create NetworkPolicy: deny-all (default deny all ingress)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: network-demo
spec:
  podSelector: {}
  policyTypes:
    - Ingress
EOF

# Create NetworkPolicy: allow-frontend-to-backend
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 80
EOF

# Create NetworkPolicy: allow-backend-to-db
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-db
  namespace: network-demo
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: backend
      ports:
        - protocol: TCP
          port: 3306
EOF

# Wait for pods to be running
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod/frontend -n network-demo --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/backend -n network-demo --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/database -n network-demo --timeout=60s 2>/dev/null || true

echo ""
echo "Setup complete!"
echo "Namespace: network-demo"
echo "Pods: frontend (role=wrong-frontend), backend (role=wrong-backend), database (role=wrong-db)"
echo "NetworkPolicies: deny-all, allow-frontend-to-backend, allow-backend-to-db"
echo ""
echo "Your task: Fix the Pod labels to match the NetworkPolicy selectors."
