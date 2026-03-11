# SoulX-FlashHead Lite Phase 4 结果（无 face_crop）

**执行日期**：2026-03-11
**脚本**：`test/soulx-flashhead/run_phase4_nofacecrop.sh`
**环境**：flashhead-env（torch 2.7.1+cu128, transformers 4.57.3）
**说明**：不传 `--use_face_crop` 参数，使用默认值 False（注意：传 `--use_face_crop False` 因 argparse type=bool 的 bug 实际会解析为 True，必须完全省略该参数）

## Lite 推理结果

| Condition | 音频 | 图像 | 耗时 | 输出大小 | 备注 |
|-----------|------|------|------|---------|------|
| C_half_short | EM2_no_smoking.wav (~5.4s) | half_body/13.png | ~61s | 232K | 无编译开销（复用缓存） |
| C_half_long | A001.wav (~100s) | half_body/2.png | ~97s | 5.6M | 无编译开销 |
| C_full_short | S002_adele.wav (~8.6s) | full_body/1.png | ~61s | 428K | 全身图直接输入，无人脸裁剪 |
| C_full_long | MT_eng.wav (~60s) | full_body/3.png | ~81s | 2.4M | 全身图直接输入，无人脸裁剪 |

## 关键参数

| 参数 | 值 |
|------|-----|
| model_type | lite |
| audio_encode_mode | stream |
| use_face_crop | False（默认，完全不传该参数） |
| 峰值显存（Lite） | ~6–8 GB |

## 注意事项

- `--use_face_crop False` 存在 argparse type=bool bug：`bool("False")` == True，实际开启 face_crop；必须**完全省略**该参数才能使用默认 False
- 运行时必须设置 `export XFORMERS_IGNORE_FLASH_VERSION_CHECK=1`
- 全身图（full_body）输入时，模型直接对 2048×2048 图片做 resize_and_centercrop 到 512×512，人物整体可见
