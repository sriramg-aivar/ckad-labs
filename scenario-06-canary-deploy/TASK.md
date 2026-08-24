# Scenario 06 – Create Canary Deployment with Manual Traffic Split

## Context

In namespace `default`, the following resources exist:
- Deployment `web-app` with 5 replicas, Pod labels `app=webapp, version=v1`
- Service `web-service` with selector `app=webapp`

The Service selects all Pods with label `app=webapp`, regardless of the `version` label.

## Task

1. Scale Deployment `web-app` to **8 replicas** (representing 80% of total traffic)
2. Create a new Deployment named `web-app-canary` with:
   - **2 replicas** (representing 20% of total traffic)
   - Pod labels: `app=webapp, version=v2`
   - Same container image as the original deployment
3. Ensure Service `web-service` routes traffic to **both** Deployments

## Requirements

- `web-app` must have exactly 8 replicas
- `web-app-canary` must have exactly 2 replicas
- Pods from `web-app-canary` must have labels `app=webapp` and `version=v2`
- Do NOT modify the Service selector
- Total pods serving traffic: 10 (8 v1 + 2 v2 = 80/20 split)

## Hints

- The Service selector only uses `app=webapp`, so any Pod with that label gets traffic
- Use `kubectl get endpoints web-service` to verify both sets of pods are included
- The canary deployment's `selector.matchLabels` must include `version=v2` to avoid conflicts

## Docs Reference

- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/concepts/services-networking/service/
