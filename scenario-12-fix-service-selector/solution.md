# Solution – Scenario 12: Fix Service Selector

## Step 1 – Check current state

```bash
# Check Pod labels
kubectl get pods --show-labels

# Check current service selector
kubectl get svc web-svc -o yaml

# Check endpoints (should be empty or missing)
kubectl get endpoints web-svc
```

## Step 2 – Fix the Service selector

```bash
kubectl edit svc web-svc
```

Change the selector from:

```yaml
spec:
  selector:
    app: wrongapp
```

To:

```yaml
spec:
  selector:
    app: webapp
```

Save and exit.

## Step 3 – Verify endpoints

```bash
kubectl get endpoints web-svc
# Should now show IPs of web-app pods

kubectl describe svc web-svc
```

## Alternative: Using kubectl patch

```bash
kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"webapp"}}}'
```
