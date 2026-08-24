#!/bin/bash
# Validation for Scenario 06 – Canary Deployment
PASS=0
FAIL=0

echo "=== Checking Scenario 06 ==="
echo ""

# Check 1: web-app has 8 replicas
REPLICAS=$(kubectl get deploy web-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "8" ]; then
  echo "PASS: web-app has 8 replicas"
  PASS=$((PASS + 1))
else
  echo "FAIL: web-app has $REPLICAS replicas (expected 8)"
  FAIL=$((FAIL + 1))
fi

# Check 2: web-app-canary exists with 2 replicas
CANARY_REPLICAS=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$CANARY_REPLICAS" = "2" ]; then
  echo "PASS: web-app-canary exists with 2 replicas"
  PASS=$((PASS + 1))
else
  if [ -z "$CANARY_REPLICAS" ]; then
    echo "FAIL: web-app-canary deployment does not exist"
  else
    echo "FAIL: web-app-canary has $CANARY_REPLICAS replicas (expected 2)"
  fi
  FAIL=$((FAIL + 1))
fi

# Check 3: web-app-canary pods have labels app=webapp,version=v2
CANARY_LABELS=$(kubectl get deploy web-app-canary -n default -o jsonpath='{.spec.template.metadata.labels}' 2>/dev/null)
if echo "$CANARY_LABELS" | grep -q '"app":"webapp"' && echo "$CANARY_LABELS" | grep -q '"version":"v2"'; then
  echo "PASS: web-app-canary pods have labels app=webapp,version=v2"
  PASS=$((PASS + 1))
else
  echo "FAIL: web-app-canary pods do not have correct labels (app=webapp,version=v2)"
  echo "      Found: $CANARY_LABELS"
  FAIL=$((FAIL + 1))
fi

# Check 4: web-service endpoints include pods from both deployments
V1_PODS=$(kubectl get pods -n default -l app=webapp,version=v1 --field-selector=status.phase=Running -o jsonpath='{.items[*].status.podIP}' 2>/dev/null | wc -w)
V2_PODS=$(kubectl get pods -n default -l app=webapp,version=v2 --field-selector=status.phase=Running -o jsonpath='{.items[*].status.podIP}' 2>/dev/null | wc -w)
ENDPOINTS=$(kubectl get endpoints web-service -n default -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w)

if [ "$V1_PODS" -gt 0 ] && [ "$V2_PODS" -gt 0 ] && [ "$ENDPOINTS" -ge 2 ]; then
  echo "PASS: web-service endpoints include pods from both deployments ($V1_PODS v1 + $V2_PODS v2 pods, $ENDPOINTS endpoints)"
  PASS=$((PASS + 1))
else
  echo "FAIL: web-service does not serve both deployments (v1 pods: $V1_PODS, v2 pods: $V2_PODS, endpoints: $ENDPOINTS)"
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
