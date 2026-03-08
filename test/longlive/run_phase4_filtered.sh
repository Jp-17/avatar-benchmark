#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LongLive
ENV=sf-longlive-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4
LOG_DIR=$OUT_DIR/logs
PROMPT_DIR=$OUT_DIR/prompts
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR" "$PROMPT_DIR"
HALF_PROMPT="A waist-up portrait shot of a person speaking directly to the camera, natural facial expressions, subtle head motion, clean studio lighting."
FULL_PROMPT="A full-body shot of a person singing in front of the camera, expressive body movement, rhythmic performance, cinematic lighting."
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
  "model": "longlive",
  "phase": "Phase 4",
  "mode": "text-to-video",
  "num_output_frames": 21,
  "denoising_step_list": [1000, 750, 500, 250],
  "num_frame_per_block": 3,
  "condition_mapping": "LongLive 不支持 audio-driven，本轮使用 text-only prompt 分别映射 half/full shot 的短时语义。",
  "supported_conditions": {
    "C_half_short": {
      "prompt_file": "output/longlive_newphase4/prompts/C_half_short.txt",
      "prompt_text": "A waist-up portrait shot of a person speaking directly to the camera, natural facial expressions, subtle head motion, clean studio lighting."
    },
    "C_full_short": {
      "prompt_file": "output/longlive_newphase4/prompts/C_full_short.txt",
      "prompt_text": "A full-body shot of a person singing in front of the camera, expressive body movement, rhythmic performance, cinematic lighting."
    }
  },
  "skipped_conditions": {
    "C_half_long": "参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。",
    "C_full_long": "参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LongLive Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/longlive/run_phase4_filtered.sh
- 配置文件：output/longlive_newphase4/config.json
- 输出目录：output/longlive_newphase4/
- 说明：参考 test/longlive/test.md 的最小素材测试经验，沿用 text-only 21 帧稳定路径；由于模型不支持 audio-driven，本轮用 prompt 语义映射 half/full short 条件。

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
- config 参数：见 output/longlive_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/longlive/test.md 中已验证的 sf-longlive-env + shared Wan2.1-T2V-1.3B 稳定路径，并保留已补装的 `datasets` 依赖。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
write_prompt() {
  local path="$1"
  local text="$2"
  printf '%s\n' "$text" > "$path"
}
write_case_config() {
  local config_path="$1"
  local prompt_file="$2"
  local tmp_dir="$3"
  cat > "$config_path" <<YAML
denoising_step_list:
- 1000
- 750
- 500
- 250
warp_denoising_step: true
num_frame_per_block: 3
model_name: Wan2.1-T2V-1.3B
model_kwargs:
  local_attn_size: 12
  timestep_shift: 5.0
  sink_size: 3
data_path: $prompt_file
output_folder: $tmp_dir
inference_iter: -1
num_output_frames: 21
use_ema: false
seed: 0
num_samples: 1
save_with_index: true
global_sink: true
context_noise: 0
generator_ckpt: longlive_models/models/longlive_base.pt
lora_ckpt: longlive_models/models/lora.pt
adapter:
  type: lora
  rank: 256
  alpha: 256
  dropout: 0.0
  dtype: bfloat16
  verbose: false
YAML
}
run_case() {
  local cond="$1"
  local prompt_text="$2"
  local prompt_file="$PROMPT_DIR/${cond}.txt"
  local config_file="$LOG_DIR/${cond}.yaml"
  local tmp_dir="$OUT_DIR/${cond}_tmp"
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  local metrics="$LOG_DIR/${cond}.gpu_peak"
  local start_ts end_ts gpu_pid peak cmd cmd_status src
  write_prompt "$prompt_file" "$prompt_text"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  rm -f "$log" "$out" "$metrics" "$config_file"
  write_case_config "$config_file" "$prompt_file" "$tmp_dir"
  cmd="conda run --no-capture-output -n $ENV env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path $config_file"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -n "$ENV" env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path "$config_file" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  src=$(find "$tmp_dir" -maxdepth 1 -name '*.mp4' -type f | sort | head -1)
  if [ -z "$src" ]; then
    echo "LongLive output not found for $cond" >> "$log"
    return 1
  fi
  mv "$src" "$out"
  rm -rf "$tmp_dir"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$prompt_file" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。"
append_skip C_full_long "参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。"
run_case C_half_short "$HALF_PROMPT"
run_case C_full_short "$FULL_PROMPT"
finalize_results_md
