#!/bin/bash
set -e

cd /root/autodl-tmp/avatar-benchmark/models/OmniAvatar

export CUDA_VISIBLE_DEVICES=0

source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/envs/omniavatar-env

torchrun --standalone --nproc_per_node=1 scripts/inference.py \
    --config configs/inference.yaml \
    --input_file /root/autodl-tmp/avatar-benchmark/test/omniavatar/infer_samples.txt
