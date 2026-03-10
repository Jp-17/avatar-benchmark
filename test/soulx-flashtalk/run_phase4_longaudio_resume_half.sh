#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk
ENV=/root/autodl-tmp/envs/flashtalk-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio
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
get_duration_seconds() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo ""
    return 0
  fi
  { ffmpeg -i "$file" 2>&1 || true; } | awk -F'[: ,]+' '/Duration:/{printf "%.3f", ($2 * 3600) + ($3 * 60) + $4; exit}'
}
get_runtime_from_log() {
  local log="$1"
  /root/miniconda3/bin/python3 - "$log" <<'PY'
import re, sys
from datetime import datetime
text = open(sys.argv[1], 'r', encoding='utf-8', errors='ignore').read()
values = re.findall(r'(20\d\d-\d\d-\d\d \d\d:\d\d:\d\d\.\d+)', text)
if len(values) < 2:
    print('0')
    raise SystemExit(0)
start = datetime.strptime(values[0], '%Y-%m-%d %H:%M:%S.%f')
end = datetime.strptime(values[-1], '%Y-%m-%d %H:%M:%S.%f')
print(int((end - start).total_seconds()))
PY
}
ensure_results_md() {
  if [ -f "$RESULTS_MD" ]; then
    return 0
  fi
  cat > "$RESULTS_MD" <<'MD'
# SoulX-FlashTalk Phase 4 长音频探针结果

## 状态
- 当前状态：进行中
- 执行脚本：test/soulx-flashtalk/run_phase4_longaudio.sh
- 配置文件：output/soulx_flashtalk_newphase4_longaudio/config.json
- 输出目录：output/soulx_flashtalk_newphase4_longaudio/
- 参考短时目录：output/soulx_flashtalk_newphase4/
- 说明：沿用 generate_video.py + audio_encode_mode=stream + cpu_offload 的稳定链路，直接验证 Phase 4 长音频条件是否能扩展到接近音频原始时长。

## Condition 明细
MD
}
has_case_recorded() {
  local cond="$1"
  grep -q "^### ${cond}$" "$RESULTS_MD" 2>/dev/null
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
  local audio_duration="${10}"
  local video_duration="${11}"
  local delta="${12}"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：✅ done
- 素材：$img + $audio + ${prompt_type} prompt
- 实际命令：$cmd
- 输出路径：$out
- 音频时长：${audio_duration} 秒
- 视频时长：${video_duration} 秒
- 时长差（视频-音频）：${delta} 秒
- 显存峰值：${peak} MB
- 推理生成时间：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：长音频探针成功完成，可继续据此评估是否纳入正式长音频批跑。
MD
}
append_failure() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local cmd="$5"
  local log="$6"
  local runtime="$7"
  cat >> "$RESULTS_MD" <<MD

### ${cond}
- 状态：❌ failed
- 素材：$img + $audio + ${prompt_type} prompt
- 实际命令：$cmd
- 推理耗时：${runtime} 秒
- 日志：$log
- 失败经验与解决方法：长音频探针执行失败，需结合日志继续排查。
MD
}
record_existing_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local cmd="$5"
  local out="$6"
  local log="$7"
  local metrics="$8"
  local peak runtime audio_duration video_duration delta
  if has_case_recorded "$cond"; then
    echo "[$(date '+%F %T')] SKIP record $cond already_present"
    return 0
  fi
  if [ ! -s "$out" ]; then
    echo "[$(date '+%F %T')] SKIP record $cond missing_output"
    return 0
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  runtime=$(get_runtime_from_log "$log")
  audio_duration=$(get_duration_seconds "$audio")
  video_duration=$(get_duration_seconds "$out")
  delta=$(/root/miniconda3/bin/python3 - <<PY
from decimal import Decimal
video = Decimal('${video_duration:-0}')
audio = Decimal('${audio_duration:-0}')
print(f"{video - audio:.3f}")
PY
)
  echo "gpu_peak_mb=$peak" >> "$log"
  echo "runtime_seconds=$runtime" >> "$log"
  echo "audio_duration_seconds=$audio_duration" >> "$log"
  echo "video_duration_seconds=$video_duration" >> "$log"
  echo "duration_delta_seconds=$delta" >> "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_duration" "$video_duration" "$delta"
  echo "[$(date '+%F %T')] RECORDED $cond runtime=${runtime}s audio=${audio_duration}s video=${video_duration}s delta=${delta}s"
}
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt_type="$4"
  local prompt log out start_ts end_ts metrics gpu_pid peak cmd cmd_status runtime audio_duration video_duration delta
  if has_case_recorded "$cond"; then
    echo "[$(date '+%F %T')] SKIP $cond already_recorded"
    return 0
  fi
  if [ "$prompt_type" = "singing" ]; then
    prompt="$SING_PROMPT"
  else
    prompt="$SPEECH_PROMPT"
  fi
  log="$LOG_DIR/${cond}.log"
  out="$OUT_DIR/${cond}.mp4"
  metrics="$LOG_DIR/${cond}.gpu_peak"
  rm -f "$log" "$out" "$metrics"
  cmd="/root/miniconda3/bin/conda run --no-capture-output -p $ENV env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt '$prompt' --cond_image $img --audio_path $audio --audio_encode_mode stream --save_file $out --cpu_offload"
  cd "$MODEL_DIR"
  echo "[$(date '+%F %T')] START $cond"
  echo "[$(date '+%F %T')] CMD $cmd"
  start_ts=$(date +%s)
  gpu_pid=$(start_gpu_monitor "$metrics")
  set +e
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt "$prompt" --cond_image "$img" --audio_path "$audio" --audio_encode_mode stream --save_file "$out" --cpu_offload 2>&1 | tee -a "$log"
  cmd_status=${PIPESTATUS[0]}
  set -e
  end_ts=$(date +%s)
  runtime=$((end_ts-start_ts))
  stop_gpu_monitor "$gpu_pid"
  if [ "$cmd_status" -ne 0 ]; then
    append_failure "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$log" "$runtime"
    echo "[$(date '+%F %T')] FAIL $cond status=$cmd_status"
    return "$cmd_status"
  fi
  if [ ! -s "$out" ]; then
    echo "SoulX-FlashTalk output not found for $cond" | tee -a "$log"
    append_failure "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$log" "$runtime"
    echo "[$(date '+%F %T')] FAIL $cond output_missing"
    return 1
  fi
  peak=$(cat "$metrics" 2>/dev/null || echo 0)
  audio_duration=$(get_duration_seconds "$audio")
  video_duration=$(get_duration_seconds "$out")
  delta=$(/root/miniconda3/bin/python3 - <<PY
from decimal import Decimal
video = Decimal('${video_duration:-0}')
audio = Decimal('${audio_duration:-0}')
print(f"{video - audio:.3f}")
PY
)
  echo "gpu_peak_mb=$peak" | tee -a "$log"
  echo "runtime_seconds=$runtime" | tee -a "$log"
  echo "audio_duration_seconds=$audio_duration" | tee -a "$log"
  echo "video_duration_seconds=$video_duration" | tee -a "$log"
  echo "duration_delta_seconds=$delta" | tee -a "$log"
  append_result "$cond" "$img" "$audio" "$prompt_type" "$cmd" "$out" "$log" "$peak" "$runtime" "$audio_duration" "$video_duration" "$delta"
  echo "[$(date '+%F %T')] DONE $cond runtime=${runtime}s audio=${audio_duration}s video=${video_duration}s delta=${delta}s"
}
ensure_results_md
record_existing_case C_full_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav singing "/root/miniconda3/bin/conda run --no-capture-output -p $ENV env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt '$SING_PROMPT' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/C_full_long.mp4 --cpu_offload" /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/C_full_long.mp4 /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/logs/C_full_long.log /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/logs/C_full_long.gpu_peak
run_case C_half_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav speech
perl -0pi -e 's/当前状态：进行中/当前状态：长音频探针完成/' "$RESULTS_MD"
