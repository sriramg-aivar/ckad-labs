# Scenario 04 – Fix Broken Pod with Correct ServiceAccount

## Context

In namespace `monitoring`, Pod `metrics-pod` is using ServiceAccount `wrong-sa` and receiving authorization errors when trying to list pods.

Multiple ServiceAccounts, Roles, and RoleBindings already exist in the namespace:
- **ServiceAccounts:** `monitor-sa`, `wrong-sa`, `admin-sa`
- **Roles:** `metrics-reader`, `full-access`, `view-only`
- **RoleBindings:** `monitor-binding`, `admin-binding`

## Task

1. Investigate the existing RBAC resources to determine which ServiceAccount has the appropriate permissions to read pods
2. Update Pod `metrics-pod` to use the correct ServiceAccount
3. Verify the Pod is running without authorization errors

**Note:** You need to find the SA that is bound to the role with the correct (minimal) permissions for reading pods — not the one with excessive permissions.

## Test BEFORE fix

```bash
# Check current SA
kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}'
# Expected: wrong-sa

# Check pod logs
kubectl logs metrics-pod -n monitoring
# Expected: authorization error
```

## Test AFTER fix

```bash
# Check updated SA
kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}'
# Expected: monitor-sa

# Verify pod is running
kubectl get pod metrics-pod -n monitoring
# Expected: Running

# Check pod logs (should succeed or show no auth errors)
kubectl logs metrics-pod -n monitoring
```

## Hints

- `kubectl get rolebindings -n monitoring` — see which SA is bound to which role
- `kubectl describe rolebinding <name> -n monitoring` — see subjects and role ref
- `kubectl describe role <name> -n monitoring` — see permissions
- Look for the RoleBinding that connects a SA to a Role with `get` and `list` on `pods`
- The correct SA is `monitor-sa` (bound to `metrics-reader` via `monitor-binding`)
