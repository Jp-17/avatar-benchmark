#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Ovi
ENV=/root/autodl-tmp/envs/ovi-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/ovi_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, clear lip movements, and a friendly welcoming gesture."
SING_PROMPT="A person singing expressively toward the camera with vivid facial animation, rhythmic lip movements, and performance energy."
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
  "model": "ovi",
  "phase": "Phase 4",
  "resolution": {"width": 960, "height": 960},
  "sample_steps": 30,
  "solver_name": "unipc",
  "model_name": "960x960_10s",
  "cpu_offload": true,
  "qint8": true,
  "seed": 42,
  "supported_conditions": {
    "C_half_short": {
      "image": "input/avatar_img/filtered/half_body/13.png",
      "prompt_type": "speech"
    },
    "C_full_short": {
      "image": "input/avatar_img/filtered/full_body/1.png",
      "prompt_type": "singing"
    }
  },
  "skipped_conditions": {
    "C_half_long": "Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。",
    "C_full_long": "Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# Ovi Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/ovi/run_phase4_filtered.sh
- 配置文件：output/ovi_newphase4/config.json
- 输出目录：output/ovi_newphase4/
- 说明：参考 test/ovi/test.md 的最小素材测试经验，沿用 960x960_10s + qint8 + cpu_offload 的稳定路径，只执行 text+image 的短时子集，并记录每个 condition 的命令、显存峰值与耗时。

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
  local prompt_type="$3"
  local cmd="$4"
  local out="$5"
  local log="$6"
  local peak="$7"
  local runtime="$8"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + ${prompt_type} prompt
- 实际命令：$cmd
- config 参数：见 output/ovi_newphase4/config.json 与 output/ovi_newphase4/logs/${cond}.yaml
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/ovi/test.md 中已验证的 qint8 + cpu_offload 稳定路径。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local prompt_type="$3"
  local prompt csv config tmp_dir log out src start_ts end_ts metrics gpu_pid peak cmd
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  csv="$LOG_DIR/${cond}.csv"
  config="$LOG_DIR/${cond}.yaml"
  tmp_dir="$OUT_DIR/${cond}_tmp"
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  rm -f "$csv" "$config" "$log" "$out" "$metrics"
  cat > "$csv" <<CSV
text_prompt,image_path
"$prompt",$img
CSV
  cat > "$config" <<YAML
ckpt_dir: /root/autodl-tmp/avatar-benchmark/models/Ovi/ckpts
output_dir: $tmp_dir
sample_steps: 30
solver_name: unipc
model_name: "960x960_10s"
shift: 5.0
sp_size: 1
audio_guidance_scale: 3.0
video_guidance_scale: 4.0
mode: "i2v"
fp8: False
cpu_offload: True
qint8: True
seed: 42
video_negative_prompt: "jitter, bad hands, blur, distortion"
audio_negative_prompt: "robotic, muffled, echo, distorted"
video_frame_height_width: [960, 960]
text_prompt: $csv
slg_layer: 11
each_example_n_times: 1
YAML
  cmd="python inference.py --config-file $config"
  cd "$MODEL_DIR"
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate "$ENV"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  python inference.py --config-file "$config" >> "$log" 2>&1
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  src=$(find "$tmp_dir" -maxdepth 1 -name '*.mp4' -type f | head -1)
  if [ -z "$src" ]; then
    echo "Ovi output not found for $cond" >> "$log"
    exit 1
  fi
  mv "$src" "$out"
  rm -rf "$tmp_dir"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。"
append_skip C_full_long "Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png singing
finalize_results_md
