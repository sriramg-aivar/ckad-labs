#!/bin/bash

PASS=0
FAIL=0

check() {
  local description="$1"
  local result="$2"
  if [ "$result" == "true" ]; then
    echo "✅ PASS: $description"
    ((PASS++))
  else
    echo "❌ FAIL: $description"
    ((FAIL++))
  fi
}

echo "=== Checking Scenario 17 – ConfigMap consumed by Deployment ==="
echo ""

# Check 1: ConfigMap exists
CM=$(kubectl get configmap app-config -n default -o name 2>/dev/null)
check "ConfigMap app-config exists in namespace default" "$([ -n "$CM" ] && echo true || echo false)"

# Check 2: APP_COLOR=blue
COLOR=$(kubectl get configmap app-config -n default -o jsonpath='{.data.APP_COLOR}' 2>/dev/null)
check "ConfigMap key APP_COLOR=blue (got: $COLOR)" "$([ "$COLOR" == "blue" ] && echo true || echo false)"

# Check 3: APP_MODE=production
MODE=$(kubectl get configmap app-config -n default -o jsonpath='{.data.APP_MODE}' 2>/dev/null)
check "ConfigMap key APP_MODE=production (got: $MODE)" "$([ "$MODE" == "production" ] && echo true || echo false)"

# Check 4: envFrom references the configmap
ENVFROM=$(kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.containers[0].envFrom[*].configMapRef.name}' 2>/dev/null)
check "Deployment uses envFrom configMapRef app-config (got: $ENVFROM)" "$(echo "$ENVFROM" | grep -qw app-config && echo true || echo false)"

# Check 5: a volume references the configmap
VOLCM=$(kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.volumes[*].configMap.name}' 2>/dev/null)
check "Deployment has a volume from configMap app-config (got: $VOLCM)" "$(echo "$VOLCM" | grep -qw app-config && echo true || echo false)"

# Check 6: mount path is /etc/appconfig
MOUNT=$(kubectl get deploy web-config -n default -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null)
check "ConfigMap mounted at /etc/appconfig (got: $MOUNT)" "$(echo "$MOUNT" | grep -qw /etc/appconfig && echo true || echo false)"

# Check 7 (runtime, best-effort): env var present in a running pod
POD=$(kubectl get pods -n default -l app=web-config -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
RUNTIME_COLOR=""
if [ -n "$POD" ]; then
  RUNTIME_COLOR=$(kubectl exec "$POD" -n default -- printenv APP_COLOR 2>/dev/null)
fi
check "Runtime env APP_COLOR=blue inside pod (got: ${RUNTIME_COLOR:-<none>})" "$([ "$RUNTIME_COLOR" == "blue" ] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && echo "🎉 All checks passed!" || echo "⚠️  Some checks failed."
exit $FAIL
