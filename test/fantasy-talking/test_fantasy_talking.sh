#!/bin/bash
set -e
echo "[$(date)] Starting FantasyTalking inference test"

cd /root/autodl-tmp/avatar-benchmark/models/fantasy-talking

export CUDA_VISIBLE_DEVICES=0
export PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/fantasy-talking:$PYTHONPATH

source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/envs/fantasy-talking-env

IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/trimmed/A007_5s.wav
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/fantasy-talking/output

python infer.py \
    --wan_model_dir ./models/Wan2.1-I2V-14B-720P \
    --fantasytalking_model_path ./models/fantasytalking_model.ckpt \
    --wav2vec_dir ./models/wav2vec2-base-960h \
    --image_path ${IMG} \
    --audio_path ${AUDIO} \
    --prompt "A woman is speaking directly to the camera with natural facial expressions and synchronized lip movements." \
    --output_dir ${OUTPUT} \
    --image_size 512 \
    --audio_scale 1.0 \
    --prompt_cfg_scale 5.0 \
    --audio_cfg_scale 5.0 \
    --max_num_frames 81 \
    --fps 23 \
    --num_persistent_param_in_dit 7000000000 \
    --seed 42

echo "[$(date)] FantasyTalking inference done"
ls -lh ${OUTPUT}/
