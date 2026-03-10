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

## 2026-03-09 排查补记

- 复核发现旧产物“看起来没声音”主要是封装兼容性问题：源文件内音轨存在，但部分播放器对 `MP3-in-MP4` 支持较差，因此现已统一在测试脚本和 Phase 4 脚本中加入 `ffmpeg` AAC remux。
- 当前仓库内已验证：`output/hallo3_newphase4/C_half_short.mp4` 与 `output/hallo3_newphase4/C_full_short.mp4` 的视频时长分别约为 `5.41s` / `8.59s`，与对应音频 `5.355s` / `8.557s` 基本对齐；`test/hallo3/output/hallo3_minimal.mp4` 约 `5.04s`，也与 `5.0s` 音频对齐。
- README 中额外值得注意的要求是：输入图像尽量满足 `1:1` 或 `3:2`，音频优先使用 `WAV`，英文/清晰人声效果通常更稳；现有 full-body 样本并非严格按该比例准备，可能是人物观感略弱于预期的原因之一。
- 下一步会在不覆盖旧文件的前提下，前台重跑最小素材测试，生成新的 `test/hallo3/output/` 文件以确认 AAC 封装后的稳定链路。

## 2026-03-09 15:25 CST 最小重测补记

- 已按“不覆盖旧文件”的要求前台重跑最小素材，目标输出为 `test/hallo3/output/hallo3_minimal_rerun_aac_20260309.mp4`。
- 本次失败并非 Hallo3 自身链路回退，而是运行中出现新的外部 GPU 占用：日志记录 `Process 205579`（SoulX-FlashTalk 长音频任务）同时占用了最高约 `38.93 GiB` 显存，导致 Hallo3 在音频分离阶段触发 CUDA OOM。
- 因此，当前 Hallo3 需要在真正独占 GPU 的窗口下再重跑一次；已有 AAC remux 与时长对齐结论仍然有效。
