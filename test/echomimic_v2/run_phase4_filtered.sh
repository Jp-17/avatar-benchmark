#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/echomimic_v2
ENV=/root/autodl-tmp/envs/echomimic2-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/echomimic_v2_newphase4
LOG_DIR=$OUT_DIR/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"
POSE_DIR=./assets/halfbody_demo/pose/01/
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local tmp_yaml="$LOG_DIR/${cond}.yaml"
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  local frames
  frames=$(/root/miniconda3/bin/python - <<PY2
import wave
with wave.open(r"$audio", "rb") as wf:
    seconds = wf.getnframes() / float(wf.getframerate())
frames = int(seconds * 24)
print(min(max(frames, 1), 336))
PY2
)
  cat > "$tmp_yaml" <<EOF
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
  "$img":
    - "$audio"
    - "$POSE_DIR"
EOF
  cd "$MODEL_DIR"
  rm -f "$out" "$log"
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" python infer_acc.py --config "$tmp_yaml" -W 768 -H 768 -L "$frames" --seed 420 --steps 6 --fps 24 >> "$log" 2>&1
  src=$(find "$MODEL_DIR/output" -name "$(basename "$img" .png)-a-$(basename "$audio" .wav)-i0_sig.mp4" -type f | head -1)
  if [ -z "$src" ]; then
    echo "output not found for $cond" >> "$log"
    return 1
  fi
  mv "$src" "$out"
  echo "$cond done frames=$frames output=$out" >> "$log"
}
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav
run_case C_half_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav
run_case C_full_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav
