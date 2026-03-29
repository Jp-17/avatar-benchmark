#!/bin/bash
set -euo pipefail

MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/davinci-magihuman
ENV=/root/autodl-tmp/envs/davinci-magihuman-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4
LOG_DIR=$OUT_DIR/logs
RUN_ID=full_body_3_fusion_prompt_approx_768x768_251f
CONFIG_JSON=$OUT_DIR/config_${RUN_ID}.json
RUNTIME_CONFIG_JSON=$OUT_DIR/runtime_${RUN_ID}.json
RESULTS_MD=$OUT_DIR/results.md
LOG=$LOG_DIR/${RUN_ID}.log
OUT_PREFIX=$OUT_DIR/${RUN_ID}
RAW_MP4=${OUT_PREFIX}_10s_384x384.mp4
GPU_PEAK=$LOG_DIR/${RUN_ID}.gpu_peak
PROBE_TXT=$LOG_DIR/${RUN_ID}.probe.txt
IMAGE=/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png
REQUESTED_OUTPUT=/root/autodl-tmp/fusion_forcing/test_outputs/ltx23_distilled_compare_20260322_053332/distilled_compare_768x768_249f.mp4
PROMPT="A cheerful full-body young woman stands facing the camera in a bright indoor scene, speaking directly to the viewer with natural lip sync and a warm smile. She says, Hi everyone, I am really happy to see you today, thank you for being here with me. While talking, she gently waves one hand, alternates small expressive hand gestures near her chest, and lightly sways her head from side to side in a lively and friendly way. Her posture stays relaxed and confident, her eyes stay engaged with the camera, and the motion remains smooth, realistic, and suitable for a front-facing talking avatar video."
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

mkdir -p "$OUT_DIR" "$LOG_DIR" "$MODEL_DIR/weights"
ln -sfn "$T5_SHARED" "$T5_DIR"
ln -sfn "$AUDIO_SHARED" "$AUDIO_DIR"

for req in \
  "$IMAGE" \
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

cat > "$CONFIG_JSON" <<JSON
{
  "run_id": "$RUN_ID",
  "reference": "fusion_forcing ltx23_distilled_compare_20260322_053332",
  "requested_config": {
    "image": "$IMAGE",
    "prompt": "$PROMPT",
    "output_path": "$REQUESTED_OUTPUT",
    "num_frames": 249,
    "height": 768,
    "width": 768
  },
  "actual_strategy": {
    "model_variant": "base",
    "num_inference_steps": 32,
    "seconds": 10,
    "br_width": 384,
    "br_height": 384,
    "output_width": 768,
    "output_height": 768,
    "upsample_mode": "bicubic",
    "cpu_offload_t5": true,
    "output_path": "$RAW_MP4"
  },
  "compatibility_note": "daVinci-MagiHuman 当前 CLI 不支持直接传入 num_frames，实际帧数由 seconds * 25 + 1 决定；与 249f 最接近的稳定路径是 10s -> 251f。本次按 official base + 768x768 上采样路径执行，并保留 exact 官方依赖模型。"
}
JSON

cat > "$RUNTIME_CONFIG_JSON" <<JSON
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

rm -f "$LOG" "$RAW_MP4" "$GPU_PEAK" "$PROBE_TXT"

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
export MASTER_PORT=${MASTER_PORT:-6012}
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
  --config-load-path "$RUNTIME_CONFIG_JSON"
  --prompt "$PROMPT"
  --image_path "$IMAGE"
  --seconds 10
  --br_width 384
  --br_height 384
  --output_width 768
  --output_height 768
  --upsample_mode bicubic
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

if [ ! -f "$RAW_MP4" ]; then
  echo "Expected output not found: $RAW_MP4" >> "$LOG"
  ls -lah "$OUT_DIR" >> "$LOG"
  exit 1
fi

"$ENV/bin/python" - <<PY > "$PROBE_TXT"
import cv2
path = "$RAW_MP4"
cap = cv2.VideoCapture(path)
print("video_opened", cap.isOpened())
print("video_width", int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)))
print("video_height", int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))
print("video_fps", cap.get(cv2.CAP_PROP_FPS))
print("video_frames", int(cap.get(cv2.CAP_PROP_FRAME_COUNT)))
cap.release()
PY

GPU_PEAK_MB=$(cat "$GPU_PEAK" 2>/dev/null || echo 0)
RUNTIME_SECONDS=$((END_TS-START_TS))
VIDEO_WIDTH=$(awk '/^video_width /{print $2}' "$PROBE_TXT")
VIDEO_HEIGHT=$(awk '/^video_height /{print $2}' "$PROBE_TXT")
VIDEO_FPS=$(awk '/^video_fps /{print $2}' "$PROBE_TXT")
VIDEO_FRAMES=$(awk '/^video_frames /{print $2}' "$PROBE_TXT")

{
  echo "gpu_peak_mb=$GPU_PEAK_MB"
  echo "runtime_seconds=$RUNTIME_SECONDS"
  cat "$PROBE_TXT"
} >> "$LOG"

cat > "$RESULTS_MD" <<MD
# daVinci-MagiHuman New Phase4 Results

- status: success
- run_id: $RUN_ID
- requested_output_reference: $REQUESTED_OUTPUT
- actual_video: $RAW_MP4
- config_record: $CONFIG_JSON
- runtime_config: $RUNTIME_CONFIG_JSON
- log: $LOG
- script: /root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/run_custom_fullbody3_fusion_prompt.sh
- runtime_seconds: $RUNTIME_SECONDS
- gpu_peak_mb: $GPU_PEAK_MB
- actual_resolution: ${VIDEO_WIDTH}x${VIDEO_HEIGHT}
- actual_fps: $VIDEO_FPS
- actual_frames: $VIDEO_FRAMES
- note: daVinci-MagiHuman 当前稳定路径无法直接精确输出 249 帧；本次按 10s -> 251f 的最近稳定配置运行，并将结果上采样到 768x768。
MD

echo "custom_run_output=$RAW_MP4"
echo "custom_run_log=$LOG"
