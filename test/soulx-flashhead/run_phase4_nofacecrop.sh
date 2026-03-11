#!/bin/bash
set -euo pipefail
PROJ_ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$PROJ_ROOT/models/soulx-flashhead
PYTHON=/root/autodl-tmp/envs/flashhead-env/bin/python
export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1

run_one() {
  local model_type=$1
  local cond_name=$2
  local img=$3
  local audio=$4
  local output_dir=$PROJ_ROOT/output/soulx_flashhead_${model_type}_phase4_nofacecrop
  local output=$output_dir/${cond_name}.mp4
  mkdir -p $output_dir
  cd $MODEL_DIR
  echo "[$(date '+%H:%M:%S')] START $model_type $cond_name"
  CUDA_VISIBLE_DEVICES=0 $PYTHON generate_video.py \
    --ckpt_dir $MODEL_DIR/weights/SoulX-FlashHead-1_3B \
    --wav2vec_dir $MODEL_DIR/weights/wav2vec2-base-960h \
    --model_type $model_type \
    --cond_image $img \
    --audio_path $audio \
    --audio_encode_mode stream \
    --save_file $output
  echo "[$(date '+%H:%M:%S')] DONE $model_type $cond_name -> $(du -sh $output | cut -f1)"
}

# === Lite 4条件（不传 --use_face_crop，使用默认 False）===
run_one lite C_half_short \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/13.png" \
  "$PROJ_ROOT/input/audio/filtered/short/EM2_no_smoking.wav"
run_one lite C_half_long \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/2.png" \
  "$PROJ_ROOT/input/audio/filtered/long/A001.wav"
run_one lite C_full_short \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/1.png" \
  "$PROJ_ROOT/input/audio/filtered/short/S002_adele.wav"
run_one lite C_full_long \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/3.png" \
  "$PROJ_ROOT/input/audio/filtered/long/MT_eng.wav"

# === Pro 4条件（不传 --use_face_crop，使用默认 False）===
run_one pro C_half_short \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/13.png" \
  "$PROJ_ROOT/input/audio/filtered/short/EM2_no_smoking.wav"
run_one pro C_half_long \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/2.png" \
  "$PROJ_ROOT/input/audio/filtered/long/A001.wav"
run_one pro C_full_short \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/1.png" \
  "$PROJ_ROOT/input/audio/filtered/short/S002_adele.wav"
run_one pro C_full_long \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/3.png" \
  "$PROJ_ROOT/input/audio/filtered/long/MT_eng.wav"

echo "All done."
