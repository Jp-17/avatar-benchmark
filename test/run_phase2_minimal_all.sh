#!/bin/bash
set -u
BASE=/root/autodl-tmp/avatar-benchmark/test
RUN_LOG=$BASE/run_phase2_minimal_all.log
STATUS_FILE=$BASE/run_phase2_minimal_all.status
MODELS=(echomimic_v2 stableavatar livetalk hallo3 ovi mova wan2.2-s2v liveavatar soulx-flashtalk ltx2 omniavatar fantasy-talking)
printf '' > "$RUN_LOG"
printf '' > "$STATUS_FILE"
for model in "${MODELS[@]}"; do
  script=$(find "$BASE/$model" -maxdepth 1 -name 'test_*.sh' -type f | head -1)
  echo "[$(date '+%F %T')] START $model" | tee -a "$RUN_LOG"
  start_ts=$(date +%s)
  bash "$script" >> "$RUN_LOG" 2>&1
  exit_code=$?
  end_ts=$(date +%s)
  runtime=$((end_ts-start_ts))
  echo "$model exit_code=$exit_code runtime_seconds=$runtime" | tee -a "$STATUS_FILE"
  echo "[$(date '+%F %T')] END $model exit=$exit_code runtime=${runtime}s" | tee -a "$RUN_LOG"
done
