#!/bin/bash
set -e

echo "Setting up Scenario 12 - Fix Service Selector..."

# Create deployment web-app with 3 replicas, label app=webapp, using nginx
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
EOF

# Create service web-svc with WRONG selector app=wrongapp
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: default
spec:
  selector:
    app: wrongapp
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
EOF

# Wait for deployment to be ready
echo "Waiting for deployment web-app to be ready..."
kubectl rollout status deploy web-app --timeout=120s

echo ""
echo "Setup complete! Deployment web-app is running, but Service web-svc has a wrong selector."
echo "Run 'cat TASK.md' to see your task."
