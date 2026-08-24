#!/bin/bash
set -e

echo "Setting up Scenario 15 – Fix Ingress PathType..."

# Create deployment api-deploy with label app=api
kubectl create deployment api-deploy --image=nginx --replicas=2 -n default
kubectl label deployment api-deploy app=api -n default --overwrite

# Patch pod template labels
kubectl patch deployment api-deploy -n default --type='json' -p='[
  {"op": "replace", "path": "/spec/template/metadata/labels", "value": {"app": "api"}},
  {"op": "replace", "path": "/spec/selector/matchLabels", "value": {"app": "api"}}
]'

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
