#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/monitor_longcat_gpu.log
PID=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/monitor_longcat_gpu.pid
: > "$LOG"
echo $$ > "$PID"
printf "[%s] longcat gpu monitor start\n" "$(date "+%F %T")" >> "$LOG"
started=0
while true; do
  pids=$(pgrep -f "run_demo_avatar_single_audio_to_video.py" || true)
  if [ -n "$pids" ]; then
    started=1
    while IFS=, read -r pid pname used; do
      pid=$(echo "$pid" | xargs)
      used=$(echo "$used" | xargs)
      [ -n "$pid" ] || continue
      cmd=$(ps -p "$pid" -o cmd= 2>/dev/null || true)
      case "$cmd" in
        *run_demo_avatar_single_audio_to_video.py*) printf "[%s] longcat pid=%s used_gpu_memory=%s MiB cmd=%s\n" "$(date "+%F %T")" "$pid" "$used" "$cmd" >> "$LOG" ;;
      esac
    done < <(nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader,nounits 2>/dev/null || true)
  fi
  if [ "$started" -eq 1 ] && [ -z "$pids" ]; then
    break
  fi
  sleep 1
done
printf "[%s] longcat gpu monitor end\n" "$(date "+%F %T")" >> "$LOG"
