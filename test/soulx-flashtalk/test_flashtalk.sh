#!/bin/bash
set -e
echo "[$(date)] Starting SoulX-FlashTalk inference test"
cd /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk

IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/trimmed/A007_5s.wav
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk/output/test_output.mp4

conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env     env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1     python generate_video.py     --ckpt_dir models/SoulX-FlashTalk-14B     --wav2vec_dir models/chinese-wav2vec2-base     --input_prompt "A person is talking. Only the foreground characters are moving, the background remains static."     --cond_image $IMG     --audio_path $AUDIO     --audio_encode_mode stream     --save_file $OUTPUT     --cpu_offload

echo "[$(date)] SoulX-FlashTalk inference done"
ls -lh $OUTPUT
