# LiveAvatar 官方近似命令测试记录

## 状态
- 当前状态：❌ failed
- 测试时间：2026-03-09 17:56-17:58 CST
- 工作目录：models/LiveAvatar
- 输出目录：output/liveavatar_official_nearby/
- 目标：验证“尽量接近官方单卡脚本”的多 clip 路径在项目当前素材上能否直接运行，并改善旧结果中“视频时长偏短”和“尾段质量退化”的问题。

## 测试素材
- 图片：`/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png`
- 音频：`/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav`
- prompt：`A person speaking directly to the camera with natural facial expressions and synchronized lip movements.`

## 命令
```bash
/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env \
  TOKENIZERS_PARALLELISM=false \
  CUDA_VISIBLE_DEVICES=0 \
  NCCL_DEBUG=WARN \
  NCCL_DEBUG_SUBSYS=OFF \
  ENABLE_COMPILE=false \
  torchrun --nproc_per_node=1 --master_port=29101 minimal_inference/s2v_streaming_interact.py \
  --ulysses_size 1 \
  --task s2v-14B \
  --size '704*384' \
  --base_seed 420 \
  --training_config liveavatar/configs/s2v_causal_sft.yaml \
  --offload_model True \
  --convert_model_dtype \
  --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' \
  --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png \
  --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav \
  --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_official_nearby/C_half_short.mp4 \
  --infer_frames 48 \
  --load_lora \
  --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors \
  --sample_steps 4 \
  --sample_guide_scale 0 \
  --num_clip 3 \
  --num_gpus_dit 1 \
  --sample_solver euler \
  --single_gpu \
  --ckpt_dir ckpt/Wan2.2-S2V-14B/ \
  --fp8
```

## 与官方脚本的主要差异
- 保留官方单卡核心参数：`infer_frames=48`、`single_gpu`、`offload_model=True`、`fp8`、`sample_steps=4`、`sample_solver=euler`。
- 将 `ENABLE_COMPILE` 设为 `false`，避免首次编译等待干扰对 OOM/卡住根因的判断。
- 将 `lora_path_dmd` 改为本地已落盘权重 `ckpt/LiveAvatar/liveavatar.safetensors`，不依赖 repo id 在线解析。
- 不再把 `num_clip` 写死为 `1`；当前音频 `5.355s`，按 `25fps` 和 `48` 帧 clip 计算，`num_clip=ceil(5.355*25/48)=3`。

## 结果
- 未生成 `C_half_short.mp4`。
- 失败类型：CUDA OOM。
- 失败位置：进入 `Generating video ...` 之后，完成 `complete prepare conditional inputs`，在 `causal_s2v_pipeline.py` 的 KV cache 初始化阶段失败。
- 关键报错：`torch.OutOfMemoryError: CUDA out of memory. Tried to allocate 360.00 MiB. GPU 0 has a total capacity of 79.25 GiB ... this process has 79.02 GiB memory in use.`

## 结论
- “尽量接近官方”的单卡多 clip 路径，在当前项目素材和当前 80GB 单卡环境下不能直接运行。
- 这次失败说明：官方推荐的 `48f + 多 clip + no offload_kv_cache + fp8` 并不能绕过本机的 KV cache 显存瓶颈。
- 因此，旧问题中的“视频时长偏短”虽然在参数设计上应该通过多 clip 修正，但当前环境下多 clip 还没有稳定可用的执行路径。
