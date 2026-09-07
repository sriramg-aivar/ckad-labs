# Solution – Scenario 19: Manually Trigger a Job From a CronJob

## Step 1 – Create the Job from the CronJob

```bash
kubectl create job manual-report --from=cronjob/report-generator -n default
```

`--from=cronjob/<name>` copies the CronJob's `jobTemplate` into a new standalone
Job, so you don't have to rewrite the pod spec, image, or command.

## Step 2 – Wait for completion & verify

```bash
kubectl wait --for=condition=complete job/manual-report -n default --timeout=60s
kubectl get job manual-report -n default
kubectl logs job/manual-report -n default   # Report generated
```

## Verification

```bash
kubectl get job manual-report -n default -o jsonpath='{.status.succeeded}'   # 1
kubectl get cronjob report-generator -n default                             # unchanged
```

## Key Points

- `--from=cronjob/<name>` is the fastest way to run a scheduled job on demand.
- The CronJob itself is untouched — schedule and history limits stay the same.
- The Job inherits `restartPolicy`, image, and command from the CronJob's template.
- `kubectl wait --for=condition=complete` blocks until the Job finishes.
