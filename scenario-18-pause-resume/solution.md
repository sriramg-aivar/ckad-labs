# Solution – Scenario 18: Pause, Batch Changes, and Resume

## Step 1 – Pause the rollout

```bash
kubectl rollout pause deploy/rollout-app -n default
```

## Step 2 – Make both changes while paused

```bash
kubectl set image deploy/rollout-app app=nginx:1.26 -n default
kubectl set env deploy/rollout-app RELEASE=canary -n default
```

Because the deployment is paused, **no** new ReplicaSet/rollout is created yet.
You can confirm it's paused:

```bash
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.paused}'   # true
# kubectl rollout status ... would hang here
```

## Step 3 – Resume

```bash
kubectl rollout resume deploy/rollout-app -n default
kubectl rollout status deploy/rollout-app -n default
```

## Verification

```bash
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].image}'  # nginx:1.26
kubectl get deploy rollout-app -n default -o jsonpath='{.spec.template.spec.containers[0].env}'    # RELEASE=canary
kubectl rollout history deploy/rollout-app -n default
```

## Key Points

- `pause` freezes the deployment controller so multiple edits don't each trigger a rollout.
- All changes made while paused roll out together in **one** revision on `resume`.
- A paused deployment cannot be rolled back until it is resumed.
- `kubectl rollout status` hanging is the expected proof that the deployment is paused.
