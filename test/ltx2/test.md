# LTX-2 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：LTX-2
- 当前状态：✅ 已通过
- 环境：.venv (uv)
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/ltx2/test_ltx2.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/ltx2/output/ltx2_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/ltx2/input/I013.png
- 音频：test/ltx2/input/A007_5s.wav
- 文本：test/ltx2/input/P011.txt
- 输出目录：test/ltx2/output/

### 运行资源与时间
- 运行时间：83 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/ltx2/test_ltx2.sh
- 核心推理命令：

    python -m ltx_pipelines.a2vid_two_stage --checkpoint-path "$WEIGHTS/ltx-2-19b-dev-fp8.safetensors" --gemma-root "$WEIGHTS" --distilled-lora "$WEIGHTS/ltx-2-19b-distilled-lora-384.safetensors" 0.0 --spatial-upsampler-path "$WEIGHTS/ltx-2-spatial-upscaler-x2-1.0.safetensors" --audio-path "$AUDIO_STEREO" --image "$IMG" 0 1.0 --prompt "$PROMPT" --output-path "$OUT_MP4" --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42 >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/ltx2/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/ltx2/output/ltx2_minimal.mp4

### 遇到的问题
- 首次失败于 fp8-cast 在当前 GPU 架构上不支持；移除该参数后，又暴露出 FP8 base checkpoint 与 stage-2 distilled LoRA 尺寸不匹配。

### 解决方案
- 当前已改为去掉 fp8-cast，并将 stage2 LoRA 强度临时降为 0.0；在该临时验证配置下，最小推理已成功生成 5.04 秒、512x512 的 mp4 输出。
