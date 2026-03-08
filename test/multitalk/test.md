# MultiTalk 最小推理测试

## 环境信息
- 环境名：unified-env（直接调用 env 内 `python` 仍会在 SSH 下挂起）
- 模型目录：/root/autodl-tmp/avatar-benchmark/models/MultiTalk
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/multitalk
- 复用基座：weights/Wan2.1-I2V-14B-480P -> /root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P
- 复用音频编码器：weights/chinese-wav2vec2-base -> /root/autodl-tmp/avatar-benchmark/weights_shared/chinese-wav2vec2-base
- 启动补丁：`generate_multitalk.py` 已改为仅在 `--audio_mode tts` 时才懒加载 Kokoro
- 兼容层：test/shared_pydeps/unified_transformers_449（transformers 4.49.0 + tokenizers 0.21.0 + huggingface-hub 0.28.1 + minimal misaki deps）

## 最小测试素材
- 图片：input/I013.png
- 音频：input/A007_5s.wav
- Prompt：input/P011.txt
- 输入 JSON：multitalk_minimal_image.json

## 当前检查结果
- 已补建最小测试脚手架，包括输入素材、JSON、`test_multitalk.sh` 与输出目录。
- 已为 `weights/` 接好 shared Wan / wav2vec 软链接，后续无需再重复复制公共基座。
- 已确认用 base Python + unified overlay 的方式可以正常启动 `generate_multitalk.py --help`，说明 SSH 下的最小启动链路已打通。
- `multitalk.safetensors` 已于 2026-03-08 01:43 下载完成，MultiTalk 自身主 checkpoint 已到位。
- shared Wan 已补接 `models_t5_umt5-xxl-enc-bf16.pth` 与 `models_clip_open-clip-xlm-roberta-large-vit-huge-14.pth` 软链接；当前只缺 `diffusion_pytorch_model-00001-of-00007.safetensors` 到 `diffusion_pytorch_model-00007-of-00007.safetensors`。
- shared wav2vec2-base 已补接 `pytorch_model.bin`，并在 MultiTalk 上下文中验证 `Wav2Vec2Model.from_pretrained(...)` 可正常加载。

## 当前阻塞
1. shared Wan2.1-I2V-14B-480P 仍缺 7 个 diffusion shards。
2. unified-env 仍不能直接在 SSH 下跑 env 内 python，只能经 base Python + overlay 绕过。

## 待补充
- 公共基座补齐情况
- `test_multitalk.sh` 实际运行日志、耗时、显存占用与输出文件信息
