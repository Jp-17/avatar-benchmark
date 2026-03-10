#!/bin/bash
# SoulX-FlashHead Pro 最小测试脚本
# 测试条件：I013.png + A007_5s.wav (~5s)
set -e

PROJ_ROOT=/root/autodl-tmp/avatar-benchmark
MODEL_DIR=$PROJ_ROOT/models/soulx-flashhead
PYTHON=/root/autodl-tmp/envs/flashhead-env/bin/python

echo "=== SoulX-FlashHead Pro 最小测试 ==="
echo "开始时间: $(date)"
start_time=$(date +%s)

cd $MODEL_DIR

XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 CUDA_VISIBLE_DEVICES=0 \
$PYTHON generate_video.py \
  --ckpt_dir weights/SoulX-FlashHead-1_3B \
  --wav2vec_dir weights/wav2vec2-base-960h \
  --model_type pro \
  --cond_image $PROJ_ROOT/test/soulx-flashhead/input/I013.png \
  --audio_path $PROJ_ROOT/test/soulx-flashhead/input/A007_5s.wav \
  --audio_encode_mode stream \
  --save_file $PROJ_ROOT/test/soulx-flashhead/output/pro/flashhead_pro_minimal.mp4

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "结束时间: $(date)"
echo "耗时: ${duration}s"

# 记录峰值显存
echo "显存使用: $(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits) MiB"

# 输出视频信息
if [ -f "$PROJ_ROOT/test/soulx-flashhead/output/pro/flashhead_pro_minimal.mp4" ]; then
  echo "输出文件: $(ls -lh $PROJ_ROOT/test/soulx-flashhead/output/pro/flashhead_pro_minimal.mp4)"
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \
    $PROJ_ROOT/test/soulx-flashhead/output/pro/flashhead_pro_minimal.mp4 2>/dev/null | xargs -I{} echo "视频时长: {}s"
fi
echo "=== Pro 测试完成 ==="
