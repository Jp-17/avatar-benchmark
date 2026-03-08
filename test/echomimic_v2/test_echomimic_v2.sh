#!/bin/bash
set -euo pipefail
TEST_DIR=/root/autodl-tmp/avatar-benchmark/test/echomimic_v2
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/echomimic_v2
ENV=/root/autodl-tmp/envs/echomimic2-env
OUTPUT_DIR=$TEST_DIR/output
OUT_MP4=$OUTPUT_DIR/echomimic_v2_minimal.mp4
CONFIG=$TEST_DIR/echomimic_v2_minimal.yaml
LOG=$OUTPUT_DIR/echomimic_v2_minimal.log
IMG=$TEST_DIR/input/I013.png
AUDIO=$TEST_DIR/input/A007_5s.wav
mkdir -p "$OUTPUT_DIR"
rm -f "$OUT_MP4" "$LOG" "$CONFIG"
cat > "$CONFIG" <<EOF
pretrained_base_model_path: "./pretrained_weights/sd-image-variations-diffusers"
pretrained_vae_path: "./pretrained_weights/sd-vae-ft-mse"
denoising_unet_path: './pretrained_weights/denoising_unet_acc.pth'
reference_unet_path: "./pretrained_weights/reference_unet.pth"
pose_encoder_path: "./pretrained_weights/pose_encoder.pth"
motion_module_path: './pretrained_weights/motion_module_acc.pth'
audio_mapper_path: "./pretrained_weights/audio_mapper-50000.pth"
auido_guider_path: "./pretrained_weights/wav2vec2-base-960h"
auto_flow_path: "./pretrained_weights/AutoFlow"
audio_model_path: "./pretrained_weights/audio_processor/tiny.pt"
inference_config: "./configs/inference/inference_v2.yaml"
weight_dtype: 'fp16'

test_cases:
  "$IMG":
    - "$AUDIO"
    - "./assets/halfbody_demo/pose/01/"
EOF
cd "$MODEL_DIR"
rm -f output/I013-a-A007_5s-i0_sig.mp4
START_TS=$(date +%s)
/root/miniconda3/bin/conda run --no-capture-output -p "$ENV" python infer_acc.py --config "$CONFIG" -W 768 -H 768 -L 120 --seed 420 --steps 6 --fps 24 >> "$LOG" 2>&1
SRC=$(find "$MODEL_DIR/output" -name 'I013-a-A007_5s-i0_sig.mp4' -type f | head -1)
if [ -z "$SRC" ]; then
  echo "EchoMimic output not found" >> "$LOG"
  exit 1
fi
mv "$SRC" "$OUT_MP4"
END_TS=$(date +%s)
echo "runtime_seconds=$((END_TS-START_TS))" >> "$LOG"
ls -lh "$OUT_MP4"
