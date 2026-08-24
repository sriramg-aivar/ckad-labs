# Scenario 07 – Fix NetworkPolicy by Updating Pod Labels

## Context

In namespace `network-demo`, three Pods exist:
- `frontend` with label `role=wrong-frontend`
- `backend` with label `role=wrong-backend`
- `database` with label `role=wrong-db`

Three NetworkPolicies exist:
- `deny-all` — Default deny all ingress traffic in the namespace
- `allow-frontend-to-backend` — Allows ingress to Pods with `role=backend` from Pods with `role=frontend`
- `allow-backend-to-db` — Allows ingress to Pods with `role=db` from Pods with `role=backend`

## Task

Update the Pod labels (do **NOT** modify the NetworkPolicies) to enable the following communication chain:

```
frontend → backend → database
```

## Requirements

- Pod `frontend` must have label `role=frontend`
- Pod `backend` must have label `role=backend`
- Pod `database` must have label `role=db`
- Do NOT delete or modify any NetworkPolicy
- Do NOT delete and recreate the Pods

## Hints

- Use `kubectl label` with `--overwrite` to change existing labels
- Use `kubectl get networkpolicy -n network-demo -o yaml` to inspect the selectors
- Labels are mutable on running Pods — no need to recreate

## Docs Reference

- https://kubernetes.io/docs/concepts/services-networking/network-policies/
