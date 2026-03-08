#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/longlive
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LongLive
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/longlive_minimal.log
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
source /root/miniconda3/etc/profile.d/conda.sh
conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path "$TEST_DIR/longlive_inference_minimal.yaml" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lah "$OUTPUT_DIR"
