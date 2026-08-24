# 🎯 CKAD Practice Labs

Practice all **16 CKAD exam scenarios** on a real **kubeadm cluster** (2 nodes: controlplane + node01).

Designed for **Killercoda** Kubernetes playgrounds — or any kubeadm cluster with 2 nodes.

---

## Quick Start (Killercoda)

```bash
# 1. Open a Killercoda Kubernetes playground (2 nodes)
# 2. Clone this repo on the controlplane node:
git clone <this-repo>
cd ckad-labs

# 3. One-time setup (verifies cluster, creates namespaces):
cd cluster && ./create-cluster.sh && cd ..

# 4. Start studying:
./ckad.sh
```

---

## How it works

```
╔═══════════════════════════════════════════════════════════════╗
║            CKAD Practice Labs - Study Mode                    ║
╚═══════════════════════════════════════════════════════════════╝

  Progress: 0/16 completed

  ▶ Scenario 01/16: Create Secret from Variables

  Options:
    [r] Run/Setup this scenario
    [t] Show Task (question)
    [s] Show Solution
    [c] Check my answer
    [x] Reset (cleanup) scenario
    [d] Mark done & next →
    [n] Next scenario →
    [p] Previous scenario ←
    [l] List all scenarios
    [q] Quit
```

### Workflow:
1. **`[r]`** — Setup scenario (creates resources, sets up the problem)
2. **Task shows on screen** — solve it in another terminal tab
3. **`[c]`** — Check your answer (automated validation)
4. **`[s]`** — View solution if stuck
5. **`[d]`** — Mark done, move to next

Progress is saved. Quit with `[q]` (asks to save or reset progress).

---

## All 16 Scenarios

| # | Topic | What you do |
|---|-------|-------------|
| 01 | Create Secret | Create Secret from hardcoded env vars, update Deployment |
| 02 | CronJob | Create CronJob with schedule + history limits |
| 03 | RBAC | Create ServiceAccount, Role, RoleBinding from error |
| 04 | Fix ServiceAccount | Investigate RBAC, fix Pod's ServiceAccount |
| 05 | Podman Image Build | Build image with Podman, save as tarball |
| 06 | Canary Deployment | Scale + create canary with shared Service |
| 07 | NetworkPolicy Labels | Fix Pod labels to match NetworkPolicy selectors |
| 08 | Fix Broken YAML | Fix deprecated apiVersion + missing selector |
| 09 | Rolling Update | Update image, verify rollout, rollback |
| 10 | Readiness Probe | Add HTTP readiness probe to Deployment |
| 11 | Security Context | Set runAsUser + add NET_ADMIN capability |
| 12 | Fix Service Selector | Fix Service selector to match Deployment pods |
| 13 | NodePort Service | Create NodePort Service for Deployment |
| 14 | Create Ingress | Create Ingress with host routing |
| 15 | Fix Ingress PathType | Fix invalid pathType in Ingress manifest |
| 16 | Resource Limits | Create Pod with requests/limits based on ResourceQuota |

---

## Cluster Info

| Node | Role | Access |
|------|------|--------|
| controlplane | Control plane | You're on it |
| node01 | Worker | `ssh node01` |

---

## Tips for CKAD Exam

- Practice each scenario until < 5 minutes
- kubernetes.io/docs is allowed — know where things are
- Do a timed full run — all 16 in < 90 minutes
- `kubectl explain <resource>.<field>` is your best friend
- Use `kubectl create` and `kubectl run` with `--dry-run=client -o yaml` for quick YAML generation
- Know imperative commands: `kubectl expose`, `kubectl set image`, `kubectl scale`
- For debugging: `kubectl describe`, `kubectl logs`, `kubectl get events`

---

## File Structure

```
ckad-labs/
├── ckad.sh                    # ← Interactive runner
├── run.sh                     # Run scenario by number
├── check.sh                   # Check scenario by number
├── reset.sh                   # Reset scenario by number
├── cluster/
│   ├── create-cluster.sh      # Verify cluster + create namespaces
│   └── destroy-cluster.sh     # Teardown info
├── scenario-01-secret/
│   ├── TASK.md                # Exam-style question
│   ├── solution.md            # Full solution
│   ├── setup.sh               # Creates the problem
│   ├── cleanup.sh             # Resets everything
│   └── check.sh               # Validates your answer
├── ...
└── scenario-16-resource-limits/
```

---

## Troubleshooting

### kubectl not working / connection refused

```bash
# Check if API server is running
crictl ps | grep kube-apiserver

# Restart kubelet
systemctl restart kubelet
sleep 30
kubectl get nodes
```

### Scenario won't set up (AlreadyExists errors)

Run reset first: press `[x]` in the menu, then `[r]` again.

### Pods stuck in Pending/ContainerCreating

```bash
kubectl describe pod <pod-name> -n <namespace>
# Check Events section for the actual error
```

### Using without Killercoda

Any kubeadm cluster with 2 nodes works. You can also use:
- **kind** (some scenarios like Podman won't work)
- **minikube** (single node, most scenarios still work)
- **Cloud VMs** (best experience — 2 Ubuntu VMs with kubeadm)

---

## Related

- [CKAD Practice Questions](https://github.com/aravind4799/CKAD-Practice-Questions) — The questions these labs are based on
- **Medium post:** [CKAD 2026 — What to Expect & How I Passed](https://medium.com/@araviku04/ckad-2026-what-to-expect-how-i-passed-448f134ac8b5)

---

Good luck with your CKAD exam! ⭐
