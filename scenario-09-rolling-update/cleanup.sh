#!/bin/bash

echo "Cleaning up Scenario 09..."

kubectl delete deployment app-v1 --ignore-not-found
echo "Cleanup complete."
