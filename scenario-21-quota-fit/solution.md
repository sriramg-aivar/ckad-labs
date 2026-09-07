# Solution – Scenario 21: Make the Deployment Fit the ResourceQuota

## Step 1 – Inspect the quota and current usage

```bash
kubectl describe quota team-a-quota -n team-a
kubectl get deploy team-app -n team-a          # e.g. 2/4 ready
kubectl describe rs -n team-a -l app=team-app  # "exceeded quota" events
```

Quota totals for the whole namespace:
- requests.cpu = `1` (1000m), requests.memory = `1Gi` (1024Mi)
- limits.cpu = `2` (2000m), limits.memory = `2Gi` (2048Mi)

## Step 2 – Compute per-pod values (÷ replica count = 4)

| Resource | Total | ÷4 (per pod) |
|----------|-------|--------------|
| requests.cpu    | 1000m | 250m  |
| requests.memory | 1024Mi| 256Mi |
| limits.cpu      | 2000m | 500m  |
| limits.memory   | 2048Mi| 512Mi |

## Step 3 – Apply the right-sized resources

```bash
kubectl set resources deploy/team-app -n team-a -c app \
  --requests=cpu=250m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi
```

(Or `kubectl edit deploy team-app -n team-a` and edit the `resources` block.)

## Step 4 – Verify

```bash
kubectl rollout status deploy/team-app -n team-a
kubectl get deploy team-app -n team-a            # 4/4 READY
kubectl describe quota team-a-quota -n team-a     # Used <= Hard everywhere
```

## Key Points

- A ResourceQuota caps the **sum** across all pods in the namespace.
- Per-pod budget = quota_total / number_of_replicas.
- If a Deployment exceeds the quota, the ReplicaSet fails to create the extra pods
  (`FailedCreate: exceeded quota`) — the Deployment reports fewer ready pods, not an error on itself.
- Under a quota, every container must set both requests and limits or pod creation is rejected.
