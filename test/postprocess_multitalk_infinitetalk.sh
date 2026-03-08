#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/postprocess_multitalk_infinitetalk.log
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1
RUNNER_PID_FILE=/root/autodl-tmp/avatar-benchmark/test/run_multitalk_infinitetalk_minimal.pid
if [ -f "$RUNNER_PID_FILE" ]; then
  PID=$(cat "$RUNNER_PID_FILE")
  while ps -p "$PID" >/dev/null 2>&1; do
    printf "[%s] waiting runner pid=%s\n" "$(date "+%F %T")" "$PID"
    sleep 60
  done
fi
for model in multitalk infinitetalk; do
  UPPER=$(echo "$model" | tr a-z A-Z)
  printf "\n[%s] === %s summary ===\n" "$(date "+%F %T")" "$UPPER"
  if [ -f "test/$model/output/${model}_minimal.log" ]; then
    printf -- "log_path=test/%s/output/%s_minimal.log\n" "$model" "$model"
    grep -n "runtime_seconds=" "test/$model/output/${model}_minimal.log" || true
    tail -40 "test/$model/output/${model}_minimal.log" || true
  fi
  if [ -f "test/$model/output/${model}_minimal.mp4" ]; then
    ls -lh "test/$model/output/${model}_minimal.mp4"
    ffmpeg -i "test/$model/output/${model}_minimal.mp4" 2>&1 | sed -n "1,40p"
  fi
done
