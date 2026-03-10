#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/liveavatar
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LiveAvatar
ENV=/root/autodl-tmp/envs/liveavatar-env
OUTPUT_DIR=${OUTPUT_DIR:-$TEST_DIR/output}
LOG=${LOG:-$OUTPUT_DIR/liveavatar_minimal_80gpu.log}
OUT_MP4=${OUT_MP4:-$OUTPUT_DIR/liveavatar_minimal_80gpu.mp4}
IMG=${IMG:-$TEST_DIR/input/I013.png}
AUDIO=${AUDIO:-$TEST_DIR/input/A007_5s.wav}
PROMPT_FILE=${PROMPT_FILE:-$TEST_DIR/input/P011.txt}
MASTER_PORT=${MASTER_PORT:-29111}
INFER_FRAMES=${INFER_FRAMES:-80}
NUM_CLIP=${NUM_CLIP:-1}
USE_OFFLOAD_KV_CACHE=${USE_OFFLOAD_KV_CACHE:-1}
USE_FP8=${USE_FP8:-0}
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
KV_CACHE_ARGS=()
FP8_ARGS=()
if [ "$USE_OFFLOAD_KV_CACHE" = "1" ]; then
  KV_CACHE_ARGS+=(--offload_kv_cache)
fi
if [ "$USE_FP8" = "1" ]; then
  FP8_ARGS+=(--fp8)
fi
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
CMD=(/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port="$MASTER_PORT" minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt "$PROMPT" --image "$IMG" --audio "$AUDIO" --save_file "$OUT_MP4" --infer_frames "$INFER_FRAMES" --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip "$NUM_CLIP" --num_gpus_dit 1 --sample_solver euler --single_gpu "${KV_CACHE_ARGS[@]}" --ckpt_dir ckpt/Wan2.2-S2V-14B/ "${FP8_ARGS[@]}")
"${CMD[@]}" >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
