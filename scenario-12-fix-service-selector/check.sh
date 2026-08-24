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

echo "=== Checking Scenario 12 - Fix Service Selector ==="
echo ""

# Check 1: Service web-svc selector is app=webapp
SELECTOR=$(kubectl get svc web-svc -o jsonpath='{.spec.selector.app}' 2>/dev/null)
check "Service web-svc selector is app=webapp" "$([ "$SELECTOR" = "webapp" ] && echo true || echo false)"

# Check 2: Endpoints for web-svc are not empty (has pod IPs)
ENDPOINTS=$(kubectl get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
check "Endpoints for web-svc are not empty (has pod IPs)" "$([ -n "$ENDPOINTS" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
