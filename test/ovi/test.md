# Ovi 推理测试报告

## 基本信息
- 环境：ovi-env (conda)
- 权重大小：68G（含3个模型变体各22G + Wan2.2-TI2V-5B 15G + MMAudio）
- 显存需求：~24G（qint8 + cpu_offload 模式）
- 推理类型：text+img → video+audio（双骨干音视频同步生成）
- 模型参数：11.66B (Fusion)

## 模型变体
| 变体 | 文件 | 大小 |
|------|------|------|
| 基础 | model.safetensors | 22G |
| 960x960 | model_960x960.safetensors | 22G |
| 960x960_10s | model_960x960_10s.safetensors | 22G |

## 测试素材
- 图像：input/avatar_img/half_body/I001.png
- 文本：含 <S>...<E> 语音标签和 Audio: 音频描述的 prompt
- 模式：i2v (image-to-video)
- 分辨率：960x960, 30步, seed=42

## 推理命令
```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/envs/ovi-env
cd /root/autodl-tmp/avatar-benchmark/models/Ovi
python3 inference.py --config-file test/ovi/inference_test.yaml
```

## 配置 (inference_test.yaml)
```yaml
ckpt_dir: models/Ovi/ckpts
model_name: "960x960_10s"
mode: "i2v"
cpu_offload: True
qint8: True
sample_steps: 30
solver_name: unipc
shift: 5.0
video_guidance_scale: 4.0
audio_guidance_scale: 3.0
video_frame_height_width: [960, 960]
seed: 42
```

## 结果
- 引擎加载：**成功**（~2.5分钟加载，初始GPU 2G）
- 组件加载顺序：VAE → T5 text encoder → Fusion checkpoint
- 是否成功推理：**否**（进程被 watchdog 终止，推理未开始）
- 输出文件：未生成

## 问题与解决
1. **CPU offload 生效**：初始 GPU 仅占 2G，模型在 CPU 上
2. **python3.10 被替换**：Cursor agent 将 ovi-env/bin/python3.10 替换为 `exit 0`
3. **修复方法**：从 hallo3-env 复制 python3.10 二进制恢复

## 待办
- 等GPU可用后重新运行推理
- 预计推理时间：待确认（引擎加载~2.5min，推理步骤时间未知）
- 可尝试 fp8: True 替代 qint8 看是否兼容

*最后更新: 2026-03-07*

---

## Phase 2 最小推理验证（2026-03-07）

### 基本信息
- 模型名称：Ovi
- 当前状态：✅ 已通过
- 环境：ovi-env
- 脚本路径：/root/autodl-tmp/avatar-benchmark/test/ovi/test_ovi.sh
- 日志路径：/root/autodl-tmp/avatar-benchmark/test/ovi/output/ovi_minimal.log
- 是否完成 Phase 4：无

### 固定输入素材
- 图片：test/ovi/input/I013.png
- 音频：test/ovi/input/A007_5s.wav
- 文本：test/ovi/input/P011.txt
- 输出目录：test/ovi/output/

### 运行资源与时间
- 运行时间：846 秒
- 说明：本节仅记录 Phase 2 的最小素材推理验证，不代表 Phase 4 正式横评已启动。

### 实际运行命令
- 启动命令：bash /root/autodl-tmp/avatar-benchmark/test/ovi/test_ovi.sh
- 核心推理命令：

    python inference.py --config-file "$CONFIG" >> "$LOG" 2>&1

### 运行配置与素材要求
- 固定素材来自 test/ovi/input/，图片统一为 half_body/I013.png，音频统一为 A007_5s.wav。
- 若脚本读取文本 prompt，则统一使用 P011.txt。
- 关键参数、config 路径、分辨率、帧数、step 等配置以脚本中的核心推理命令为准。

### 当前输出
- /root/autodl-tmp/avatar-benchmark/test/ovi/output/ovi_minimal.mp4

### 遇到的问题
- 最小推理采用 qint8 + cpu_offload 路径，以降低显存占用。

### 解决方案
- 保留最小素材和固定配置，验证单卡 A800 上的基础推理链路。
