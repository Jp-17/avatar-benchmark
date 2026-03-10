# SoulX-FlashHead 推理测试记录

## 模型信息

- **模型名称**：SoulX-FlashHead（Pro / Lite）
- **论文/仓库**：https://github.com/Soul-AILab/SoulX-FlashHead
- **参数量**：1.3B（Pro 和 Lite 共享同一 DiT 架构，权重各约 6GB）
- **环境**：flashhead-env（torch 2.7.1+cu128, transformers 4.57.3, flash_attn 2.8.3）
- **推理脚本**：`generate_video.py`
- **权重路径**：`weights/SoulX-FlashHead-1_3B/`（Model_Lite / Model_Pro / VAE_LTX / VAE_Wan）
- **wav2vec 路径**：`weights/wav2vec2-base-960h`（软链接至 weights_shared）

## 最小测试命令

### Lite

```bash
cd /root/autodl-tmp/avatar-benchmark/models/soulx-flashhead
CUDA_VISIBLE_DEVICES=0 \
/root/autodl-tmp/envs/flashhead-env/bin/python generate_video.py \
  --ckpt_dir weights/SoulX-FlashHead-1_3B \
  --wav2vec_dir weights/wav2vec2-base-960h \
  --model_type lite \
  --cond_image /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/input/I013.png \
  --audio_path /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/input/A007_5s.wav \
  --audio_encode_mode stream \
  --save_file /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/output/lite/flashhead_lite_minimal.mp4
```

### Pro

```bash
cd /root/autodl-tmp/avatar-benchmark/models/soulx-flashhead
CUDA_VISIBLE_DEVICES=0 \
/root/autodl-tmp/envs/flashhead-env/bin/python generate_video.py \
  --ckpt_dir weights/SoulX-FlashHead-1_3B \
  --wav2vec_dir weights/wav2vec2-base-960h \
  --model_type pro \
  --cond_image /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/input/I013.png \
  --audio_path /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/input/A007_5s.wav \
  --audio_encode_mode stream \
  --save_file /root/autodl-tmp/avatar-benchmark/test/soulx-flashhead/output/pro/flashhead_pro_minimal.mp4
```

## 最小测试结果

（2026-03-11 测试完成）

| 版本 | 耗时 | 峰值显存（单独使用时估算） | 输出大小 | 输出时长 | 状态 |
|------|------|----------------------|---------|---------|------|
| Lite | 174s | ~6 GB（总 27.7 GB - OmniAvatar 21.7 GB） | 135 KB | ~5s | ✅ 成功 |
| Pro  | 283s | ~11 GB（总 32.8 GB - OmniAvatar 21.7 GB） | 175 KB | ~5s | ✅ 成功 |

**注意**：测试期间 OmniAvatar 进程占用 21.7 GB，实际 FlashHead 独占显存更低。
- Lite 首 chunk 约 0.06s/step，Pro 首 chunk 约 0.35s/step
- 首次推理有编译开销（~120s），后续 chunk 极快（~2.7s/chunk）
- 环境变量需设置：`XFORMERS_IGNORE_FLASH_VERSION_CHECK=1`（xformers 0.0.31 与 flash_attn 2.8.3 的版本检查绕过）

## 使用的素材

| 文件 | 路径 |
|------|------|
| 参考图像 | `test/soulx-flashhead/input/I013.png` → `input/avatar_img/half_body/I013.png` |
| 参考音频 | `test/soulx-flashhead/input/A007_5s.wav` → `test/echomimic_v2/input/A007_5s.wav` |

## 关键参数

| 参数 | Lite | Pro |
|------|------|-----|
| `--model_type` | `lite` | `pro` |
| `--audio_encode_mode` | `stream` | `stream` |
| `--use_face_crop` | 可选（全身图时加） | 可选（全身图时加） |
| 显存需求 | ~8–12 GB | ~15–20 GB |

## 批处理脚本（Phase 4）

- `run_phase4_lite.sh`：Lite 版 4 条件批推理，输出到 `output/soulx_flashhead_lite_phase4/`
- `run_phase4_pro.sh`：Pro 版 4 条件批推理，输出到 `output/soulx_flashhead_pro_phase4/`

执行顺序：Lite（4 条件）→ Pro（4 条件），顺序执行，不并行。
