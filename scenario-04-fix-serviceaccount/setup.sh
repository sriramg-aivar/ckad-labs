#!/bin/bash
set -e

echo "=== Setting up Scenario 04: Fix Broken Pod with Correct ServiceAccount ==="

# Clean up any existing resources
kubectl delete namespace monitoring --ignore-not-found 2>/dev/null
sleep 2

# Create namespace
kubectl create namespace monitoring

# Create ServiceAccounts
kubectl create sa monitor-sa -n monitoring
kubectl create sa wrong-sa -n monitoring
kubectl create sa admin-sa -n monitoring

# Create Role metrics-reader with get/list on pods
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: metrics-reader
  namespace: monitoring
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
EOF

# Create Role full-access (distractor)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: full-access
  namespace: monitoring
rules:
  - apiGroups: [""]
    resources: ["*"]
    verbs: ["*"]
EOF

# Create Role view-only (distractor)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: view-only
  namespace: monitoring
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get"]
EOF

# Create RoleBinding monitor-binding: binds metrics-reader to monitor-sa
kubectl create rolebinding monitor-binding \
  --role=metrics-reader \
  --serviceaccount=monitoring:monitor-sa \
  -n monitoring

# Create RoleBinding admin-binding: binds full-access to admin-sa (distractor)
kubectl create rolebinding admin-binding \
  --role=full-access \
  --serviceaccount=monitoring:admin-sa \
  -n monitoring

# Create pod metrics-pod using wrong-sa (will have auth errors)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: metrics-pod
  namespace: monitoring
spec:
  serviceAccountName: wrong-sa
  containers:
    - name: metrics
      image: busybox:latest
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            wget -qO- --header="Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
              https://kubernetes.default.svc/api/v1/namespaces/monitoring/pods --no-check-certificate 2>&1 || \
              echo "ERROR: User system:serviceaccount:monitoring:wrong-sa cannot list pods in the namespace monitoring"
            sleep 30
          done
EOF

# Wait for pod to be running
echo "Waiting for pod to be running..."
kubectl wait --for=condition=Ready pod/metrics-pod -n monitoring --timeout=60s 2>/dev/null || true

echo ""
echo "=== Setup complete ==="
echo ""
echo "TASK: Pod 'metrics-pod' in namespace 'monitoring' is using the wrong ServiceAccount."
echo "      Investigate existing RBAC resources and fix the pod to use the correct SA."
echo ""
echo "See TASK.md for full instructions."
