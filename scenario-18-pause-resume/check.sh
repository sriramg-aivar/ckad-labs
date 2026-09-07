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

echo "=== Checking Scenario 18 – Pause / Resume Rollout ==="
echo ""

# Check 1: image updated to nginx:1.26
IMAGE=$(kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
check "Image is nginx:1.26 (got: $IMAGE)" "$([ "$IMAGE" == "nginx:1.26" ] && echo true || echo false)"

# Check 2: env RELEASE=canary present
RELEASE=$(kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="RELEASE")].value}' 2>/dev/null)
check "Env RELEASE=canary present (got: $RELEASE)" "$([ "$RELEASE" == "canary" ] && echo true || echo false)"

# Check 3: deployment is NOT paused
PAUSED=$(kubectl get deploy rollout-app -n default -o jsonpath='{.spec.paused}' 2>/dev/null)
NOT_PAUSED="false"
if [ -z "$PAUSED" ] || [ "$PAUSED" == "false" ]; then
  NOT_PAUSED="true"
fi
check "Deployment is resumed (not paused) (got: ${PAUSED:-<empty>})" "$NOT_PAUSED"

# Check 4: rollout is complete / available
AVAIL=$(kubectl get deploy rollout-app -n default -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deploy rollout-app -n default -o jsonpath='{.spec.replicas}' 2>/dev/null)
check "All replicas available ($AVAIL/$DESIRED)" "$([ -n "$AVAIL" ] && [ "$AVAIL" == "$DESIRED" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
