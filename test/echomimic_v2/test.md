# EchoMimic v2 推理结果记录

## 模型信息

- **模型名称**：EchoMimicV2
- **环境**：echomimic2-env（torch 2.5.1+cu121）
- **推理脚本**：
- **分辨率**：768×768（fp16）

## 实际运行命令

### 单条件命令格式
```bash
cd /root/autodl-tmp/avatar-benchmark/models/echomimic_v2
conda run --no-capture-output -p /root/autodl-tmp/envs/echomimic2-env \
    python infer_acc.py \
    --config /tmp/em2_phase4_<COND>.yaml \
    -W 768 -H 768 -L <FRAMES> \
    --seed 420 --steps 6 --fps 24
```

### 帧数计算
EchoMimic v2 使用  序列（336帧），输出帧数受限于：

- 24fps × 14s = 336 帧（pose/01/ 最大帧数上限）
- 超过 14s 的条件均输出 14s（336帧）

### 批处理脚本
- 批处理脚本：（自动为每个 Condition 生成 YAML 并运行）
- 日志：

## 使用的素材

| Condition | 参考图像 | 音频文件 | 帧数(-L) | 实际时长 |
|-----------|---------|---------|---------|---------|
| C_zh_5s   | input/avatar_img/half_body/I001.png | audio/trimmed/A001_5s.wav  | 120 | 5s |
| C_zh_10s  | 同上 | audio/trimmed/A001_10s.wav | 240 | 10s |
| C_zh_30s  | 同上 | audio/trimmed/A001_30s.wav | 336 | 14s（pose上限） |
| C_zh_1m   | 同上 | audio/trimmed/A001_1m.wav  | 336 | 14s（pose上限） |
| C_en_5s   | 同上 | audio/trimmed/A007_5s.wav  | 120 | 5s |
| C_en_10s  | 同上 | audio/trimmed/A007_10s.wav | 240 | 10s |
| C_en_30s  | 同上 | audio/trimmed/A007_30s.wav | 336 | 14s（pose上限） |
| C_en_1m   | 同上 | audio/trimmed/A007_1m.wav  | 336 | 14s（pose上限） |
| C_en_3m   | 同上 | audio/trimmed/A007_3m.wav  | 336 | 14s（pose上限） |
| C_en_5m   | 同上 | audio/trimmed/A007_5m.wav  | 336 | 14s（pose上限） |
| C_sing_zh | 同上 | audio/singing/S001_jaychou.wav | 240 | 10s |
| C_sing_en | 同上 | audio/singing/S002_adele.wav   | 205 | 8.6s |

Pose 序列统一使用：（336 帧 npy 文件）

## 配置参数

| 参数 | 值 |
|------|-----|
| width | 768 |
| height | 768 |
| steps | 6（accelerated DDIM） |
| fps | 24 |
| seed | 420 |
| weight_dtype | fp16 |
| context_frames | 12（默认） |
| context_overlap | 3（默认） |

## 遇到的问题与解决方法

1. **transformers 版本冲突（关键）**
   - 问题：echomimic2-env 的 transformers==5.3.0 删除了 ，导致 diffusers 0.31.0 导入失败
   - 报错：
   - 解决：将 transformers 降级到 4.44.2（同时 huggingface-hub 降级到 0.36.2，tokenizers 降级到 0.19.1）

2. **wav2vec2 符号链接失效**
   - 问题： 指向的  路径不存在
   - 解决：重新指向 StableAvatar 已有的权重：

3. **audio_mapper-50000.pth 缺失**
   - 状态：YAML config 中有该路径，但 infer_acc.py 代码中未实际加载（不影响推理）

4. **AutoFlow 路径缺失**
   - 状态：同上，YAML 中配置但代码未使用

5. **pose 序列最大 336 帧（14s @ 24fps）**
   - 所有超过 14s 的条件自动截断为 336 帧（14s）

## 产出结果

| Condition | 状态 | 输出路径 | 文件大小 |
|-----------|------|---------|----------|
| C_zh_5s   | done | output/echomimic_v2/C_zh_5s.mp4  | 745KB |
| C_zh_10s  | done | output/echomimic_v2/C_zh_10s.mp4 | 1.5MB |
| C_zh_30s  | done | output/echomimic_v2/C_zh_30s.mp4 | 2.1MB |
| C_zh_1m   | done | output/echomimic_v2/C_zh_1m.mp4  | 2.1MB |
| C_en_5s   | done | output/echomimic_v2/C_en_5s.mp4  | 746KB |
| C_en_10s  | done | output/echomimic_v2/C_en_10s.mp4 | 1.5MB |
| C_en_30s  | done | output/echomimic_v2/C_en_30s.mp4 | 2.1MB |
| C_en_1m   | done | output/echomimic_v2/C_en_1m.mp4  | 2.1MB |
| C_en_3m   | done | output/echomimic_v2/C_en_3m.mp4  | 2.1MB |
| C_en_5m   | done | output/echomimic_v2/C_en_5m.mp4  | 2.1MB |
| C_sing_zh | done | output/echomimic_v2/C_sing_zh.mp4 | 1.5MB |
| C_sing_en | done | output/echomimic_v2/C_sing_en.mp4 | 1.3MB |

**12/12 全部完成** - 注意超过14s的条件因pose帧上限被截断为14s。

*最后更新：2026-03-07*

---

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：EchoMimic v2
- 当前状态：✅ 已通过
- 环境：echomimic2-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/echomimic_v2/test_echomimic_v2.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/echomimic_v2/output/echomimic_v2_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/echomimic_v2/input/I013.png
- 音频：test/echomimic_v2/input/A007_5s.wav
- 文本：无
- 输出目录：test/echomimic_v2/output/

### 运行资源与时间
- 运行时间：93 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/echomimic_v2/test_echomimic_v2.sh
- 核心推理命令：

    /root/miniconda3/bin/conda run --no-capture-output -p "$ENV" python infer_acc.py --config "$CONFIG" -W 768 -H 768 -L 120 --seed 420 --steps 6 --fps 24 >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/echomimic_v2/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/echomimic_v2/output/echomimic_v2_minimal.mp4

### 遇到的问题
- 已按最小素材规范单独生成一轮验证输出。

### 解决方案
- 当前最小链路可直接复用 test/echomimic_v2/test_echomimic_v2.sh。
