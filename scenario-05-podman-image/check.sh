#!/bin/bash
# Validation for Scenario 05 – Build Container Image with Podman
PASS=0
FAIL=0

echo "=== Checking Scenario 05 ==="
echo ""

# Determine container runtime
RUNTIME=""
if command -v podman &>/dev/null; then
  RUNTIME="podman"
elif command -v docker &>/dev/null; then
  RUNTIME="docker"
else
  echo "FAIL: Neither podman nor docker found"
  FAIL=$((FAIL + 1))
fi

# Check 1: Image my-app:1.0 exists
if [ -n "$RUNTIME" ]; then
  if $RUNTIME images --format '{{.Repository}}:{{.Tag}}' | grep -q '^my-app:1.0$'; then
    echo "PASS: Image my-app:1.0 exists"
    PASS=$((PASS + 1))
  else
    # Try alternative format
    if $RUNTIME images | grep -q 'my-app.*1.0'; then
      echo "PASS: Image my-app:1.0 exists"
      PASS=$((PASS + 1))
    else
      echo "FAIL: Image my-app:1.0 not found"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

# Check 2: Tarball /root/my-app.tar exists and is non-empty
if [ -f /root/my-app.tar ]; then
  if [ -s /root/my-app.tar ]; then
    echo "PASS: /root/my-app.tar exists and is non-empty"
    PASS=$((PASS + 1))
  else
    echo "FAIL: /root/my-app.tar exists but is empty"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL: /root/my-app.tar does not exist"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ $FAIL -eq 0 ]; then
  echo "All checks passed!"
  exit 0
else
  echo "Some checks failed."
  exit 1
fi
