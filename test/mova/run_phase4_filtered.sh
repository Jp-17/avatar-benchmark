#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/MOVA
ACTIVATE=/root/autodl-tmp/envs/mova-env/bin/activate
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/mova_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
CKPT=/root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion."
SING_PROMPT="A person singing to the camera with expressive facial animation, natural body rhythm, and strong performance energy."
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
  "model": "mova",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "num_frames": 97,
  "num_inference_steps": 30,
  "seed": 42,
  "offload": "cpu",
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
    "C_half_long": "MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。",
    "C_full_long": "MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# MOVA Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/mova/run_phase4_filtered.sh
- 配置文件：output/mova_newphase4/config.json
- 输出目录：output/mova_newphase4/
- 说明：参考 test/mova/test.md 的最小素材测试经验，沿用固定 97 帧的稳定路径，仅执行 text+image 的短时子集，并记录每个 condition 的命令、显存峰值与耗时。

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
- config 参数：见 output/mova_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/mova/test.md 中已验证的固定 97 帧短视频路径。
MD
}
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local prompt_type="$3"
  local prompt log out start_ts end_ts metrics gpu_pid peak cmd
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -f "$log" "$out" "$metrics"
  cmd="torchrun --nproc_per_node=1 scripts/inference_single.py --ckpt_path $CKPT --cp_size 1 --height 512 --width 512 --num_frames 97 --num_inference_steps 30 --prompt '$prompt' --ref_path $img --output_path $out --offload cpu --remove_video_dit --seed 42"
  cd "$MODEL_DIR"
  export PYTHONPATH=$MODEL_DIR${PYTHONPATH:+:$PYTHONPATH}
  export CUDA_VISIBLE_DEVICES=0
  source "$ACTIVATE"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  torchrun --nproc_per_node=1 scripts/inference_single.py --ckpt_path "$CKPT" --cp_size 1 --height 512 --width 512 --num_frames 97 --num_inference_steps 30 --prompt "$prompt" --ref_path "$img" --output_path "$out" --offload cpu --remove_video_dit --seed 42 >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。"
append_skip C_full_long "MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png singing
finalize_results_md
