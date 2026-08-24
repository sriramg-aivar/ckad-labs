# Scenario 10 – Add Readiness Probe to Deployment

## Context

In namespace `default`, Deployment `api-deploy` exists with a container named `api` listening on port `8080`.

## Task

Add a readiness probe to the Deployment with the following specifications:

- HTTP GET on path `/ready`
- Port `8080`
- `initialDelaySeconds: 5`
- `periodSeconds: 10`

Ensure the Deployment rolls out successfully after the change.

## Hints

- Use `kubectl edit deploy api-deploy` to modify the deployment
- The readinessProbe goes under the container spec
- Use `kubectl explain deploy.spec.template.spec.containers.readinessProbe` for field reference

## Docs

- Readiness Probes: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
