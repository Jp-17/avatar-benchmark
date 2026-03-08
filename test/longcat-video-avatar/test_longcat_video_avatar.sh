#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/longcat_video_avatar_minimal.log
ENV_SITE=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH="$ENV_SITE" /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json "$TEST_DIR/single_minimal_image.json" --num_inference_steps 8 --output_dir "$OUTPUT_DIR" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lah "$OUTPUT_DIR"
