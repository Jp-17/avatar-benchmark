#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/monitor_infinitetalk_gpu_rerun.log
: > "$LOG"
printf "[%s] infinitetalk gpu monitor start\n" "$(date "+%F %T")" >> "$LOG"
started=0
while true; do
  pids=$(pgrep -f "generate_infinitetalk.py" || true)
  if [ -n "$pids" ]; then
    started=1
    while read -r pid pname used; do
      pid=$(echo "$pid" | xargs)
      used=$(echo "$used" | xargs)
      [ -n "$pid" ] || continue
      cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || true)
      case "$cmd" in
        *generate_infinitetalk.py*) printf "[%s] infinitetalk pid=%s used_gpu_memory=%s MiB cmd=%s\n" "$(date "+%F %T")" "$pid" "$used" "$cmd" >> "$LOG" ;;
      esac
    done < <(nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader,nounits 2>/dev/null || true)
  fi
  if [ "$started" -eq 1 ] && [ -z "$pids" ]; then
    break
  fi
  sleep 1
done
printf "[%s] infinitetalk gpu monitor end\n" "$(date "+%F %T")" >> "$LOG"
