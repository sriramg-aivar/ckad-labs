# Solution – Scenario 20: Double the Resource Requests and Limits

## Step 1 – Read the current values

```bash
kubectl get deploy compute-app -n default \
  -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq .
```

Current:
- requests: `cpu=100m`, `memory=128Mi`
- limits: `cpu=250m`, `memory=256Mi`

Doubled:
- requests: `cpu=200m`, `memory=256Mi`
- limits: `cpu=500m`, `memory=512Mi`

## Step 2 – Apply the doubled values

Fastest imperative way:

```bash
kubectl set resources deploy/compute-app -n default -c worker \
  --requests=cpu=200m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi
```

Or `kubectl edit deploy compute-app` and update the `resources` block manually.

## Step 3 – Verify

```bash
kubectl rollout status deploy/compute-app -n default
kubectl get deploy compute-app -n default \
  -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq .
```

## Key Points

- Always read the base numbers first — the "double" is relative to what's there.
- `kubectl set resources` targets a specific container with `-c`.
- Memory doubling: `128Mi -> 256Mi`, `256Mi -> 512Mi` (stay in the same unit to avoid mistakes).
- Changing resources on a Deployment triggers a new rollout.
