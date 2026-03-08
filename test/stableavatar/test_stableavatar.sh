#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/stableavatar
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/stableavatar
ENV=/root/autodl-tmp/envs/stableavatar-env
OUTPUT_DIR=$TEST_DIR/output
TMP_DIR=$OUTPUT_DIR/stableavatar_tmp
OUT_MP4=$OUTPUT_DIR/stableavatar_minimal.mp4
LOG=$OUTPUT_DIR/stableavatar_minimal.log
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
PROMPT_FILE=$TEST_DIR/input/P011.txt
PROMPT=$(/root/miniconda3/bin/python -c "from pathlib import Path; print(Path('$PROMPT_FILE').read_text(encoding='utf-8').strip())")
mkdir -p "$OUTPUT_DIR"
rm -rf "$TMP_DIR"
rm -f "$OUT_MP4" "$LOG"
cd "$MODEL_DIR"
START_TS=$(date +%s)
/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python inference.py --config_path=deepspeed_config/wan2.1/wan_civitai.yaml --pretrained_model_name_or_path=weights/StableAvatar/Wan2.1-Fun-V1.1-1.3B-InP --transformer_path=weights/StableAvatar/StableAvatar-1.3B/transformer3d-square.pt --pretrained_wav2vec_path=weights/StableAvatar/wav2vec2-base-960h --validation_reference_path="$IMG" --validation_driven_audio_path="$AUDIO" --output_dir="$TMP_DIR" --validation_prompts "$PROMPT" --seed=42 --motion_frame=25 --sample_steps=50 --width=512 --height=512 --overlap_window_length=5 --clip_sample_n_frames=81 --GPU_memory_mode=model_full_load --sample_text_guide_scale=3.0 --sample_audio_guide_scale=5.0 >> "$LOG" 2>&1
ffmpeg -i "$TMP_DIR/video_without_audio.mp4" -i "$AUDIO" -c:v copy -c:a aac -shortest "$OUT_MP4" -y >> "$LOG" 2>&1
rm -rf "$TMP_DIR"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
