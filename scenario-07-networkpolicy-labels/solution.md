# Solution – Scenario 07: Fix NetworkPolicy by Updating Pod Labels

## Step 1 – Inspect the NetworkPolicies

```bash
kubectl get networkpolicies -n network-demo -o yaml
```

Identify the selectors:
- `allow-frontend-to-backend`: ingress to `role=backend` from `role=frontend`
- `allow-backend-to-db`: ingress to `role=db` from `role=backend`

## Step 2 – Update Pod labels

```bash
kubectl label pod frontend -n network-demo role=frontend --overwrite
kubectl label pod backend -n network-demo role=backend --overwrite
kubectl label pod database -n network-demo role=db --overwrite
```

## Step 3 – Verify labels

```bash
kubectl get pods -n network-demo --show-labels
```

Expected output:
```
NAME       READY   STATUS    LABELS
frontend   1/1     Running   role=frontend,...
backend    1/1     Running   role=backend,...
database   1/1     Running   role=db,...
```

## Step 4 – Verify NetworkPolicies are unchanged

```bash
kubectl get networkpolicies -n network-demo
kubectl describe networkpolicy allow-frontend-to-backend -n network-demo
kubectl describe networkpolicy allow-backend-to-db -n network-demo
```

## Key Concepts

- `kubectl label --overwrite` changes an existing label value without recreating the Pod
- NetworkPolicies select pods dynamically based on current labels
- The communication chain `frontend → backend → database` requires correct labels on all three Pods
- The `deny-all` policy blocks everything by default; only explicitly allowed traffic passes
