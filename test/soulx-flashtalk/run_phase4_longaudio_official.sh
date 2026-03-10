#!/bin/bash
set -euo pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$ROOT/models/SoulX-FlashTalk
ENV=/root/autodl-tmp/envs/flashtalk-env
OUT_DIR=$ROOT/output/soulx_flashtalk_newphase4_longaudio_official
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."

ensure_results_md() {
  if [ -f "$RESULTS_MD" ]; then
    return 0
  fi
  cat > "$RESULTS_MD" <<'MD'
# SoulX-FlashTalk Phase 4 长音频条件结果（正式版）

## 状态
- 当前状态：进行中
- 执行脚本：test/soulx-flashtalk/run_phase4_longaudio_official.sh
- 配置文件：output/soulx_flashtalk_newphase4_longaudio_official/config.json
- 输出目录：output/soulx_flashtalk_newphase4_longaudio_official/
- 说明：沿用 `test/soulx-flashtalk/test.md` 与 `test/soulx-flashtalk/run_phase4_filtered.sh` 的 `generate_video.py + audio_encode_mode=stream + cpu_offload` 稳定链路，正式执行 `C_half_long` / `C_full_long` 两个长音频条件。

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
  local cmd="$4"
  local out="$5"
  local log="$6"
  local peak="$7"
  local runtime="$8"
  local audio_sec="$9"
  local video_sec="${10}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + speech prompt
- 实际命令：$cmd
- 输出路径：$out
- 音频时长：${audio_sec} 秒
- 视频时长：${video_sec} 秒
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 cpu_offload 长链路执行正式长音频条件。
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
- 素材：$img + $audio + speech prompt
- 实际命令：$cmd
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：正式长音频条件执行失败，需结合日志继续排查。
MD
}

record_existing_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local cmd="$4"
  local out="$5"
  local log="$6"
  local metrics="$7"
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
  append_result "$cond" "$img" "$audio" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
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
  "model": "soulx-flashtalk",
  "phase": "Phase 4 long-audio official",
  "mode": "audio_encode_mode=stream",
  "cpu_offload": true,
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
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  local metrics="$LOG_DIR/${cond}.gpu_peak"
  local cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir $ROOT/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir $ROOT/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt '$SPEECH_PROMPT' --cond_image $img --audio_path $audio --audio_encode_mode stream --save_file $out --cpu_offload"
  local peak runtime audio_sec video_sec gpu_pid start_ts end_ts cmd_status
  record_existing_case "$cond" "$img" "$audio" "$cmd" "$out" "$log" "$metrics"
  if has_case_recorded "$cond"; then
    return 0
  fi
  rm -f "$log" "$out" "$metrics"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir "$ROOT/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B" --wav2vec_dir "$ROOT/models/SoulX-FlashTalk/models/chinese-wav2vec2-base" --input_prompt "$SPEECH_PROMPT" --cond_image "$img" --audio_path "$audio" --audio_encode_mode stream --save_file "$out" --cpu_offload >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  runtime=$((end_ts-start_ts))
  if [ "$cmd_status" -ne 0 ]; then
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return "$cmd_status"
  fi
  if [ ! -s "$out" ]; then
    echo "SoulX-FlashTalk output not found for $cond" >> "$log"
    append_failure "$cond" "$img" "$audio" "$cmd" "$log" "$runtime"
    return 1
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  audio_sec=$(audio_duration "$audio")
  video_sec=$(video_duration "$out")
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$runtime" >> "$log"
  append_result "$cond" "$img" "$audio" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_sec" "$video_sec"
}


main() {
  local failures=0
  ensure_results_md
  write_config_json
  # C_half_long skipped per user instruction
  run_case C_full_long "$ROOT/input/avatar_img/filtered/full_body/3.png" "$ROOT/input/audio/filtered/long/MT_eng.wav" || failures=1
  finalize_results "$failures"
  [ "$failures" -eq 0 ]
}

main "$@"
