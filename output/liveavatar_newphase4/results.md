# LiveAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/liveavatar/run_phase4_filtered.sh
- 配置文件：output/liveavatar_newphase4/config.json
- 输出目录：output/liveavatar_newphase4/
- 说明：参考 test/liveavatar/test.md 的最小素材测试经验，沿用已验证成功的 80 帧稳定链路；并保持串行执行，避免与其他大模型并行导致显存冲突。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=29171 minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_half_short.mp4 --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/
- config 参数：见 output/liveavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_half_short.mp4
- 显存峰值：52153 MB
- 推理生成时间：572 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/liveavatar/test.md 中已验证的短时稳定路径；必须串行执行以避免与其他 14B/18B 模型并行时触发 OOM。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=29171 minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_full_short.mp4 --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/
- config 参数：见 output/liveavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_full_short.mp4
- 显存峰值：52133 MB
- 推理生成时间：639 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/liveavatar/test.md 中已验证的短时稳定路径；必须串行执行以避免与其他 14B/18B 模型并行时触发 OOM。
