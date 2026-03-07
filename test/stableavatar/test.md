# StableAvatar 推理测试报告

## 基本信息
- 环境：stableavatar-env（torch 2.7.0+cu128，conda）
- 权重大小：26G（含 Wan2.1-Fun-V1.1-1.3B-InP 19G + StableAvatar-1.3B 6.6G + wav2vec 721M）
- 显存需求：~28G（model_full_load 模式）
- 推理类型：img + audio → video（音频驱动说话人头像）

## 测试素材
- 图像：input/avatar_img/half_body/I001.png
- 音频：input/audio/trimmed/ 下各长度（5s/10s/30s/1m）
  - 中文：A001_*.wav
  - 英文：A007_*.wav

## 推理命令
```bash
cd /root/autodl-tmp/avatar-benchmark/models/stableavatar
conda run --no-capture-output -p /root/autodl-tmp/envs/stableavatar-env \
    python inference.py \
    --config_path=deepspeed_config/wan2.1/wan_civitai.yaml \
    --pretrained_model_name_or_path=weights/StableAvatar/Wan2.1-Fun-V1.1-1.3B-InP \
    --transformer_path=weights/StableAvatar/StableAvatar-1.3B/transformer3d-square.pt \
    --pretrained_wav2vec_path=weights/StableAvatar/wav2vec2-base-960h \
    --validation_reference_path=<IMAGE_PATH> \
    --validation_driven_audio_path=<AUDIO_PATH> \
    --output_dir=<OUTPUT_DIR> \
    --validation_prompts "A person speaking directly to the camera with natural facial expressions and synchronized lip movements." \
    --seed=42 --motion_frame=25 --sample_steps=50 \
    --width=512 --height=512 \
    --overlap_window_length=5 --clip_sample_n_frames=81 \
    --GPU_memory_mode=model_full_load \
    --sample_text_guide_scale=3.0 --sample_audio_guide_scale=5.0
```

## 结果

| Condition | 输出文件 | 文件大小 | 状态 |
|-----------|---------|---------|------|
| C_zh_5s   | C_zh_5s.mp4  | 476K | ✅ |
| C_zh_10s  | C_zh_10s.mp4 | 972K | ✅ |
| C_zh_30s  | C_zh_30s.mp4 | 3.3M | ✅ |
| C_zh_1m   | C_zh_1m.mp4  | 6.7M | ✅ |
| C_en_5s   | C_en_5s.mp4  | 428K | ✅ |
| C_en_10s  | C_en_10s.mp4 | 932K | ✅ |
| C_en_30s  | C_en_30s.mp4 | 3.0M | ✅ |
| C_en_1m   | C_en_1m.mp4  | 6.3M | ✅ |

- 是否成功运行：是（8/8 全部成功）
- 显存占用：~28G（model_full_load）

## 素材要求
- 图像：支持各种分辨率（会自动缩放到 512×512）
- 音频：WAV 格式
- 时长：理论无上限（分块生成，81帧一块，5帧重叠），1分钟音频可正常运行
- 语言：中英文均可

## 配置说明
- `sample_steps=50`：去噪步数，值越大质量越高但速度越慢
- `motion_frame=25`：运动帧数
- `overlap_window_length=5`：分块重叠帧数
- `clip_sample_n_frames=81`：每块生成帧数
- `GPU_memory_mode=model_full_load`：全模型加载（VRAM ~28G）
- `sample_text_guide_scale=3.0`：文本引导强度
- `sample_audio_guide_scale=5.0`：音频引导强度

## 问题与解决
- 目前运行稳定，8个条件全部成功生成
- 支持长音频（1m+），通过分块生成实现
- 3分钟音频正在测试中（GPU 上当前运行进程）

*最后更新：2026-03-06*
