# Scenario 18 – Pause, Batch Changes, and Resume a Deployment Rollout

## Context

In namespace `default`, Deployment `rollout-app` runs image `nginx:1.24` with 4 replicas.

You need to apply **multiple** changes but roll them out as a **single** revision
(so you don't trigger one rollout per change). This is the classic
`kubectl rollout pause` / `resume` workflow.

## Task

1. **Pause** the rollout of Deployment `rollout-app`
2. While paused, make BOTH of these changes:
   - Update the container image to `nginx:1.26`
   - Add an environment variable `RELEASE=canary` to the container `app`
3. **Resume** the rollout so both changes are applied together
4. Verify the rollout completes successfully

## Test BEFORE fix

```bash
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].image}'
# Expected: nginx:1.24
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.paused}'
# Expected: <empty> (not paused)
```

## Test AFTER fix

```bash
# Image updated
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].image}'
# Expected: nginx:1.26

# Env var present
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].env}'
# Expected: RELEASE=canary

# Not paused anymore
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.paused}'
# Expected: <empty>

# Rollout finished
kubectl rollout status deploy/rollout-app -n default
```

## Hints

- `kubectl rollout pause deploy/rollout-app`
- Make edits while paused: `kubectl set image ...` and `kubectl set env ...`
- While paused, `kubectl rollout status` will hang — that proves it's paused
- `kubectl rollout resume deploy/rollout-app`

## Docs Reference

- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pausing-and-resuming-a-deployment
