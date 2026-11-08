#!/usr/bin/env bash
# Wrapper: check mode by default, logs every run, never hides a failure.
#   scripts/run.sh <playbook> <inventory> [--apply] [extra ansible args]
set -euo pipefail
PB="${1:?playbook}"; INV="${2:?inventory}"; shift 2
MODE=(--check --diff)
if [[ "${1:-}" == "--apply" ]]; then MODE=(); shift; fi
mkdir -p logs
LOG="logs/$(basename "$PB" .yml)-$(date +%Y%m%d-%H%M%S).log"
echo "playbook=$PB inventory=$INV mode=${MODE[*]:-apply} log=$LOG"
set +e
ansible-playbook -i "$INV" "$PB" "${MODE[@]}" "$@" 2>&1 | tee "$LOG"
rc=${PIPESTATUS[0]}
set -e
echo "exit=$rc"
exit "$rc"
