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

echo "=== Checking Scenario 16 – Resource Requests and Limits ==="
echo ""

# Check 1: Pod resource-pod exists in namespace prod
POD=$(kubectl get pod resource-pod -n prod -o name 2>/dev/null)
check "Pod resource-pod exists in namespace prod" "$([ -n "$POD" ] && echo true || echo false)"

# Check 2: CPU limit is 1 (or 1000m)
CPU_LIMIT=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
VALID_CPU_LIMIT="false"
if [ "$CPU_LIMIT" == "1" ] || [ "$CPU_LIMIT" == "1000m" ]; then
  VALID_CPU_LIMIT="true"
fi
check "CPU limit is 1 (got: $CPU_LIMIT)" "$VALID_CPU_LIMIT"

# Check 3: Memory limit is 2Gi
MEM_LIMIT=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
VALID_MEM_LIMIT="false"
if [ "$MEM_LIMIT" == "2Gi" ] || [ "$MEM_LIMIT" == "2048Mi" ]; then
  VALID_MEM_LIMIT="true"
fi
check "Memory limit is 2Gi (got: $MEM_LIMIT)" "$VALID_MEM_LIMIT"

# Check 4: CPU request is at least 100m
CPU_REQ=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
# Convert to millicores for comparison
CPU_REQ_MILLI=""
if echo "$CPU_REQ" | grep -q 'm$'; then
  CPU_REQ_MILLI=$(echo "$CPU_REQ" | sed 's/m$//')
else
  CPU_REQ_MILLI=$((${CPU_REQ:-0} * 1000))
fi
VALID_CPU_REQ="false"
if [ -n "$CPU_REQ_MILLI" ] && [ "$CPU_REQ_MILLI" -ge 100 ] 2>/dev/null; then
  VALID_CPU_REQ="true"
fi
check "CPU request is at least 100m (got: $CPU_REQ)" "$VALID_CPU_REQ"

# Check 5: Memory request is at least 128Mi
MEM_REQ=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
# Simple check - extract numeric value
MEM_REQ_NUM=$(echo "$MEM_REQ" | sed 's/[^0-9]//g')
VALID_MEM_REQ="false"
if echo "$MEM_REQ" | grep -qE '^[0-9]+(Mi|Gi)$'; then
  if echo "$MEM_REQ" | grep -q 'Gi$'; then
    VALID_MEM_REQ="true"  # Any Gi value >= 128Mi
  elif echo "$MEM_REQ" | grep -q 'Mi$'; then
    MEM_MI=$(echo "$MEM_REQ" | sed 's/Mi$//')
    if [ "$MEM_MI" -ge 128 ] 2>/dev/null; then
      VALID_MEM_REQ="true"
    fi
  fi
fi
check "Memory request is at least 128Mi (got: $MEM_REQ)" "$VALID_MEM_REQ"

# Check 6: Image is nginx:latest
IMAGE=$(kubectl get pod resource-pod -n prod -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
VALID_IMAGE="false"
if [ "$IMAGE" == "nginx:latest" ] || [ "$IMAGE" == "nginx" ]; then
  VALID_IMAGE="true"
fi
check "Image is nginx:latest (got: $IMAGE)" "$VALID_IMAGE"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
