#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
STATUS_FILE=$ROOT/test/phase4_monitor.status
LOG_FILE=$ROOT/test/phase4_monitor.log
cd "$ROOT"
while true; do
  ts=$(date '+%F %T')
  queue1=$(cat test/phase4_queue.status 2>/dev/null || echo 'queue1: unavailable')
  queue2=$(cat test/phase4_queue_stage2.status 2>/dev/null || echo 'queue2: unavailable')
  gpu=$(nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv,noheader,nounits | head -1 | tr '\n' ' ')
  running=$(ps -ef | grep -E 'run_phase4_filtered.sh|sample_video.py|inference.py --config-file|inference_single.py|generate.py --task s2v-14B|generate_multitalk.py|generate_infinitetalk.py|phase4_queue' | grep -v grep | head -20)
  {
    echo "=== ${ts} ==="
    echo "queue1: ${queue1}"
    echo "queue2: ${queue2}"
    echo "gpu: ${gpu}"
    echo "running:"
    echo "${running}"
    echo
  } >> "$LOG_FILE"
  printf '%s | %s | %s | gpu=%s\n' "$ts" "$queue1" "$queue2" "$gpu" > "$STATUS_FILE"
  sleep 600
 done
