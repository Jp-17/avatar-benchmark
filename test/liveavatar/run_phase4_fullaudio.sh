#!/bin/bash
set -u -o pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$ROOT/models/LiveAvatar
ENV=/root/autodl-tmp/envs/liveavatar-env
OUT_DIR=${OUT_DIR:-$ROOT/output/liveavatar_newphase4_fullaudio}
LOG_DIR=${LOG_DIR:-$OUT_DIR/logs}
RESULTS_MD=${RESULTS_MD:-$OUT_DIR/results.md}
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
INFER_FRAMES=${INFER_FRAMES:-48}
USE_OFFLOAD_KV_CACHE=${USE_OFFLOAD_KV_CACHE:-0}
USE_FP8=${USE_FP8:-0}
KV_CACHE_ARG=""
FP8_ARG=""
if [ "$USE_OFFLOAD_KV_CACHE" = "1" ]; then
  KV_CACHE_ARG="--offload_kv_cache"
fi
if [ "$USE_FP8" = "1" ]; then
  FP8_ARG="--fp8"
fi
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animation and synchronized mouth motion."
clip_count_for_audio() {
  /root/miniconda3/bin/python - "$1" "$INFER_FRAMES" <<'PY'
import contextlib, math, wave, sys
with contextlib.closing(wave.open(sys.argv[1], "rb")) as wf:
    sec = wf.getnframes() / float(wf.getframerate())
infer_frames = float(sys.argv[2])
print(max(1, math.ceil(sec * 25 / infer_frames - 1e-9)))
PY
}
write_config_json() {
  cat > "$OUT_DIR/config.json" <<JSON
{
  "model": "liveavatar",
  "phase": "Phase 4 full-audio rerun",
  "baseline_output": "output/liveavatar_newphase4/",
  "description": "优先沿用更接近官方单卡脚本的 ${INFER_FRAMES} 帧粒度，并通过 num_clip 对齐音频时长。",
  "sample_fps": 25,
  "infer_frames": $INFER_FRAMES,
  "align_multiple": 4,
  "supported_conditions": {
    "C_half_short": {
      "image": "input/avatar_img/filtered/half_body/13.png",
      "audio": "input/audio/filtered/short/EM2_no_smoking.wav",
      "prompt_type": "speech"
    },
    "C_full_short": {
      "image": "input/avatar_img/filtered/full_body/1.png",
      "audio": "input/audio/filtered/short/S002_adele.wav",
      "prompt_type": "singing"
    }
  },
  "notes": [
    "保留 offload_model、expandable_segments、compile disable、single GPU 等单卡稳定参数。",
    "默认不启用 offload_kv_cache，避免多 clip 推理时出现 CPU 空转 / GPU 低利用率的软卡住。",
    "本轮只补跑短时条件，使输出时长更接近原始音频；长时条件仍不在本轮夜间队列范围内。"
  ]
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<'MD'
# LiveAvatar Phase 4 原始音频时长补跑

## 状态
- 当前状态：进行中
- 执行脚本：test/liveavatar/run_phase4_fullaudio.sh
- 配置文件：output/liveavatar_newphase4_fullaudio/config.json
- 输出目录：output/liveavatar_newphase4_fullaudio/
- 基线目录：output/liveavatar_newphase4/
- 说明：沿用 test/liveavatar/test.md 的单卡稳定链路，优先以 ${INFER_FRAMES} 帧粒度 + num_clip 补齐时长。

## Condition 明细
MD
}
append_skip() {
  local cond="$1"
  local reason="$2"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：⏭️ skipped
- 跳过原因：$reason
MD
}
append_result() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local infer_frames="$5"
  local audio_sec="$6"
  local output_sec="$7"
  local cmd="$8"
  local out="$9"
  local log="${10}"
  local peak="${11}"
  local runtime="${12}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + ${prompt_type} prompt
- 源音频时长：${audio_sec} 秒
- 推理帧数：${infer_frames}
- 输出视频时长：${output_sec} 秒
- 实际命令：$cmd
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
MD
}
append_failure() {
  local cond="$1"
  local audio_sec="$2"
  local infer_frames="$3"
  local log="$4"
  local runtime="$5"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：❌ failed
- 源音频时长：${audio_sec} 秒
- 推理帧数：${infer_frames}
- 推理生成时间：${runtime} 秒
- 日志：$log
MD
}
finalize_ok() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成按原始音频时长补跑/' "$RESULTS_MD"
}
finalize_partial() {
  perl -0pi -e 's/当前状态：进行中/当前状态：部分失败（原始音频时长补跑未全过）/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local master_port="$5"
  local prompt log out metrics case_json start_ts end_ts gpu_pid peak cmd_status infer_frames audio_sec output_sec cmd num_clip
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  case_json="$LOG_DIR/${cond}.json"
  audio_sec=$(audio_duration "$audio")
  infer_frames=$INFER_FRAMES
  num_clip=$(clip_count_for_audio "$audio")
  cat > "$case_json" <<JSON
{
  "condition": "$cond",
  "image": "$img",
  "audio": "$audio",
  "prompt_type": "$prompt_type",
  "audio_duration_s": $audio_sec,
  "infer_frames": $infer_frames,
  "num_clip": $num_clip,
  "sample_fps": 25
}
JSON
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=$master_port minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt '$prompt' --image $img --audio $audio --save_file $out --infer_frames $infer_frames --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip $num_clip --num_gpus_dit 1 --sample_solver euler --single_gpu $KV_CACHE_ARG --ckpt_dir ckpt/Wan2.2-S2V-14B/ $FP8_ARG"
  rm -f "$log" "$metrics"
  if [ -s "$out" ]; then
    output_sec=$(video_duration "$out")
    append_result "$cond" "$img" "$audio" "$prompt_type" "$infer_frames" "$audio_sec" "$output_sec" "$cmd" "$out" "$log" "reuse" "0"
    return 0
  fi
  cd "$MODEL_DIR" || return 1
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port="$master_port" minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt "$prompt" --image "$img" --audio "$audio" --save_file "$out" --infer_frames "$infer_frames" --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip "$num_clip" --num_gpus_dit 1 --sample_solver euler --single_gpu $KV_CACHE_ARG --ckpt_dir ckpt/Wan2.2-S2V-14B/ $FP8_ARG >> "$log" 2>&1
  cmd_status=$?
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  if [ "$cmd_status" -eq 0 ] && [ -s "$out" ]; then
    output_sec=$(video_duration "$out")
    append_result "$cond" "$img" "$audio" "$prompt_type" "$infer_frames" "$audio_sec" "$output_sec" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
    return 0
  fi
  append_failure "$cond" "$audio_sec" "$infer_frames" "$log" "$((end_ts-start_ts))"
  return 1
}
main() {
  local failures=0
  write_config_json
  init_results_md
  append_skip C_half_long "本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。"
  append_skip C_full_long "本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。"
  run_case C_half_short "$ROOT/input/avatar_img/filtered/half_body/13.png" "$ROOT/input/audio/filtered/short/EM2_no_smoking.wav" speech 30231 || failures=1
  run_case C_full_short "$ROOT/input/avatar_img/filtered/full_body/1.png" "$ROOT/input/audio/filtered/short/S002_adele.wav" singing 30232 || failures=1
  if [ "$failures" -eq 0 ]; then
    finalize_ok
    return 0
  fi
  finalize_partial
  return 1
}
main "$@"
