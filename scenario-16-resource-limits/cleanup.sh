#!/bin/bash
set -e

echo "Cleaning up Scenario 16..."

kubectl delete namespace prod --ignore-not-found

echo "Cleanup complete."
