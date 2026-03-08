# Hallo3 测试记录

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：Hallo3
- 当前状态：✅ 已通过
- 环境：hallo3-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/hallo3/test_hallo3.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/hallo3/output/hallo3_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/hallo3/input/I013.png
- 音频：test/hallo3/input/A007_5s.wav
- 文本：test/hallo3/input/P011.txt
- 输出目录：test/hallo3/output/

### 运行资源与时间
- 运行时间：1385 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/hallo3/test_hallo3.sh
- 核心推理命令：

    见脚本正文

### 运行配置与素材要求
- 固定素材来自 test/hallo3/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/hallo3/output/hallo3_minimal.mp4

### 遇到的问题
- 此前 Phase 4 批测受 GPU 冲突中断；本轮最小素材链路已单独跑通。

### 解决方案
- 单独拆出最小推理脚本后重新验证，最终成功生成输出。
