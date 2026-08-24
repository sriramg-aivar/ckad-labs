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

echo "=== Checking Scenario 11 - Security Context ==="
echo ""

# Check 1: Pod-level securityContext.runAsUser is 1000
RUN_AS_USER=$(kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
check "Pod-level runAsUser is 1000" "$([ "$RUN_AS_USER" = "1000" ] && echo true || echo false)"

# Check 2: Container 'app' has capability NET_ADMIN added
# Get capabilities for the container named 'app'
CAPABILITIES=$(kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.containers[?(@.name=="app")].securityContext.capabilities.add}' 2>/dev/null)
HAS_NET_ADMIN=$(echo "$CAPABILITIES" | grep -c "NET_ADMIN" 2>/dev/null || echo "0")
check "Container 'app' has capability NET_ADMIN added" "$([ "$HAS_NET_ADMIN" -ge 1 ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
