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

echo "=== Checking Scenario 19 – Job From CronJob ==="
echo ""

# Check 1: CronJob still exists (untouched)
CJ=$(kubectl get cronjob report-generator -n default -o name 2>/dev/null)
check "CronJob report-generator still exists" "$([ -n "$CJ" ] && echo true || echo false)"

# Check 2: Job manual-report exists
JOB=$(kubectl get job manual-report -n default -o name 2>/dev/null)
check "Job manual-report exists in namespace default" "$([ -n "$JOB" ] && echo true || echo false)"

# Check 3: Job was created FROM the cronjob (owner ref / annotation)
OWNER=$(kubectl get job manual-report -n default -o jsonpath='{.metadata.ownerReferences[*].kind}' 2>/dev/null)
ANNO=$(kubectl get job manual-report -n default -o jsonpath='{.metadata.annotations.cronjob\.kubernetes\.io/instantiate}' 2>/dev/null)
FROM_CJ="false"
if [ "$ANNO" == "manual" ] || echo "$OWNER" | grep -qi cronjob; then
  FROM_CJ="true"
fi
check "Job was created from the CronJob (annotation/owner: ${ANNO:-$OWNER})" "$FROM_CJ"

# Check 4: Job succeeded (allow a brief wait)
SUCCEEDED=""
for i in $(seq 1 12); do
  SUCCEEDED=$(kubectl get job manual-report -n default -o jsonpath='{.status.succeeded}' 2>/dev/null)
  [ "$SUCCEEDED" == "1" ] && break
  sleep 5
done
check "Job completed successfully (succeeded: ${SUCCEEDED:-0})" "$([ "$SUCCEEDED" == "1" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
