#!/bin/bash
# Cleanup for Scenario 05 – Build Container Image with Podman
echo "Cleaning up Scenario 05..."

# Remove app-source directory
rm -rf /root/app-source

# Remove tarball
rm -f /root/my-app.tar

# Remove image if it exists
if command -v podman &>/dev/null; then
  podman rmi my-app:1.0 2>/dev/null || true
elif command -v docker &>/dev/null; then
  docker rmi my-app:1.0 2>/dev/null || true
fi

echo "Cleanup complete."
