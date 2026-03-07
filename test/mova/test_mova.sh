#!/bin/bash
set -e

cd /root/autodl-tmp/avatar-benchmark/models/MOVA

IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/mova/output/test_output.mp4
CKPT=/root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p

export PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/MOVA:$PYTHONPATH
export CUDA_VISIBLE_DEVICES=0

source /root/autodl-tmp/envs/mova-env/bin/activate

torchrun --nproc_per_node=1 scripts/inference_single.py \
    --ckpt_path $CKPT \
    --cp_size 1 \
    --height 352 \
    --width 640 \
    --num_frames 97 \
    --num_inference_steps 30 \
    --prompt "A woman is speaking to the camera with natural facial expressions and synchronized lip movements. She says with a friendly tone. Audio: Clear female voice speaking naturally, indoor room ambience." \
    --ref_path $IMG \
    --output_path $OUTPUT \
    --offload cpu \
    --remove_video_dit \
    --seed 42
