#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4
LOG_DIR=$OUT_DIR/logs
TMP_DIR=$OUT_DIR/tmp
RESULTS_MD=$OUT_DIR/results.md
ENV_SITE=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages
mkdir -p "$OUT_DIR" "$LOG_DIR" "$TMP_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion."
SING_PROMPT="A person singing naturally to the camera with expressive facial animation, rhythmic motion, and strong performance energy."
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
      if [ "$used" -gt "$max" ]; then max=$used; fi
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
  "model": "longcat-video-avatar",
  "phase": "Phase 4",
  "stage_1": "ai2v",
  "context_parallel_size": 1,
  "num_inference_steps": 8,
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
    "C_half_long": "LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。",
    "C_full_long": "LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# LongCat-Video-Avatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/longcat-video-avatar/run_phase4_filtered.sh
- 配置文件：output/longcat_video_avatar_newphase4/config.json
- 输出目录：output/longcat_video_avatar_newphase4/
- 说明：参考 test/longcat-video-avatar/test.md 的最小素材测试经验，沿用 base Python wrapper + context_parallel_size=1 + num_inference_steps=8 的稳定路径，只执行短时子集。

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
- config 参数：见 output/longcat_video_avatar_newphase4/config.json 与 output/longcat_video_avatar_newphase4/logs/${cond}.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/longcat-video-avatar/test.md 中已验证的 base Python wrapper + `PYTHONPATH` + `--context_parallel_size=1` 稳定路径。
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
  local prompt json log out metrics case_dir start_ts end_ts gpu_pid peak cmd cmd_status src
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  json="$LOG_DIR/${cond}.json"
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  case_dir="$TMP_DIR/${cond}"
  rm -rf "$case_dir"
  mkdir -p "$case_dir"
  rm -f "$log" "$out" "$metrics"
  cat > "$json" <<JSON
{
  "prompt": "$prompt",
  "cond_image": "$img",
  "cond_audio": {
    "person1": "$audio"
  }
}
JSON
  cmd="env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH=$ENV_SITE /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json $json --num_inference_steps 8 --output_dir $case_dir"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH="$ENV_SITE" /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json "$json" --num_inference_steps 8 --output_dir "$case_dir" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  src=$(find "$case_dir" -name '*.mp4' -type f | sort | tail -1)
  if [ -z "$src" ]; then
    echo "LongCat output not found for $cond" >> "$log"
    return 1
  fi
  cp "$src" "$out"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。"
append_skip C_full_long "LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
