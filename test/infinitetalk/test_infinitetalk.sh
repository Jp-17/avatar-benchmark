#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/infinitetalk
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/InfiniteTalk
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/infinitetalk_minimal.log
PY_DEPS=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449
ENV_SITE=/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG" "$OUTPUT_DIR/infinitetalk_minimal.mp4"
cd "$MODEL_DIR"
START_TS=$(date +%s)
env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH="$PY_DEPS:$ENV_SITE" /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json "$TEST_DIR/single_minimal_image.json" --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file "$OUTPUT_DIR/infinitetalk_minimal" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lah "$OUTPUT_DIR"
