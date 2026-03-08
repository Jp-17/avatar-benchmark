# LiveAvatar 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：LiveAvatar
- 当前状态：✅ 已通过
- 环境：liveavatar-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/liveavatar/test_liveavatar.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/liveavatar/output/liveavatar_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/liveavatar/input/I013.png
- 音频：test/liveavatar/input/A007_5s.wav
- 文本：test/liveavatar/input/P011.txt
- 输出目录：test/liveavatar/output/

### 运行资源与时间
- 运行时间：202 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/liveavatar/test_liveavatar.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 ENABLE_COMPILE=false NCCL_DEBUG=WARN torchrun --nproc_per_node=1 --master_port=29101 minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt "$PROMPT" --image "$IMG" --audio "$AUDIO" --save_file "$OUT_MP4" --infer_frames 48 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --ckpt_dir ckpt/Wan2.2-S2V-14B/ >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/liveavatar/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/liveavatar/output/liveavatar_minimal.mp4

### 遇到的问题
- 最初传入的是 LoRA 目录而不是具体权重文件；随后又遇到 --fp8 在当前 A800/CUDA 架构上不支持；当前最小输出时长只有约 1.84 秒。

### 解决方案
- 已改为具体文件 ckpt/LiveAvatar/liveavatar.safetensors，并移除 --fp8；后续需把 infer_frames 调整到与 5 秒音频更匹配的帧数后重跑。
