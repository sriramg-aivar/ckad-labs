#!/bin/bash

PASS=0
FAIL=0

check() {
  local description="$1"
  local result="$2"
  if [ "$result" == "true" ]; then
    echo "✅ PASS: $description"
    ((PASS++))
  else
    echo "❌ FAIL: $description"
    ((FAIL++))
  fi
}

echo "=== Checking Scenario 13 – Create NodePort Service ==="
echo ""

# Check 1: Service api-nodeport exists
SVC=$(kubectl get svc api-nodeport -n default -o name 2>/dev/null)
check "Service api-nodeport exists" "$([ -n "$SVC" ] && echo true || echo false)"

# Check 2: Service type is NodePort
TYPE=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.type}' 2>/dev/null)
check "Service type is NodePort" "$([ "$TYPE" == "NodePort" ] && echo true || echo false)"

# Check 3: Selector is app=api
SELECTOR=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.selector.app}' 2>/dev/null)
check "Selector is app=api" "$([ "$SELECTOR" == "api" ] && echo true || echo false)"

# Check 4: Port is 80
PORT=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
check "Service port is 80" "$([ "$PORT" == "80" ] && echo true || echo false)"

# Check 5: TargetPort is 9090
TARGET_PORT=$(kubectl get svc api-nodeport -n default -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
check "Target port is 9090" "$([ "$TARGET_PORT" == "9090" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
