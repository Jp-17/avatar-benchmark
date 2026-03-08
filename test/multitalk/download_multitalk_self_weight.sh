#!/bin/bash
set -euo pipefail
LOG=/root/autodl-tmp/avatar-benchmark/test/multitalk/download_multitalk_self_weight.log
exec > >(tee -a "$LOG") 2>&1
TARGET_DIR=/root/autodl-tmp/avatar-benchmark/models/MultiTalk/weights/MeiGen-MultiTalk
echo "[$(date '+%F %T')] start MultiTalk self checkpoint download"
env HF_ENDPOINT=https://hf-mirror.com PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449 /root/miniconda3/bin/python - <<'PY2'
from huggingface_hub import hf_hub_download
path = hf_hub_download(
    repo_id='MeiGen-AI/MeiGen-MultiTalk',
    filename='multitalk.safetensors',
    local_dir='/root/autodl-tmp/avatar-benchmark/models/MultiTalk/weights/MeiGen-MultiTalk',
)
print(path)
PY2
echo "[$(date '+%F %T')] MultiTalk self checkpoint download completed"
