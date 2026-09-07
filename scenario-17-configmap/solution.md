# Solution – Scenario 17: ConfigMap consumed by Deployment

## Step 1 – Create the ConfigMap

```bash
kubectl create configmap app-config -n default \
  --from-literal=APP_COLOR=blue \
  --from-literal=APP_MODE=production
```

## Step 2 – Wire it into the Deployment

`kubectl edit deploy web-config` and add `envFrom`, a volume, and a volumeMount:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-config
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-config
  template:
    metadata:
      labels:
        app: web-config
    spec:
      containers:
        - name: web
          image: nginx:1.25
          envFrom:
            - configMapRef:
                name: app-config
          volumeMounts:
            - name: config-vol
              mountPath: /etc/appconfig
      volumes:
        - name: config-vol
          configMap:
            name: app-config
```

Apply the change (if you edited a file):

```bash
kubectl apply -f web-config.yaml
kubectl rollout status deploy/web-config -n default
```

## Verification

```bash
kubectl exec deploy/web-config -n default -- env | grep APP_
kubectl exec deploy/web-config -n default -- cat /etc/appconfig/APP_COLOR   # blue
```

## Key Points

- `envFrom.configMapRef` injects **every** key as an env var (key becomes the var name).
- Use `env[].valueFrom.configMapKeyRef` instead if you only want a single key.
- A ConfigMap volume renders one file per key; the filename is the key name.
- Editing the pod template triggers a new rollout automatically.
