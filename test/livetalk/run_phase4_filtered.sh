#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/livetalk
ENV=/root/autodl-tmp/envs/livetalk-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animations and synchronized lip movements to the music."
calc_duration() {
  local audio="$1"
  /root/miniconda3/bin/python - <<PY
import wave
path = r"$audio"
with wave.open(path, "rb") as wf:
    sec = wf.getnframes() / float(wf.getframerate())
allowed = min(254, int(sec))
while allowed > 2 and allowed % 3 != 2:
    allowed -= 1
if allowed <= 2:
    allowed = 2
print(allowed)
PY
}
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
  "model": "livetalk",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "fps": 16,
  "num_steps": 4,
  "seed": 42,
  "frame_seq_length": 1024,
  "num_frame_per_block": 3,
  "local_attn_size": 15,
  "conditions": {
    "C_half_short": {
      "image": "input/avatar_img/filtered/half_body/13.png",
      "audio": "input/audio/filtered/short/EM2_no_smoking.wav",
      "prompt_type": "speech",
      "video_duration": $(calc_duration /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav)
    },
    "C_half_long": {
      "image": "input/avatar_img/filtered/half_body/2.png",
      "audio": "input/audio/filtered/long/A001.wav",
      "prompt_type": "speech",
      "video_duration": $(calc_duration /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav)
    },
    "C_full_short": {
      "image": "input/avatar_img/filtered/full_body/1.png",
      "audio": "input/audio/filtered/short/S002_adele.wav",
      "prompt_type": "singing",
      "video_duration": $(calc_duration /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav)
    },
    "C_full_long": {
      "image": "input/avatar_img/filtered/full_body/3.png",
      "audio": "input/audio/filtered/long/MT_eng.wav",
      "prompt_type": "speech",
      "video_duration": $(calc_duration /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav)
    }
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LiveTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/livetalk/run_phase4_filtered.sh
- 配置文件：output/livetalk_newphase4/config.json
- 输出目录：output/livetalk_newphase4/
- 说明：本轮严格按 plan.md 4.2 的要求记录每个 Condition 的实际命令、素材路径、config 参数、输出路径、显存峰值、推理生成时间，以及失败经验与解决方法。

## 标准 Conditions
- C_half_short：input/audio/filtered/short/EM2_no_smoking.wav + input/avatar_img/filtered/half_body/13.png
- C_half_long：input/audio/filtered/long/A001.wav + input/avatar_img/filtered/half_body/2.png
- C_full_short：input/audio/filtered/short/S002_adele.wav + input/avatar_img/filtered/full_body/1.png
- C_full_long：input/audio/filtered/long/MT_eng.wav + input/avatar_img/filtered/full_body/3.png

## Condition 明细
MD
}
append_result() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local duration="$5"
  local cmd="$6"
  local out="$7"
  local log="$8"
  local peak="$9"
  local runtime="${10}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$audio + $img
- prompt 类型：$prompt_type
- video_duration：$duration
- 实际命令：
  \
$cmd
  \
- config 参数：见 `output/livetalk_newphase4/config.json` 与 `output/livetalk_newphase4/logs/${cond}.yaml`
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：无新增问题，沿用 test/livetalk/test.md 中已验证的 `frame_seq_length=1024` 与 `3n+2` 时长映射规则。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local config="$LOG_DIR/${cond}.yaml"
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  local metrics="$LOG_DIR/${cond}.gpu_peak"
  local prompt duration start_ts end_ts gpu_pid peak cmd
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  duration=$(calc_duration "$audio")
  cat > "$config" <<YAML
dtype: "bf16"
text_encoder_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/Wan-AI/Wan2.1-T2V-1.3B/models_t5_umt5-xxl-enc-bf16.pth
dit_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/LiveTalk-1.3B-V0.1/model.safetensors
vae_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/Wan-AI/Wan2.1-T2V-1.3B/Wan2.1_VAE.pth
wav2vec_path: /root/autodl-tmp/avatar-benchmark/models/livetalk/weights/wav2vec2
image_path: $img
audio_path: $audio
prompt: "$prompt"
output_path: $out
video_duration: $duration
max_hw: 720
image_sizes_720: [[512, 512]]
fps: 16
sample_rate: 16000
num_steps: 4
local_attn_size: 15
denoising_step_list: [1000, 750, 500, 250]
warp_denoising_step: true
num_transformer_blocks: 30
frame_seq_length: 1024
num_frame_per_block: 3
independent_first_frame: False
YAML
  rm -f "$out" "$log" "$metrics"
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env PYTHONPATH=$MODEL_DIR:$MODEL_DIR/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config $config"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env PYTHONPATH=$MODEL_DIR:$MODEL_DIR/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config "$config" >> "$log" 2>&1
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "video_duration=$duration" >> "$log"
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$duration" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_half_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
run_case C_full_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav speech
finalize_results_md
