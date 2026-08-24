#!/usr/bin/env bash
set -euo pipefail

echo "Verifying kubeadm cluster is ready for CKAD labs..."
if ! kubectl get nodes &>/dev/null; then
  echo "ERROR: kubectl cannot reach the cluster."
  echo "Make sure you're on the controlplane node of a Killercoda Kubernetes playground (2 nodes)."
  exit 1
fi

echo ""
kubectl get nodes -o wide

# Verify 2-node cluster
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [ "$NODE_COUNT" -lt 2 ]; then
  echo ""
  echo "⚠ Only $NODE_COUNT node(s) detected. Expected 2 (controlplane + node01)."
  echo "  Some scenarios may still work on a single-node cluster."
fi

# Ensure CNI is running (Killercoda has Calico by default)
echo ""
if kubectl get pods -n kube-system -l k8s-app=calico-node 2>/dev/null | grep -q Running; then
  echo "✓ Calico CNI is running (NetworkPolicies enforced)"
elif kubectl get pods -n calico-system 2>/dev/null | grep -q Running; then
  echo "✓ Calico CNI is running (NetworkPolicies enforced)"
elif kubectl get pods -n kube-system 2>/dev/null | grep -q flannel; then
  echo "✓ Flannel CNI is running"
  echo "⚠ Note: Flannel does not enforce NetworkPolicies. Scenario 07 may not work as expected."
else
  echo "⚠ Calico not detected. Installing..."
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
  echo "Waiting for Calico to be ready..."
  kubectl wait --for=condition=Ready pods -l k8s-app=calico-node -n kube-system --timeout=120s 2>/dev/null || true
fi

# Create namespaces used across scenarios
echo ""
echo "Pre-creating namespaces..."
for ns in audit monitoring network-demo prod; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null
done
echo "✓ Namespaces ready"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Cluster ready! Run ../ckad.sh to start studying"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Nodes:"
echo "  controlplane — you are here"
echo "  node01       — ssh node01"
echo ""
echo "Tips:"
echo "  - Use kubectl explain <resource> for field discovery"
echo "  - kubernetes.io/docs is allowed in the exam"
echo "  - Practice each scenario until < 5 minutes"
