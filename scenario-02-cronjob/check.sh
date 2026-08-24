#!/bin/bash

echo "=== Checking Scenario 02: Create CronJob with Schedule and History Limits ==="
echo ""

FAILED=0

# Check 1: CronJob exists
echo -n "CHECK 1: CronJob 'backup-job' exists in default namespace... "
if kubectl get cronjob backup-job -n default &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 2: Schedule is */30 * * * *
echo -n "CHECK 2: Schedule is '*/30 * * * *'... "
SCHEDULE=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [ "$SCHEDULE" = "*/30 * * * *" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$SCHEDULE')"
  FAILED=$((FAILED + 1))
fi

# Check 3: successfulJobsHistoryLimit is 3
echo -n "CHECK 3: successfulJobsHistoryLimit is 3... "
SJHL=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [ "$SJHL" = "3" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$SJHL')"
  FAILED=$((FAILED + 1))
fi

# Check 4: failedJobsHistoryLimit is 2
echo -n "CHECK 4: failedJobsHistoryLimit is 2... "
FJHL=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
if [ "$FJHL" = "2" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$FJHL')"
  FAILED=$((FAILED + 1))
fi

# Check 5: activeDeadlineSeconds is 300
echo -n "CHECK 5: activeDeadlineSeconds is 300... "
ADS=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
if [ "$ADS" = "300" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$ADS')"
  FAILED=$((FAILED + 1))
fi

# Check 6: restartPolicy is Never
echo -n "CHECK 6: restartPolicy is Never... "
RP=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.template.spec.restartPolicy}' 2>/dev/null)
if [ "$RP" = "Never" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$RP')"
  FAILED=$((FAILED + 1))
fi

# Check 7: Image is busybox:latest
echo -n "CHECK 7: Image is busybox:latest... "
IMAGE=$(kubectl get cronjob backup-job -n default -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "busybox:latest" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$IMAGE')"
  FAILED=$((FAILED + 1))
fi

echo ""
echo "=== Results ==="
if [ $FAILED -eq 0 ]; then
  echo "ALL CHECKS PASSED ✅"
  exit 0
else
  echo "$FAILED CHECK(S) FAILED ❌"
  exit 1
fi
