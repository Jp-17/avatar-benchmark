#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Wan2.2
ENV=/root/autodl-tmp/envs/wan2.2-env
CKPT=/root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-S2V-14B
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4
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
  "model": "wan2.2-s2v",
  "phase": "Phase 4",
  "resolution": {"width": 832, "height": 480},
  "task": "s2v-14B",
  "offload_model": true,
  "seed": 42,
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
    "C_half_long": "参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。",
    "C_full_long": "参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# Wan2.2-S2V Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/wan2.2-s2v/run_phase4_filtered.sh
- 配置文件：output/wan22_s2v_newphase4/config.json
- 输出目录：output/wan22_s2v_newphase4/
- 说明：参考 test/wan2.2-s2v/test.md 的最小素材测试经验，沿用已验证的 832x480 稳定路径，只执行短时子集，并记录每个 condition 的命令、显存峰值与耗时。

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
- 素材：$audio + $img
- prompt 类型：$prompt_type
- 实际命令：$cmd
- config 参数：见 output/wan22_s2v_newphase4/config.json
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：沿用 test/wan2.2-s2v/test.md 中已验证的 832x480 稳定路径。
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
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir $CKPT --offload_model True --convert_model_dtype --prompt '$prompt' --image $img --audio $audio --save_file $out --num_clip 1"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir "$CKPT" --offload_model True --convert_model_dtype --prompt "$prompt" --image "$img" --audio "$audio" --save_file "$out" --num_clip 1 >> "$log" 2>&1
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
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。"
append_skip C_full_long "参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
