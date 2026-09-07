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

cpu_to_milli() {
  local v="$1"
  [ -z "$v" ] && { echo ""; return; }
  if echo "$v" | grep -q 'm$'; then echo "${v%m}"; else awk "BEGIN{printf \"%d\", $v * 1000}"; fi
}
mem_to_mi() {
  local v="$1"
  [ -z "$v" ] && { echo ""; return; }
  if echo "$v" | grep -q 'Gi$'; then awk "BEGIN{printf \"%d\", ${v%Gi} * 1024}";
  elif echo "$v" | grep -q 'Mi$'; then echo "${v%Mi}"; else echo "$v"; fi
}

echo "=== Checking Scenario 21 – Deployment Fits ResourceQuota ==="
echo ""

REPLICAS=$(kubectl get deploy team-app -n team-a -o jsonpath='{.spec.replicas}' 2>/dev/null)
check "Deployment still requests 4 replicas (got: $REPLICAS)" "$([ "$REPLICAS" == "4" ] && echo true || echo false)"

# All replicas available
AVAIL=$(kubectl get deploy team-app -n team-a -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
check "All 4 replicas available (got: ${AVAIL:-0}/4)" "$([ "$AVAIL" == "4" ] && echo true || echo false)"

# Per-pod resources must fit: requests<=250m/256Mi, limits<=500m/512Mi
CPU_REQ=$(cpu_to_milli "$(kubectl get deploy team-app -n team-a -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)")
MEM_REQ=$(mem_to_mi "$(kubectl get deploy team-app -n team-a -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)")
CPU_LIM=$(cpu_to_milli "$(kubectl get deploy team-app -n team-a -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)")
MEM_LIM=$(mem_to_mi "$(kubectl get deploy team-app -n team-a -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)")

check "Per-pod CPU request <= 250m (got: ${CPU_REQ:-none}m)" "$([ -n "$CPU_REQ" ] && [ "$CPU_REQ" -le 250 ] 2>/dev/null && echo true || echo false)"
check "Per-pod memory request <= 256Mi (got: ${MEM_REQ:-none}Mi)" "$([ -n "$MEM_REQ" ] && [ "$MEM_REQ" -le 256 ] 2>/dev/null && echo true || echo false)"
check "Per-pod CPU limit <= 500m (got: ${CPU_LIM:-none}m)" "$([ -n "$CPU_LIM" ] && [ "$CPU_LIM" -le 500 ] 2>/dev/null && echo true || echo false)"
check "Per-pod memory limit <= 512Mi (got: ${MEM_LIM:-none}Mi)" "$([ -n "$MEM_LIM" ] && [ "$MEM_LIM" -le 512 ] 2>/dev/null && echo true || echo false)"

# Quota not exceeded: Used <= Hard (kubectl enforces this, but confirm quota object exists)
QUOTA=$(kubectl get quota team-a-quota -n team-a -o name 2>/dev/null)
check "ResourceQuota team-a-quota still present" "$([ -n "$QUOTA" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
