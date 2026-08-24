#!/bin/bash

echo "=== Cleaning up Scenario 04 ==="

kubectl delete namespace monitoring --ignore-not-found

echo "=== Cleanup complete ==="
