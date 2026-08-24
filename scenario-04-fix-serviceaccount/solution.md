# Solution – Scenario 04: Fix Broken Pod with Correct ServiceAccount

## Step 1 – Investigate RBAC resources

```bash
# List all RoleBindings
kubectl get rolebindings -n monitoring

# Check monitor-binding
kubectl describe rolebinding monitor-binding -n monitoring
# Shows: Role=metrics-reader, Subject=monitor-sa

# Check admin-binding
kubectl describe rolebinding admin-binding -n monitoring
# Shows: Role=full-access, Subject=admin-sa

# Check the metrics-reader role
kubectl describe role metrics-reader -n monitoring
# Shows: Resources=pods, Verbs=get,list
```

**Conclusion:** `monitor-sa` is bound to `metrics-reader` which has `get` and `list` on `pods`. This is the correct, minimal-permission SA.

## Step 2 – Update Pod to use correct ServiceAccount

Since `serviceAccountName` is immutable, export, edit, delete, and recreate:

```bash
kubectl get pod metrics-pod -n monitoring -o yaml > /tmp/metrics-pod.yaml
```

Edit `/tmp/metrics-pod.yaml`:
- Change `serviceAccountName: wrong-sa` to `serviceAccountName: monitor-sa`
- Remove `status:` section and dynamic metadata fields (`resourceVersion`, `uid`, `creationTimestamp`)

```bash
kubectl delete pod metrics-pod -n monitoring
kubectl apply -f /tmp/metrics-pod.yaml
```

### Alternative: One-liner with sed

```bash
kubectl get pod metrics-pod -n monitoring -o yaml | \
  sed 's/serviceAccountName: wrong-sa/serviceAccountName: monitor-sa/' | \
  kubectl replace --force -f -
```

## Step 3 – Verify

```bash
kubectl get pod metrics-pod -n monitoring -o jsonpath='{.spec.serviceAccountName}'
# Output: monitor-sa

kubectl get pod metrics-pod -n monitoring
# STATUS should be Running

kubectl logs metrics-pod -n monitoring
# Should show successful pod list or no auth errors
```
