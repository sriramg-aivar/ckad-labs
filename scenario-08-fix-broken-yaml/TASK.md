# Scenario 08 – Fix Broken Deployment YAML

## Context

File `/root/broken-deploy.yaml` contains a Deployment manifest that fails to apply due to multiple issues.

## Task

1. Attempt to apply the file and observe the errors
2. Fix **all** issues in the YAML file:
   - Uses a deprecated API version
   - Missing required field(s) for the current API version
3. Apply the fixed manifest successfully
4. Verify the Deployment is running with all Pods ready

## Requirements

- The Deployment must use `apiVersion: apps/v1`
- The Deployment must have a proper `selector` field matching the template labels
- Deployment name must remain `broken-app`
- Replicas must remain `2`
- The Deployment must be successfully applied and available

## Hints

- In `apps/v1`, the `selector` field is required (it was optional in `extensions/v1beta1`)
- The `selector.matchLabels` must match `spec.template.metadata.labels`
- Use `kubectl explain deployment.spec.selector` for field reference

## Docs Reference

- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://kubernetes.io/docs/reference/using-api/deprecation-guide/
