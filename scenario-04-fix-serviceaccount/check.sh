#!/bin/bash

echo "=== Checking Scenario 04: Fix Broken Pod with Correct ServiceAccount ==="
echo ""

FAILED=0

# Check 1: Pod metrics-pod exists
echo -n "CHECK 1: Pod 'metrics-pod' exists in namespace 'monitoring'... "
if kubectl get pod metrics-pod -n monitoring &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 2: Pod uses serviceAccountName: monitor-sa
echo -n "CHECK 2: Pod uses serviceAccountName 'monitor-sa'... "
SA_NAME=$(kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$SA_NAME" = "monitor-sa" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$SA_NAME')"
  FAILED=$((FAILED + 1))
fi

# Check 3: Pod is Running
echo -n "CHECK 3: Pod is in Running state... "
POD_STATUS=$(kubectl get pod metrics-pod -n monitoring -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$POD_STATUS')"
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
