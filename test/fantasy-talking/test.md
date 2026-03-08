# FantasyTalking 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：FantasyTalking
- 当前状态：✅ 已通过
- 环境：fantasy-talking-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/fantasy-talking/test_fantasy_talking.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/fantasy-talking/output/fantasy_talking_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/fantasy-talking/input/I013.png
- 音频：test/fantasy-talking/input/A007_5s.wav
- 文本：test/fantasy-talking/input/P011.txt
- 输出目录：test/fantasy-talking/output/

### 运行资源与时间
- 运行时间：972 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/fantasy-talking/test_fantasy_talking.sh
- 核心推理命令：

    python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path "$IMG" --audio_path "$AUDIO" --prompt "$PROMPT" --output_dir "$OUTPUT_DIR" --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42 >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/fantasy-talking/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/fantasy-talking/output/fantasy_talking_minimal.mp4

### 遇到的问题
- 最初参数名写成 --wav2vec_dir，和仓库实际 CLI 不一致。

### 解决方案
- 已修正为 --wav2vec_model_dir，最小推理通过。
