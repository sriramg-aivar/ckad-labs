#!/bin/bash
# Setup for Scenario 08 – Fix Broken Deployment YAML
set -e

echo "Setting up Scenario 08..."

# Create the broken deployment YAML file
cat > /root/broken-deploy.yaml <<'EOF'
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: web
        image: nginx
EOF

echo "Setup complete!"
echo "File created: /root/broken-deploy.yaml"
echo ""
echo "Your task: Fix the YAML file and apply it successfully."
