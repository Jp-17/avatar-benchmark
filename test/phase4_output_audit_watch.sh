#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
LOG_FILE=$ROOT/test/phase4_output_audit.log
STATUS_FILE=$ROOT/test/phase4_output_audit.status
cd "$ROOT"
while true; do
  ts=$(date '+%F %T')
  if /root/miniconda3/bin/python test/verify_phase4_outputs.py --all-completed >> "$LOG_FILE" 2>&1; then
    printf '%s 已完成 Phase4 模型输出巡检正常\n' "$ts" > "$STATUS_FILE"
  else
    printf '%s 已完成 Phase4 模型输出巡检发现异常，详见 test/phase4_output_audit.log\n' "$ts" > "$STATUS_FILE"
  fi
  sleep 600
done
