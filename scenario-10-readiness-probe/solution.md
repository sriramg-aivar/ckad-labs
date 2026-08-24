# Solution – Scenario 10: Add Readiness Probe to Deployment

## Step 1 – Edit the Deployment

```bash
kubectl edit deploy api-deploy
```

Add the readiness probe under the container spec:

```yaml
spec:
  template:
    spec:
      containers:
        - name: api
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
```

Save and exit.

## Step 2 – Verify the rollout

```bash
kubectl rollout status deploy api-deploy
```

## Step 3 – Verify the probe configuration

```bash
kubectl get deploy api-deploy -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}'
```

## Alternative: Patch command

```bash
kubectl patch deploy api-deploy --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/ready",
        "port": 8080
      },
      "initialDelaySeconds": 5,
      "periodSeconds": 10
    }
  }
]'
```
