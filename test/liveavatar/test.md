# LiveAvatar 测试记录

## Phase 2 最小推理验证（2026-03-08 校正）

### 基本信息
- 模型名称：LiveAvatar
- 当前状态：✅ 已建立可信最小成功基线（80 帧）
- 环境：liveavatar-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/liveavatar/test_liveavatar_80gpu.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/liveavatar/output/liveavatar_minimal_80gpu.log
- 是否完成 Phase 4：否（待按同一 80 帧稳定路径复跑）

### 固定输入素材
- 图片：test/liveavatar/input/I013.png
- 音频：test/liveavatar/input/A007_5s.wav
- 文本：test/liveavatar/input/P011.txt
- 输出目录：test/liveavatar/output/

### 运行资源与时间
- 运行时间：599 秒
- 显存占用：约 52 GiB（单卡独占）
- 说明：该结果是在单独占用 GPU 的前提下完成的，可作为后续 Phase 4 的可信最小基线。

### 实际运行命令
- 启动命令：MASTER_PORT=29161 bash /root/autodl-tmp/avatar-benchmark/test/liveavatar/test_liveavatar_80gpu.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=${MASTER_PORT:-29111} minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt "$PROMPT" --image "$IMG" --audio "$AUDIO" --save_file "$OUT_MP4" --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/ >> "$LOG" 2>&1

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/liveavatar/output/liveavatar_minimal_80gpu.mp4

### 历史修正说明
- 旧版 `test/liveavatar/test.md` 曾将 124 帧链路记录为“✅ 已通过 / 202 秒 / liveavatar_minimal.mp4”，但仓库中没有对应可信输出，且日志显示该链路在 `Generating video ...` 后被外部终止。
- 旧版 80 帧日志也曾在与其他模型并行时因显存不足 OOM；本次单独占用 GPU 后，80 帧链路已真实跑通。

### 当前结论
- LiveAvatar 现阶段可复用的稳定基线是：`80` 帧 + `--offload_kv_cache` + `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` + `TORCH_COMPILE_DISABLE=1` + `TORCHDYNAMO_DISABLE=1`。
- 后续 Phase 4 应优先沿用这条 80 帧稳定路径，而不是继续使用旧的 124 帧记录。
