#!/bin/bash
# Validation for Scenario 07 – Fix NetworkPolicy by Updating Pod Labels
PASS=0
FAIL=0

echo "=== Checking Scenario 07 ==="
echo ""

# Check 1: Pod frontend has label role=frontend
FRONTEND_ROLE=$(kubectl get pod frontend -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [ "$FRONTEND_ROLE" = "frontend" ]; then
  echo "PASS: Pod frontend has label role=frontend"
  PASS=$((PASS + 1))
else
  echo "FAIL: Pod frontend has label role=$FRONTEND_ROLE (expected role=frontend)"
  FAIL=$((FAIL + 1))
fi

# Check 2: Pod backend has label role=backend
BACKEND_ROLE=$(kubectl get pod backend -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [ "$BACKEND_ROLE" = "backend" ]; then
  echo "PASS: Pod backend has label role=backend"
  PASS=$((PASS + 1))
else
  echo "FAIL: Pod backend has label role=$BACKEND_ROLE (expected role=backend)"
  FAIL=$((FAIL + 1))
fi

# Check 3: Pod database has label role=db
DB_ROLE=$(kubectl get pod database -n network-demo -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
if [ "$DB_ROLE" = "db" ]; then
  echo "PASS: Pod database has label role=db"
  PASS=$((PASS + 1))
else
  echo "FAIL: Pod database has label role=$DB_ROLE (expected role=db)"
  FAIL=$((FAIL + 1))
fi

# Check 4: NetworkPolicies still exist (not modified/deleted)
NP_COUNT=$(kubectl get networkpolicies -n network-demo --no-headers 2>/dev/null | wc -l)
if [ "$NP_COUNT" -ge 3 ]; then
  echo "PASS: All 3 NetworkPolicies still exist"
  PASS=$((PASS + 1))
else
  echo "FAIL: Expected 3 NetworkPolicies, found $NP_COUNT"
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
