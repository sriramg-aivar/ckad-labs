#!/bin/bash

PASS=0
FAIL=0

check() {
  local description="$1"
  local result="$2"
  if [ "$result" = "true" ]; then
    echo "✅ PASS: $description"
    ((PASS++))
  else
    echo "❌ FAIL: $description"
    ((FAIL++))
  fi
}

echo "=== Checking Scenario 09 - Rolling Update and Rollback ==="
echo ""

# Check 1: Deployment app-v1 exists
DEPLOY_EXISTS=$(kubectl get deploy app-v1 -o name 2>/dev/null | grep -c "deployment.apps/app-v1")
check "Deployment app-v1 exists" "$([ "$DEPLOY_EXISTS" -ge 1 ] && echo true || echo false)"

# Check 2: Current image is nginx:1.20 (after rollback)
CURRENT_IMAGE=$(kubectl get deploy app-v1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
check "Current image is nginx:1.20 (after rollback)" "$([ "$CURRENT_IMAGE" = "nginx:1.20" ] && echo true || echo false)"

# Check 3: Rollout history has at least 2 revisions
REVISION_COUNT=$(kubectl rollout history deploy app-v1 2>/dev/null | grep -c "^[0-9]")
check "Rollout history has at least 2 revisions" "$([ "$REVISION_COUNT" -ge 2 ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
