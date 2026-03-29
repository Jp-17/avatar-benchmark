#!/bin/bash
set -euo pipefail

MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/davinci-magihuman
ENV=/root/autodl-tmp/envs/davinci-magihuman-env
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman
IN_DIR=$TEST_DIR/input
OUT_DIR=$TEST_DIR/output
CONFIG_JSON=$OUT_DIR/config_minimal_base_4s_384x384.json
LOG=$OUT_DIR/davinci_magihuman_minimal.log
OUT_PREFIX=$OUT_DIR/davinci_magihuman_minimal
EXPECTED_MP4=${OUT_PREFIX}_4s_384x384.mp4
GPU_PEAK=$OUT_DIR/davinci_magihuman_minimal.gpu_peak
PROBE_TXT=$OUT_DIR/davinci_magihuman_minimal.probe.txt
IMG_SRC=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I013.png
PROMPT_SRC=/root/autodl-tmp/avatar-benchmark/input/prompt/P011.txt
IMG=$IN_DIR/I013.png
PROMPT_FILE=$IN_DIR/P011.txt
BASE_CKPT_DIR=$MODEL_DIR/weights/base
T5_SHARED=/root/autodl-tmp/avatar-benchmark/weights_shared/t5gemma-9b-9b-ul2
AUDIO_SHARED=/root/autodl-tmp/avatar-benchmark/weights_shared/stable-audio-open-1.0
T5_DIR=$MODEL_DIR/weights/t5gemma-9b-9b-ul2
AUDIO_DIR=$MODEL_DIR/weights/stable-audio-open-1.0
WAN_VAE_DIR=/root/autodl-tmp/avatar-benchmark/models/Ovi/ckpts/Wan2.2-TI2V-5B
GPU_PID=""

verify_index_dir() {
  local index_path="$1"
  "$ENV/bin/python" - "$index_path" <<'PY'
import json
import os
import sys
index_path = sys.argv[1]
with open(index_path, "r", encoding="utf-8") as f:
    data = json.load(f)
root = os.path.dirname(index_path)
files = sorted(set(data.get("weight_map", {}).values()))
missing = [name for name in files if not os.path.exists(os.path.join(root, name))]
if missing:
    print(f"missing index shards for {index_path}:", file=sys.stderr)
    for name in missing:
        print(name, file=sys.stderr)
    raise SystemExit(1)
print(f"verified_index={index_path} shard_count={len(files)}")
PY
}

start_gpu_monitor() {
  local metrics_file="$1"
  (
    local max=0
    while true; do
      local used
      used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
      used=${used:-0}
      case "$used" in
        ''|*[!0-9]*) used=0 ;;
      esac
      if [ "$used" -gt "$max" ]; then
        max=$used
      fi
      echo "$max" > "$metrics_file"
      sleep 1
    done
  ) >/dev/null 2>&1 &
  echo $!
}

stop_gpu_monitor() {
  local pid="$1"
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

cleanup() {
  if [ -n "${GPU_PID:-}" ]; then
    stop_gpu_monitor "$GPU_PID"
  fi
}

trap cleanup EXIT

mkdir -p "$IN_DIR" "$OUT_DIR" "$MODEL_DIR/weights"
cp -f "$IMG_SRC" "$IMG"
cp -f "$PROMPT_SRC" "$PROMPT_FILE"
ln -sfn "$T5_SHARED" "$T5_DIR"
ln -sfn "$AUDIO_SHARED" "$AUDIO_DIR"

for req in \
  "$IMG_SRC" \
  "$PROMPT_SRC" \
  "$BASE_CKPT_DIR/model.safetensors.index.json" \
  "$T5_DIR/config.json" \
  "$T5_DIR/model.safetensors.index.json" \
  "$AUDIO_DIR/model_config.json" \
  "$AUDIO_DIR/model.safetensors" \
  "$WAN_VAE_DIR/Wan2.2_VAE.pth"
do
  if [ ! -e "$req" ]; then
    echo "Missing required file: $req" >&2
    exit 1
  fi
done

verify_index_dir "$BASE_CKPT_DIR/model.safetensors.index.json"
verify_index_dir "$T5_DIR/model.safetensors.index.json"

PROMPT="$(tr '\n' ' ' < "$PROMPT_FILE" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')"

cat > "$CONFIG_JSON" <<JSON
{
  "engine_config": {
    "load": "$BASE_CKPT_DIR",
    "cp_size": 1
  },
  "evaluation_config": {
    "cfg_number": 2,
    "num_inference_steps": 32,
    "audio_model_path": "$AUDIO_DIR",
    "txt_model_path": "$T5_DIR",
    "vae_model_path": "$WAN_VAE_DIR",
    "use_turbo_vae": false
  }
}
JSON

rm -f "$LOG" "$EXPECTED_MP4" "$GPU_PEAK" "$PROBE_TXT"

source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV"
cd "$MODEL_DIR"
export PYTHONPATH=${MODEL_DIR}${PYTHONPATH:+:$PYTHONPATH}

"$ENV/bin/python" - <<'PY'
import importlib
mods = [
    "flash_attn.flash_attn_interface",
    "magi_compiler",
    "inference.pipeline.entry",
]
missing = []
for name in mods:
    try:
        importlib.import_module(name)
    except Exception as exc:
        missing.append((name, repr(exc)))
if missing:
    raise SystemExit("; ".join(f"{name}: {err}" for name, err in missing))
print("python_import_preflight=ok")
PY

export MASTER_ADDR=${MASTER_ADDR:-localhost}
export MASTER_PORT=${MASTER_PORT:-6011}
export NNODES=${NNODES:-1}
export NODE_RANK=${NODE_RANK:-0}
export GPUS_PER_NODE=${GPUS_PER_NODE:-1}
export WORLD_SIZE=$((GPUS_PER_NODE * NNODES))
export PYTORCH_CUDA_ALLOC_CONF=${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}
export NCCL_ALGO=${NCCL_ALGO:-^NVLS}
export CPU_OFFLOAD=1
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1

DISTRIBUTED_ARGS="--nnodes=${NNODES} --node_rank=${NODE_RANK} --nproc_per_node=${GPUS_PER_NODE} --rdzv-backend=c10d --rdzv-endpoint=${MASTER_ADDR}:${MASTER_PORT}"
CMD=(
  torchrun ${DISTRIBUTED_ARGS}
  inference/pipeline/entry.py
  --config-load-path "$CONFIG_JSON"
  --prompt "$PROMPT"
  --image_path "$IMG"
  --seconds 4
  --br_width 384
  --br_height 384
  --output_path "$OUT_PREFIX"
)

printf 'command=%q ' "${CMD[@]}" > "$LOG"
printf '\n' >> "$LOG"
START_TS=$(date +%s)
GPU_PID=$(start_gpu_monitor "$GPU_PEAK")
"${CMD[@]}" >> "$LOG" 2>&1
END_TS=$(date +%s)
stop_gpu_monitor "$GPU_PID"
GPU_PID=""

if [ ! -f "$EXPECTED_MP4" ]; then
  echo "Expected output not found: $EXPECTED_MP4" >> "$LOG"
  ls -lah "$OUT_DIR" >> "$LOG"
  exit 1
fi

"$ENV/bin/python" - <<PY > "$PROBE_TXT"
import cv2
path = "$EXPECTED_MP4"
cap = cv2.VideoCapture(path)
print("video_opened", cap.isOpened())
print("video_width", int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)))
print("video_height", int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))
print("video_fps", cap.get(cv2.CAP_PROP_FPS))
print("video_frames", int(cap.get(cv2.CAP_PROP_FRAME_COUNT)))
cap.release()
PY

{
  echo "gpu_peak_mb=$(cat "$GPU_PEAK" 2>/dev/null || echo 0)"
  echo "runtime_seconds=$((END_TS-START_TS))"
  cat "$PROBE_TXT"
} >> "$LOG"

echo "minimal_test_output=$EXPECTED_MP4"
echo "minimal_test_log=$LOG"
