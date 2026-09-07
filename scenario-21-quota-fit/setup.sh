#!/bin/bash
set -e

echo "Setting up Scenario 21 – Make a Deployment fit within the namespace ResourceQuota..."

# Namespace
kubectl create namespace team-a --dry-run=client -o yaml | kubectl apply -f -

# ResourceQuota: total limits across the namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a
spec:
  hard:
    requests.cpu: "1"
    requests.memory: "1Gi"
    limits.cpu: "2"
    limits.memory: "2Gi"
EOF

# Deployment that is TOO BIG to fit: 4 replicas * limits(cpu=800m,mem=768Mi)
#   = limits.cpu 3200m (> 2000m quota) and limits.mem 3072Mi (> 2048Mi quota)
# So some replicas will be BLOCKED by the quota (FailedCreate on the ReplicaSet).
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: team-app
  namespace: team-a
  labels:
    app: team-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: team-app
  template:
    metadata:
      labels:
        app: team-app
    spec:
      containers:
        - name: app
          image: nginx:1.25
          resources:
            requests:
              cpu: "300m"
              memory: "256Mi"
            limits:
              cpu: "800m"
              memory: "768Mi"
EOF

echo "Waiting a moment for the ReplicaSet to try (and partly fail) to create pods..."
sleep 5

echo ""
echo "Setup complete!"
echo "  Namespace 'team-a' has a ResourceQuota:"
echo "     requests.cpu=1,  requests.memory=1Gi"
echo "     limits.cpu=2,    limits.memory=2Gi"
echo ""
echo "  Deployment 'team-app' wants 4 replicas but its per-pod resources are too big,"
echo "  so the quota BLOCKS some pods (check: kubectl get deploy team-app -n team-a)."
echo ""
echo "Your task: adjust the container resources so ALL 4 replicas fit within the quota"
echo "and the deployment becomes fully available."
