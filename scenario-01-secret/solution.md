# Solution – Scenario 01: Create Secret from Hardcoded Variables

## Step 1 – Create the Secret

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS='Secret123!' \
  -n default
```

## Step 2 – Update Deployment to use Secret

```bash
kubectl edit deploy api-server -n default
```

Replace the hardcoded environment variables section with:

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
  - name: DB_PASS
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_PASS
```

Save and exit.

### Alternative: Patch command

```bash
kubectl patch deploy api-server -n default --type='json' -p='[
  {"op": "replace", "path": "/spec/template/spec/containers/0/env", "value": [
    {"name": "DB_USER", "valueFrom": {"secretKeyRef": {"name": "db-credentials", "key": "DB_USER"}}},
    {"name": "DB_PASS", "valueFrom": {"secretKeyRef": {"name": "db-credentials", "key": "DB_PASS"}}}
  ]}
]'
```

## Step 3 – Verify

```bash
kubectl rollout status deploy api-server -n default
kubectl exec deploy/api-server -n default -- env | grep DB_
```

Expected output:
```
DB_USER=admin
DB_PASS=Secret123!
```
