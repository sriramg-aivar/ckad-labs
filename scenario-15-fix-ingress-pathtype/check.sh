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

echo "=== Checking Scenario 15 – Fix Ingress PathType ==="
echo ""

# Check 1: Ingress api-ingress exists in cluster
ING=$(kubectl get ingress api-ingress -n default -o name 2>/dev/null)
check "Ingress api-ingress exists in cluster" "$([ -n "$ING" ] && echo true || echo false)"

# Check 2: PathType is a valid value (Prefix, Exact, or ImplementationSpecific)
PATH_TYPE=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
VALID_TYPE="false"
if [ "$PATH_TYPE" == "Prefix" ] || [ "$PATH_TYPE" == "Exact" ] || [ "$PATH_TYPE" == "ImplementationSpecific" ]; then
  VALID_TYPE="true"
fi
check "PathType is valid ($PATH_TYPE)" "$VALID_TYPE"

# Check 3: Path is /api
PATH_VAL=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
check "Path is /api" "$([ "$PATH_VAL" == "/api" ] && echo true || echo false)"

# Check 4: Backend service name is api-svc
BACKEND_SVC=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
check "Backend service is api-svc" "$([ "$BACKEND_SVC" == "api-svc" ] && echo true || echo false)"

# Check 5: Backend service port is 8080
BACKEND_PORT=$(kubectl get ingress api-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
check "Backend service port is 8080" "$([ "$BACKEND_PORT" == "8080" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
