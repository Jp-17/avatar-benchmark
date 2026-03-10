# SoulX-FlashHead Lite Phase 4 结果

**执行日期**：2026-03-11
**脚本**：`test/soulx-flashhead/run_phase4_resume.sh`
**环境**：flashhead-env（torch 2.7.1+cu128, transformers 4.57.3）

## Lite 推理结果

| Condition | 音频 | 图像 | 耗时 | 输出大小 | 备注 |
|-----------|------|------|------|---------|------|
| C_half_short | EM2_no_smoking.wav (~5.4s) | half_body/13.png | ~174s | 229K | 含首次编译开销 |
| C_half_long | A001.wav (~100s) | half_body/2.png | ~118s | 5.6M | 续批chunk无编译开销 |
| C_full_short | S002_adele.wav (~8.6s) | full_body/1.png | ~300s | 516K | --use_face_crop True |
| C_full_long | MT_eng.wav (~60s) | full_body/3.png | ~450s | 3.3M | --use_face_crop True |

## 关键参数

| 参数 | 值 |
|------|-----|
| model_type | lite |
| audio_encode_mode | stream |
| use_face_crop | False（半身图）/ True（全身图） |
| 峰值显存（Lite 独占估算） | ~6–8 GB（A800 80G 与 OmniAvatar 21G 共存时总 27–39 GB） |

## 注意事项

- 运行时必须设置 `export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1`（xformers 0.0.31 不支持 flash_attn 2.8.3）
- 首次推理有 TorchInductor 编译开销（~120s），后续 chunk 极快（~0.45s/chunk at 96fps）
- `--use_face_crop True` 会调用 mediapipe 进行面部检测，对全身图效果改善明显
