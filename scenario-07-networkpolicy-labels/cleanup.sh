#!/bin/bash
# Cleanup for Scenario 07 – Fix NetworkPolicy by Updating Pod Labels
echo "Cleaning up Scenario 07..."

kubectl delete namespace network-demo --ignore-not-found

echo "Cleanup complete."
