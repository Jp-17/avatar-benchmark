#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$ROOT/models/MultiTalk
OUT_DIR=$ROOT/output/multitalk_newphase4_longaudio
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
PY_DEPS=$ROOT/test/shared_pydeps/unified_transformers_449
ENV_SITE=/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and smooth upper-body motion."
SING_PROMPT="A person singing naturally to the camera with expressive mouth motion and rhythmic body movement."

ensure_results_md() {
  if [ -f "$RESULTS_MD" ]; then
    return 0
  fi
  cat > "$RESULTS_MD" <<'MD'
# MultiTalk Phase 4 长音频条件结果

## 状态
- 当前状态：进行中
- 执行脚本：test/multitalk/run_phase4_longaudio.sh
- 配置文件：output/multitalk_newphase4_longaudio/config.json
- 输出目录：output/multitalk_newphase4_longaudio/
- 说明：沿用 `test/multitalk/test.md` 的稳定 multitalk-480 + streaming 链路，仅执行 `C_half_long` / `C_full_long` 两个长音频条件。

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
  local prompt_type="$4"
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
- 素材：$audio + $img
- prompt 类型：$prompt_type
- 实际命令：$cmd
- 输出路径：$out
- 音频时长：${audio_sec} 秒
- 视频时长：${video_sec} 秒
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 multitalk-480 + streaming 稳定路径完成本轮长音频条件执行。
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
- 素材：$audio + $img
- 实际命令：$cmd
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：长音频条件执行失败，需结合日志继续排查。
MD
}

record_existing_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local cmd="$5"
  local out="$6"
  local log="$7"
  local metrics="$8"
  if has_case_recorded "$cond"; then
    return 0
  fi
  if [ ! -s "$out" ]; then
    return 0
  fi
  local peak runtime audio_sec video_sec
  peak=$(cat "$metrics" 2>/dev/null || echo reuse)
  runtime=$(read_runtime "$log")
  audio_sec=$(audio_duration "$audio")
  video_sec=$(video_duration "$out")
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
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
  "model": "multitalk",
  "phase": "Phase 4 long-audio",
  "size": "multitalk-480",
  "sample_steps": 8,
  "mode": "streaming",
  "motion_frame": 9,
  "num_persistent_param_in_dit": 0,
  "supported_conditions": {
    "C_half_long": {
      "image": "input/avatar_img/filtered/half_body/2.png",
      "audio": "input/audio/filtered/long/A001.wav",
      "prompt_type": "speech"
    },
    "C_full_long": {
      "image": "input/avatar_img/filtered/full_body/3.png",
      "audio": "input/audio/filtered/long/MT_eng.wav",
      "prompt_type": "singing"
    }
  }
}
JSON
}

run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  local input_json="$LOG_DIR/${cond}.json"
  local log="$LOG_DIR/${cond}.log"
  local metrics="$LOG_DIR/${cond}.gpu_peak"
  local prefix="$OUT_DIR/${cond}"
  local out="$OUT_DIR/${cond}.mp4"
  local cmd="env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=$PY_DEPS:$ENV_SITE /root/miniconda3/bin/python -S generate_multitalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --input_json $input_json --size multitalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --num_persistent_param_in_dit 0 --save_file $prefix"
  cat > "$input_json" <<JSON
{
  "prompt": "$prompt",
  "cond_image": "$img",
  "cond_audio": {
    "person1": "$audio"
  }
}
JSON
  record_existing_case "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$metrics"
  if has_case_recorded "$cond"; then
    return 0
  fi
  rm -f "$log" "$metrics"
  cd "$MODEL_DIR"
  local start_ts end_ts gpu_pid cmd_status runtime peak audio_sec video_sec
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  env CUDA_VISIBLE_DEVICES=0 \
    LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib \
    PYTHONPATH="$PY_DEPS:$ENV_SITE" \
    /root/miniconda3/bin/python -S generate_multitalk.py \
      --ckpt_dir weights/Wan2.1-I2V-14B-480P \
      --wav2vec_dir weights/chinese-wav2vec2-base \
      --input_json "$input_json" \
      --size multitalk-480 \
      --sample_steps 8 \
      --mode streaming \
      --motion_frame 9 \
      --num_persistent_param_in_dit 0 \
      --save_file "$prefix" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  runtime=$((end_ts - start_ts))
  if [ "$cmd_status" -ne 0 ]; then
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return "$cmd_status"
  fi
  if [ ! -s "$out" ]; then
    echo "MultiTalk output not found for $cond" >> "$log"
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return 1
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  audio_sec=$(audio_duration "$audio")
  video_sec=$(video_duration "$out")
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$runtime" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
}


main() {
  local failures=0
  ensure_results_md
  write_config_json
  # C_half_long skipped per user instruction
  run_case C_full_long "$ROOT/input/avatar_img/filtered/full_body/3.png" "$ROOT/input/audio/filtered/long/MT_eng.wav" singing || failures=1
  finalize_results "$failures"
  [ "$failures" -eq 0 ]
}

main "$@"
