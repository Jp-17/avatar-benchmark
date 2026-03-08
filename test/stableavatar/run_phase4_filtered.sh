#!/bin/bash
set -euo pipefail
MODEL_DIR=/root/autodl-tmp/avatar-benchmark/models/stableavatar
ENV=/root/autodl-tmp/envs/stableavatar-env
OUT_DIR=/root/autodl-tmp/avatar-benchmark/output/stableavatar_newphase4
LOG_DIR=$OUT_DIR/logs
mkdir -p "$OUT_DIR" "$LOG_DIR"
run_case() {
  local cond="$1"
  local img="$2"
  local audio="$3"
  local prompt="$4"
  local tmp_dir="$OUT_DIR/${cond}_tmp"
  local log="$LOG_DIR/${cond}.log"
  local out="$OUT_DIR/${cond}.mp4"
  rm -rf "$tmp_dir"
  rm -f "$out" "$log"
  cd "$MODEL_DIR"
  /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python inference.py     --config_path=deepspeed_config/wan2.1/wan_civitai.yaml     --pretrained_model_name_or_path=weights/StableAvatar/Wan2.1-Fun-V1.1-1.3B-InP     --transformer_path=weights/StableAvatar/StableAvatar-1.3B/transformer3d-square.pt     --pretrained_wav2vec_path=weights/StableAvatar/wav2vec2-base-960h     --validation_reference_path="$img"     --validation_driven_audio_path="$audio"     --output_dir="$tmp_dir"     --validation_prompts "$prompt"     --seed=42 --motion_frame=25 --sample_steps=50     --width=512 --height=512 --overlap_window_length=5     --clip_sample_n_frames=81 --GPU_memory_mode=model_full_load     --sample_text_guide_scale=3.0 --sample_audio_guide_scale=5.0 >> "$log" 2>&1
  ffmpeg -nostdin -loglevel error -y -i "$tmp_dir/video_without_audio.mp4" -i "$audio" -c:v copy -c:a aac -shortest "$out" >> "$log" 2>&1
  echo "$cond done output=$out" >> "$log"
}
SPEECH_PROMPT="A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
SING_PROMPT="A person singing naturally with expressive facial animations and synchronized lip movements to the music."
run_case C_half_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav "$SPEECH_PROMPT"
run_case C_half_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav "$SPEECH_PROMPT"
run_case C_full_short /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav "$SING_PROMPT"
run_case C_full_long /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav "$SPEECH_PROMPT"
