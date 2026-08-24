# Solution – Scenario 08: Fix Broken Deployment YAML

## Step 1 – Try applying the broken file

```bash
kubectl apply -f /root/broken-deploy.yaml
```

You'll see an error like:
```
error: resource mapping not found for name: "broken-app" namespace: "" from "/root/broken-deploy.yaml":
no matches for kind "Deployment" in version "extensions/v1beta1"
```

## Step 2 – Identify the issues

View the file:

```bash
cat /root/broken-deploy.yaml
```

Issues:
1. `apiVersion: extensions/v1beta1` — deprecated and removed in Kubernetes 1.16+
2. Missing `spec.selector` field — required in `apps/v1`

## Step 3 – Fix the file

Edit the file:

```bash
vi /root/broken-deploy.yaml
```

The corrected file should be:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: web
        image: nginx
```

Changes made:
1. Changed `apiVersion` from `extensions/v1beta1` to `apps/v1`
2. Added `spec.selector.matchLabels` matching the template labels

## Step 4 – Apply and verify

```bash
kubectl apply -f /root/broken-deploy.yaml
kubectl rollout status deploy broken-app
kubectl get deploy broken-app
kubectl get pods -l app=myapp
```

## Key Concepts

- `extensions/v1beta1` was removed in Kubernetes 1.16; use `apps/v1` for Deployments
- In `apps/v1`, `spec.selector` is required and immutable after creation
- `spec.selector.matchLabels` must match `spec.template.metadata.labels`
