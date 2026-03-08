#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LTX-2
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
WEIGHTS=/root/autodl-tmp/avatar-benchmark/models/LTX-2/weights
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
  "model": "ltx2",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "num_frames": 121,
  "frame_rate": 24,
  "seed": 42,
  "lora_strength": 0.0,
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
    "C_half_long": "LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。",
    "C_full_long": "LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LTX-2 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/ltx2/run_phase4_filtered.sh
- 配置文件：output/ltx2_newphase4/config.json
- 输出目录：output/ltx2_newphase4/
- 说明：参考 test/ltx2/test.md 的最小素材测试经验，沿用去掉 fp8-cast、LoRA 强度 0.0 的固定短帧稳定路径，只执行短时子集。

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
- config 参数：见 output/ltx2_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/ltx2/test.md 中已验证的去掉 fp8-cast 且 LoRA 强度 0.0 的短帧稳定路径。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
prepare_audio() {
  local input_audio="$1"
  local stereo_audio="$2"
  ffmpeg -nostdin -loglevel error -y -i "$input_audio" -ac 2 "$stereo_audio"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt log out stereo_audio start_ts end_ts metrics gpu_pid peak cmd cmd_status
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  stereo_audio="$LOG_DIR/${cond}_stereo.wav"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -f "$log" "$out" "$stereo_audio" "$metrics"
  prepare_audio "$audio" "$stereo_audio"
  cmd="python -m ltx_pipelines.a2vid_two_stage --checkpoint-path $WEIGHTS/ltx-2-19b-dev-fp8.safetensors --gemma-root $WEIGHTS --distilled-lora $WEIGHTS/ltx-2-19b-distilled-lora-384.safetensors 0.0 --spatial-upsampler-path $WEIGHTS/ltx-2-spatial-upscaler-x2-1.0.safetensors --audio-path $stereo_audio --image $img 0 1.0 --prompt '$prompt' --output-path $out --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42"
  cd "$MODEL_DIR"
  source .venv/bin/activate
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  python -m ltx_pipelines.a2vid_two_stage --checkpoint-path "$WEIGHTS/ltx-2-19b-dev-fp8.safetensors" --gemma-root "$WEIGHTS" --distilled-lora "$WEIGHTS/ltx-2-19b-distilled-lora-384.safetensors" 0.0 --spatial-upsampler-path "$WEIGHTS/ltx-2-spatial-upscaler-x2-1.0.safetensors" --audio-path "$stereo_audio" --image "$img" 0 1.0 --prompt "$prompt" --output-path "$out" --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42 >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  if [ ! -s "$out" ]; then
    echo "LTX-2 output not found for $cond" >> "$log"
    return 1
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。"
append_skip C_full_long "LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
