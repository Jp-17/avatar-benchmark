#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/fantasy-talking
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/fantasy-talking
ENV=/root/autodl-tmp/envs/fantasy-talking-env
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/fantasy_talking_minimal.log
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$LOG"
rm -f "$OUTPUT_DIR"/*.mp4
cd "$MODEL_DIR"
export CUDA_VISIBLE_DEVICES=0
export PYTHONPATH=$MODEL_DIR${PYTHONPATH:+:$PYTHONPATH}
source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV"
START_TS=$(date +%s)
python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path "$IMG" --audio_path "$AUDIO" --prompt "$PROMPT" --output_dir "$OUTPUT_DIR" --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42 >> "$LOG" 2>&1
SRC=$(find "$OUTPUT_DIR" -maxdepth 1 -name '*.mp4' -type f | head -1)
if [ -z "$SRC" ]; then
  echo "FantasyTalking output not found" >> "$LOG"
  exit 1
fi
mv "$SRC" "$OUTPUT_DIR/fantasy_talking_minimal.mp4"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUTPUT_DIR/fantasy_talking_minimal.mp4"
