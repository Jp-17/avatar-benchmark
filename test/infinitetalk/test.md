# InfiniteTalk 最小推理测试

## 环境信息
- 环境名：unified-env（SSH 下实际通过 `/root/miniconda3/bin/python -S` + unified overlay 运行）
- 模型目录：`/root/autodl-tmp/avatar-benchmark/models/InfiniteTalk`
- 测试目录：`/root/autodl-tmp/avatar-benchmark/test/infinitetalk`
- 复用基座：`weights/Wan2.1-I2V-14B-480P -> /root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P`
- InfiniteTalk 权重：`weights/InfiniteTalk/single/infinitetalk.safetensors -> comfyui/infinitetalk_single.safetensors`
- 音频编码器：`weights/chinese-wav2vec2-base -> /root/autodl-tmp/avatar-benchmark/weights_shared/chinese-wav2vec2-base`
- 启动脚本：`/root/autodl-tmp/avatar-benchmark/test/infinitetalk/test_infinitetalk.sh`
- 日志路径：`/root/autodl-tmp/avatar-benchmark/test/infinitetalk/output/infinitetalk_minimal.log`

## 最小测试素材
- 图片：`test/infinitetalk/input/I013.png`（源自 `input/avatar_img/half_body/I013.png`）
- 音频：`test/infinitetalk/input/A007_5s.wav`（5s，16kHz，mono）
- Prompt：`test/infinitetalk/input/P011.txt`
- 输入 JSON：`test/infinitetalk/single_minimal_image.json`

## Phase 2 最小推理验证（2026-03-08）

### 基本信息
- 当前状态：✅ 已通过
- 环境：`unified-env`
- 启动命令：`bash /root/autodl-tmp/avatar-benchmark/test/infinitetalk/test_infinitetalk.sh`
- 核心推理命令：`env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json /root/autodl-tmp/avatar-benchmark/test/infinitetalk/single_minimal_image.json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file /root/autodl-tmp/avatar-benchmark/test/infinitetalk/output/infinitetalk_minimal`

### 运行资源与时间
- GPU：单卡 `CUDA_VISIBLE_DEVICES=0`
- 共享基座：`weights_shared/Wan2.1-I2V-14B-480P` 7/7 diffusion shards 已补齐
- 运行时长：`1030` 秒（修复 `ffprobe` fallback 后的重跑结果）
- 观测资源：单卡 GPU0；首次起跑监控在加载/生成阶段记录到约 `6190 MiB` 显存占用（见 `test/monitor_multitalk_infinitetalk_gpu.log`）
- 输出文件：`test/infinitetalk/output/infinitetalk_minimal.mp4`（`356K`，约 `5.05s`，`640x640`）

### 运行配置与素材要求
- 固定参数：`size=infinitetalk-480`、`sample_steps=8`、`mode=streaming`、`motion_frame=9`
- 图片统一使用 half-body `I013.png`
- 音频统一使用 `A007_5s.wav`
- 文本 prompt 统一使用 `P011.txt`
- `scene_seg=False`，本轮验证的是最小 image-input 链路

### 遇到的问题
1. shared Wan2.1-I2V-14B-480P 最初缺少 7 个 diffusion shards，无法进入最小推理。
2. 首次起跑在 image-input 场景下仍无条件调用 `ffprobe`，报错 `FileNotFoundError: [Errno 2] No such file or directory: ffprobe`。
3. `unified-env` 在 SSH 下直接调用 env 内 python 仍不稳定，因此继续沿用 base Python + overlay 的运行方式。

### 解决方案
1. 先补齐 shared Wan 的 7 个 diffusion shards，再重启最小测试。
2. 为 `models/InfiniteTalk/wan/utils/utils.py` 中的 `get_video_codec()` 增加 fallback：当输入不是视频文件，或系统中不存在 `ffprobe`，直接返回空 codec，避免图片输入链路被无效依赖阻塞。
3. 重新执行 `test_infinitetalk.sh` 后通过最小素材推理验证。
