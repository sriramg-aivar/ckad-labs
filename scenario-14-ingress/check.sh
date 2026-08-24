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

echo "=== Checking Scenario 14 – Create Ingress Resource ==="
echo ""

# Check 1: Ingress web-ingress exists
ING=$(kubectl get ingress web-ingress -n default -o name 2>/dev/null)
check "Ingress web-ingress exists" "$([ -n "$ING" ] && echo true || echo false)"

# Check 2: Host is web.example.com
HOST=$(kubectl get ingress web-ingress -n default -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
check "Host is web.example.com" "$([ "$HOST" == "web.example.com" ] && echo true || echo false)"

# Check 3: Path is /
PATH_VAL=$(kubectl get ingress web-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
check "Path is /" "$([ "$PATH_VAL" == "/" ] && echo true || echo false)"

# Check 4: PathType is Prefix
PATH_TYPE=$(kubectl get ingress web-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
check "PathType is Prefix" "$([ "$PATH_TYPE" == "Prefix" ] && echo true || echo false)"

# Check 5: Backend service name is web-svc
BACKEND_SVC=$(kubectl get ingress web-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
check "Backend service is web-svc" "$([ "$BACKEND_SVC" == "web-svc" ] && echo true || echo false)"

# Check 6: Backend service port is 8080
BACKEND_PORT=$(kubectl get ingress web-ingress -n default -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
check "Backend service port is 8080" "$([ "$BACKEND_PORT" == "8080" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
