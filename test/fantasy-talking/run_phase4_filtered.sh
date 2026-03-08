#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/fantasy-talking
ENV=/root/autodl-tmp/envs/fantasy-talking-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
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
  "model": "fantasy-talking",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "fps": 23,
  "max_num_frames": 81,
  "seed": 42,
  "audio_scale": 1.0,
  "prompt_cfg_scale": 5.0,
  "audio_cfg_scale": 5.0,
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
    "C_half_long": "FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。",
    "C_full_long": "FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# FantasyTalking Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/fantasy-talking/run_phase4_filtered.sh
- 配置文件：output/fantasy_talking_newphase4/config.json
- 输出目录：output/fantasy_talking_newphase4/
- 说明：参考 test/fantasy-talking/test.md 的最小素材测试经验，沿用已验证的短时配置，只执行短时子集。

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
- config 参数：见 output/fantasy_talking_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/fantasy-talking/test.md 中已验证的 81 帧短视频路径，长时条件暂不扩展。
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
  local prompt log tmp_dir out src start_ts end_ts metrics gpu_pid peak cmd cmd_status
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  tmp_dir="$OUT_DIR/${cond}_tmp"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  rm -f "$log" "$out" "$metrics"
  cmd="conda activate $ENV && python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path $img --audio_path $audio --prompt '$prompt' --output_dir $tmp_dir --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42"
  cd "$MODEL_DIR"
  export CUDA_VISIBLE_DEVICES=0
  export PYTHONPATH=$MODEL_DIR${PYTHONPATH:+:$PYTHONPATH}
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate "$ENV"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path "$img" --audio_path "$audio" --prompt "$prompt" --output_dir "$tmp_dir" --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42 >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  src=$(find "$tmp_dir" -maxdepth 1 -name "*.mp4" -type f | head -1)
  if [ -z "$src" ]; then
    echo "FantasyTalking output not found for $cond" >> "$log"
    return 1
  fi
  mv "$src" "$out"
  rm -rf "$tmp_dir"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。"
append_skip C_full_long "FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
