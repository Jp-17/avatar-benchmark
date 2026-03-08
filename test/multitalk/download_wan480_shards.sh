#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/multitalk/download_wan480_shards.log
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1
export HF_ENDPOINT=https://hf-mirror.com
export PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449
export HF_HUB_ENABLE_HF_TRANSFER=0
export HF_HUB_DISABLE_XET=1
TARGET=/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P
REPO=Wan-AI/Wan2.1-I2V-14B-480P
printf "[%s] start sequential shard download\n" "$(date "+%F %T")"
for i in 01 02 03 04 05 06 07; do
  FILE=diffusion_pytorch_model-000${i}-of-00007.safetensors
  if [ -f "$TARGET/$FILE" ]; then
    printf "[%s] already exists %s\n" "$(date "+%F %T")" "$FILE"
    ls -lh "$TARGET/$FILE"
    continue
  fi
  printf "[%s] downloading %s\n" "$(date "+%F %T")" "$FILE"
  /root/miniconda3/bin/python - <<PY
from huggingface_hub import hf_hub_download
path = hf_hub_download(
    repo_id="$REPO",
    filename="$FILE",
    local_dir="$TARGET",
    local_dir_use_symlinks=False,
    resume_download=True,
)
print(path)
PY
  printf "[%s] finished %s\n" "$(date "+%F %T")" "$FILE"
  ls -lh "$TARGET/$FILE"
done
printf "[%s] all shard downloads finished\n" "$(date "+%F %T")"
