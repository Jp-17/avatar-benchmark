#!/bin/bash
# SoulX-FlashHead Phase 4 批推理脚本 - Lite 版本
# 4 个 condition，顺序执行

PROJ_ROOT=/root/autodl-tmp/avatar-benchmark
export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1
MODEL_DIR=$PROJ_ROOT/models/soulx-flashhead
PYTHON=/root/autodl-tmp/envs/flashhead-env/bin/python
OUTPUT_DIR=$PROJ_ROOT/output/soulx_flashhead_lite_phase4

mkdir -p $OUTPUT_DIR

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

run_condition() {
  local cond_name=$1
  local img=$2
  local audio=$3
  local use_face_crop=${4:-""}  # 可选参数
  local output=$OUTPUT_DIR/${cond_name}.mp4

  log "=== 开始: $cond_name ==="
  start_t=$(date +%s)

  cmd_args="--ckpt_dir $MODEL_DIR/weights/SoulX-FlashHead-1_3B \
    --wav2vec_dir $MODEL_DIR/weights/wav2vec2-base-960h \
    --model_type lite \
    --cond_image $img \
    --audio_path $audio \
    --audio_encode_mode stream \
    --save_file $output"

  if [ -n "$use_face_crop" ]; then
    cmd_args="$cmd_args --use_face_crop True"
  fi

  cd $MODEL_DIR
  CUDA_VISIBLE_DEVICES=0 $PYTHON generate_video.py $cmd_args

  end_t=$(date +%s)
  dur=$((end_t - start_t))
  vram=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  log "=== 完成: $cond_name | 耗时: ${dur}s | 显存: ${vram}MiB ==="
  if [ -f "$output" ]; then
    log "输出大小: $(du -sh $output | cut -f1)"
  fi
}

log "=== SoulX-FlashHead Lite Phase 4 开始 ==="

# C_half_short: 半身图 + 短音频(~5.4s)
run_condition "C_half_short" \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/13.png" \
  "$PROJ_ROOT/input/audio/filtered/short/EM2_no_smoking.wav"

# C_half_long: 半身图 + 长音频(~100s)
run_condition "C_half_long" \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/2.png" \
  "$PROJ_ROOT/input/audio/filtered/long/A001.wav"

# C_full_short: 全身图 + 短音频(~8.6s) + face_crop
run_condition "C_full_short" \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/1.png" \
  "$PROJ_ROOT/input/audio/filtered/short/S002_adele.wav" \
  "use_face_crop"

# C_full_long: 全身图 + 长音频(~60s) + face_crop
run_condition "C_full_long" \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/3.png" \
  "$PROJ_ROOT/input/audio/filtered/long/MT_eng.wav" \
  "use_face_crop"

log "=== SoulX-FlashHead Lite Phase 4 全部完成 ==="

# 生成 config.json
cat > $OUTPUT_DIR/config.json <<EOF
{
  "model": "SoulX-FlashHead-Lite",
  "model_type": "lite",
  "ckpt_dir": "weights/SoulX-FlashHead-1_3B",
  "wav2vec_dir": "weights/wav2vec2-base-960h",
  "audio_encode_mode": "stream",
  "conditions": [
    {"name": "C_half_short", "image": "input/avatar_img/filtered/half_body/13.png", "audio": "input/audio/filtered/short/EM2_no_smoking.wav"},
    {"name": "C_half_long", "image": "input/avatar_img/filtered/half_body/2.png", "audio": "input/audio/filtered/long/A001.wav"},
    {"name": "C_full_short", "image": "input/avatar_img/filtered/full_body/1.png", "audio": "input/audio/filtered/short/S002_adele.wav", "use_face_crop": true},
    {"name": "C_full_long", "image": "input/avatar_img/filtered/full_body/3.png", "audio": "input/audio/filtered/long/MT_eng.wav", "use_face_crop": true}
  ]
}
EOF

log "config.json 已生成"
