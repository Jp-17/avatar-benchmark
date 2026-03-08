#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/multitalk/download_wan480_shards.log
PART=/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P/.cache/huggingface/download/uCtE_F0oILZScKSho7gFwN4WDjM=.d1bc30f07b162c34b90e4ee4a349f81b6e1a3a342187ea9ea153c9e4dbb07676.incomplete
FINAL=/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P/diffusion_pytorch_model-00007-of-00007.safetensors
LOCK=/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P/.cache/huggingface/download/diffusion_pytorch_model-00007-of-00007.safetensors.lock
URL=https://hf-mirror.com/Wan-AI/Wan2.1-I2V-14B-480P/resolve/main/diffusion_pytorch_model-00007-of-00007.safetensors
TARGET_SIZE=7061933536
printf "[%s] switch to wget resume for diffusion_pytorch_model-00007-of-00007.safetensors\n" "$(date "+%F %T")" >> "$LOG"
rm -f "$LOCK"
wget -c -O "$PART" "$URL" >> "$LOG" 2>&1
ACTUAL=$(stat -c %s "$PART")
printf "[%s] wget finished size=%s\n" "$(date "+%F %T")" "$ACTUAL" >> "$LOG"
if [ "$ACTUAL" -ne "$TARGET_SIZE" ]; then
  printf "[%s] size mismatch expected=%s actual=%s\n" "$(date "+%F %T")" "$TARGET_SIZE" "$ACTUAL" >> "$LOG"
  exit 1
fi
mv "$PART" "$FINAL"
ls -lh "$FINAL" >> "$LOG" 2>&1
printf "[%s] finished diffusion_pytorch_model-00007-of-00007.safetensors via wget\n" "$(date "+%F %T")" >> "$LOG"
printf "[%s] all shard downloads finished\n" "$(date "+%F %T")" >> "$LOG"
