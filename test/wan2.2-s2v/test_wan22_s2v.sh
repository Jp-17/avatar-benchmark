#!/bin/bash
set -e
echo "[$(date)] Starting Wan2.2-S2V inference test"
cd /root/autodl-tmp/avatar-benchmark/models/Wan2.2

CKPT=/root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-S2V-14B
IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/trimmed/A007_5s.wav
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v/output/test_output.mp4

conda run --no-capture-output -p /root/autodl-tmp/envs/wan2.2-env     env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0     python generate.py     --task s2v-14B     --size 704*384     --ckpt_dir $CKPT     --offload_model True     --convert_model_dtype     --prompt "A person speaking directly to the camera with natural facial expressions and synchronized lip movements."     --image $IMG     --audio $AUDIO     --save_file $OUTPUT     --num_clip 1

echo "[$(date)] Wan2.2-S2V inference done"
ls -lh $OUTPUT
