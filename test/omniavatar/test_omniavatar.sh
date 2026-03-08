#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/omniavatar
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/OmniAvatar
ENV=/root/autodl-tmp/envs/omniavatar-env
OUTPUT_DIR=$TEST_DIR/output
INPUT_FILE=$TEST_DIR/infer_samples.txt
LOG=$OUTPUT_DIR/omniavatar_minimal.log
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$INPUT_FILE" "$LOG"
rm -f "$OUTPUT_DIR"/*.mp4
printf '%s@@%s@@%s
' "$PROMPT" "$IMG" "$AUDIO" > "$INPUT_FILE"
cd "$MODEL_DIR"
START_TS=$(date +%s)
source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV"
torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file "$INPUT_FILE" >> "$LOG" 2>&1
SRC=$(find "$MODEL_DIR/demo_out" -name '*.mp4' -type f | sort | tail -1)
if [ -z "$SRC" ]; then
  echo "OmniAvatar output not found" >> "$LOG"
  exit 1
fi
cp "$SRC" "$OUTPUT_DIR/omniavatar_minimal.mp4"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUTPUT_DIR/omniavatar_minimal.mp4"
