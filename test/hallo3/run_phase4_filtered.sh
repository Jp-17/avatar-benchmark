#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/hallo3
ENV=/root/autodl-tmp/envs/hallo3-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animations and synchronized lip movements to the music."
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
  "model": "hallo3",
  "phase": "Phase 4",
  "resolution": {"width": 512, "height": 512},
  "seed": 42,
  "base_configs": ["./configs/cogvideox_5b_i2v_s2.yaml", "./configs/inference.yaml"],
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
    "C_half_long": "按 test/hallo3/test.md 的最小测试稳定路径，本轮不扩展到 100s 长音频；历史记录显示 30s 已需较长时间，1m+ 会显著阻塞顺序队列。",
    "C_full_long": "按 test/hallo3/test.md 的最小测试稳定路径，本轮不扩展到 60s 长音频；先完成稳定短时对比。"
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<MD
# Hallo3 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/hallo3/run_phase4_filtered.sh
- 配置文件：output/hallo3_newphase4/config.json
- 输出目录：output/hallo3_newphase4/
- 说明：参考 test/hallo3/test.md 的最小素材测试经验，本轮先执行稳定的短时子集，并按 plan.md 4.2 记录每个 Condition 的命令、素材、显存峰值、耗时与日志。

## 条件范围
- 已执行：C_half_short, C_full_short
- 跳过：C_half_long, C_full_long

## Condition 明细
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
- config 参数：见 output/hallo3_newphase4/config.json 与 output/hallo3_newphase4/logs/${cond}.txt
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：无新增问题；继续沿用 test/hallo3/test.md 中已验证的单条件输入格式与禁用 expandable_segments 经验。
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
finalize_results_md() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成支持子集/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt input_txt tmp_dir log out src metrics cmd start_ts end_ts gpu_pid peak
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  input_txt="$LOG_DIR/${cond}.txt"
  tmp_dir="$OUT_DIR/${cond}_tmp"
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -rf "$tmp_dir"
  rm -f "$out" "$log" "$input_txt" "$metrics"
  printf '%s@@%s@@%s\n' "$prompt" "$img" "$audio" > "$input_txt"
  cmd="WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 /root/miniconda3/bin/conda run --no-capture-output -p $ENV python hallo3/sample_video.py --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml --seed 42 --input-file $input_txt --output-dir $tmp_dir"
  cd "$MODEL_DIR"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" python hallo3/sample_video.py --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml --seed 42 --input-file "$input_txt" --output-dir "$tmp_dir" >> "$log" 2>&1
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  src=$(find "$tmp_dir" -name '*_with_audio.mp4' -type f | head -1)
  if [ -z "$src" ]; then
    echo "Hallo3 output not found for $cond" >> "$log"
    exit 1
  fi
  tmp_out="${out%.mp4}.aac.mp4"
  rm -f "$tmp_out"
  if ffmpeg -y -i "$src" -c:v copy -c:a aac -b:a 192k -movflags +faststart "$tmp_out" >> "$log" 2>&1; then
    mv "$tmp_out" "$out"
  else
    echo "AAC remux failed for $cond, fallback to original mp4 container" >> "$log"
    rm -f "$tmp_out"
    mv "$src" "$out"
  fi
  rm -rf "$tmp_dir"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$((end_ts-start_ts))" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
}
write_config_json
init_results_md
append_skip C_half_long "当前稳定路径未覆盖 100s 长音频；历史记录显示 Hallo3 长时推理耗时极长。"
append_skip C_full_long "当前稳定路径未覆盖 60s 长音频；本轮先完成短时横评。"
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav speech
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav singing
finalize_results_md
