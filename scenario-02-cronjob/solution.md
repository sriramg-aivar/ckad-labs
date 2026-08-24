# Solution – Scenario 02: Create CronJob with Schedule and History Limits

## Option 1 – Apply YAML manifest

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  namespace: default
spec:
  schedule: "*/30 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 300
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: backup
              image: busybox:latest
              command: ["/bin/sh", "-c"]
              args: ["echo Backup completed"]
EOF
```

## Option 2 – Generate with kubectl and edit

```bash
# Generate base YAML
kubectl create cronjob backup-job \
  --image=busybox:latest \
  --schedule="*/30 * * * *" \
  --dry-run=client -o yaml > /tmp/backup-job.yaml
```

Edit `/tmp/backup-job.yaml` to add:
- `spec.successfulJobsHistoryLimit: 3`
- `spec.failedJobsHistoryLimit: 2`
- `spec.jobTemplate.spec.activeDeadlineSeconds: 300`
- `spec.jobTemplate.spec.template.spec.restartPolicy: Never`
- Container command: `["/bin/sh", "-c"]` with args `["echo Backup completed"]`

Then apply:

```bash
kubectl apply -f /tmp/backup-job.yaml
```

## Verify

```bash
kubectl get cronjob backup-job -n default
kubectl describe cronjob backup-job -n default

# Test manually
kubectl create job backup-job-test --from=cronjob/backup-job -n default
kubectl wait --for=condition=complete job/backup-job-test -n default --timeout=30s
kubectl logs job/backup-job-test -n default
# Output: Backup completed
```
