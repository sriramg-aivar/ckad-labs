#!/bin/bash

echo "=== Cleaning up Scenario 03 ==="

kubectl delete namespace audit --ignore-not-found

echo "=== Cleanup complete ==="
