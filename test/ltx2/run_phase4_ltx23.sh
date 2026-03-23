#!/bin/bash
set -euo pipefail

MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LTX-2
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
WEIGHTS=/root/autodl-tmp/avatar-benchmark/models/LTX-2/weights
INPUT_BASE=/root/autodl-tmp/avatar-benchmark/input

mkdir -p "$OUT_DIR" "$LOG_DIR"

SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animation and synchronized mouth motion."
PYTHON_BIN=/root/autodl-tmp/avatar-benchmark/models/LTX-2/.venv/bin/python

start_gpu_monitor() {
  local metrics_file="$1"
  (
    max=0
    while true; do
      used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d " ")
      used=${used:-0}
      case "$used" in
        ""|*[!0-9]*) used=0 ;;
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
  "model": "ltx-2.3",
  "model_version": "22B",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "frame_rate": 24,
  "seed": 42,
  "lora_strength": 0.8,
  "checkpoint": "ltx-2.3-22b-dev.safetensors",
  "gemma_root": "weights/gemma-3-12b",
  "spatial_upsampler": "ltx-2.3-spatial-upscaler-x2-1.1.safetensors",
  "conditions": {
    "C_half_short": {
      "image": "input/avatar_img/filtered/half_body/13.png",
      "audio": "input/audio/filtered/short/EM2_no_smoking.wav",
      "prompt_type": "speech"
    },
    "C_half_long": {
      "image": "input/avatar_img/filtered/half_body/2.png",
      "audio": "input/audio/filtered/long/A001.wav",
      "prompt_type": "speech"
    },
    "C_full_short": {
      "image": "input/avatar_img/filtered/full_body/1.png",
      "audio": "input/audio/filtered/short/S002_adele.wav",
      "prompt_type": "singing"
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

init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LTX-2.3 Phase 4 结果记录

## 状态
- 当前状态：进行中
- 执行脚本：test/ltx2/run_phase4_ltx23.sh
- 配置文件：output/ltx23_newphase4/config.json
- 输出目录：output/ltx23_newphase4/
- 模型版本：LTX-2.3 (22B)
- 文本编码器：Gemma 3 12B QAT (Lightricks/gemma-3-12b-it-qat-q4_0-unquantized)
- LoRA 强度：0.8
- 帧数计算：num_frames = round(audio_sec * 24)

## Condition 明细
MD
}

append_result() {
  local cond="$1"
  local status="$2"
  local img="$3"
  local audio="$4"
  local prompt_type="$5"
  local out="$6"
  local log="$7"
  local peak="$8"
  local runtime="$9"
  local num_frames="${10}"
  local audio_dur="${11}"
  local video_dur="${12}"
  local note="${13:-}"

  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：${status}
- 素材：${img} + ${audio} + ${prompt_type} prompt
- 音频时长：${audio_dur}s
- 帧数：${num_frames}
- 输出路径：${out}
- 输出视频时长：${video_dur}s
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：${log}
${note:+- 备注：${note}}
MD
}

append_fail() {
  local cond="$1"
  local reason="$2"
  local log="$3"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：❌ failed
- 失败原因：${reason}
- 日志：${log}
MD
}

prepare_audio() {
  local input_audio="$1"
  local stereo_audio="$2"
  ffmpeg -nostdin -loglevel error -y -i "$input_audio" -ac 2 "$stereo_audio"
}

get_audio_duration() {
  local audio_file="$1"
  "$PYTHON_BIN" -c 'import sys, wave; f = wave.open(sys.argv[1], "rb"); print(f"{f.getnframes() / float(f.getframerate()):.2f}")' "$audio_file"
}

get_video_duration() {
  local num_frames="$1"
  "$PYTHON_BIN" -c 'import sys; print(f"{int(sys.argv[1]) / 24.0:.2f}")' "$num_frames"
}

calc_num_frames() {
  local audio_sec="$1"
  "$PYTHON_BIN" -c 'import sys; print(max(121, round(float(sys.argv[1]) * 24)))' "$audio_sec"
}

run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"

  local prompt log out stereo_audio start_ts end_ts metrics gpu_pid peak cmd_status
  local audio_dur num_frames video_dur

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

  echo "=== $cond ===" > "$log"
  echo "start_time=$(date '+%Y-%m-%d %H:%M:%S')" >> "$log"

  prepare_audio "$audio" "$stereo_audio"
  audio_dur=$(get_audio_duration "$stereo_audio")
  num_frames=$(calc_num_frames "$audio_dur")

  echo "audio_duration=${audio_dur}s" >> "$log"
  echo "num_frames=${num_frames}" >> "$log"

  cd "$MODEL_DIR"
  source .venv/bin/activate

  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")

  set +e
  python -m ltx_pipelines.a2vid_two_stage     --checkpoint-path "$WEIGHTS/ltx-2.3-22b-dev.safetensors"     --gemma-root "$WEIGHTS/gemma-3-12b"     --distilled-lora "$WEIGHTS/ltx-2.3-22b-distilled-lora-384.safetensors" 0.8     --spatial-upsampler-path "$WEIGHTS/ltx-2.3-spatial-upscaler-x2-1.1.safetensors"     --audio-path "$stereo_audio"     --image "$img" 0 1.0     --prompt "$prompt"     --output-path "$out"     --height 512 --width 512     --num-frames "$num_frames"     --frame-rate 24     --seed 42 >> "$log" 2>&1
  cmd_status=$?
  set -e

  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"

  echo "end_time=$(date '+%Y-%m-%d %H:%M:%S')" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"

  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"

  if [ "$cmd_status" -ne 0 ] || [ ! -s "$out" ]; then
    echo "FAIL: exit_code=$cmd_status" >> "$log"
    append_fail "$cond" "exit_code=$cmd_status" "$log"
    return 0
  fi

  video_dur=$(get_video_duration "$num_frames")
  echo "video_duration=${video_dur}s" >> "$log"

  append_result "$cond" "✅ done" "$img" "$audio" "$prompt_type" "$out" "$log" "$peak" "$((end_ts-start_ts))" "$num_frames" "$audio_dur" "$video_dur"
}

write_config_json
init_results_md

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting LTX-2.3 Phase 4..."

run_case C_half_short   "$INPUT_BASE/avatar_img/filtered/half_body/13.png"   "$INPUT_BASE/audio/filtered/short/EM2_no_smoking.wav"   speech

run_case C_half_long   "$INPUT_BASE/avatar_img/filtered/half_body/2.png"   "$INPUT_BASE/audio/filtered/long/A001.wav"   speech

run_case C_full_short   "$INPUT_BASE/avatar_img/filtered/full_body/1.png"   "$INPUT_BASE/audio/filtered/short/S002_adele.wav"   singing

run_case C_full_long   "$INPUT_BASE/avatar_img/filtered/full_body/3.png"   "$INPUT_BASE/audio/filtered/long/MT_eng.wav"   speech

perl -0pi -e 's/当前状态：进行中/当前状态：已完成/' "$RESULTS_MD"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] LTX-2.3 Phase 4 complete."
