# Scenario 11 – Configure Pod and Container Security Context

## Context

In namespace `default`, Deployment `secure-app` exists without any security context configured. The container is named `app`.

## Task

1. Set Pod-level `runAsUser: 1000`
2. Add container-level capability `NET_ADMIN` to the container named `app`

## Important Notes

- Capabilities are set at the **container level**, not the Pod level
- `runAsUser` is set at the **Pod level** (under `spec.securityContext`)

## Hints

- Use `kubectl edit deploy secure-app` to modify the deployment
- Use `kubectl explain pod.spec.securityContext` for Pod-level fields
- Use `kubectl explain pod.spec.containers.securityContext.capabilities` for container-level fields

## Docs

- Security Context: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
