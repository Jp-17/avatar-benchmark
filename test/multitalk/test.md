# MultiTalk 最小推理测试

## 环境信息
- 环境名：unified-env（SSH 下实际通过 `/root/miniconda3/bin/python -S` + unified overlay 运行）
- 模型目录：`/root/autodl-tmp/avatar-benchmark/models/MultiTalk`
- 测试目录：`/root/autodl-tmp/avatar-benchmark/test/multitalk`
- 权重目录：`models/MultiTalk/weights/Wan2.1-I2V-14B-480P`（模型局部 overlay：复用 shared Wan 7 shards / T5 / CLIP / VAE，同时接入 `MeiGen-MultiTalk` 的 index 与 `multitalk.safetensors`）
- 音频编码器：`weights/chinese-wav2vec2-base -> /root/autodl-tmp/avatar-benchmark/weights_shared/chinese-wav2vec2-base`
- 启动脚本：`/root/autodl-tmp/avatar-benchmark/test/multitalk/test_multitalk.sh`
- 日志路径：`/root/autodl-tmp/avatar-benchmark/test/multitalk/output/multitalk_minimal.log`

## 最小测试素材
- 图片：`test/multitalk/input/I013.png`（源自 `input/avatar_img/half_body/I013.png`）
- 音频：`test/multitalk/input/A007_5s.wav`（5s，16kHz，mono）
- Prompt：`test/multitalk/input/P011.txt`
- 输入 JSON：`test/multitalk/multitalk_minimal_image.json`

## Phase 2 最小推理验证（2026-03-08）

### 基本信息
- 当前状态：✅ 已通过
- 环境：`unified-env`
- 启动命令：`bash /root/autodl-tmp/avatar-benchmark/test/multitalk/test_multitalk.sh`
- 核心推理命令：`env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_multitalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --input_json /root/autodl-tmp/avatar-benchmark/test/multitalk/multitalk_minimal_image.json --size multitalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --num_persistent_param_in_dit 0 --save_file /root/autodl-tmp/avatar-benchmark/test/multitalk/output/multitalk_minimal`

### 运行资源与时间
- GPU：单卡 `CUDA_VISIBLE_DEVICES=0`
- 共享基座：`weights_shared/Wan2.1-I2V-14B-480P` 7/7 diffusion shards 已补齐
- 运行时长：`2053` 秒
- 观测显存：峰值约 `14884 MiB`（来自 `test/monitor_multitalk_infinitetalk_gpu.log`）
- 输出文件：`test/multitalk/output/multitalk_minimal.mp4`（`398K`，约 `4.94s`，`640x640`）

### 运行配置与素材要求
- 固定参数：`size=multitalk-480`、`sample_steps=8`、`mode=streaming`、`motion_frame=9`、`num_persistent_param_in_dit=0`
- 图片统一使用 half-body `I013.png`
- 音频统一使用 `A007_5s.wav`
- 文本 prompt 统一使用 `P011.txt`

### 遇到的问题
1. shared Wan2.1-I2V-14B-480P 最初缺少 7 个 diffusion shards，无法启动最小推理。
2. 最后一片 shard 通过 `huggingface_hub` 续传时速度降到约 `0.1MB/s`。
3. MultiTalk 首次运行报错 `Cannot copy out of meta tensor`，根因并非 VRAM 管理本身，而是 `weights/Wan2.1-I2V-14B-480P` 仍使用基础 Wan 的 index，没有接入 MultiTalk adapter 的 index / `multitalk.safetensors`。
4. `unified-env` 在 SSH 下直接调用 env 内 python 仍不稳定，因此继续沿用 base Python + overlay 的运行方式。

### 解决方案
1. 补齐 shared Wan 的 7 个 diffusion shards；最后一片改用 `wget -c` 复用已有 partial file 续传完成。
2. 保留 shared 基座不变，仅在 `models/MultiTalk/weights/Wan2.1-I2V-14B-480P` 建立模型局部 overlay，复用 shared 7 shards / T5 / CLIP / VAE，同时接入 `MeiGen-MultiTalk/diffusion_pytorch_model.safetensors.index.json` 与 `multitalk.safetensors`。
3. 继续使用 `test/shared_pydeps/unified_transformers_449` 与 base Python + overlay 作为 SSH 下的稳定启动链路。
4. 重新执行最小素材推理后通过。
