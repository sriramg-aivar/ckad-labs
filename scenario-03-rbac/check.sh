#!/bin/bash

echo "=== Checking Scenario 03: ServiceAccount, Role, and RoleBinding ==="
echo ""

FAILED=0

# Check 1: ServiceAccount log-sa exists in audit
echo -n "CHECK 1: ServiceAccount 'log-sa' exists in namespace 'audit'... "
if kubectl get sa log-sa -n audit &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 2: Role log-role exists in audit
echo -n "CHECK 2: Role 'log-role' exists in namespace 'audit'... "
if kubectl get role log-role -n audit &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 3: Role log-role has correct verbs on pods
echo -n "CHECK 3: Role 'log-role' has get, list, watch on pods... "
ROLE_JSON=$(kubectl get role log-role -n audit -o json 2>/dev/null)
if echo "$ROLE_JSON" | python3 -c "
import sys, json
role = json.load(sys.stdin)
rules = role.get('rules', [])
for rule in rules:
    resources = rule.get('resources', [])
    verbs = rule.get('verbs', [])
    if 'pods' in resources:
        required = {'get', 'list', 'watch'}
        if required.issubset(set(verbs)):
            sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 4: RoleBinding log-rb exists in audit
echo -n "CHECK 4: RoleBinding 'log-rb' exists in namespace 'audit'... "
if kubectl get rolebinding log-rb -n audit &>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 5: RoleBinding log-rb binds log-role to log-sa
echo -n "CHECK 5: RoleBinding 'log-rb' binds 'log-role' to 'log-sa'... "
RB_JSON=$(kubectl get rolebinding log-rb -n audit -o json 2>/dev/null)
if echo "$RB_JSON" | python3 -c "
import sys, json
rb = json.load(sys.stdin)
role_ref = rb.get('roleRef', {})
subjects = rb.get('subjects', [])
if role_ref.get('name') != 'log-role' or role_ref.get('kind') != 'Role':
    sys.exit(1)
for s in subjects:
    if s.get('kind') == 'ServiceAccount' and s.get('name') == 'log-sa' and s.get('namespace', 'audit') == 'audit':
        sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL"
  FAILED=$((FAILED + 1))
fi

# Check 6: Pod log-collector uses serviceAccountName: log-sa
echo -n "CHECK 6: Pod 'log-collector' uses serviceAccountName 'log-sa'... "
SA_NAME=$(kubectl get pod log-collector -n audit -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$SA_NAME" = "log-sa" ]; then
  echo "PASS"
else
  echo "FAIL (got: '$SA_NAME')"
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
