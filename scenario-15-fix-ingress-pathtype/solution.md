# Solution – Scenario 15: Fix Ingress PathType

## Step 1 – Try to apply (will fail)

```bash
kubectl apply -f /root/fix-ingress.yaml
# Error: pathType: Unsupported value: "InvalidType"
```

## Step 2 – Fix the file

Edit `/root/fix-ingress.yaml` and change `pathType: InvalidType` to `pathType: Prefix`:

```bash
vi /root/fix-ingress.yaml
```

Or use sed:

```bash
sed -i 's/pathType: InvalidType/pathType: Prefix/' /root/fix-ingress.yaml
```

The fixed file should look like:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: default
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 8080
```

## Step 3 – Apply the fixed manifest

```bash
kubectl apply -f /root/fix-ingress.yaml
```

## Verification

```bash
kubectl get ingress api-ingress
kubectl describe ingress api-ingress
```

## Key Points

- Valid `pathType` values: `Prefix`, `Exact`, `ImplementationSpecific`
- `pathType` is a required field in `networking.k8s.io/v1`
