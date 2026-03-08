# LiveTalk 推理结果记录

## 模型信息

- **模型名称**：LiveTalk-1.3B-V0.1
- **环境**：livetalk-env（torch 2.10.0+cu128）
- **推理脚本**：`models/livetalk/scripts/inference_example.py`
- **配置文件**：`models/livetalk/configs/phase4_base.yaml`

## 遇到的问题与解决方法

### 问题1：transformers 版本不兼容
- **错误**：`cannot import name 'FLAX_WEIGHTS_NAME' from 'transformers.utils'`
- **原因**：livetalk-env 中 transformers==5.3.0 与 diffusers==0.31.0 不兼容
- **解决**：`conda run -p /root/autodl-tmp/envs/livetalk-env pip install 'transformers==4.51.3'`

### 问题2：flash_attn ABI 不兼容
- **错误**：`undefined symbol: _ZN3c104cuda29c10_cuda_check_implementationEiPKcS2_ib`
- **原因**：已安装的 flash_attn 与 torch 2.10.0+cu128 ABI 不兼容
- **解决**：`conda run -p /root/autodl-tmp/envs/livetalk-env pip uninstall flash-attn -y`（LiveTalk 不强依赖 flash_attn）

### 问题3：demo_utils 模块找不到
- **错误**：`ModuleNotFoundError: No module named 'demo_utils'`
- **原因**：inference_example.py 依赖 OmniAvatar 子目录中的 demo_utils
- **解决**：在运行时添加 `env PYTHONPATH=$PROJ:$PROJ/OmniAvatar`

### 问题4：video_duration 断言失败
- **错误**：`AssertionError: assert num_frames % self.num_frame_per_block == 0`
- **原因**：LiveTalk 要求 `num_frames = 4*duration + 1` 能被 `num_frame_per_block=3` 整除
  - 条件：`(4*duration + 1) % 3 == 0`，即 `duration mod 3 == 2`（3n+2格式）
  - 有效值：2, 5, 8, 11, 14, 17, 20, 23, 26, 29, ..., 59, ..., 179, ..., 254, ...
- **解决**：将各 Condition 时长映射到最近的 3n+2 值

### 问题5：C_en_5m（299s）超出最大帧数限制（关键发现）
- **错误**：`RuntimeError: shape '[3, 1, 1, -1]' is invalid for input of size 22`
- **根因分析**：
  - `current_start = current_start_frame * frame_seq_length`（其中 `frame_seq_length=1024` = 每帧空间 token 数）
  - `self.freqs[0]` 是大小为 `frame_seq_length` 的 RoPE 频率表，以帧索引寻址
  - 对于 video_duration=299：num_frames = 4*299+1 = 1197 > 1024，越界截断
  - **错误尝试**：将 frame_seq_length 改为 2048 → 破坏 KV cache 的位置索引计算（step=3*2048=6144 ≠ num_new_tokens=3072），导致新错误 `RuntimeError: The expanded size of the tensor (0)`
- **结论**：**LiveTalk 最大支持 video_duration=254（≈4m14s）**
  - 限制：`num_frames = 4*duration+1 ≤ frame_seq_length=1024`，即 duration ≤ 255.75
  - 最大有效 3n+2 值：254（4*254+1=1017 ≤ 1024）
  - frame_seq_length 必须保持 1024（等于每帧空间 token 数），不可随意增大
- **处理方式**：C_en_5m 使用 video_duration=254（生成 4m14s 视频），音频使用完整 5m 文件（视频截取前 4m14s 内容）

### 问题6：C_sing_zh/en 文件路径错误
- **错误**：`FileNotFoundError: No such file or directory: '.../S001.wav'`
- **原因**：实际文件名含艺人名（S001_jaychou.wav、S002_adele.wav），批处理脚本使用了 S001.wav
- **解决**：retry 脚本使用正确路径 `S001_jaychou.wav`、`S002_adele.wav`

## 实际运行命令

### 基础命令格式
```bash
cd /root/autodl-tmp/avatar-benchmark/models/livetalk
conda run --no-capture-output -p /root/autodl-tmp/envs/livetalk-env \
    env PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/livetalk:/root/autodl-tmp/avatar-benchmark/models/livetalk/OmniAvatar \
    python scripts/inference_example.py \
    --config configs/phase4_base.yaml \
    --hparams audio_path=<AUDIO>,output_path=<OUTPUT>,video_duration=<DURATION>
```

### 批处理脚本
- 主批次脚本：`/root/autodl-tmp/livetalk_batch2.sh`（处理 C_zh_10s ~ C_sing_en）
- 修复重跑：`/root/autodl-tmp/livetalk_retry2.sh`（C_en_5m + C_sing_zh + C_sing_en）
- 日志：`/root/autodl-tmp/livetalk_C_<condition>.log`
- 修复日志：`/root/autodl-tmp/livetalk_C_<condition>_retry2.log`

## 使用的素材

| Condition | 参考图像 | 音频文件 | video_duration |
|-----------|---------|---------|----------------|
| C_zh_5s   | input/avatar_img/half_body/I001.png | input/audio/trimmed/A001_5s.wav  | 5   |
| C_zh_10s  | 同上 | input/audio/trimmed/A001_10s.wav | 11  |
| C_zh_30s  | 同上 | input/audio/trimmed/A001_30s.wav | 29  |
| C_zh_1m   | 同上 | input/audio/trimmed/A001_1m.wav  | 59  |
| C_en_5s   | 同上 | input/audio/trimmed/A007_5s.wav  | 5   |
| C_en_10s  | 同上 | input/audio/trimmed/A007_10s.wav | 11  |
| C_en_30s  | 同上 | input/audio/trimmed/A007_30s.wav | 29  |
| C_en_1m   | 同上 | input/audio/trimmed/A007_1m.wav  | 59  |
| C_en_3m   | 同上 | input/audio/trimmed/A007_3m.wav  | 179 |
| C_en_5m   | 同上 | input/audio/trimmed/A007_5m.wav  | **254**（最大支持，≈4m14s） |
| C_sing_zh | 同上 | input/audio/singing/S001_jaychou.wav | 11 |
| C_sing_en | 同上 | input/audio/singing/S002_adele.wav   | 8  |

## 配置参数（phase4_base.yaml）

| 参数 | 值 |
|------|-----|
| dtype | bf16 |
| fps | 16 |
| num_steps | 4 |
| seed | 42 |
| resolution | 512x512 |
| local_attn_size | 15 |
| num_transformer_blocks | 30 |
| frame_seq_length | **1024**（等于每帧空间token数，不可修改） |
| num_frame_per_block | 3 |
| denoising_step_list | [1000, 750, 500, 250] |

## 产出结果

| Condition | 状态 | 输出路径 | 时长 | 文件大小 |
|-----------|------|---------|------|---------|
| C_zh_5s   | done    | output/livetalk/C_zh_5s.mp4  | 5.06s | 711KB |
| C_zh_10s  | done    | output/livetalk/C_zh_10s.mp4 | ~11s  | 1.5MB |
| C_zh_30s  | done    | output/livetalk/C_zh_30s.mp4 | ~29s  | 4.6MB |
| C_zh_1m   | done    | output/livetalk/C_zh_1m.mp4  | ~59s  | 9.4MB |
| C_en_5s   | done    | output/livetalk/C_en_5s.mp4  | ~5s   | 745KB |
| C_en_10s  | done    | output/livetalk/C_en_10s.mp4 | ~11s  | 1.5MB |
| C_en_30s  | done    | output/livetalk/C_en_30s.mp4 | ~29s  | 4.3MB |
| C_en_1m   | done    | output/livetalk/C_en_1m.mp4  | ~59s  | 9.0MB |
| C_en_3m   | done    | output/livetalk/C_en_3m.mp4  | ~179s | 31MB  |
| C_en_5m   | killed  | output/livetalk/C_en_5m.mp4  | ~254s | —（进程被终止） |
| C_sing_zh | done    | output/livetalk/C_sing_zh.mp4 | ~11s  | 1.4MB |
| C_sing_en | done    | output/livetalk/C_sing_en.mp4 | ~8s   | 1.1MB |

*最后更新：2026-03-06*

---

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：LiveTalk
- 当前状态：✅ 已通过
- 环境：livetalk-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/livetalk/test_livetalk.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/livetalk/output/livetalk_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/livetalk/input/I013.png
- 音频：test/livetalk/input/A007_5s.wav
- 文本：test/livetalk/input/P011.txt
- 输出目录：test/livetalk/output/

### 运行资源与时间
- 运行时间：101 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/livetalk/test_livetalk.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" env PYTHONPATH=$MODEL_DIR:$MODEL_DIR/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config "$CONFIG" >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/livetalk/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/livetalk/output/livetalk_minimal.mp4

### 遇到的问题
- 最小推理已通过；历史长时长测试受 frame_seq_length 限制。

### 解决方案
- 最小验证使用固定 5 秒音频，不触发长时长限制。
