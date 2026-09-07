#!/bin/bash
set -e

echo "Cleaning up Scenario 21..."

kubectl delete namespace team-a --ignore-not-found

echo "Cleanup complete."
