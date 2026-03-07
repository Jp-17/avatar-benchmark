#!/bin/bash
set -e
echo "[$(date)] Starting LTX-2 A2Vid inference test"

cd /root/autodl-tmp/avatar-benchmark/models/LTX-2
export CUDA_VISIBLE_DEVICES=0

WEIGHTS=/root/autodl-tmp/avatar-benchmark/models/LTX-2/weights
IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/trimmed/A007_5s.wav
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/ltx2/output/test_a2v.mp4

source .venv/bin/activate

python -m ltx_pipelines.a2vid_two_stage \
    --checkpoint-path ${WEIGHTS}/ltx-2-19b-dev-fp8.safetensors \
    --gemma-root ${WEIGHTS}/text_encoder \
    --distilled-lora ${WEIGHTS}/ltx-2-19b-distilled-lora-384.safetensors 0.8 \
    --spatial-upsampler-path ${WEIGHTS}/ltx-2-spatial-upscaler-x2-1.0.safetensors \
    --audio-path ${AUDIO} \
    --image ${IMG} \
    --prompt "A woman is speaking directly to the camera with natural facial expressions and synchronized lip movements." \
    --output-path ${OUTPUT} \
    --quantization fp8-cast \
    --height 512 --width 512 \
    --num-frames 121 \
    --frame-rate 24 \
    --seed 42

echo "[$(date)] LTX-2 A2Vid inference done"
ls -lh ${OUTPUT}
