# SoulX-FlashHead Pro Phase 4 结果

**执行日期**：2026-03-11
**脚本**：`test/soulx-flashhead/run_phase4_resume.sh`
**环境**：flashhead-env（torch 2.7.1+cu128, transformers 4.57.3）

## Pro 推理结果

| Condition | 音频 | 图像 | 耗时 | 输出大小 | 备注 |
|-----------|------|------|------|---------|------|
| C_half_short | EM2_no_smoking.wav (~5.4s) | half_body/13.png | ~283s | 321K | 含首次编译开销 |
| C_half_long | A001.wav (~100s) | half_body/2.png | ~390s | 7.3M | Pro 质量优先，更大输出 |
| C_full_short | S002_adele.wav (~8.6s) | full_body/1.png | ~360s | 649K | --use_face_crop True |
| C_full_long | MT_eng.wav (~60s) | full_body/3.png | 239s | 4.2M | --use_face_crop True |

## 关键参数

| 参数 | 值 |
|------|-----|
| model_type | pro |
| audio_encode_mode | stream |
| use_face_crop | False（半身图）/ True（全身图） |
| 峰值显存（Pro 独占估算） | ~11 GB（A800 80G 与 OmniAvatar 21G 共存时总 32–40 GB） |

## 注意事项

- 运行时必须设置 `export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1`
- Pro 首次推理编译时间约 180s，后续 chunk 约 3s/chunk（约 25fps）
- Pro 质量优于 Lite，但速度约慢 6–7x（3s vs 0.45s per chunk）
- `--use_face_crop True` 支持全身图输入，mediapipe 自动检测人脸区域
