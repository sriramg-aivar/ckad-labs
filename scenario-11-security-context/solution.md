# Solution – Scenario 11: Configure Pod and Container Security Context

## Step 1 – Edit the Deployment

```bash
kubectl edit deploy secure-app
```

Add security context at both Pod level and container level:

```yaml
spec:
  template:
    spec:
      securityContext:        # Pod-level
        runAsUser: 1000
      containers:
        - name: app
          image: nginx
          securityContext:    # Container-level
            capabilities:
              add:
                - NET_ADMIN
```

Save and exit.

## Step 2 – Verify the rollout

```bash
kubectl rollout status deploy secure-app
```

## Step 3 – Verify security context

```bash
# Check Pod-level runAsUser
kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.securityContext.runAsUser}'
# Should output: 1000

# Check container-level capabilities
kubectl get deploy secure-app -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add}'
# Should output: ["NET_ADMIN"]
```

## Alternative: Using kubectl patch

```bash
kubectl patch deploy secure-app --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/securityContext",
    "value": {"runAsUser": 1000}
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/securityContext",
    "value": {"capabilities": {"add": ["NET_ADMIN"]}}
  }
]'
```
