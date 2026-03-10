#!/bin/bash
set -u -o pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
LOG=$ROOT/test/gpu_idle_phase4_queue_remaining.log
PID_FILE=$ROOT/test/gpu_idle_phase4_queue_remaining.pid
queue_names=(FantasyTalking)
queue_scripts=($ROOT/test/fantasy-talking/run_phase4_fullaudio.sh)
queue_outputs_a=($ROOT/output/fantasy_talking_newphase4_fullaudio/C_half_short.mp4)
queue_outputs_b=($ROOT/output/fantasy_talking_newphase4_fullaudio/C_full_short.mp4)
timestamp() {
  date "+%F %T"
}
gpu_busy() {
  local pids
  pids=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null | sed "/^[[:space:]]*$/d")
  [ -n "$pids" ]
}
echo $$ > "$PID_FILE"
echo "[$(timestamp)] queue started" >> "$LOG"
index=0
count=${#queue_names[@]}
while [ "$index" -lt "$count" ]; do
  name=${queue_names[$index]}
  script=${queue_scripts[$index]}
  out_a=${queue_outputs_a[$index]}
  out_b=${queue_outputs_b[$index]}
  if [ -s "$out_a" ] && [ -s "$out_b" ]; then
    echo "[$(timestamp)] skip $name because outputs already exist" >> "$LOG"
    index=$((index + 1))
    continue
  fi
  if gpu_busy; then
    echo "[$(timestamp)] gpu busy; wait 60s before $name" >> "$LOG"
    sleep 60
    continue
  fi
  echo "[$(timestamp)] gpu idle; start $name" >> "$LOG"
  bash "$script" >> "$LOG" 2>&1
  status=$?
  echo "[$(timestamp)] $name exit=$status" >> "$LOG"
  if [ "$status" -ne 0 ]; then
    echo "[$(timestamp)] queue stopped on $name failure" >> "$LOG"
    rm -f "$PID_FILE"
    exit "$status"
  fi
  index=$((index + 1))
done
echo "[$(timestamp)] queue finished" >> "$LOG"
rm -f "$PID_FILE"
