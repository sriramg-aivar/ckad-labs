# Scenario 21 – Make a Deployment Fit Within the Namespace ResourceQuota

## Context

Namespace `team-a` has a ResourceQuota `team-a-quota`:

| Quota | Value |
|-------|-------|
| `requests.cpu`    | `1`   |
| `requests.memory` | `1Gi` |
| `limits.cpu`      | `2`   |
| `limits.memory`   | `2Gi` |

Deployment `team-app` wants **4 replicas**, but each pod requests more than the
quota can afford for all 4 pods, so the ResourceQuota is **blocking** some pods
(the ReplicaSet reports `FailedCreate` / `exceeded quota`).

## Task

1. Inspect the ResourceQuota and the current per-pod resource values
2. Compute per-pod requests/limits so that **all 4 replicas fit** within the quota
3. Update Deployment `team-app` accordingly (keep 4 replicas)
4. Verify the Deployment becomes fully available (4/4 ready) and no quota errors remain

## The math

The quota is the total for the whole namespace, so divide by the replica count (4):

| Resource | Quota total | Max per pod (÷4) |
|----------|-------------|------------------|
| requests.cpu    | `1000m` | `250m`  |
| requests.memory | `1024Mi`| `256Mi` |
| limits.cpu      | `2000m` | `500m`  |
| limits.memory   | `2048Mi`| `512Mi` |

Setting each pod to (requests `250m`/`256Mi`, limits `500m`/`512Mi`) fits exactly.
Anything smaller also fits.

## Test BEFORE fix

```bash
kubectl get deploy team-app -n team-a
# Expected: fewer than 4 pods available (e.g. 1/4 or 2/4)

kubectl describe rs -n team-a -l app=team-app | grep -i quota
# Expected: "exceeded quota" / FailedCreate events

kubectl describe quota team-a-quota -n team-a
```

## Test AFTER fix

```bash
kubectl get deploy team-app -n team-a
# Expected: 4/4 READY

kubectl rollout status deploy/team-app -n team-a

kubectl describe quota team-a-quota -n team-a
# Used should be <= Hard for every line
```

## Hints

- `kubectl describe quota team-a-quota -n team-a` shows Hard vs Used.
- Per-pod limit = quota_total / replicas. With 4 replicas: `limits.cpu` per pod ≤ `500m`.
- `kubectl set resources deploy/team-app -c app --requests=cpu=250m,memory=256Mi --limits=cpu=500m,memory=512Mi -n team-a`
- Every pod under a quota MUST declare both requests and limits.

## Docs Reference

- https://kubernetes.io/docs/concepts/policy/resource-quotas/
