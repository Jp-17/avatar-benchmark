#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/download_longcat_avatar_missing.log
PID=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/download_longcat_avatar_missing.pid
ROOT=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video-Avatar
FILES=(
  "avatar_single/diffusion_pytorch_model-00004-of-00006.safetensors"
  "avatar_single/diffusion_pytorch_model-00005-of-00006.safetensors"
  "avatar_single/diffusion_pytorch_model-00006-of-00006.safetensors"
)
echo $$ > "$PID"
exec > >(tee -a "$LOG") 2>&1
printf "[%s] restart LongCat remaining shard download\n" "$(date "+%F %T")"
for rel in "${FILES[@]}"; do
  out="$ROOT/$rel"
  mkdir -p "$(dirname "$out")"
  if [ -f "$out" ] && [ -s "$out" ]; then
    printf "[%s] already exists %s\n" "$(date "+%F %T")" "$rel"
    ls -lh "$out"
    continue
  fi
  url="https://hf-mirror.com/meituan-longcat/LongCat-Video-Avatar/resolve/main/$rel"
  printf "[%s] downloading %s\n" "$(date "+%F %T")" "$rel"
  wget -c -O "$out" "$url"
  printf "[%s] finished %s\n" "$(date "+%F %T")" "$rel"
  ls -lh "$out"
done
printf "[%s] LongCat remaining shard download completed\n" "$(date "+%F %T")"
