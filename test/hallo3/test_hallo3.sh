#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/hallo3
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/hallo3
ENV=/root/autodl-tmp/envs/hallo3-env
OUTPUT_DIR=${OUTPUT_DIR:-$TEST_DIR/output}
TMP_DIR=${TMP_DIR:-$OUTPUT_DIR/hallo3_tmp}
OUT_MP4=${OUT_MP4:-$OUTPUT_DIR/hallo3_minimal.mp4}
INPUT_TXT=${INPUT_TXT:-$TEST_DIR/input/minimal_input.txt}
LOG=${LOG:-$OUTPUT_DIR/hallo3_minimal.log}
IMG=${IMG:-$TEST_DIR/input/I013.png}
AUDIO=${AUDIO:-$TEST_DIR/input/A007_5s.wav}
PROMPT_FILE=${PROMPT_FILE:-$TEST_DIR/input/P011.txt}
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -rf "$TMP_DIR"
rm -f "$OUT_MP4" "$INPUT_TXT" "$LOG"
printf '%s@@%s@@%s\n' "$PROMPT" "$IMG" "$AUDIO" > "$INPUT_TXT"
cd "$MODEL_DIR"
START_TS=$(date +%s)
WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" python hallo3/sample_video.py --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml --seed 42 --input-file "$INPUT_TXT" --output-dir "$TMP_DIR" >> "$LOG" 2>&1
SRC=$(find "$TMP_DIR" -name '*_with_audio.mp4' -type f | head -1)
if [ -z "$SRC" ]; then
  echo "Hallo3 output not found" >> "$LOG"
  exit 1
fi
TMP_MP4=${TMP_MP4:-${OUT_MP4%.mp4}.aac.mp4}
rm -f "$TMP_MP4"
if ffmpeg -y -i "$SRC" -c:v copy -c:a aac -b:a 192k -movflags +faststart "$TMP_MP4" >> "$LOG" 2>&1; then
  mv "$TMP_MP4" "$OUT_MP4"
else
  echo "AAC remux failed, fallback to original mp4 container" >> "$LOG"
  rm -f "$TMP_MP4"
  mv "$SRC" "$OUT_MP4"
fi
rm -rf "$TMP_DIR"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
