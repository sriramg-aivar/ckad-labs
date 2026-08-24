# Scenario 13 – Create NodePort Service

## Context

In namespace `default`, Deployment `api-server` exists with Pods labeled `app=api` and container port `9090`.

## Task

Create a Service named `api-nodeport` that:
- Type: `NodePort`
- Selects Pods with label `app=api`
- Exposes Service port `80` mapping to target port `9090`

## Verification

```bash
kubectl get svc api-nodeport
kubectl describe svc api-nodeport
kubectl get endpoints api-nodeport
```

## Docs

- NodePort Services: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport
