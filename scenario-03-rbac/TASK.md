# Scenario 03 – Create ServiceAccount, Role, and RoleBinding from Logs Error

## Context

In namespace `audit`, Pod `log-collector` exists but is failing with authorization errors.

## Task

1. Check the Pod logs to identify the permission issue
2. Create a ServiceAccount named `log-sa` in namespace `audit`
3. Create a Role named `log-role` in namespace `audit` that grants `get`, `list`, and `watch` on resource `pods`
4. Create a RoleBinding named `log-rb` in namespace `audit` that binds `log-role` to `log-sa`
5. Update Pod `log-collector` to use ServiceAccount `log-sa`

**Note:** Pods have immutable `serviceAccountName` — you will need to delete and recreate the Pod.

## Test BEFORE fix

```bash
# Check the pod logs to see the error
kubectl logs log-collector -n audit
# Expected: authorization error message

# Check current service account
kubectl get pod log-collector -n audit -o jsonpath='{.spec.serviceAccountName}'
# Expected: default
```

## Test AFTER fix

```bash
# Verify ServiceAccount exists
kubectl get sa log-sa -n audit

# Verify Role exists with correct permissions
kubectl describe role log-role -n audit

# Verify RoleBinding exists
kubectl describe rolebinding log-rb -n audit

# Verify pod uses the new SA
kubectl get pod log-collector -n audit -o jsonpath='{.spec.serviceAccountName}'
# Expected: log-sa
```

## Hints

- `kubectl create sa --help`
- `kubectl create role --help`
- `kubectl create rolebinding --help`
- Since pods are immutable for `serviceAccountName`, export the pod YAML, edit, delete, and recreate
