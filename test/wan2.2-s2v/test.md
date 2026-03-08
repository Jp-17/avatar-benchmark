# Wan2.2-S2V 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：Wan2.2-S2V
- 当前状态：✅ 已通过
- 环境：wan2.2-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v/test_wan22_s2v.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v/output/wan2.2_s2v_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/wan2.2-s2v/input/I013.png
- 音频：test/wan2.2-s2v/input/A007_5s.wav
- 文本：test/wan2.2-s2v/input/P011.txt
- 输出目录：test/wan2.2-s2v/output/

### 运行资源与时间
- 运行时间：777 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v/test_wan22_s2v.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir "$CKPT" --offload_model True --convert_model_dtype --prompt "$PROMPT" --image "$IMG" --audio "$AUDIO" --save_file "$OUT_MP4" --num_clip 1 >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/wan2.2-s2v/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/wan2.2-s2v/output/wan2.2_s2v_minimal.mp4

### 遇到的问题
- 最初 --size 704*384 不在允许列表。

### 解决方案
- 已调整为 832*480，最小推理通过。
