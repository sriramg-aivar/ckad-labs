#!/bin/bash
set -e

echo "Setting up Scenario 19 – Trigger a Job manually from an existing CronJob..."

# Clean any prior manual job so BEFORE-state is correct
kubectl delete job manual-report -n default --ignore-not-found >/dev/null 2>&1 || true

# Create the CronJob (scheduled far in the future so it won't auto-fire during practice)
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report-generator
  namespace: default
spec:
  schedule: "0 3 * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: report
              image: busybox:latest
              command: ["sh", "-c", "echo 'Report generated'"]
EOF

echo ""
echo "Setup complete! CronJob 'report-generator' exists (runs daily at 03:00)."
echo "Your task:"
echo "  Manually trigger a one-off Job named 'manual-report' FROM this CronJob,"
echo "  without waiting for the schedule."
