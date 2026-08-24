# Scenario 14 – Create Ingress Resource

## Context

In namespace `default`, the following resources exist:
- Deployment `web-deploy` with Pods labeled `app=web`
- Service `web-svc` with selector `app=web` on port `8080`

## Task

Create an Ingress named `web-ingress` that:
- Routes host `web.example.com`
- Path `/` with `pathType: Prefix`
- Backend Service `web-svc` on port `8080`
- Uses API version `networking.k8s.io/v1`

## Verification

```bash
kubectl get ingress web-ingress
kubectl describe ingress web-ingress
```

## Docs

- Ingress: https://kubernetes.io/docs/concepts/services-networking/ingress/
