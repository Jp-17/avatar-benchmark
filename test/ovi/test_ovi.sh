#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/ovi
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/Ovi
ENV=/root/autodl-tmp/envs/ovi-env
OUTPUT_DIR=$TEST_DIR/output
CONFIG=$TEST_DIR/inference_test.yaml
PROMPT_CSV=$TEST_DIR/test_prompt.csv
LOG=$OUTPUT_DIR/ovi_minimal.log
IMG=$TEST_DIR/input/I013.png
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*.mp4 "$CONFIG" "$PROMPT_CSV" "$LOG"
cat > "$PROMPT_CSV" <<EOF
text_prompt,image_path
"$PROMPT",$IMG
EOF
cat > "$CONFIG" <<EOF
ckpt_dir: /root/autodl-tmp/avatar-benchmark/models/Ovi/ckpts
output_dir: $OUTPUT_DIR
sample_steps: 30
solver_name: unipc
model_name: "960x960_10s"
shift: 5.0
sp_size: 1
audio_guidance_scale: 3.0
video_guidance_scale: 4.0
mode: "i2v"
fp8: False
cpu_offload: True
qint8: True
seed: 42
video_negative_prompt: "jitter, bad hands, blur, distortion"
audio_negative_prompt: "robotic, muffled, echo, distorted"
video_frame_height_width: [960, 960]
text_prompt: $PROMPT_CSV
slg_layer: 11
each_example_n_times: 1
EOF
cd "$MODEL_DIR"
START_TS=$(date +%s)
source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV"
python inference.py --config-file "$CONFIG" >> "$LOG" 2>&1
SRC=$(find "$OUTPUT_DIR" -maxdepth 1 -name '*.mp4' -type f | head -1)
if [ -z "$SRC" ]; then
  echo "Ovi output not found" >> "$LOG"
  exit 1
fi
mv "$SRC" "$OUTPUT_DIR/ovi_minimal.mp4"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUTPUT_DIR/ovi_minimal.mp4"
