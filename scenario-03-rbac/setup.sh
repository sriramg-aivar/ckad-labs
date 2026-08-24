#!/bin/bash
set -e

echo "=== Setting up Scenario 03: Create ServiceAccount, Role, and RoleBinding ==="

# Clean up any existing resources
kubectl delete namespace audit --ignore-not-found 2>/dev/null
sleep 2

# Create namespace
kubectl create namespace audit

# Create pod log-collector using default service account
# The pod tries to list pods via the API, which will fail with default SA
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: log-collector
  namespace: audit
spec:
  serviceAccountName: default
  containers:
    - name: collector
      image: busybox:latest
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            wget -qO- --header="Authorization: Bearer \$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
              https://kubernetes.default.svc/api/v1/namespaces/audit/pods --no-check-certificate 2>&1 || \
              echo "ERROR: User system:serviceaccount:audit:default cannot list pods in the namespace audit"
            sleep 30
          done
EOF

# Wait for pod to be running
echo "Waiting for pod to be running..."
kubectl wait --for=condition=Ready pod/log-collector -n audit --timeout=60s 2>/dev/null || true

echo ""
echo "=== Setup complete ==="
echo ""
echo "TASK: Pod 'log-collector' in namespace 'audit' is failing with authorization errors."
echo "      Check the logs and fix the RBAC permissions."
echo ""
echo "See TASK.md for full instructions."
