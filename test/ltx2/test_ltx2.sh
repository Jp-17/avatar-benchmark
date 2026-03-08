#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/ltx2
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/LTX-2
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/ltx2_minimal.log
OUT_MP4=$OUTPUT_DIR/ltx2_minimal.mp4
WEIGHTS=/root/autodl-tmp/avatar-benchmark/models/LTX-2/weights
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
AUDIO_STEREO=$TEST_DIR/input/A007_5s_stereo.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG" "$AUDIO_STEREO"
ffmpeg -i "$AUDIO" -ac 2 "$AUDIO_STEREO" -y >/dev/null 2>&1
cd "$MODEL_DIR"
source .venv/bin/activate
START_TS=$(date +%s)
python -m ltx_pipelines.a2vid_two_stage --checkpoint-path "$WEIGHTS/ltx-2-19b-dev-fp8.safetensors" --gemma-root "$WEIGHTS" --distilled-lora "$WEIGHTS/ltx-2-19b-distilled-lora-384.safetensors" 0.0 --spatial-upsampler-path "$WEIGHTS/ltx-2-spatial-upscaler-x2-1.0.safetensors" --audio-path "$AUDIO_STEREO" --image "$IMG" 0 1.0 --prompt "$PROMPT" --output-path "$OUT_MP4" --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42 >> "$LOG" 2>&1
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
