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

echo "=== Checking Scenario 10 - Readiness Probe ==="
echo ""

# Check 1: Deployment api-deploy has a readinessProbe
HAS_PROBE=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)
check "Deployment api-deploy has a readinessProbe" "$([ -n "$HAS_PROBE" ] && echo true || echo false)"

# Check 2: httpGet path is /ready
HTTP_PATH=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
check "httpGet path is /ready" "$([ "$HTTP_PATH" = "/ready" ] && echo true || echo false)"

# Check 3: httpGet port is 8080
HTTP_PORT=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
check "httpGet port is 8080" "$([ "$HTTP_PORT" = "8080" ] && echo true || echo false)"

# Check 4: initialDelaySeconds is 5
INITIAL_DELAY=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
check "initialDelaySeconds is 5" "$([ "$INITIAL_DELAY" = "5" ] && echo true || echo false)"

# Check 5: periodSeconds is 10
PERIOD=$(kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
check "periodSeconds is 10" "$([ "$PERIOD" = "10" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
