#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/self-forcing
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Self-Forcing
ENV=sf-longlive-env
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/self_forcing_minimal.log
PROMPT_FILE=$TEST_DIR/input/P011.txt
CKPT=$MODEL_DIR/checkpoints/self_forcing_dmd.pt
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
source /root/miniconda3/etc/profile.d/conda.sh
conda run --no-capture-output -n "$ENV" env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path configs/self_forcing_dmd.yaml --checkpoint_path "$CKPT" --data_path "$PROMPT_FILE" --output_folder "$OUTPUT_DIR" --num_output_frames 21 --num_samples 1 --use_ema --save_with_index >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUTPUT_DIR"
