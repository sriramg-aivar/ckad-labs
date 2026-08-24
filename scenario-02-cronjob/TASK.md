# Scenario 02 – Create CronJob with Schedule and History Limits

## Context

You need to create a scheduled backup job that runs periodically with specific constraints.

## Task

Create a CronJob named `backup-job` in namespace `default` with the following specifications:

- **Schedule:** Run every 30 minutes (`*/30 * * * *`)
- **Image:** `busybox:latest`
- **Container command:** `echo "Backup completed"`
- **successfulJobsHistoryLimit:** `3`
- **failedJobsHistoryLimit:** `2`
- **activeDeadlineSeconds:** `300`
- **restartPolicy:** `Never`

## Test BEFORE fix

```bash
# No CronJob should exist yet
kubectl get cronjob backup-job -n default
# Expected: Error - not found
```

## Test AFTER fix

```bash
# Verify CronJob exists
kubectl get cronjob backup-job -n default

# Verify schedule
kubectl get cronjob backup-job -n default -o jsonpath='{.spec.schedule}'
# Expected: */30 * * * *

# Verify history limits
kubectl get cronjob backup-job -n default -o jsonpath='{.spec.successfulJobsHistoryLimit}'
# Expected: 3
kubectl get cronjob backup-job -n default -o jsonpath='{.spec.failedJobsHistoryLimit}'
# Expected: 2

# Test by creating a job from the cronjob
kubectl create job backup-job-test --from=cronjob/backup-job -n default
kubectl logs job/backup-job-test -n default
# Expected: Backup completed
```

## Hints

- `kubectl create cronjob --help`
- `kubectl explain cronjob.spec`
- `kubectl explain cronjob.spec.jobTemplate.spec`
- `activeDeadlineSeconds` goes under `jobTemplate.spec`, not `cronjob.spec`
