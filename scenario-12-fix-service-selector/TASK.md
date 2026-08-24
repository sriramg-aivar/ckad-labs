# Scenario 12 – Fix Service Selector

## Context

In namespace `default`, Deployment `web-app` exists with Pods labeled `app=webapp`.

Service `web-svc` exists but has an incorrect selector `app=wrongapp`, so it is not routing traffic to the correct Pods.

## Task

Update Service `web-svc` to correctly select Pods from Deployment `web-app`.

## Verification

After fixing the selector:
- `kubectl get endpoints web-svc` should show Pod IPs (not empty)

## Hints

- Use `kubectl get pods --show-labels` to see Pod labels
- Use `kubectl get svc web-svc -o yaml` to see the current selector
- Use `kubectl edit svc web-svc` to fix the selector

## Docs

- Services: https://kubernetes.io/docs/concepts/services-networking/service/
