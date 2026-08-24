#!/bin/bash

echo "=== Checking Scenario 01: Create Secret from Hardcoded Variables ==="
echo ""

FAILED=0

# Check 1: Secret exists
echo -n "CHECK 1: Secret 'db-credentials' exists in default namespace... "
if kubectl get secret db-credentials -n default &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 2: Secret has key DB_USER
echo -n "CHECK 2: Secret has key 'DB_USER'... "
if kubectl get secret db-credentials -n default -o jsonpath='{.data.DB_USER}' 2>/dev/null | base64 -d | grep -q "admin"; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 3: Secret has key DB_PASS
echo -n "CHECK 3: Secret has key 'DB_PASS'... "
if kubectl get secret db-credentials -n default -o jsonpath='{.data.DB_PASS}' 2>/dev/null | base64 -d | grep -q "Secret123!"; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 4: Deployment uses secretKeyRef for DB_USER
echo -n "CHECK 4: Deployment uses secretKeyRef for DB_USER referencing db-credentials... "
ENV_JSON=$(kubectl get deploy api-server -n default -o jsonpath='{.spec.template.spec.containers[0].env}' 2>/dev/null)
if echo "$ENV_JSON" | grep -q '"name":"DB_USER"' || echo "$ENV_JSON" | python3 -c "
import sys, json
envs = json.load(sys.stdin)
for e in envs:
    if e.get('name') == 'DB_USER' and e.get('valueFrom', {}).get('secretKeyRef', {}).get('name') == 'db-credentials' and e.get('valueFrom', {}).get('secretKeyRef', {}).get('key') == 'DB_USER':
        sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 5: Deployment uses secretKeyRef for DB_PASS
echo -n "CHECK 5: Deployment uses secretKeyRef for DB_PASS referencing db-credentials... "
if echo "$ENV_JSON" | python3 -c "
import sys, json
envs = json.load(sys.stdin)
for e in envs:
    if e.get('name') == 'DB_PASS' and e.get('valueFrom', {}).get('secretKeyRef', {}).get('name') == 'db-credentials' and e.get('valueFrom', {}).get('secretKeyRef', {}).get('key') == 'DB_PASS':
        sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 6: Deployment rollout is successful
echo -n "CHECK 6: Deployment rollout is successful... "
if kubectl rollout status deploy api-server -n default --timeout=30s &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
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
