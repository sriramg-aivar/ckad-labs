# Solution – Scenario 03: Create ServiceAccount, Role, and RoleBinding

## Step 1 – Check the logs

```bash
kubectl logs log-collector -n audit
```

You'll see: `User "system:serviceaccount:audit:default" cannot list pods in the namespace "audit"`

## Step 2 – Create ServiceAccount

```bash
kubectl create sa log-sa -n audit
```

## Step 3 – Create Role

```bash
kubectl create role log-role \
  --verb=get,list,watch \
  --resource=pods \
  -n audit
```

Or using YAML:

```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: log-role
  namespace: audit
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
EOF
```

## Step 4 – Create RoleBinding

```bash
kubectl create rolebinding log-rb \
  --role=log-role \
  --serviceaccount=audit:log-sa \
  -n audit
```

## Step 5 – Update Pod to use new ServiceAccount

Since `serviceAccountName` is immutable, export, edit, delete, and recreate:

```bash
kubectl get pod log-collector -n audit -o yaml > /tmp/log-collector.yaml
```

Edit `/tmp/log-collector.yaml`:
- Change `serviceAccountName: default` to `serviceAccountName: log-sa`
- Remove `status:` section, `resourceVersion`, `uid`, `creationTimestamp` metadata
- Remove any `serviceAccount:` field (deprecated)

```bash
kubectl delete pod log-collector -n audit
kubectl apply -f /tmp/log-collector.yaml
```

## Verify

```bash
kubectl get pod log-collector -n audit -o jsonpath='{.spec.serviceAccountName}'
# Output: log-sa

kubectl logs log-collector -n audit
# Should no longer show authorization errors (or show successful pod list)
```
