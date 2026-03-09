#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/OmniAvatar
ENV=/root/autodl-tmp/envs/omniavatar-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4
LOG_DIR=$OUT_DIR/logs
PROMPT_DIR=$OUT_DIR/prompts
RESULTS_MD=$OUT_DIR/results.md
SING_PROMPT="A person singing naturally to the camera with expressive facial animation, rhythmic motion, and strong performance energy."
mkdir -p "$OUT_DIR" "$LOG_DIR" "$PROMPT_DIR"
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
PROMPT_FILE="$PROMPT_DIR/C_full_short.txt"
INPUT_FILE="$LOG_DIR/C_full_short.infer.txt"
LOG="$LOG_DIR/C_full_short.log"
OUT="$OUT_DIR/C_full_short.mp4"
METRICS="$LOG_DIR/C_full_short.gpu_peak"
IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav
printf '%s\n' "$SING_PROMPT" > "$PROMPT_FILE"
printf '%s@@%s@@%s\n' "$SING_PROMPT" "$IMG" "$AUDIO" > "$INPUT_FILE"
rm -f "$LOG" "$OUT" "$METRICS"
mkdir -p "$MODEL_DIR/demo_out"
find "$MODEL_DIR/demo_out" -type f \( -name '*.mp4' -o -name '*.wav' \) -delete
source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV"
cd "$MODEL_DIR"
START_TS=$(date +%s)
GPU_PID=$(start_gpu_monitor "$METRICS")
set +e
torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file "$INPUT_FILE" >> "$LOG" 2>&1
CMD_STATUS=$?
set -e
END_TS=$(date +%s)
stop_gpu_monitor "$GPU_PID"
if [ "$CMD_STATUS" -ne 0 ]; then
  exit "$CMD_STATUS"
fi
SRC=$(find "$MODEL_DIR/demo_out" -name '*.mp4' -type f | sort | tail -1)
if [ -z "$SRC" ]; then
  echo "OmniAvatar output not found for C_full_short" >> "$LOG"
  exit 1
fi
cp "$SRC" "$OUT"
PEAK=$(cat "$METRICS" 2>/dev/null || echo 0)
echo "gpu_peak_mb=$PEAK" >> "$LOG"
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
/root/miniconda3/bin/python - <<'PY'
from pathlib import Path
results = Path('/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/results.md')
text = results.read_text()
old = '''### C_full_short
- 状态：❌ not_run
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/prompts/C_full_short.txt
- 跳过原因：首轮运行在 `C_half_short` 输出回收阶段中断，未进入 `C_full_short`。现已修正 `test/omniavatar/run_phase4_filtered.sh` 为递归查找 `demo_out` 嵌套结果，后续可直接补跑剩余条件。
'''
new = '''### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/prompts/C_full_short.txt
- 实际命令：conda activate /root/autodl-tmp/envs/omniavatar-env && torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_full_short.infer.txt
- config 参数：见 output/omniavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/C_full_short.mp4
- 显存峰值：{peak} MB
- 推理生成时间：{runtime} 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/omniavatar/test.md 中已验证的 `scripts/inference.py + configs/inference.yaml` 稳定路径，并继续使用 PATH 中的 ffmpeg。
'''.format(peak=Path('/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_full_short.gpu_peak').read_text().strip() or '0', runtime=(Path('/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_full_short.log').read_text().split('runtime_seconds=')[-1].splitlines()[0] if 'runtime_seconds=' in Path('/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_full_short.log').read_text() else '0'))
if old in text:
    text = text.replace(old, new)
text = text.replace('当前状态：部分完成，待复跑', '当前状态：已完成支持子集')
results.write_text(text)
PY
