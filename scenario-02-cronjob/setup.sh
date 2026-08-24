#!/bin/bash
set -e

echo "=== Setting up Scenario 02: Create CronJob with Schedule and History Limits ==="

# Clean up any existing resources
kubectl delete cronjob backup-job -n default --ignore-not-found 2>/dev/null

echo ""
echo "=== Setup complete ==="
echo ""
echo "TASK: Create a CronJob named 'backup-job' in namespace 'default' with specific"
echo "      schedule, history limits, and container settings."
echo ""
echo "No pre-existing resources needed for this scenario."
echo ""
echo "See TASK.md for full instructions."
