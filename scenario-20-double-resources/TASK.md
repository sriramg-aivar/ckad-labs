# Scenario 20 – Double the Resource Requests and Limits of a Deployment

## Context

In namespace `default`, Deployment `compute-app` (container `worker`) is currently
under-provisioned. Its container resources are:

- **requests:** `cpu=100m`, `memory=128Mi`
- **limits:** `cpu=250m`, `memory=256Mi`

The workload needs twice the capacity.

## Task

1. Inspect the current requests and limits of container `worker`
2. **Double** each value:
   - requests: `cpu=200m`, `memory=256Mi`
   - limits: `cpu=500m`, `memory=512Mi`
3. Roll out the change and verify all pods become ready
4. Keep the same Deployment name, namespace, and container name

## Test BEFORE fix

```bash
kubectl get deploy compute-app -n default \
  -o jsonpath='{.spec.template.spec.containers[0].resources}'
# Expected: requests 100m/128Mi, limits 250m/256Mi
```

## Test AFTER fix

```bash
kubectl get deploy compute-app -n default \
  -o jsonpath='{.spec.template.spec.containers[0].resources}'
# Expected: requests 200m/256Mi, limits 500m/512Mi

kubectl rollout status deploy/compute-app -n default
```

## Hints

- Read the current values first — the exam gives you the base numbers to double.
- `kubectl edit deploy compute-app` and update `resources.requests` and `resources.limits`.
- Or use `kubectl set resources deploy/compute-app -c worker --requests=cpu=200m,memory=256Mi --limits=cpu=500m,memory=512Mi`.
- Remember `256Mi` doubled is `512Mi`, and `128Mi` doubled is `256Mi`.

## Docs Reference

- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
