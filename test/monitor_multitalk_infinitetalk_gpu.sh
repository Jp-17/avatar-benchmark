#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/monitor_multitalk_infinitetalk_gpu.log
RUNNER_PID_FILE=/root/autodl-tmp/avatar-benchmark/test/run_multitalk_infinitetalk_minimal.pid
: > "$LOG"
printf "[%s] gpu monitor start\n" "$(date "+%F %T")" >> "$LOG"
RUNNER_PID=$(cat "$RUNNER_PID_FILE" 2>/dev/null || true)
while true; do
  NOW=$(date "+%F %T")
  if command -v nvidia-smi >/dev/null 2>&1; then
    while IFS=, read -r pid pname used; do
      pid=$(echo "$pid" | xargs)
      used=$(echo "$used" | xargs)
      [ -n "$pid" ] || continue
      cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || true)
      case "$cmd" in
        *generate_multitalk.py*) printf "[%s] multitalk pid=%s used_gpu_memory=%s MiB cmd=%s\n" "$NOW" "$pid" "$used" "$cmd" >> "$LOG" ;;
        *generate_infinitetalk.py*) printf "[%s] infinitetalk pid=%s used_gpu_memory=%s MiB cmd=%s\n" "$NOW" "$pid" "$used" "$cmd" >> "$LOG" ;;
      esac
    done < <(nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader,nounits 2>/dev/null || true)
  fi
  if [ -n "$RUNNER_PID" ] && ! ps -p "$RUNNER_PID" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
printf "[%s] gpu monitor end\n" "$(date "+%F %T")" >> "$LOG"
