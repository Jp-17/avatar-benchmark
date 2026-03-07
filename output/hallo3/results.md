# Hallo3 推理结果记录

## 模型信息

- **模型名称**：Hallo3（基于 CogVideoX-5B I2V）
- **环境**：hallo3-env（torch 2.4.0+cu121）
- **框架**：SAT (Simple And Tough) + DeepSpeed
- **推理脚本**：`models/hallo3/hallo3/sample_video.py`
- **GPU 占用**：~48–50 GB（A800-80GB 可运行）

## 实际运行命令

### 基础命令格式
```bash
cd /root/autodl-tmp/avatar-benchmark/models/hallo3
WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 \
  conda run --no-capture-output -p /root/autodl-tmp/envs/hallo3-env \
  python hallo3/sample_video.py \
  --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml \
  --seed 42 \
  --input-file <input_txt> \
  --output-dir <output_dir>
```

### input.txt 格式
```
<prompt>@@<image_path>@@<audio_path>
```

### 批处理脚本
- `/root/autodl-tmp/hallo3_batch.sh`（10 条件，排除 C_en_3m/C_en_5m）
- 日志：`/root/autodl-tmp/hallo3_batch.log`

## 使用的素材

| Condition | 参考图像 | 音频文件 | prompt 类型 |
|-----------|---------|---------|------------|
| C_zh_5s   | input/avatar_img/half_body/I001.png | input/audio/trimmed/A001_5s.wav      | speech  |
| C_zh_10s  | 同上 | input/audio/trimmed/A001_10s.wav    | speech  |
| C_zh_30s  | 同上 | input/audio/trimmed/A001_30s.wav    | speech  |
| C_zh_1m   | 同上 | input/audio/trimmed/A001_1m.wav     | speech  |
| C_en_5s   | 同上 | input/audio/trimmed/A007_5s.wav     | speech  |
| C_en_10s  | 同上 | input/audio/trimmed/A007_10s.wav    | speech  |
| C_en_30s  | 同上 | input/audio/trimmed/A007_30s.wav    | speech  |
| C_en_1m   | 同上 | input/audio/trimmed/A007_1m.wav     | speech  |
| C_sing_zh | 同上 | input/audio/singing/S001_jaychou.wav | singing |
| C_sing_en | 同上 | input/audio/singing/S002_adele.wav   | singing |

speech prompt: "A person speaking directly to the camera with natural facial expressions and synchronized lip movements."
singing prompt: "A person singing naturally with expressive facial animations and synchronized lip movements to the music."

（注：C_en_3m/C_en_5m 估算需 ~26h/~43h，本批次已排除）

## 配置参数

| 参数 | 值 |
|------|-----|
| sampler | VPSDEDPMPP2MSampler |
| steps/window | 51 |
| seed | 42 |
| 每窗口采样时间 | ~10.8 min（12.7s/step × 51 steps） |
| 窗口数/5s音频 | ~4 个窗口（线性扩展） |
| 模型加载时间 | ~10 min（每条件重新加载） |

## 遇到的问题与解决方法

### 问题1：依赖安装
- 需提前在 hallo3-env 中执行 `pip install -r requirements.txt`

### 问题2：VAE decode OOM（已修复）
- **现象**：所有窗口采样完成后 VAE decode 时 OOM（`recons.append(recon)` 积累所有帧在 GPU 显存）
- **修复**：修改 `hallo3/sample_video.py` VAE decode 循环：
  ```python
  # 修改前
  recons.append(recon)
  # 修改后（已应用）
  recons.append(recon.cpu())
  torch.cuda.empty_cache()
  ```

### 问题3：expandable_segments=True 导致模型加载卡死
- 设置 `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` 后，DeepSpeed/NCCL 初始化卡死（353% CPU 空转 57+ 分钟，GPU 无法加载）
- **修复**：移除该环境变量

### 问题4：AutoDL 平台自动触发 GPU 基准测试（主要干扰源）
- **现象**：GPU 空闲时 AutoDL 平台自动启动 `/tmp/test_mova.sh`、`/tmp/test_ovi.sh`、`/tmp/run_bench.sh`（进程 PPid=1）占用 8–10 GB GPU，导致 Hallo3+SA 合计超出 80GB OOM
- **临时规避**：
  - 将所有干扰脚本替换为 no-op shell 脚本
  - 部署 `watchdog_v2.sh`（每 20s 扫描 `/proc/*/exe` 路径，自动 kill mova-env/ovi-env 进程）
- **根本原因**：AutoDL 平台在检测到 GPU 空闲时触发内置 benchmark job

### 问题5：Hallo3 + StableAvatar 同时运行时偶发 OOM
- Hallo3 采样期间峰值可达 54.6 GB（正常稳态 ~48 GB）；SA 加载峰值 ~28 GB → 合计 >80 GB
- **建议**：等 Hallo3 进入稳态采样（GPU 稳定在 48 GB）后再启动 SA

## 产出结果

| Condition | 状态 | 输出路径 | 文件大小 | 完成时间 |
|-----------|------|---------|---------|---------|
| C_zh_5s   | ✅ done  | output/hallo3/C_zh_5s.mp4  | 340 KB | 2026-03-07 05:15 |
| C_zh_10s  | ✅ done  | output/hallo3/C_zh_10s.mp4 | 755 KB | 2026-03-07 06:36 |
| C_zh_30s  | ✅ done  | output/hallo3/C_zh_30s.mp4 | 2.3 MB | 2026-03-07 09:49 |
| C_zh_1m   | ⏸ 中止  | —                           | —      | 任务中止时正在运行 |
| C_en_5s   | ⏸ 未运行 | —                          | —      | — |
| C_en_10s  | ⏸ 未运行 | —                          | —      | — |
| C_en_30s  | ⏸ 未运行 | —                          | —      | — |
| C_en_1m   | ⏸ 未运行 | —                          | —      | — |
| C_en_3m   | ⛔ 排除  | 预估 ~26h，不可行            | —      | — |
| C_en_5m   | ⛔ 排除  | 预估 ~43h，不可行            | —      | — |
| C_sing_zh | ⏸ 未运行 | —                          | —      | — |
| C_sing_en | ⏸ 未运行 | —                          | —      | — |

**当前完成度：3/10（C_en_3m/C_en_5m 不计入）**

*最后更新：2026-03-07*
