#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk
ENV=/root/autodl-tmp/envs/flashtalk-env
OUTPUT_DIR=$TEST_DIR/output
LOG=$OUTPUT_DIR/soulx_flashtalk_minimal.log
OUT_MP4=$OUTPUT_DIR/soulx_flashtalk_minimal.mp4
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
set +e
/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt "$PROMPT" --cond_image "$IMG" --audio_path "$AUDIO" --audio_encode_mode stream --save_file "$OUT_MP4" --cpu_offload >> "$LOG" 2>&1
EXIT_CODE=$?
set -e
if [ ! -s "$OUT_MP4" ]; then
  exit $EXIT_CODE
fi
END_TS=$(date +%s)
echo "command_exit_code=$EXIT_CODE" >> "$LOG"
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
