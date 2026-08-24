# Scenario 16 – Add Resource Requests and Limits to Pod

## Context

In namespace `prod`, a ResourceQuota exists that sets resource limits for the namespace.

## Task

1. Check the ResourceQuota for namespace `prod` to see the limits set
2. Create a Pod named `resource-pod` in namespace `prod` with:
   - Image: `nginx:latest`
   - Set the CPU and memory **limits** to **half** of the limits set in the ResourceQuota
   - Set appropriate **requests** (at least `100m` CPU and `128Mi` memory)

## Hints

- Use `kubectl get quota -n prod` and `kubectl describe quota -n prod` to find the quota limits
- The ResourceQuota has `limits.cpu=2` and `limits.memory=4Gi`
- Half of those values: CPU limit = `1`, memory limit = `2Gi`

## Verification

```bash
kubectl get pod resource-pod -n prod
kubectl describe pod resource-pod -n prod
kubectl get quota -n prod
```

## Docs

- ResourceQuota: https://kubernetes.io/docs/concepts/policy/resource-quotas/
- Resource Management: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
