#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/livetalk
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/livetalk
ENV=/root/autodl-tmp/envs/livetalk-env
OUTPUT_DIR=$TEST_DIR/output
OUT_MP4=$OUTPUT_DIR/livetalk_minimal.mp4
CONFIG=$TEST_DIR/livetalk_minimal.yaml
LOG=$OUTPUT_DIR/livetalk_minimal.log
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$CONFIG" "$LOG"
cat > "$CONFIG" <<EOF
dtype: "bf16"
text_encoder_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/Wan-AI/Wan2.1-T2V-1.3B/models_t5_umt5-xxl-enc-bf16.pth
dit_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/LiveTalk-1.3B-V0.1/model.safetensors
vae_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/Wan-AI/Wan2.1-T2V-1.3B/Wan2.1_VAE.pth
wav2vec_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/wav2vec2
image_path: $IMG
audio_path: $AUDIO
prompt: "$PROMPT"
output_path: $OUT_MP4
video_duration: 5
max_hw: 720
image_sizes_720: [[512, 512]]
fps: 16
sample_rate: 16000
num_steps: 4
local_attn_size: 15
denoising_step_list: [1000, 750, 500, 250]
warp_denoising_step: true
num_transformer_blocks: 30
frame_seq_length: 1024
num_frame_per_block: 3
independent_first_frame: False
EOF
cd "$MODEL_DIR"
START_TS=$(date +%s)
/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env PYTHONPATH=$MODEL_DIR:$MODEL_DIR/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config "$CONFIG" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
