# InfiniteTalk 最小推理测试

## 环境信息
- 环境名：unified-env（直接调用 env 内 `python` 仍会在 SSH 下挂起）
- 模型目录：/root/autodl-tmp/avatar-benchmark/models/InfiniteTalk
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/infinitetalk
- 复用基座：weights/Wan2.1-I2V-14B-480P -> /root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P
- 复用音频编码器：weights/chinese-wav2vec2-base -> /root/autodl-tmp/avatar-benchmark/weights_shared/chinese-wav2vec2-base
- InfiniteTalk 权重：weights/InfiniteTalk/single/infinitetalk.safetensors -> comfyui/infinitetalk_single.safetensors
- 启动补丁：`generate_infinitetalk.py` 已改为仅在 `--audio_mode tts` 时才懒加载 Kokoro
- 兼容层：test/shared_pydeps/unified_transformers_449（transformers 4.49.0 + tokenizers 0.21.0 + huggingface-hub 0.28.1 + minimal misaki deps）

## 最小测试素材
- 图片：input/I013.png
- 音频：input/A007_5s.wav
- Prompt：input/P011.txt
- 输入 JSON：single_minimal_image.json

## 当前检查结果
- 已确认最小测试脚手架存在，包括输入素材、`single_minimal_image.json`、`test_infinitetalk.sh` 与输出目录。
- InfiniteTalk 自身权重的 single/multi checkpoint 已基本到位：`single/infinitetalk.safetensors` 当前软链接到 `comfyui/infinitetalk_single.safetensors`（2.6G），`multi/infinitetalk.safetensors` 为 9.3G。
- 已确认用 base Python + unified overlay 的方式可以正常启动 `generate_infinitetalk.py --help`，说明 SSH 下的最小启动链路已打通。
- 当前真正阻塞已收敛到共享 Wan 主体：shared Wan 已补接 T5/CLIP 权重，shared wav2vec2-base 也已补接 `pytorch_model.bin` 并验证可正常加载；当前仍缺 7 个 diffusion shards。

## 当前阻塞
1. shared Wan2.1-I2V-14B-480P 仍缺 7 个 diffusion shards。
2. unified-env 仍不能直接在 SSH 下跑 env 内 python，只能经 base Python + overlay 绕过。

## 待补充
- 公共基座补齐情况
- `test_infinitetalk.sh` 实际运行日志、耗时、显存占用与输出文件信息
