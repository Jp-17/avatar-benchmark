#!/bin/bash
set -euo pipefail

TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/ltx2
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LTX-2
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/ltx23_minimal.log
OUT_MP4=$OUTPUT_DIR/ltx23_minimal.mp4
WEIGHTS=/root/autodl-tmp/avatar-benchmark/models/LTX-2/weights

IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
AUDIO_STEREO=$TEST_DIR/input/A007_5s_stereo.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt

PROMPT=$(python3 -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())" 2>/dev/null || cat "$PROMPT_FILE")

mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG" "$AUDIO_STEREO"

# Convert to stereo
ffmpeg -i "$AUDIO" -ac 2 "$AUDIO_STEREO" -y >/dev/null 2>&1

cd "$MODEL_DIR"
source .venv/bin/activate

echo "=== LTX-2.3 minimal inference test ===" > "$LOG"
echo "start_time=$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

START_TS=$(date +%s)

python -m ltx_pipelines.a2vid_two_stage \
  --checkpoint-path "$WEIGHTS/ltx-2.3-22b-dev.safetensors" \
  --gemma-root "$WEIGHTS/gemma-3-12b" \
  --distilled-lora "$WEIGHTS/ltx-2.3-22b-distilled-lora-384.safetensors" 0.8 \
  --spatial-upsampler-path "$WEIGHTS/ltx-2.3-spatial-upscaler-x2-1.1.safetensors" \
  --audio-path "$AUDIO_STEREO" \
  --image "$IMG" 0 1.0 \
  --prompt "$PROMPT" \
  --output-path "$OUT_MP4" \
  --height 512 --width 512 \
  --num-frames 121 --frame-rate 24 \
  --seed 42 >> "$LOG" 2>&1

END_TS=$(date +%s)

echo "end_time=$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"

# Record GPU peak memory
nvidia-smi --query-gpu=memory.used --format=csv,noheader >> "$LOG" 2>/dev/null

if [ -s "$OUT_MP4" ]; then
  echo "SUCCESS: output generated" >> "$LOG"
  ls -lh "$OUT_MP4"
else
  echo "FAIL: no output generated" >> "$LOG"
  exit 1
fi
