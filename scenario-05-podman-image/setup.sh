#!/bin/bash
# Setup for Scenario 05 – Build Container Image with Podman
set -e

echo "Setting up Scenario 05..."

# Create the app-source directory
mkdir -p /root/app-source

# Create index.html
cat > /root/app-source/index.html <<'EOF'
Hello CKAD
EOF

# Create the Dockerfile
cat > /root/app-source/Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
EOF

echo "Setup complete!"
echo "Directory /root/app-source created with Dockerfile and index.html"
echo ""
echo "Your task: Build image my-app:1.0 and save it as /root/my-app.tar"
