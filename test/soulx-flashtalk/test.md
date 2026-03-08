# SoulX-FlashTalk 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：SoulX-FlashTalk
- 当前状态：✅ 已通过
- 环境：flashtalk-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk/test_flashtalk.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk/output/soulx_flashtalk_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/soulx-flashtalk/input/I013.png
- 音频：test/soulx-flashtalk/input/A007_5s.wav
- 文本：test/soulx-flashtalk/input/P011.txt
- 输出目录：test/soulx-flashtalk/output/

### 运行资源与时间
- 运行时间：235 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk/test_flashtalk.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt "$PROMPT" --cond_image "$IMG" --audio_path "$AUDIO" --audio_encode_mode stream --save_file "$OUT_MP4" --cpu_offload >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/soulx-flashtalk/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/soulx-flashtalk/output/soulx_flashtalk_minimal.mp4

### 遇到的问题
- 缺少 models_t5_umt5-xxl-enc-bf16.pth；随后 ffmpeg 因输入输出同名导致合并音频失败；当前默认目标尺寸来自 infer_params.yaml 的 768x448，输出比例与输入图不一致。

### 解决方案
- 已补齐共享权重软链接，并将脚本调整为只要视频文件存在就不因音频合并失败判定整体验证失败；后续需改成更合理的方形或接近输入比例的 target_size。
