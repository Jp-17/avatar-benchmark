#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LiveAvatar
ENV=/root/autodl-tmp/envs/liveavatar-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
MASTER_PORT=${MASTER_PORT:-29131}
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animation and synchronized mouth motion."
start_gpu_monitor() {
  local metrics_file="$1"
  (
    max=0
    while true; do
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
write_config_json() {
  cat > "$OUT_DIR/config.json" <<JSON
{
  "model": "liveavatar",
  "phase": "Phase 4",
  "resolution": {"width": 704, "height": 384},
  "task": "s2v-14B",
  "infer_frames": 80,
  "sample_steps": 4,
  "seed": 42,
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
  "skipped_conditions": {
    "C_half_long": "参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。",
    "C_full_long": "参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LiveAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/liveavatar/run_phase4_filtered.sh
- 配置文件：output/liveavatar_newphase4/config.json
- 输出目录：output/liveavatar_newphase4/
- 说明：参考 test/liveavatar/test.md 的最小素材测试经验，沿用已验证成功的 80 帧稳定链路；并保持串行执行，避免与其他大模型并行导致显存冲突。

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
  local cmd="$5"
  local out="$6"
  local log="$7"
  local peak="$8"
  local runtime="$9"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + ${prompt_type} prompt
- 实际命令：$cmd
- config 参数：见 output/liveavatar_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/liveavatar/test.md 中已验证的短时稳定路径；必须串行执行以避免与其他 14B/18B 模型并行时触发 OOM。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt log out start_ts end_ts metrics gpu_pid peak cmd cmd_status
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -f "$log" "$out" "$metrics"
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=$MASTER_PORT minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt '$prompt' --image $img --audio $audio --save_file $out --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=$MASTER_PORT minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt "$prompt" --image "$img" --audio "$audio" --save_file "$out" --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/ >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  if [ ! -s "$out" ]; then
    echo "LiveAvatar output not found for $cond" >> "$log"
    return 1
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。"
append_skip C_full_long "参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
