#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/multitalk
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/MultiTalk
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/multitalk_minimal.log
PY_DEPS=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449
ENV_SITE=/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG" "$OUTPUT_DIR"/multitalk_minimal.mp4
cd "$MODEL_DIR"
START_TS=$(date +%s)
env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH="$PY_DEPS:$ENV_SITE" /root/miniconda3/bin/python -S generate_multitalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --input_json "$TEST_DIR/multitalk_minimal_image.json" --size multitalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --num_persistent_param_in_dit 0 --save_file "$OUTPUT_DIR/multitalk_minimal" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lah "$OUTPUT_DIR"
