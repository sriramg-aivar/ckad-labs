# Scenario 09 – Perform Rolling Update and Rollback

## Context

In namespace `default`, Deployment `app-v1` exists with image `nginx:1.20` and 3 replicas.

## Task

1. Update the Deployment `app-v1` to use image `nginx:1.25`
2. Verify the rolling update completes successfully
3. Rollback to the previous revision
4. Verify the rollback completed and the image is back to `nginx:1.20`

## Hints

- Use `kubectl set image` to update the container image
- Use `kubectl rollout status` to monitor the update
- Use `kubectl rollout undo` to rollback
- Use `kubectl rollout history` to view revision history

## Docs

- Rolling Updates: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment
