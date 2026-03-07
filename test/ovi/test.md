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
