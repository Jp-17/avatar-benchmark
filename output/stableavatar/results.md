# StableAvatar 推理结果记录

## 模型信息

- **模型名称**：StableAvatar-1.3B
- **基底模型**：Wan2.1-Fun-V1.1-1.3B-InP
- **环境**：stableavatar-env（torch 2.7.0+cu128）
- **推理脚本**：`models/stableavatar/inference.py`
- **参考脚本**：`models/stableavatar/inference.sh`

## 实际运行命令

### 基础命令格式
```bash
cd /root/autodl-tmp/avatar-benchmark/models/stableavatar
conda run --no-capture-output -p /root/autodl-tmp/envs/stableavatar-env \
    env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 \
    python inference.py \
    --config_path="deepspeed_config/wan2.1/wan_civitai.yaml" \
    --pretrained_model_name_or_path=weights/StableAvatar/Wan2.1-Fun-V1.1-1.3B-InP \
    --transformer_path=weights/StableAvatar/StableAvatar-1.3B/transformer3d-square.pt \
    --pretrained_wav2vec_path=weights/StableAvatar/wav2vec2-base-960h \
    --validation_reference_path=<IMG> \
    --validation_driven_audio_path=<AUDIO> \
    --output_dir=<OUTPUT_TMP_DIR> \
    --validation_prompts "<PROMPT>" \
    --seed=42 --motion_frame=25 --sample_steps=50 \
    --width=512 --height=512 --overlap_window_length=5 \
    --clip_sample_n_frames=81 --GPU_memory_mode="model_full_load" \
    --sample_text_guide_scale=3.0 --sample_audio_guide_scale=5.0
# 之后合并音频：
ffmpeg -i <OUTPUT_TMP_DIR>/video_without_audio.mp4 -i <AUDIO> \
    -c:v copy -c:a aac -shortest <OUTPUT>.mp4 -y
```

### 批处理脚本
- C_zh_5s 手动测试（已完成），之后起批次
- 批处理脚本：`/root/autodl-tmp/stableavatar_batch2.sh`（从 C_zh_10s 开始）
- 日志：`/root/autodl-tmp/stableavatar_C_<condition>.log`

## 说明

- StableAvatar 的 inference.py 主输出为 `output_dir/video_without_audio.mp4`（无音频）
- 还会生成 `output_dir/animated_images/`（逐帧 PNG，可后续删除以节省空间）
- 需后处理：用 ffmpeg 将音频合并进视频
- 视频时长由音频长度自动决定（sliding window 推理），无需手动指定帧数
- FPS = 25，clip_sample_n_frames=81（每窗口81帧≈3.24s），overlap=5帧

## 使用的素材

| Condition | 参考图像 | 音频文件 | prompt 类型 |
|-----------|---------|---------|------------|
| C_zh_5s   | input/avatar_img/half_body/I001.png | input/audio/trimmed/A001_5s.wav  | speech |
| C_zh_10s  | 同上 | input/audio/trimmed/A001_10s.wav | speech |
| C_zh_30s  | 同上 | input/audio/trimmed/A001_30s.wav | speech |
| C_zh_1m   | 同上 | input/audio/trimmed/A001_1m.wav  | speech |
| C_en_5s   | 同上 | input/audio/trimmed/A007_5s.wav  | speech |
| C_en_10s  | 同上 | input/audio/trimmed/A007_10s.wav | speech |
| C_en_30s  | 同上 | input/audio/trimmed/A007_30s.wav | speech |
| C_en_1m   | 同上 | input/audio/trimmed/A007_1m.wav  | speech |
| C_en_3m   | 同上 | input/audio/trimmed/A007_3m.wav  | speech |
| C_en_5m   | 同上 | input/audio/trimmed/A007_5m.wav  | speech |
| C_sing_zh | 同上 | input/audio/singing/S001_jaychou.wav | singing |
| C_sing_en | 同上 | input/audio/singing/S002_adele.wav   | singing |

speech prompt: "A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
singing prompt: "A person singing naturally with expressive facial animations and synchronized lip movements to the music."

## 配置参数

| 参数 | 值 |
|------|-----|
| sample_steps | 50 |
| width | 512 |
| height | 512 |
| fps | 25 |
| seed | 42 |
| motion_frame | 25 |
| overlap_window_length | 5 |
| clip_sample_n_frames | 81 |
| GPU_memory_mode | model_full_load |
| sample_text_guide_scale | 3.0 |
| sample_audio_guide_scale | 5.0 |

## 遇到的问题与解决方法

（截至目前无报错，测试通过）

## 产出结果

| Condition | 状态 | 输出路径 | 时长 | 文件大小 |
|-----------|------|---------|------|---------|
| C_zh_5s   | done    | output/stableavatar/C_zh_5s.mp4  | ~5s  | 475KB |
| C_zh_10s  | done    | output/stableavatar/C_zh_10s.mp4 | ~10s | 969KB |
| C_zh_30s  | running | — | — | — |
| C_zh_1m   | pending | — | — | — |
| C_en_5s   | pending | — | — | — |
| C_en_10s  | pending | — | — | — |
| C_en_30s  | pending | — | — | — |
| C_en_1m   | pending | — | — | — |
| C_en_3m   | pending | — | — | — |
| C_en_5m   | pending | — | — | — |
| C_sing_zh | pending | — | — | — |
| C_sing_en | pending | — | — | — |

*最后更新：2026-03-06*

## Phase 4 产出结果（更新：2026-03-07）

| Condition | 状态 | 输出路径 | 文件大小 | 完成时间 |
|-----------|------|---------|---------|---------|
| C_zh_5s   | ✅ done  | output/stableavatar/C_zh_5s.mp4   | 475 KB | 2026-03-06 18:47 |
| C_zh_10s  | ✅ done  | output/stableavatar/C_zh_10s.mp4  | 969 KB | 2026-03-06 19:04 |
| C_zh_30s  | ✅ done  | output/stableavatar/C_zh_30s.mp4  | 3.3 MB | 2026-03-06 19:41 |
| C_zh_1m   | ✅ done  | output/stableavatar/C_zh_1m.mp4   | 6.7 MB | 2026-03-06 20:41 |
| C_en_5s   | ✅ done  | output/stableavatar/C_en_5s.mp4   | 427 KB | 2026-03-06 20:46 |
| C_en_10s  | ✅ done  | output/stableavatar/C_en_10s.mp4  | 929 KB | 2026-03-06 20:57 |
| C_en_30s  | ✅ done  | output/stableavatar/C_en_30s.mp4  | 3.0 MB | 2026-03-06 21:27 |
| C_en_1m   | ✅ done  | output/stableavatar/C_en_1m.mp4   | 6.3 MB | 2026-03-06 22:33 |
| C_en_3m   | ❌ OOM  | — | — | Hallo3(54.6GB)+SA 加载超出 80GB |
| C_en_5m   | ⏸ 中止  | — | — | 运行至 step 30/50 时中止 |
| C_sing_zh | ⏸ 未运行 | — | — | — |
| C_sing_en | ⏸ 未运行 | — | — | — |

**当前完成度：8/12**
