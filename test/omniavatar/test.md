# OmniAvatar 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：OmniAvatar
- 当前状态：✅ 已通过
- 环境：omniavatar-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/omniavatar/test_omniavatar.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/omniavatar/output/omniavatar_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/omniavatar/input/I013.png
- 音频：test/omniavatar/input/A007_5s.wav
- 文本：test/omniavatar/input/P011.txt
- 输出目录：test/omniavatar/output/

### 运行资源与时间
- 运行时间：约 56 分 55 秒（主体推理）
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/omniavatar/test_omniavatar.sh
- 核心推理命令：

    torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file "$INPUT_FILE" >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/omniavatar/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/omniavatar/output/omniavatar_minimal.mp4

### 遇到的问题
- 首次重试已跑完整个主体推理流程，但先后遇到两类后处理问题：imageio 缺少视频 backend，以及仓库代码把 ffmpeg 写死成了 /usr/bin/ffmpeg。

### 解决方案
- 已在 omniavatar-env 安装 imageio-ffmpeg，并将代码中的 ffmpeg 调用改为使用 PATH 中的 ffmpeg；同时利用已生成的 result_000_000.mp4 与 audio_out_000.wav 手工合成最终 omniavatar_minimal.mp4。
