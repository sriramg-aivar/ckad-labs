#!/bin/bash
# Validation for Scenario 08 – Fix Broken Deployment YAML
PASS=0
FAIL=0

echo "=== Checking Scenario 08 ==="
echo ""

# Check 1: Deployment broken-app exists
if kubectl get deploy broken-app -n default &>/dev/null; then
  echo "PASS: Deployment broken-app exists"
  PASS=$((PASS + 1))
else
  echo "FAIL: Deployment broken-app does not exist"
  FAIL=$((FAIL + 1))
  echo ""
  echo "=== Results: $PASS passed, $FAIL failed ==="
  echo "Some checks failed."
  exit 1
fi

# Check 2: Deployment is available (has available replicas)
AVAILABLE=$(kubectl get deploy broken-app -n default -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
if [ "$AVAILABLE" = "2" ]; then
  echo "PASS: Deployment is available with 2 replicas"
  PASS=$((PASS + 1))
else
  echo "FAIL: Deployment has $AVAILABLE available replicas (expected 2)"
  FAIL=$((FAIL + 1))
fi

# Check 3: Uses apiVersion apps/v1 (check the live object)
API_VERSION=$(kubectl get deploy broken-app -n default -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$API_VERSION" = "apps/v1" ]; then
  echo "PASS: Deployment uses apiVersion apps/v1"
  PASS=$((PASS + 1))
else
  echo "FAIL: Deployment uses apiVersion $API_VERSION (expected apps/v1)"
  FAIL=$((FAIL + 1))
fi

# Check 4: selector.matchLabels.app = myapp
SELECTOR_APP=$(kubectl get deploy broken-app -n default -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
if [ "$SELECTOR_APP" = "myapp" ]; then
  echo "PASS: selector.matchLabels.app = myapp"
  PASS=$((PASS + 1))
else
  echo "FAIL: selector.matchLabels.app = '$SELECTOR_APP' (expected 'myapp')"
  FAIL=$((FAIL + 1))
fi

# Check 5: Replicas is 2
REPLICAS=$(kubectl get deploy broken-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "2" ]; then
  echo "PASS: Replicas is 2"
  PASS=$((PASS + 1))
else
  echo "FAIL: Replicas is $REPLICAS (expected 2)"
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
