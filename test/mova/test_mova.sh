#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/mova
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/MOVA
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/mova_minimal.log
OUT_MP4=$OUTPUT_DIR/mova_minimal.mp4
IMG=$TEST_DIR/input/I013.png
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
CKPT=/root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG"
cd "$MODEL_DIR"
export PYTHONPATH=$MODEL_DIR${PYTHONPATH:+:$PYTHONPATH}
export CUDA_VISIBLE_DEVICES=0
source /root/autodl-tmp/envs/mova-env/bin/activate
START_TS=$(date +%s)
torchrun --nproc_per_node=1 scripts/inference_single.py --ckpt_path "$CKPT" --cp_size 1 --height 512 --width 512 --num_frames 97 --num_inference_steps 30 --prompt "$PROMPT" --ref_path "$IMG" --output_path "$OUT_MP4" --offload cpu --remove_video_dit --seed 42 >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
