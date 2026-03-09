#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Wan2.2
ENV=/root/autodl-tmp/envs/wan2.2-env
CKPT=/root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-T2V-A14B
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/wan22_t2v_newphase4
LOG_DIR=$OUT_DIR/logs
PROMPT_DIR=$OUT_DIR/prompts
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR" "$PROMPT_DIR"
SPEECH_PROMPT="A half-body portrait of a person speaking directly to the camera with natural facial expressions, subtle gestures, and a clean studio-like background."
SING_PROMPT="A full-body shot of a person performing naturally as if singing to camera, with expressive body language, rhythmic motion, and dynamic stage presence."
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
      if [ "$used" -gt "$max" ]; then max=$used; fi
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
  "model": "wan2.2-t2v",
  "phase": "Phase 4",
  "task": "t2v-A14B",
  "resolution": {"width": 480, "height": 832},
  "frame_num": 17,
  "sample_steps": 8,
  "offload_model": true,
  "t5_cpu": true,
  "supported_conditions": {
    "C_half_short": {"prompt_type": "speech"},
    "C_full_short": {"prompt_type": "singing"}
  },
  "skipped_conditions": {
    "C_half_long": "Wan2.2-T2V 当前稳定路径只验证了 17 帧短视频，不扩展到长时。",
    "C_full_long": "Wan2.2-T2V 当前稳定路径只验证了 17 帧短视频，不扩展到长时。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# Wan2.2-T2V Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/wan2.2-t2v-i2v/run_phase4_t2v_filtered.sh
- 配置文件：output/wan22_t2v_newphase4/config.json
- 输出目录：output/wan22_t2v_newphase4/
- 说明：参考 test/wan2.2-t2v-i2v/test.md 的最小素材测试经验，沿用已验证的 480x832 + 17 帧稳定路径，只执行短时子集。

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
  local prompt_file="$2"
  local cmd="$3"
  local out="$4"
  local log="$5"
  local peak="$6"
  local runtime="$7"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$prompt_file
- 实际命令：$cmd
- config 参数：见 output/wan22_t2v_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/wan2.2-t2v-i2v/test.md 中已验证的 T2V 短时稳定路径。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local prompt_type="$2"
  local prompt log out metrics prompt_file start_ts end_ts gpu_pid peak cmd_status cmd
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  prompt_file="$PROMPT_DIR/${cond}.txt"
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  printf '%s\n' "$prompt" > "$prompt_file"
  rm -f "$log" "$out" "$metrics"
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task t2v-A14B --size 480*832 --frame_num 17 --sample_steps 8 --offload_model True --convert_model_dtype --t5_cpu --ckpt_dir $CKPT --prompt '$prompt' --save_file $out"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task t2v-A14B --size 480*832 --frame_num 17 --sample_steps 8 --offload_model True --convert_model_dtype --t5_cpu --ckpt_dir "$CKPT" --prompt "$prompt" --save_file "$out" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$prompt_file" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "Wan2.2-T2V 当前稳定路径只验证了 17 帧短视频，不扩展到长时。"
append_skip C_full_long "Wan2.2-T2V 当前稳定路径只验证了 17 帧短视频，不扩展到长时。"
run_case C_half_short speech
run_case C_full_short singing
finalize_results_md
