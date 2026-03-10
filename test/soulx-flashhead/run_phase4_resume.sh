#!/bin/bash
# FlashHead Phase 4 续跑脚本：
# Lite C_full_short + C_full_long + Pro 全部 4 个 condition
set -euo pipefail

PROJ_ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$PROJ_ROOT/models/soulx-flashhead
PYTHON=/root/autodl-tmp/envs/flashhead-env/bin/python
LOGDIR=$PROJ_ROOT/test/soulx-flashhead
export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

run_one() {
  local model_type=$1
  local cond_name=$2
  local img=$3
  local audio=$4
  local use_face_crop_val=${5:-"False"}
  local output_dir=$PROJ_ROOT/output/soulx_flashhead_${model_type}_phase4
  local output=$output_dir/${cond_name}.mp4

  mkdir -p $output_dir
  log "=== 开始: $model_type/$cond_name ==="
  start_t=$(date +%s)

  cd $MODEL_DIR
  CUDA_VISIBLE_DEVICES=0 $PYTHON generate_video.py \
    --ckpt_dir $MODEL_DIR/weights/SoulX-FlashHead-1_3B \
    --wav2vec_dir $MODEL_DIR/weights/wav2vec2-base-960h \
    --model_type $model_type \
    --cond_image $img \
    --audio_path $audio \
    --audio_encode_mode stream \
    --use_face_crop $use_face_crop_val \
    --save_file $output

  end_t=$(date +%s)
  dur=$((end_t - start_t))
  vram=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  log "=== 完成: $model_type/$cond_name | 耗时: ${dur}s | 显存: ${vram}MiB ==="
  [ -f "$output" ] && log "输出大小: $(du -sh $output | cut -f1)"
}

log "=== Phase 4 续跑开始 ==="

# ---- Lite 补跑全身图 2 个 ----
log "--- Lite C_full_short ---"
run_one lite C_full_short \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/1.png" \
  "$PROJ_ROOT/input/audio/filtered/short/S002_adele.wav" \
  "True"

log "--- Lite C_full_long ---"
run_one lite C_full_long \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/3.png" \
  "$PROJ_ROOT/input/audio/filtered/long/MT_eng.wav" \
  "True"

# 生成 Lite results.md
cat > $PROJ_ROOT/output/soulx_flashhead_lite_phase4/results.md << 'RESULTSEOF'
# SoulX-FlashHead Lite Phase 4 结果

（由 run_phase4_resume.sh 生成，2026-03-11）

| Condition | 音频时长 | 输出大小 | 状态 |
|-----------|---------|---------|------|
| C_half_short | ~5.4s | 229K | ✅ |
| C_half_long | ~100s | 5.6M | ✅ |
| C_full_short | ~8.6s | 待填写 | ✅ |
| C_full_long | ~60s | 待填写 | ✅ |
RESULTSEOF

# ---- Pro 全部 4 个 ----
log "--- Pro C_half_short ---"
run_one pro C_half_short \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/13.png" \
  "$PROJ_ROOT/input/audio/filtered/short/EM2_no_smoking.wav" \
  "False"

log "--- Pro C_half_long ---"
run_one pro C_half_long \
  "$PROJ_ROOT/input/avatar_img/filtered/half_body/2.png" \
  "$PROJ_ROOT/input/audio/filtered/long/A001.wav" \
  "False"

log "--- Pro C_full_short ---"
run_one pro C_full_short \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/1.png" \
  "$PROJ_ROOT/input/audio/filtered/short/S002_adele.wav" \
  "True"

log "--- Pro C_full_long ---"
run_one pro C_full_long \
  "$PROJ_ROOT/input/avatar_img/filtered/full_body/3.png" \
  "$PROJ_ROOT/input/audio/filtered/long/MT_eng.wav" \
  "True"

log "=== Phase 4 续跑全部完成 ==="
