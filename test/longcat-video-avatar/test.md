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

## 权重与依赖确认
- 已补建最小测试脚手架，包括输入素材、JSON、`test_longcat_video_avatar.sh` 与输出目录。
- 已补装 avatar 音频侧依赖（`librosa`、`soundfile`、`onnxruntime`、`audio-separator`、`pyloudnorm` 等），并恢复 longcat-env 的 `torch 2.6.0+cu124` 与 `numpy 1.26.4`，避免 flash-attn / numpy ABI 冲突。
- 已确认通过 base Python wrapper 可正常启动 `run_demo_avatar_single_audio_to_video.py --help`，说明 SSH 下的 CLI 启动链路已打通。
- LongCat-Video base 权重已可用，`weights/LongCat-Video/dit` 为 `6/6`，`text_encoder` 为 `5/5`，相邻目录 `tokenizer/`、`vae/`、`scheduler/` 可正常参与推理。
- LongCat-Video-Avatar 权重已补齐，`avatar_single` 与 `avatar_multi` 均为 `6/6`；最后 3 个缺失 shard 通过并行 range 下载续传完成。
- 已为 `weights/LongCat-Video-Avatar/chinese-wav2vec2-base` 补接 `pytorch_model.bin`，并验证 `Wav2Vec2ModelWrapper` 可正常加载；`weights/LongCat-Video-Avatar/vocal_separator/Kim_Vocal_2.onnx` 已从现有模型复用接入。

## 测试结果
- 自动触发的首轮运行在输出阶段失败：`get_audio_duration()` 直接调用 `ffprobe`，而 base wrapper 环境里没有 `ffprobe` 在 PATH 中。
- 已在 `models/LongCat-Video/longcat_video/audio_process/torch_utils.py` 为 `get_audio_duration()` 增加 fallback：优先 `ffprobe`，缺失时对 `.wav` 走 `wave` / `librosa`。
- 修复后重跑通过：输出 `test/longcat-video-avatar/output/ai2v_demo_1.mp4`。
- 输出大小：`457K`
- 日志文件：`test/longcat-video-avatar/output/longcat_video_avatar_minimal.log`
- 运行时长：`709s`
- 监控峰值显存：`57540 MiB`
- 输出特征：约 `5.03s`、`640x608`、`16 fps`

## 存储观察
- LongCat 权重补齐并完成最小测试后，`/root/autodl-tmp` 占用升至 `98%`，剩余约 `39G`。
- 如需继续推进新的大模型下载，优先考虑清理暂缓模型环境（如 `hunyuan-avatar-env`、`skyreels-env`）或扩容数据盘。

## 结论
- LongCat-Video-Avatar 已完成 Phase 2 / 2.2.1 最小素材推理验证。
- 当前单卡 A800 80G 的稳定路径为：base Python wrapper + `PYTHONPATH` + `--context_parallel_size=1` + `--num_inference_steps 8`。
