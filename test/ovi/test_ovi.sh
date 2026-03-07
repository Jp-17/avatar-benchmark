#!/bin/bash
set -e

cd /root/autodl-tmp/avatar-benchmark/models/Ovi

export CUDA_VISIBLE_DEVICES=0

source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/envs/ovi-env

python inference.py --config-file /root/autodl-tmp/avatar-benchmark/test/ovi/inference_test.yaml
