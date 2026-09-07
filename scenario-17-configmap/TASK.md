# Scenario 17 – Create ConfigMap and Consume It in a Deployment

## Context

In namespace `default`, Deployment `web-config` exists. The application needs
configuration data supplied via a ConfigMap — both as environment variables and
as a mounted file.

## Task

1. Create a ConfigMap named `app-config` in namespace `default` with these key/values:
   - `APP_COLOR=blue`
   - `APP_MODE=production`
2. Update Deployment `web-config` so that the container named `web`:
   - Injects **all** keys from `app-config` as environment variables using `envFrom.configMapRef`
   - Mounts the ConfigMap as a volume at `/etc/appconfig`
3. Do **not** change the Deployment name or namespace

## Test BEFORE fix

```bash
kubectl get deploy web-config -n default
kubectl get configmap app-config -n default
# Expected: ConfigMap not found
```

## Test AFTER fix

```bash
# ConfigMap exists with both keys
kubectl get configmap app-config -n default -o yaml

# Deployment uses envFrom
kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.containers[0].envFrom}'

# Volume + mount present
kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.volumes}'
kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.containers[0].volumeMounts}'

# Env vars injected inside the pod
kubectl exec deploy/web-config -n default -- env | grep APP_
# Expected: APP_COLOR=blue and APP_MODE=production

# File mounted
kubectl exec deploy/web-config -n default -- cat /etc/appconfig/APP_COLOR
# Expected: blue
```

## Hints

- `kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=production`
- `kubectl explain deployment.spec.template.spec.containers.envFrom`
- `kubectl explain deployment.spec.template.spec.volumes.configMap`
- A ConfigMap volume creates one file per key, named after the key

## Docs Reference

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
