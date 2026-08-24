# Scenario 15 – Fix Ingress PathType

## Context

File `/root/fix-ingress.yaml` contains an Ingress manifest that fails to apply due to an invalid `pathType` value.

Service `api-svc` and Deployment `api-deploy` already exist in namespace `default`.

## Task

1. Try to apply `/root/fix-ingress.yaml` and observe the error
2. Fix the `pathType` to a valid value (`Prefix`, `Exact`, or `ImplementationSpecific`)
3. Ensure the Ingress routes path `/api` to Service `api-svc` on port `8080`
4. Apply the fixed manifest successfully

## Verification

```bash
kubectl get ingress api-ingress
kubectl describe ingress api-ingress
```

## Docs

- Ingress Path Types: https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types
