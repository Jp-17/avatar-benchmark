#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$ROOT/models/OmniAvatar
ENV=/root/autodl-tmp/envs/omniavatar-env
OUT_DIR=$ROOT/output/omniavatar_newphase4_longaudio
LOG_DIR=$OUT_DIR/logs
PROMPT_DIR=$OUT_DIR/prompts
RESULTS_MD=$OUT_DIR/results.md
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
mkdir -p "$OUT_DIR" "$LOG_DIR" "$PROMPT_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion."

ensure_results_md() {
  if [ -f "$RESULTS_MD" ]; then
    return 0
  fi
  cat > "$RESULTS_MD" <<'MD'
# OmniAvatar Phase 4 长音频条件结果

## 状态
- 当前状态：进行中
- 执行脚本：test/omniavatar/run_phase4_longaudio.sh
- 配置文件：output/omniavatar_newphase4_longaudio/config.json
- 输出目录：output/omniavatar_newphase4_longaudio/
- 说明：沿用 `test/omniavatar/test.md` 与 `test/omniavatar/run_phase4_filtered.sh` 的稳定链路，仅执行 `C_half_long` / `C_full_long` 两个长音频条件。

## Condition 明细
MD
}

has_case_recorded() {
  local cond="$1"
  grep -q "^### ${cond}$" "$RESULTS_MD" 2>/dev/null
}

read_runtime() {
  local log="$1"
  awk -F= '/runtime_seconds=/{v=$2} END{if (v=="") v=0; print v}' "$log" 2>/dev/null
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
  local audio_sec="${10}"
  local video_sec="${11}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + $prompt_file
- 实际命令：$cmd
- 输出路径：$out
- 音频时长：${audio_sec} 秒
- 视频时长：${video_sec} 秒
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 `scripts/inference.py + configs/inference.yaml` 稳定路径，并继续使用 PATH 中的 ffmpeg。
MD
}

append_failure() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local cmd="$4"
  local log="$5"
  local runtime="$6"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：❌ failed
- 素材：$img + $audio
- 实际命令：$cmd
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：本轮长音频链路执行失败，需结合日志继续排查。
MD
}

record_existing_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_file="$4"
  local cmd="$5"
  local out="$6"
  local log="$7"
  local metrics="$8"
  local peak runtime audio_sec video_sec
  if has_case_recorded "$cond"; then
    return 0
  fi
  if [ ! -s "$out" ]; then
    return 0
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo reuse)
  runtime=$(read_runtime "$log")
  audio_sec=$(audio_duration "$audio")
  video_sec=$(video_duration "$out")
  append_result "$cond" "$img" "$audio" "$prompt_file" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
}

finalize_results() {
  local failures="$1"
  if [ "$failures" -eq 0 ]; then
    perl -0pi -e 's/当前状态：进行中/当前状态：长音频条件完成/' "$RESULTS_MD"
  else
    perl -0pi -e 's/当前状态：进行中/当前状态：长音频条件部分完成/' "$RESULTS_MD"
  fi
}

write_config_json() {
  cat > "$OUT_DIR/config.json" <<JSON
{
  "model": "omniavatar",
  "phase": "Phase 4 long-audio",
  "config": "configs/inference.yaml",
  "supported_conditions": {
    "C_half_long": {
      "image": "input/avatar_img/filtered/half_body/2.png",
      "audio": "input/audio/filtered/long/A001.wav",
      "prompt_type": "speech"
    },
    "C_full_long": {
      "image": "input/avatar_img/filtered/full_body/3.png",
      "audio": "input/audio/filtered/long/MT_eng.wav",
      "prompt_type": "speech"
    }
  }
}
JSON
}

run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local master_port="$4"
  local prompt_file="$PROMPT_DIR/${cond}.txt"
  local input_file="$LOG_DIR/${cond}.infer.txt"
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  local metrics="$LOG_DIR/${cond}.gpu_peak"
  local prompt="$SPEECH_PROMPT"
  local cmd="conda activate $ENV && torchrun --standalone --nproc_per_node=1 --master_port=$master_port scripts/inference.py --config configs/inference.yaml --input_file $input_file"
  local src peak runtime audio_sec video_sec gpu_pid start_ts end_ts cmd_status
  printf '%s\n' "$prompt" > "$prompt_file"
  printf '%s@@%s@@%s\n' "$prompt" "$img" "$audio" > "$input_file"
  record_existing_case "$cond" "$img" "$audio" "$prompt_file" "$cmd" "$out" "$log" "$metrics"
  if has_case_recorded "$cond"; then
    return 0
  fi
  rm -f "$log" "$metrics"
  mkdir -p "$MODEL_DIR/demo_out"
  find "$MODEL_DIR/demo_out" -type f \( -name '*.mp4' -o -name '*.wav' \) -delete
  cd "$MODEL_DIR"
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate "$ENV"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  torchrun --standalone --nproc_per_node=1 --master_port="$master_port" scripts/inference.py --config configs/inference.yaml --input_file "$input_file" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  runtime=$((end_ts-start_ts))
  if [ "$cmd_status" -ne 0 ]; then
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return "$cmd_status"
  fi
  src=$(find "$MODEL_DIR/demo_out" -name '*.mp4' -type f | sort | tail -1)
  if [ -z "$src" ]; then
    echo "OmniAvatar output not found for $cond" >> "$log"
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return 1
  fi
  cp "$src" "$out"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  audio_sec=$(audio_duration "$audio")
  video_sec=$(video_duration "$out")
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$runtime" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_file" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
}

main() {
  local failures=0
  ensure_results_md
  write_config_json
  run_case C_half_long "$ROOT/input/avatar_img/filtered/half_body/2.png" "$ROOT/input/audio/filtered/long/A001.wav" 30241 || failures=1
  run_case C_full_long "$ROOT/input/avatar_img/filtered/full_body/3.png" "$ROOT/input/audio/filtered/long/MT_eng.wav" 30242 || failures=1
  finalize_results "$failures"
  [ "$failures" -eq 0 ]
}

main "$@"
