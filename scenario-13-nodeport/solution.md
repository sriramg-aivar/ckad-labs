# Solution – Scenario 13: Create NodePort Service

## Option 1: Imperative Command

```bash
kubectl expose deploy api-server --name=api-nodeport --type=NodePort --port=80 --target-port=9090
```

## Option 2: Declarative YAML

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: api-nodeport
  namespace: default
spec:
  type: NodePort
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 9090
      protocol: TCP
EOF
```

## Verification

```bash
kubectl get svc api-nodeport
kubectl describe svc api-nodeport
kubectl get endpoints api-nodeport
```

The endpoints should show the IPs of the api-server pods.
