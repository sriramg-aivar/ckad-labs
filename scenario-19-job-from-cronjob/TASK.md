# Scenario 19 – Manually Trigger a Job From an Existing CronJob

## Context

In namespace `default`, CronJob `report-generator` exists and is scheduled to run
daily at 03:00. You need to run it **now**, on demand, without changing the
schedule or waiting for the next scheduled time.

## Task

1. Create a one-off Job named `manual-report` in namespace `default` **from** the
   existing CronJob `report-generator` (reuse its jobTemplate — do not hand-write
   a new pod spec)
2. Confirm the Job runs to completion successfully
3. Do **not** modify or delete the CronJob

## Test BEFORE fix

```bash
kubectl get cronjob report-generator -n default
kubectl get job manual-report -n default
# Expected: Job not found
```

## Test AFTER fix

```bash
# Job exists and was created from the cronjob
kubectl get job manual-report -n default

# It completed
kubectl get job manual-report -n default -o jsonpath='{.status.succeeded}'
# Expected: 1

# Output
kubectl logs job/manual-report -n default
# Expected: Report generated

# CronJob still intact
kubectl get cronjob report-generator -n default
```

## Hints

- `kubectl create job <name> --from=cronjob/<cronjob-name>`
- `--from` copies the CronJob's `jobTemplate` into a standalone Job
- Give it a moment to complete: `kubectl wait --for=condition=complete job/manual-report`

## Docs Reference

- https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
- https://kubernetes.io/docs/concepts/workloads/controllers/job/
