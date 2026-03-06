## 2026-03-05 今日

### 任务内容
1. 配置本地到服务器的 SSH 免密登录
2. 检查远程项目目录 /root/autodl-tmp/avatar-benchmark 是否存在（已存在）
3. 读取远程 claude.md 和 progress.md，了解项目状态
4. 检查远程 git 仓库连接状态（已连接 git@github.com:Jp-17/avatar-benchmark.git）
5. 将本地 prompt-1-20260305.md 同步到远程服务器
6. 完成项目首次 git 初始化提交，推送到 GitHub（master 分支）

### 结果与效果
- SSH 免密登录配置成功
- 远程 git 仓库 GitHub SSH 认证正常
- 三个文件（claude.md、progress.md、prompt-1-20260305.md）已成功推送到 GitHub

### 遇到的问题与解决方法
- 无明显问题，流程顺畅
## 2026-03-05 19:30

### 任务内容
执行 Phase 2 环境配置（部分完成）：
1. 配置 ~/.condarc，将 conda envs 和 pkgs 目录映射到 autodl-tmp（避免 /root 30G 磁盘满）
2. 创建 unified-env conda 环境（Python 3.10），存储路径 /root/autodl-tmp/envs/unified-env
3. 安装 PyTorch 2.5.1 + CUDA 12.1（torch-2.5.1+cu121，cuda 可用）
4. 启动公共依赖安装（transformers/accelerate/diffusers 等，安装中）
5. 克隆 3 个优先级 A 模型仓库（--depth=1）：stableavatar、livetalk、echomimic_v2

### 结果与效果
- conda 目录映射配置成功
- unified-env 创建成功，PyTorch 2.5.1+cu121 安装完成并验证 CUDA 可用
- 3 个模型仓库已克隆到 models/ 目录
- 公共依赖安装进行中（网络限速导致部分包下载缓慢）

### 遇到的问题与解决方法
1. SSH 免密登录失效：~/.ssh 目录权限为 755（应为 700），修复后恢复正常
2. pip 安装时网络超时：某些包下载缓慢（约 20KB/s），pip 自动重试，最终完成
3. git clone 失败（首次）：网络中断导致 EOF，改用 --depth=1 浅克隆后成功
4. 发现网络限制：GitHub（http:000）和 HuggingFace（http:000）直连受限；pypi.org 可用（25KB/s）；阿里云 pypi 镜像和 ModelScope 均可正常访问

## 2026-03-05 22:50

### 任务内容
执行 Phase 2 剩余环境配置与权重下载：
1. 启用网络加速（source /etc/network_turbo），GitHub 539KB/s，HuggingFace 直连失败改用 hf-mirror.com
2. 克隆 echomimic_v2（SSH 协议，HTTPS 不稳定）
3. 创建三个独立 conda 环境（各模型依赖版本冲突无法共用 unified-env）：
   - echomimic2-env：Python 3.10 + torch 2.5.1+cu121 + diffusers 0.31.0 + 全部推理依赖
   - stableavatar-env：Python 3.10 + torch 2.7.0+cu128 + 全部推理依赖
   - livetalk-env：Python 3.10 + torch 2.10.0+cu128 + 全部推理依赖
4. LiveTalk 额外配置：克隆 OmniAvatar，应用 patches，安装 flash-attn，setup.py develop
5. 启动 3 个权重后台下载任务：
   - EchoMimic v2: ModelScope 下载，11GB，完成
   - StableAvatar: hf-mirror 下载 FrancisRing/StableAvatar（含所有 checkpoints），下载中
   - LiveTalk: hf-mirror 下载 LiveTalk-1.3B-V0.1，ModelScope 下载 Wan2.1-T2V-1.3B，hf-mirror 下载 wav2vec2

### 结果与效果
- 三个环境均安装完成，torch import 验证通过
- EchoMimic v2 权重 11GB 完整下载
- StableAvatar 权重 17GB+ 下载中（预计另需 1-2h）
- LiveTalk wav2vec2 下载完成（721MB），Wan2.1-T2V-1.3B 下载中

### 遇到的问题与解决方法
1. HuggingFace 直连超时：改用 hf-mirror.com（设置 HF_ENDPOINT 环境变量）
2. git clone HTTPS 不稳定：改用 SSH 协议（需提前 source /etc/network_turbo）
3. torch cu128 下载慢（>2h）：cu128 wheel 捆绑了大量 CUDA 库包（总 6-8GB），正常现象
4. gradio 下载失败（echomimic2-env）：跳过 gradio（推理不需要），仅安装核心依赖
5. huggingface_hub 版本冲突（transformers 5.3.0 需要 >=1.3.0，echomimic2 要求 0.26.2）：升级为 >=1.3.0
6. SSH session 中 CUDA 不可用：NVIDIA_VISIBLE_DEVICES 为空，/dev/nvidia0 未挂载。GPU 仅在 JupyterLab 终端可访问，推理验证需在那里执行
7. conda install ffmpeg OOM kill：改用 pip install imageio-ffmpeg
8. Wan2.1-T2V-1.3B hf-mirror 超时：改用 ModelScope 下载

## 2026-03-05 23:40

### 任务内容
完成 Phase 2 全部权重下载（主要是 StableAvatar 的 Wan2.1-Fun 权重）

### 结果与效果
**Phase 2 权重下载全部完成：**
- EchoMimic v2：11GB，models/echomimic_v2/weights/BadToBest/EchoMimicV2/ ✅
- StableAvatar：~30GB，models/stableavatar/weights/StableAvatar/ ✅
  - Wan2.1-Fun-V1.1-1.3B-InP/diffusion_pytorch_model.safetensors (3.0GB)
  - Wan2.1-Fun-V1.1-1.3B-InP/models_t5_umt5-xxl-enc-bf16.pth (11GB)
  - Wan2.1-Fun-V1.1-1.3B-InP/models_clip_open-clip-xlm-roberta-large-vit-huge-14.pth (4.5GB)
  - Wan2.1-Fun-V1.1-1.3B-InP/Wan2.1_VAE.pth (485MB)
  - StableAvatar-1.3B/transformer3d-square.pt + transformer3d-rec-vec.pt (各 3.5GB)
  - wav2vec2-base-960h, Kim_Vocal_2.onnx 等
- LiveTalk：17GB+，models/livetalk/weights/ ✅（上一个 session 已完成）
磁盘总用量：90GB / 200GB

### 遇到的问题与解决方法
**关键发现：network_turbo 代理阻断 XetHub CDN**
- 问题：`source /etc/network_turbo` 设置的代理会导致访问 HuggingFace 新 XetHub CDN（cas-bridge.xethub.hf.co）时 SSL 握手超时（503/TLS error）
- 表现：hf-mirror.com 能正常返回 302 重定向，但最终的 CDN 下载失败
- 原因：较新的 HuggingFace 仓库使用 XetHub 存储格式，通过美国 CDN 提供；network_turbo 代��干扰了这条链路
- 解决：**不运行 network_turbo，直接用 hf-mirror.com 下载 XetHub 格式的 HF 文件**（`HF_ENDPOINT=https://hf-mirror.com`，但不设置代理）
- 规律：ModelScope 下载 → 可以用 network_turbo；HF XetHub 文件 → 不能用 network_turbo

**Wan2.1-Fun 不在 ModelScope 上**
- 尝试了多个 ID：Wan-AI/Wan2.1-Fun-V1.1-1.3B-InP、iic/... 等均 404
- 只能从 FrancisRing/StableAvatar HuggingFace 仓库下载

## 2026-03-06 10:00

### 任务内容
结合 plan.md 和 model.md（最新版 2026-03-06 15:30 更新）盘点 Phase 2 实际完成情况，确认各模型环境与权重的真实状态。

### 结果与效果
**Phase 2 完全完成的模型（环境+代码+全量权重）共 3 个：**
- EchoMimic v2：echomimic2-env ✅，权重 11GB（ModelScope）
- StableAvatar：stableavatar-env ✅，权重 26GB（HF）
- LiveTalk：livetalk-env ✅，权重 23GB（HF）

**其余模型状态：**
- FantasyTalking / LiveAvatar / OmniAvatar-14B：仅 adapter/LoRA 已下（3.7G/1.3G/1.2G），基底模型（Wan2.1-I2V-14B-720P / Wan2.2-S2V-14B / Wan2.1-T2V-14B）未完成
- Hallo3：权重下载中（7/35 文件，20%）
- InfiniteTalk + Wan2.1-I2V-14B-480P（共享）：下载中（6/24 文件，25%）
- SoulX-FlashTalk / HunyuanVideo-Avatar / MultiTalk / LongCat-Video-Avatar：下载进程已死，需重启
- P3（LTX-2/OVI/MOVA）/ P4（Wan2.2/HunyuanVideo-1.5/Self-Forcing/LongLive/SkyReels-V3）：多数 torch 环境未完成安装，权重待下载
- 4 个环境尚未安装 torch：longcat-env / mova-env / ltx2-hunyuan15-env / skyreels-env
- flash_attn 待 JupyterLab 安装：wan2.2-env / longcat-env / liveavatar-env / unified-env(InfiniteTalk) / skyreels-env

### 遇到的问题与解决方法
无新问题，本次为状态盘点，未执行新操作。
