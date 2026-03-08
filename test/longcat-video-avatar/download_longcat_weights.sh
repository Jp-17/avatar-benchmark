#!/bin/bash
set -euo pipefail
LOG=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/download_longcat_weights.log
exec > >(tee -a "$LOG") 2>&1
BASE_DIR=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video
AVATAR_DIR=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video-Avatar
PY_DEPS=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449
mkdir -p "$BASE_DIR" "$AVATAR_DIR"
echo "[$(date '+%F %T')] start LongCat-Video base download"
env HF_ENDPOINT=https://hf-mirror.com PYTHONPATH="$PY_DEPS" /root/miniconda3/bin/python - <<'PY2'
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='meituan-longcat/LongCat-Video',
    local_dir='/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video',
    allow_patterns=['config.json','model_index.json','dit/*','scheduler/*','text_encoder/*','tokenizer/*','vae/*'],
    resume_download=True,
)
PY2
echo "[$(date '+%F %T')] start LongCat-Video-Avatar download"
env HF_ENDPOINT=https://hf-mirror.com PYTHONPATH="$PY_DEPS" /root/miniconda3/bin/python - <<'PY3'
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='meituan-longcat/LongCat-Video-Avatar',
    local_dir='/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video-Avatar',
    allow_patterns=['config.json','model_index.json','avatar_single/*','avatar_multi/*','chinese-wav2vec2-base/*','vocal_separator/*'],
    resume_download=True,
)
PY3
echo "[$(date '+%F %T')] LongCat downloads completed"
