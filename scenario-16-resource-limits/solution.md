# Solution – Scenario 16: Add Resource Requests and Limits to Pod

## Step 1 – Check the ResourceQuota

```bash
kubectl get quota -n prod
kubectl describe quota -n prod
```

Output shows:
- `limits.cpu: 2`
- `limits.memory: 4Gi`

Half of those: CPU = `1`, Memory = `2Gi`

## Step 2 – Create the Pod

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
  namespace: prod
spec:
  containers:
    - name: web
      image: nginx:latest
      resources:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "1"
          memory: "2Gi"
EOF
```

## Verification

```bash
kubectl get pod resource-pod -n prod
kubectl describe pod resource-pod -n prod | grep -A 6 "Limits\|Requests"
kubectl get quota -n prod
```

## Key Points

- When a ResourceQuota is set in a namespace, all Pods MUST specify resource requests and limits
- Requests must be ≤ Limits
- The sum of all Pod limits in the namespace cannot exceed the ResourceQuota limits
- Half of `2` CPU = `1` (or `1000m`)
- Half of `4Gi` memory = `2Gi`
