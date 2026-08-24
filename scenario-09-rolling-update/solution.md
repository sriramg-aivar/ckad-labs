# Solution – Scenario 09: Perform Rolling Update and Rollback

## Step 1 – Update the image

```bash
kubectl set image deploy/app-v1 web=nginx:1.25
```

## Step 2 – Verify the rolling update

```bash
kubectl rollout status deploy app-v1
```

Wait until you see: `deployment "app-v1" successfully rolled out`

## Step 3 – View rollout history

```bash
kubectl rollout history deploy app-v1
```

You should see at least 2 revisions.

## Step 4 – Rollback to previous revision

```bash
kubectl rollout undo deploy app-v1
```

## Step 5 – Verify the rollback

```bash
kubectl rollout status deploy app-v1
kubectl get deploy app-v1 -o jsonpath='{.spec.template.spec.containers[0].image}'
# Should show nginx:1.20
```

## Alternative: Rollback to specific revision

```bash
kubectl rollout undo deploy app-v1 --to-revision=1
```
