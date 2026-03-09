# LiveAvatar 单 clip 长度对照实验

## 状态
- 当前状态：✅ completed
- 测试时间：2026-03-09 18:39-18:54 CST
- 目标：验证此前 LiveAvatar 短时结果中“后半段发灰/发暗”的质量退化，是否主要与 `80` 帧单 clip 路径有关，而不是保存/合并环节。
- 工作目录：`models/LiveAvatar`
- 输出目录：`output/liveavatar_singleclip_compare/`

## 实验设计
- 固定不变项：
  - 图片：`input/avatar_img/filtered/half_body/13.png`
  - prompt：`A person speaking directly to the camera with natural facial expressions and synchronized lip movements.`
  - seed：`42`
  - `num_clip=1`
  - `offload_model=True`
  - `offload_kv_cache=True`
  - `sample_steps=4`
  - `sample_solver=euler`
  - `single_gpu`
  - `ENABLE_COMPILE=false`
  - 不启用 `fp8`
- 唯一变量：`infer_frames`
  - 对照 A：`infer_frames=48`
  - 对照 B：`infer_frames=80`
- 输入音频：从 `input/audio/filtered/short/EM2_no_smoking.wav` 裁剪得到 `output/liveavatar_singleclip_compare/EM2_no_smoking_3s.wav`，实际时长 `3.019s`。

## 运行命令
### 48f
```bash
/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env \
  TOKENIZERS_PARALLELISM=false \
  CUDA_VISIBLE_DEVICES=0 \
  TORCH_COMPILE_DISABLE=1 \
  TORCHDYNAMO_DISABLE=1 \
  ENABLE_COMPILE=false \
  NCCL_DEBUG=WARN \
  PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
  torchrun --nproc_per_node=1 --master_port=29141 minimal_inference/s2v_streaming_interact.py \
  --ulysses_size 1 \
  --task s2v-14B \
  --size '704*384' \
  --base_seed 42 \
  --training_config liveavatar/configs/s2v_causal_sft.yaml \
  --offload_model True \
  --convert_model_dtype \
  --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' \
  --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png \
  --audio /root/autodl-tmp/avatar-benchmark/output/liveavatar_singleclip_compare/EM2_no_smoking_3s.wav \
  --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_singleclip_compare/C_half_3s_48f.mp4 \
  --infer_frames 48 \
  --load_lora \
  --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors \
  --sample_steps 4 \
  --sample_guide_scale 0 \
  --num_clip 1 \
  --num_gpus_dit 1 \
  --sample_solver euler \
  --single_gpu \
  --offload_kv_cache \
  --ckpt_dir ckpt/Wan2.2-S2V-14B/
```

### 80f
```bash
/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env \
  TOKENIZERS_PARALLELISM=false \
  CUDA_VISIBLE_DEVICES=0 \
  TORCH_COMPILE_DISABLE=1 \
  TORCHDYNAMO_DISABLE=1 \
  ENABLE_COMPILE=false \
  NCCL_DEBUG=WARN \
  PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
  torchrun --nproc_per_node=1 --master_port=29142 minimal_inference/s2v_streaming_interact.py \
  --ulysses_size 1 \
  --task s2v-14B \
  --size '704*384' \
  --base_seed 42 \
  --training_config liveavatar/configs/s2v_causal_sft.yaml \
  --offload_model True \
  --convert_model_dtype \
  --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' \
  --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png \
  --audio /root/autodl-tmp/avatar-benchmark/output/liveavatar_singleclip_compare/EM2_no_smoking_3s.wav \
  --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_singleclip_compare/C_half_3s_80f.mp4 \
  --infer_frames 80 \
  --load_lora \
  --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors \
  --sample_steps 4 \
  --sample_guide_scale 0 \
  --num_clip 1 \
  --num_gpus_dit 1 \
  --sample_solver euler \
  --single_gpu \
  --offload_kv_cache \
  --ckpt_dir ckpt/Wan2.2-S2V-14B/
```

## 结果
### 运行耗时
- `48f + 1clip`：约 `306s`（`18:39:07` → `18:44:13`）
- `80f + 1clip`：约 `568s`（`18:45:03` → `18:54:31`）

### 输出时长
- 裁剪音频：`3.019s`
- `48f` 输出视频：`1.80s`（`45` 帧）
- `80f` 输出视频：`3.08s`（`77` 帧）
- 说明：当前 pipeline 在首个 clip 解码后会丢弃前 `3` 帧，因此 `48f` 和 `80f` 的最终帧数分别对应 `48-3=45`、`80-3=77`。

### 亮度/饱和度对比（signalstats）
#### 48f
- 首帧：`YAVG=148.19`，`SATAVG=10.87`
- 中帧：`YAVG=148.50`，`SATAVG=10.98`
- 末帧：`YAVG=149.33`，`SATAVG=11.18`
- 尾部变化：`delta_YAVG=+1.14`，`delta_SATAVG=+0.31`
- 尾部 10 帧均值：`YAVG=149.45`，`SATAVG=11.34`
- 结论：整段非常稳定，没有出现尾段发灰或饱和度塌陷。

#### 80f
- 首帧：`YAVG=148.03`，`SATAVG=10.86`
- 中帧：`YAVG=149.35`，`SATAVG=11.55`
- 末帧：`YAVG=95.40`，`SATAVG=5.02`
- 尾部变化：`delta_YAVG=-52.64`，`delta_SATAVG=-5.83`
- 尾部 10 帧均值：`YAVG=107.31`，`SATAVG=7.37`
- 结论：尾段出现非常明显的亮度和饱和度塌陷，与此前旧短时结果中的“后半段发灰/发暗”现象一致。

## 结论
- 本次对照实验强烈支持此前判断：LiveAvatar 的质量退化问题主要出在 `80` 帧单 clip 路径本身，而不是 `save_video()` / `merge_video_audio()` 等后处理步骤。
- 理由：`48f` 与 `80f` 使用了完全相同的保存/合并链路、相同的图片、相同的 prompt、相同的音频片段、相同的 seed，唯一主要变量是单 clip 长度；结果只有 `80f` 出现明显尾段塌陷。
- 因此，旧 Phase 4 短时结果中观察到的“前半正常、后半发灰”更可能是 `80f + 1clip` 这条 workaround 路径的生成稳定性问题，而不是素材问题或 ffmpeg 合并问题。
