#!/bin/bash
set -e
echo "[$(date)] Starting LiveAvatar inference test"
cd /root/autodl-tmp/avatar-benchmark/models/LiveAvatar

export ENABLE_COMPILE=false
export CUDA_VISIBLE_DEVICES=0
export NCCL_DEBUG=WARN
export NCCL_DEBUG_SUBSYS=OFF

IMG=/root/autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I001.png
AUDIO=/root/autodl-tmp/avatar-benchmark/input/audio/trimmed/A007_5s.wav
OUTPUT=/root/autodl-tmp/avatar-benchmark/test/liveavatar/output/test_output.mp4

conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env     env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 ENABLE_COMPILE=false NCCL_DEBUG=WARN     torchrun --nproc_per_node=1 --master_port=29101     minimal_inference/s2v_streaming_interact.py     --ulysses_size 1     --task s2v-14B     --size "704*384"     --base_seed 42     --training_config liveavatar/configs/s2v_causal_sft.yaml     --offload_model True     --convert_model_dtype     --prompt "A person speaking directly to the camera with natural facial expressions and synchronized lip movements."     --image $IMG     --audio $AUDIO     --save_file $OUTPUT     --infer_frames 48     --load_lora     --lora_path_dmd ckpt/LiveAvatar     --sample_steps 4     --sample_guide_scale 0     --num_clip 1     --num_gpus_dit 1     --sample_solver euler     --single_gpu     --ckpt_dir ckpt/Wan2.2-S2V-14B/     --fp8

echo "[$(date)] LiveAvatar inference done"
ls -lh $OUTPUT
