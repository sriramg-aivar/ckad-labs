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

# Normalize CPU to millicores
cpu_to_milli() {
  local v="$1"
  [ -z "$v" ] && { echo ""; return; }
  if echo "$v" | grep -q 'm$'; then
    echo "${v%m}"
  else
    # whole/decimal cores -> millicores
    awk "BEGIN{printf \"%d\", $v * 1000}"
  fi
}

# Normalize memory to Mi
mem_to_mi() {
  local v="$1"
  [ -z "$v" ] && { echo ""; return; }
  if echo "$v" | grep -q 'Gi$'; then
    awk "BEGIN{printf \"%d\", ${v%Gi} * 1024}"
  elif echo "$v" | grep -q 'Mi$'; then
    echo "${v%Mi}"
  else
    echo "$v"
  fi
}

echo "=== Checking Scenario 20 – Double Resources ==="
echo ""

CPU_REQ=$(kubectl get deploy compute-app -n default -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
MEM_REQ=$(kubectl get deploy compute-app -n default -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
CPU_LIM=$(kubectl get deploy compute-app -n default -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
MEM_LIM=$(kubectl get deploy compute-app -n default -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)

check "CPU request doubled to 200m (got: $CPU_REQ)" "$([ "$(cpu_to_milli "$CPU_REQ")" == "200" ] && echo true || echo false)"
check "Memory request doubled to 256Mi (got: $MEM_REQ)" "$([ "$(mem_to_mi "$MEM_REQ")" == "256" ] && echo true || echo false)"
check "CPU limit doubled to 500m (got: $CPU_LIM)" "$([ "$(cpu_to_milli "$CPU_LIM")" == "500" ] && echo true || echo false)"
check "Memory limit doubled to 512Mi (got: $MEM_LIM)" "$([ "$(mem_to_mi "$MEM_LIM")" == "512" ] && echo true || echo false)"

# Rollout healthy
AVAIL=$(kubectl get deploy compute-app -n default -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deploy compute-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
check "All replicas available ($AVAIL/$DESIRED)" "$([ -n "$AVAIL" ] && [ "$AVAIL" == "$DESIRED" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
