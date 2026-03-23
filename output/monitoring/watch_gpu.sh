#!/bin/bash
set -u
ROOT=/root/autodl-tmp/avatar-benchmark
MON_DIR=$ROOT/output/monitoring
LOG=$MON_DIR/gpu_watch.log
while true; do
  ts=$(date "+%F %T %Z")
  {
    echo "=== $ts ==="
    nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits
    echo "--- compute-apps ---"
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader || true
    echo "--- key-procs ---"
    ps -ef | grep -E "(torchrun|s2v_streaming_interact|sample_video.py|infer_acc.py|infer.py|liveavatar_phase4_audiofix_bg|run_liveavatar_audiofix_bg.sh)" | grep -v grep || true
    echo
  } >> "$LOG"
  sleep 30
done
