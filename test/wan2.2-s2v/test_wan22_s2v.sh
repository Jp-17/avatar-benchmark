#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Wan2.2
ENV=/root/autodl-tmp/envs/wan2.2-env
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/wan2.2_s2v_minimal.log
OUT_MP4=$OUTPUT_DIR/wan2.2_s2v_minimal.mp4
CKPT=/root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-S2V-14B
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir "$CKPT" --offload_model True --convert_model_dtype --prompt "$PROMPT" --image "$IMG" --audio "$AUDIO" --save_file "$OUT_MP4" --num_clip 1 >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
