# Scenario 01 – Create Secret from Hardcoded Variables

## Context

In namespace `default`, Deployment `api-server` exists with hard-coded environment variables:
- `DB_USER=admin`
- `DB_PASS=Secret123!`

## Task

1. Create a Secret named `db-credentials` in namespace `default` containing these credentials (keys: `DB_USER`, `DB_PASS`)
2. Update Deployment `api-server` to use the Secret via `valueFrom.secretKeyRef` for both environment variables
3. Do **not** change the Deployment name or namespace

## Test BEFORE fix

```bash
# Verify the deployment exists with hardcoded env vars
kubectl get deploy api-server -n default
kubectl get deploy api-server -n default -o jsonpath='{.spec.template.spec.containers[0].env}' | jq .

# You should see env vars with plain 'value' fields (not secretKeyRef)
```

## Test AFTER fix

```bash
# Verify secret exists
kubectl get secret db-credentials -n default

# Verify deployment uses secretKeyRef
kubectl get deploy api-server -n default -o jsonpath='{.spec.template.spec.containers[0].env}' | jq .

# Verify pods are running
kubectl rollout status deploy api-server -n default

# Verify env vars are correctly injected
kubectl exec deploy/api-server -n default -- env | grep DB_
```

## Hints

- `kubectl create secret generic --help`
- `kubectl explain deployment.spec.template.spec.containers.env.valueFrom`
