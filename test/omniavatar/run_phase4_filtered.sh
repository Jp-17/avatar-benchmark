#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/OmniAvatar
ENV=/root/autodl-tmp/envs/omniavatar-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4
LOG_DIR=$OUT_DIR/logs
PROMPT_DIR=$OUT_DIR/prompts
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR" "$PROMPT_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion."
SING_PROMPT="A person singing naturally to the camera with expressive facial animation, rhythmic motion, and strong performance energy."
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
  "model": "omniavatar",
  "phase": "Phase 4",
  "config": "configs/inference.yaml",
  "dtype": "bf16(default from config)",
  "supported_conditions": {
    "C_half_short": {
      "image": "input/avatar_img/filtered/half_body/13.png",
      "audio": "input/audio/filtered/short/EM2_no_smoking.wav",
      "prompt_text": "A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion.",
      "prompt_type": "speech"
    },
    "C_full_short": {
      "image": "input/avatar_img/filtered/full_body/1.png",
      "audio": "input/audio/filtered/short/S002_adele.wav",
      "prompt_text": "A person singing naturally to the camera with expressive facial animation, rhythmic motion, and strong performance energy.",
      "prompt_type": "singing"
    }
  },
  "skipped_conditions": {
    "C_half_long": "参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。",
    "C_full_long": "参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# OmniAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/omniavatar/run_phase4_filtered.sh
- 配置文件：output/omniavatar_newphase4/config.json
- 输出目录：output/omniavatar_newphase4/
- 说明：参考 test/omniavatar/test.md 的最小素材测试经验，沿用 image+audio+prompt 的稳定链路，只执行短时子集，并记录显存峰值与推理时长。

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
  local prompt_file="$4"
  local cmd="$5"
  local out="$6"
  local log="$7"
  local peak="$8"
  local runtime="$9"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + $prompt_file
- 实际命令：$cmd
- config 参数：见 output/omniavatar_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/omniavatar/test.md 中已验证的 `scripts/inference.py + configs/inference.yaml` 稳定路径，并继续使用 PATH 中的 ffmpeg。
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
  local prompt prompt_file input_file log out metrics start_ts end_ts gpu_pid peak cmd cmd_status src
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  prompt_file="$PROMPT_DIR/${cond}.txt"
  input_file="$LOG_DIR/${cond}.infer.txt"
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  printf '%s\n' "$prompt" > "$prompt_file"
  printf '%s@@%s@@%s\n' "$prompt" "$img" "$audio" > "$input_file"
  rm -f "$log" "$out" "$metrics"
  mkdir -p "$MODEL_DIR/demo_out"
  find "$MODEL_DIR/demo_out" -maxdepth 1 -type f \( -name '*.mp4' -o -name '*.wav' \) -delete
  cmd="conda activate $ENV && torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file $input_file"
  cd "$MODEL_DIR"
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate "$ENV"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file "$input_file" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  src=$(find "$MODEL_DIR/demo_out" -maxdepth 1 -name '*.mp4' -type f | sort | tail -1)
  if [ -z "$src" ]; then
    echo "OmniAvatar output not found for $cond" >> "$log"
    return 1
  fi
  cp "$src" "$out"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_file" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。"
append_skip C_full_long "参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
