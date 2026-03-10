#!/bin/bash
set -u -o pipefail
ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$ROOT/models/Wan2.2
ENV=/root/autodl-tmp/envs/wan2.2-env
CKPT=$MODEL_DIR/weights/Wan2.2-S2V-14B
OUT_DIR=$ROOT/output/wan22_s2v_newphase4_fullaudio
LOG_DIR=$OUT_DIR/logs
RESULTS_MD=$OUT_DIR/results.md
UTILS=$ROOT/test/phase4_fullaudio_utils.sh
source "$UTILS"
mkdir -p "$OUT_DIR" "$LOG_DIR"
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animation and synchronized mouth motion."
write_config_json() {
  cat > "$OUT_DIR/config.json" <<'JSON'
{
  "model": "wan2.2-s2v",
  "phase": "Phase 4 full-audio rerun",
  "baseline_output": "output/wan22_s2v_newphase4/",
  "description": "沿用 test/wan2.2-s2v/test.md 的稳定路径，仅将短时条件的 infer_frames 按原始音频时长扩展。",
  "sample_fps": 16,
  "align_multiple": 4,
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
  }
}
JSON
}
init_results_md() {
  cat > "$RESULTS_MD" <<'MD'
# Wan2.2-S2V Phase 4 原始音频时长补跑

## 状态
- 当前状态：进行中
- 执行脚本：test/wan2.2-s2v/run_phase4_fullaudio.sh
- 配置文件：output/wan22_s2v_newphase4_fullaudio/config.json
- 输出目录：output/wan22_s2v_newphase4_fullaudio/
- 基线目录：output/wan22_s2v_newphase4/
- 说明：沿用 test/wan2.2-s2v/test.md 的稳定命令，仅将短时子集按原始音频时长重算 `infer_frames`。

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
  local infer_frames="$5"
  local audio_sec="$6"
  local output_sec="$7"
  local cmd="$8"
  local out="$9"
  local log="${10}"
  local peak="${11}"
  local runtime="${12}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$audio + $img + ${prompt_type} prompt
- 源音频时长：${audio_sec} 秒
- 推理帧数：${infer_frames}
- 输出视频时长：${output_sec} 秒
- 实际命令：$cmd
- 输出路径：$out
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
MD
}
append_failure() {
  local cond="$1"
  local audio_sec="$2"
  local infer_frames="$3"
  local log="$4"
  local runtime="$5"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：❌ failed
- 源音频时长：${audio_sec} 秒
- 推理帧数：${infer_frames}
- 推理生成时间：${runtime} 秒
- 日志：$log
MD
}
finalize_ok() {
  perl -0pi -e 's/当前状态：进行中/当前状态：已完成按原始音频时长补跑/' "$RESULTS_MD"
}
finalize_partial() {
  perl -0pi -e 's/当前状态：进行中/当前状态：部分失败（原始音频时长补跑未全过）/' "$RESULTS_MD"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt log out metrics case_json start_ts end_ts gpu_pid peak cmd_status infer_frames audio_sec output_sec cmd
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  case_json="$LOG_DIR/${cond}.json"
  audio_sec=$(audio_duration "$audio")
  infer_frames=$(frames_for_audio "$audio" 16 4)
  cat > "$case_json" <<JSON
{
  "condition": "$cond",
  "image": "$img",
  "audio": "$audio",
  "prompt_type": "$prompt_type",
  "audio_duration_s": $audio_sec,
  "infer_frames": $infer_frames,
  "sample_fps": 16
}
JSON
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir $CKPT --offload_model True --convert_model_dtype --prompt '$prompt' --image $img --audio $audio --save_file $out --num_clip 1 --infer_frames $infer_frames"
  rm -f "$log" "$metrics"
  if [ -s "$out" ]; then
    output_sec=$(video_duration "$out")
    append_result "$cond" "$img" "$audio" "$prompt_type" "$infer_frames" "$audio_sec" "$output_sec" "$cmd" "$out" "$log" "reuse" "0"
    return 0
  fi
  cd "$MODEL_DIR" || return 1
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir "$CKPT" --offload_model True --convert_model_dtype --prompt "$prompt" --image "$img" --audio "$audio" --save_file "$out" --num_clip 1 --infer_frames "$infer_frames" >> "$log" 2>&1
  cmd_status=$?
  end_ts=$(date +%s)
  stop_gpu_monitor "$gpu_pid"
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  if [ "$cmd_status" -eq 0 ] && [ -s "$out" ]; then
    output_sec=$(video_duration "$out")
    append_result "$cond" "$img" "$audio" "$prompt_type" "$infer_frames" "$audio_sec" "$output_sec" "$cmd" "$out" "$log" "$peak" "$((end_ts-start_ts))"
    return 0
  fi
  append_failure "$cond" "$audio_sec" "$infer_frames" "$log" "$((end_ts-start_ts))"
  return 1
}
main() {
  local failures=0
  write_config_json
  init_results_md
  append_skip C_half_long "本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。"
  append_skip C_full_long "本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。"
  run_case C_half_short "$ROOT/input/avatar_img/filtered/half_body/13.png" "$ROOT/input/audio/filtered/short/EM2_no_smoking.wav" speech || failures=1
  run_case C_full_short "$ROOT/input/avatar_img/filtered/full_body/1.png" "$ROOT/input/audio/filtered/short/S002_adele.wav" singing || failures=1
  if [ "$failures" -eq 0 ]; then
    finalize_ok
    return 0
  fi
  finalize_partial
  return 1
}
main "$@"
