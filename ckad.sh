#!/usr/bin/env bash
set -euo pipefail

# ════════════════════════════════════════════════════════════════════
#  CKAD Practice Labs — Interactive Runner
# ════════════════════════════════════════════════════════════════════

PROGRESS_FILE=".ckad-progress"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Scenarios ───────────────────────────────────────────────────────
SCENARIO_DIRS=(
  "scenario-01-secret"
  "scenario-02-cronjob"
  "scenario-03-rbac"
  "scenario-04-fix-serviceaccount"
  "scenario-05-podman-image"
  "scenario-06-canary-deploy"
  "scenario-07-networkpolicy-labels"
  "scenario-08-fix-broken-yaml"
  "scenario-09-rolling-update"
  "scenario-10-readiness-probe"
  "scenario-11-security-context"
  "scenario-12-fix-service-selector"
  "scenario-13-nodeport"
  "scenario-14-ingress"
  "scenario-15-fix-ingress-pathtype"
  "scenario-16-resource-limits"
)

SCENARIO_TITLES=(
  "Create Secret from Variables"
  "CronJob with Schedule"
  "ServiceAccount, Role & RoleBinding"
  "Fix Pod ServiceAccount"
  "Build Image with Podman"
  "Canary Deployment"
  "Fix NetworkPolicy Labels"
  "Fix Broken Deployment YAML"
  "Rolling Update & Rollback"
  "Readiness Probe"
  "Security Context"
  "Fix Service Selector"
  "NodePort Service"
  "Create Ingress Resource"
  "Fix Ingress PathType"
  "Resource Requests & Limits"
)

TOTAL=${#SCENARIO_DIRS[@]}
CURRENT=0

# ── Progress Management ─────────────────────────────────────────────
declare -a DONE

load_progress() {
  DONE=()
  for ((i=0; i<TOTAL; i++)); do
    DONE[$i]=0
  done
  if [[ -f "$PROGRESS_FILE" ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^([0-9]+)$ ]]; then
        local idx="${BASH_REMATCH[1]}"
        if (( idx >= 0 && idx < TOTAL )); then
          DONE[$idx]=1
        fi
      fi
    done < "$PROGRESS_FILE"
  fi
}

save_progress() {
  > "$PROGRESS_FILE"
  for ((i=0; i<TOTAL; i++)); do
    if [[ "${DONE[$i]}" == "1" ]]; then
      echo "$i" >> "$PROGRESS_FILE"
    fi
  done
}

# ── Display Helpers ─────────────────────────────────────────────────
print_header() {
  clear
  echo -e "${CYAN}"
  echo "  ██████╗██╗  ██╗ █████╗ ██████╗ "
  echo " ██╔════╝██║ ██╔╝██╔══██╗██╔══██╗"
  echo " ██║     █████╔╝ ███████║██║  ██║"
  echo " ██║     ██╔═██╗ ██╔══██║██║  ██║"
  echo " ╚██████╗██║  ██╗██║  ██║██████╔╝"
  echo "  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
  echo -e "${NC}"
  echo -e "${BOLD}  CKAD Practice Labs — Interactive Runner${NC}"
  echo ""
}

print_progress() {
  local done_count=0
  for ((i=0; i<TOTAL; i++)); do
    if [[ "${DONE[$i]}" == "1" ]]; then
      ((done_count++))
    fi
  done
  echo -e "  Progress: ${GREEN}${done_count}${NC}/${TOTAL} completed"
  echo ""
}

print_scenario() {
  local idx=$1
  local num=$((idx + 1))
  local numpad
  numpad=$(printf "%02d" "$num")
  local status=""
  if [[ "${DONE[$idx]}" == "1" ]]; then
    status="${GREEN}✓${NC}"
  else
    status="${RED}○${NC}"
  fi
  if [[ $idx -eq $CURRENT ]]; then
    echo -e "  ${BOLD}▶ [${status}${BOLD}] ${numpad}. ${SCENARIO_TITLES[$idx]}${NC}"
  else
    echo -e "    [${status}] ${numpad}. ${SCENARIO_TITLES[$idx]}"
  fi
}

list_all() {
  print_header
  print_progress
  echo -e "${BOLD}  All Scenarios:${NC}"
  echo ""
  for ((i=0; i<TOTAL; i++)); do
    print_scenario "$i"
  done
  echo ""
  echo -e "  Press ${YELLOW}Enter${NC} to return..."
  read -r
}

show_main_menu() {
  print_header
  print_progress
  local num=$((CURRENT + 1))
  local numpad
  numpad=$(printf "%02d" "$num")
  local status_text
  if [[ "${DONE[$CURRENT]}" == "1" ]]; then
    status_text="${GREEN}[DONE]${NC}"
  else
    status_text="${YELLOW}[TODO]${NC}"
  fi
  echo -e "  Current: ${BOLD}${numpad}. ${SCENARIO_TITLES[$CURRENT]}${NC} ${status_text}"
  echo -e "  Dir:     ${SCENARIO_DIRS[$CURRENT]}/"
  echo ""
  echo -e "  ${BOLD}Options:${NC}"
  echo -e "    ${CYAN}[r]${NC} Run/Setup     ${CYAN}[t]${NC} Show Task      ${CYAN}[s]${NC} Show Solution"
  echo -e "    ${CYAN}[c]${NC} Check answer  ${CYAN}[x]${NC} Reset          ${CYAN}[d]${NC} Mark done & next"
  echo -e "    ${CYAN}[n]${NC} Next          ${CYAN}[p]${NC} Previous       ${CYAN}[l]${NC} List all"
  echo -e "    ${CYAN}[q]${NC} Quit"
  echo ""
}

# ── Cluster Health Check ────────────────────────────────────────────
check_cluster() {
  echo -e "${YELLOW}Checking cluster health...${NC}"
  if ! kubectl get nodes &>/dev/null; then
    echo -e "${RED}ERROR: Cannot reach Kubernetes cluster!${NC}"
    echo "Make sure your cluster is running and kubectl is configured."
    echo ""
    echo -e "Press ${YELLOW}Enter${NC} to continue anyway, or Ctrl+C to abort..."
    read -r
    return 1
  fi
  echo -e "${GREEN}✓ Cluster is reachable${NC}"
  kubectl get nodes --no-headers 2>/dev/null | while read -r line; do
    echo "  $line"
  done
  echo ""
  return 0
}

# ── Scenario Actions ────────────────────────────────────────────────
run_setup() {
  local dir="${SCENARIO_DIRS[$CURRENT]}"
  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}Directory $dir not found!${NC}"
    echo -e "Press ${YELLOW}Enter${NC} to continue..."
    read -r
    return
  fi
  if [[ ! -f "$dir/setup.sh" ]]; then
    echo -e "${RED}No setup.sh found in $dir${NC}"
    echo -e "Press ${YELLOW}Enter${NC} to continue..."
    read -r
    return
  fi

  check_cluster

  echo -e "${BLUE}═══ Setting up: ${SCENARIO_TITLES[$CURRENT]} ═══${NC}"
  echo ""
  bash "$dir/setup.sh"
  echo ""
  echo -e "${GREEN}✓ Setup complete!${NC}"
  echo ""

  # Show task after setup
  if [[ -f "$dir/TASK.md" ]]; then
    echo -e "${BOLD}═══ TASK ═══${NC}"
    cat "$dir/TASK.md"
    echo ""
  fi

  # Enter sub-loop
  scenario_subloop
}

show_task() {
  local dir="${SCENARIO_DIRS[$CURRENT]}"
  if [[ -f "$dir/TASK.md" ]]; then
    echo ""
    echo -e "${BOLD}═══ TASK: ${SCENARIO_TITLES[$CURRENT]} ═══${NC}"
    echo ""
    cat "$dir/TASK.md"
    echo ""
  else
    echo -e "${RED}No TASK.md found in $dir${NC}"
  fi
  echo -e "Press ${YELLOW}Enter${NC} to continue..."
  read -r
}

show_solution() {
  local dir="${SCENARIO_DIRS[$CURRENT]}"
  if [[ -f "$dir/solution.md" ]]; then
    echo ""
    echo -e "${BOLD}═══ SOLUTION: ${SCENARIO_TITLES[$CURRENT]} ═══${NC}"
    echo ""
    cat "$dir/solution.md"
    echo ""
  else
    echo -e "${RED}No solution.md found in $dir${NC}"
  fi
  echo -e "Press ${YELLOW}Enter${NC} to continue..."
  read -r
}

check_answer() {
  local dir="${SCENARIO_DIRS[$CURRENT]}"
  if [[ -f "$dir/check.sh" ]]; then
    echo ""
    echo -e "${BOLD}═══ Checking: ${SCENARIO_TITLES[$CURRENT]} ═══${NC}"
    echo ""
    if bash "$dir/check.sh"; then
      echo ""
      echo -e "${GREEN}✓ All checks passed!${NC}"
    else
      echo ""
      echo -e "${RED}✗ Some checks failed. Review and try again.${NC}"
    fi
  else
    echo -e "${YELLOW}No automated check for this scenario.${NC}"
    echo "Compare your work against the solution: $dir/solution.md"
  fi
  echo ""
  echo -e "Press ${YELLOW}Enter${NC} to continue..."
  read -r
}

reset_scenario() {
  local dir="${SCENARIO_DIRS[$CURRENT]}"
  if [[ -f "$dir/cleanup.sh" ]]; then
    echo ""
    echo -e "${YELLOW}═══ Resetting: ${SCENARIO_TITLES[$CURRENT]} ═══${NC}"
    bash "$dir/cleanup.sh"
    echo -e "${GREEN}✓ Reset complete${NC}"
  else
    echo -e "${RED}No cleanup.sh found in $dir${NC}"
  fi
  echo ""
  echo -e "Press ${YELLOW}Enter${NC} to continue..."
  read -r
}

mark_done_next() {
  DONE[$CURRENT]=1
  save_progress
  echo -e "${GREEN}✓ Marked scenario $((CURRENT+1)) as done!${NC}"
  if ((CURRENT < TOTAL - 1)); then
    ((CURRENT++))
  fi
}

next_scenario() {
  if ((CURRENT < TOTAL - 1)); then
    ((CURRENT++))
  else
    echo -e "${YELLOW}Already at last scenario.${NC}"
    sleep 1
  fi
}

prev_scenario() {
  if ((CURRENT > 0)); then
    ((CURRENT--))
  else
    echo -e "${YELLOW}Already at first scenario.${NC}"
    sleep 1
  fi
}

# ── Sub-loop after setup ────────────────────────────────────────────
scenario_subloop() {
  while true; do
    echo -e "  ${BOLD}Scenario Active: ${SCENARIO_TITLES[$CURRENT]}${NC}"
    echo ""
    echo -e "    ${CYAN}[c]${NC} Check answer  ${CYAN}[s]${NC} Show Solution  ${CYAN}[t]${NC} Show Task"
    echo -e "    ${CYAN}[x]${NC} Reset         ${CYAN}[d]${NC} Mark done      ${CYAN}[b]${NC} Back to menu"
    echo ""
    echo -n "  Choice: "
    read -r choice
    case "$choice" in
      c) check_answer ;;
      s) show_solution ;;
      t) show_task ;;
      x) reset_scenario ;;
      d) mark_done_next; return ;;
      b|q) return ;;
      *) echo -e "${RED}Invalid option${NC}" ;;
    esac
  done
}

# ── Cleanup on quit ─────────────────────────────────────────────────
cleanup_on_quit() {
  save_progress
  echo ""
  echo -e "${GREEN}Progress saved. Good luck with your CKAD exam! 🎯${NC}"
  echo ""
}

# ── Main Loop ───────────────────────────────────────────────────────
main() {
  load_progress

  # Allow jumping to scenario via argument
  if [[ $# -ge 1 ]]; then
    local jump="${1}"
    # Support both "3" and "03" formats
    jump=$((10#$jump))  # Remove leading zeros
    if ((jump >= 1 && jump <= TOTAL)); then
      CURRENT=$((jump - 1))
    else
      echo -e "${RED}Invalid scenario number: $1 (must be 1-$TOTAL)${NC}"
      exit 1
    fi
  fi

  while true; do
    show_main_menu
    echo -n "  Choice: "
    read -r choice
    case "$choice" in
      r) run_setup ;;
      t) show_task ;;
      s) show_solution ;;
      c) check_answer ;;
      x) reset_scenario ;;
      d) mark_done_next ;;
      n) next_scenario ;;
      p) prev_scenario ;;
      l) list_all ;;
      q) cleanup_on_quit; exit 0 ;;
      [1-9]|1[0-6])
        local jump=$((10#$choice))
        if ((jump >= 1 && jump <= TOTAL)); then
          CURRENT=$((jump - 1))
        fi
        ;;
      *) echo -e "${RED}Invalid option${NC}"; sleep 0.5 ;;
    esac
  done
}

main "$@"
