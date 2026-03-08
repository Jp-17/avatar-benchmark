# LongCat-Video-Avatar 最小推理测试

## 环境信息
- 环境名：longcat-env（直接调用 env 内 `python` 仍会在 SSH 下挂起）
- 代码目录：/root/autodl-tmp/avatar-benchmark/models/LongCat-Video
- 权重目录：/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video-Avatar
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar
- 启动方式：经 base Python + `PYTHONPATH=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages` 绕过 env 内 python 挂起问题

## 最小测试素材
- 图片：input/I013.png
- 音频：input/A007_5s.wav
- Prompt：input/P011.txt
- 输入 JSON：single_minimal_image.json

## 当前检查结果
- 已补建最小测试脚手架，包括输入素材、JSON、`test_longcat_video_avatar.sh` 与输出目录。
- 已补装 avatar 音频侧依赖（`librosa`、`soundfile`、`onnxruntime`、`audio-separator`、`pyloudnorm` 等），并恢复 longcat-env 的 `torch 2.6.0+cu124` 与 `numpy 1.26.4`，避免 flash-attn / numpy ABI 冲突。
- 已确认通过 base Python wrapper 可正常启动 `run_demo_avatar_single_audio_to_video.py --help`，说明 SSH 下的 CLI 启动链路已打通。
- LongCat-Video base 目录已增长到约 73G，说明 `meituan-longcat/LongCat-Video` 基本已下完；但 Avatar 下载在首个 shard 处发生校验失败并中断，当前 `LongCat-Video-Avatar` 目录约 77G，需清理损坏分片后续传。
- 脚本还依赖相邻目录 `weights/LongCat-Video` 中的 `tokenizer/`、`text_encoder/`、`vae/`、`scheduler/` 等基础权重；该目录当前不存在。
- 已为 `weights/LongCat-Video-Avatar/chinese-wav2vec2-base` 补接 `pytorch_model.bin`，并验证 `Wav2Vec2ModelWrapper` 可正常加载；`weights/LongCat-Video-Avatar/vocal_separator/Kim_Vocal_2.onnx` 也已从现有模型复用接入。

## 当前阻塞
1. LongCat-Video base 权重目录仍未完整下载。
2. LongCat-Video-Avatar 自身 checkpoint shards 仍未完整下载。
3. longcat-env 仍不能直接在 SSH 下跑 env 内 python，只能经 base Python wrapper 绕过。
4. `download_longcat_weights.sh` 已执行完毕但以错误退出：Avatar 首个 shard 下载到 3.8G 时触发 consistency check failed，需要重新续传。

## 待补充
- LongCat-Video base 权重补齐情况
- Avatar checkpoint shards 补齐情况
- 后台下载进度与磁盘占用变化
- `test_longcat_video_avatar.sh` 实际运行日志、耗时、显存占用与输出文件信息
