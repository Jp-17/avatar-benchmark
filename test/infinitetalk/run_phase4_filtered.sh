#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/InfiniteTalk
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
PY_DEPS=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449
ENV_SITE=/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and smooth upper-body motion."
SING_PROMPT="A person singing naturally to the camera with expressive mouth motion and rhythmic body movement."
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
  "model": "infinitetalk",
  "phase": "Phase 4",
  "size": "infinitetalk-480",
  "sample_steps": 8,
  "mode": "streaming",
  "motion_frame": 9,
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
    "C_half_long": "InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。",
    "C_full_long": "InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# InfiniteTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/infinitetalk/run_phase4_filtered.sh
- 配置文件：output/infinitetalk_newphase4/config.json
- 输出目录：output/infinitetalk_newphase4/
- 说明：参考 test/infinitetalk/test.md 的最小素材测试经验，沿用 infinitetalk-480 + 8 步 streaming 稳定路径，只执行短时子集，并记录命令、显存峰值与耗时。

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
  local cmd="$4"
  local out="$5"
  local log="$6"
  local peak="$7"
  local runtime="$8"
  local prompt_type="$9"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$audio + $img
- prompt 类型：$prompt_type
- 实际命令：$cmd
- config 参数：见 output/infinitetalk_newphase4/config.json 与 output/infinitetalk_newphase4/logs/${cond}.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：无新增问题，沿用 test/infinitetalk/test.md 中已验证的 image-input fallback + streaming 稳定路径。
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
  local prompt input_json log metrics prefix out cmd start_ts end_ts gpu_pid peak
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  input_json="$LOG_DIR/${cond}.json"
  log="$LOG_DIR/${cond}.log"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  prefix="$OUT_DIR/${cond}"
  out="$OUT_DIR/${cond}.mp4"
  rm -f "$input_json" "$log" "$metrics" "$out"
  cat > "$input_json" <<JSON
{
  "prompt": "$prompt",
  "cond_video": "$img",
  "cond_audio": {
    "person1": "$audio"
  }
}
JSON
  cmd="env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=$PY_DEPS:$ENV_SITE /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json $input_json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file $prefix"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH="$PY_DEPS:$ENV_SITE" /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json "$input_json" --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file "$prefix" >> "$log" 2>&1
  cmd_status=$?
  set -e
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    return "$cmd_status"
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  if [ ! -s "$out" ]; then
    echo "InfiniteTalk output not found for $cond" >> "$log"
    exit 1
  fi
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))" "$prompt_type"
}
write_config_json
init_results_md
append_skip C_half_long "InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。"
append_skip C_full_long "InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
