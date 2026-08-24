#!/bin/bash
set -e

echo "Setting up Scenario 14 – Create Ingress Resource..."

# Create deployment web-deploy with label app=web
kubectl create deployment web-deploy --image=nginx --replicas=2 -n default
kubectl label deployment web-deploy app=web -n default --overwrite

# Patch pod template labels
kubectl patch deployment web-deploy -n default --type='json' -p='[
  {"op": "replace", "path": "/spec/template/metadata/labels", "value": {"app": "web"}},
  {"op": "replace", "path": "/spec/selector/matchLabels", "value": {"app": "web"}}
]'

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
