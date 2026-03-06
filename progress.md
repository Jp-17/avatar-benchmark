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

## 2026-03-05 23:30

### 任务内容
Phase 3 素材收集初步执行：
1. 创建 input/ 目录结构（audio/speech, audio/singing, avatar_img/half_body, avatar_img/full_body, prompt）
2. 从各模型 demo repo 下载音频：A001-A007（7 个语音文件，包含中英文）
3. 从各模型 demo repo 下载半身图片：I001-I006（EchoMimic/StableAvatar/FantasyTalking/Hallo3/OmniAvatar）
4. 从 FantasyTalking 和 StableAvatar 下载全身图片候选：I007/I008（需用户确认）
5. 创建 7 个 prompt 文本文件（P001-P007：演讲/下棋/弹琴/跳舞/微笑/愤怒/悲伤）
6. 写入完整 input.md（含 Condition 组合规划）
7. 配置 GitHub SSH（公钥已由用户添加），切换 remote URL 为 SSH

### 结果与效果
- 英文长时语音获取成功：A007.wav（LiveAvatar boy demo，353s=5.88min，英文）
- 中英文短时语音均有备份，可支持 5s-1min 档位测试
- 7 个 prompt 文件创建完成

### 遇到的问题与解决方法
- **中文长时语音缺口**：YouTube/archive.org 不可访问；HuggingFace 音频数据集均为 parquet 格式无法直接下载单文件；ModelScope AISHELL-3 无音频实体文件。最终 A001（100s 中文）仅支持到 1min 测试，3min/5min 中文档位待补充
- **唱歌音频缺口**：模型 demo 中无符合要求的唱歌音频（Wan2.2 sing.MP3 仅 18.8s）
- **图片分类待确认**：I007/I008 是否全身像、I004/I005 分辨率是否足够，需用户检视

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

## 2026-03-06 01:30

### 任务内容
Phase 3 素材补充收集：图片审查与大规模候选扩充
1. 逐一查看已有 I001-I008 全部图片，发现问题：I004（儿童野外图）、I007（demo 对比截图）为错误素材；I008 分类为 full_body 但实为半身
2. 从 SadTalker、AniPortrait、EchoMimic v2 refimag set、MimicMotion、UniAnimate 共 5 个源下载候选图片
3. 逐一视觉审查所有候选，筛选质量：LivePortrait 来源的均为名画/艺术品，排除；EchoMimic v2 ref 图质量极佳（1024×1024 AI生成标准半身）
4. 新增候选目录 `input/avatar_img/candidates/`，存放 30+ 张候选图供用户挑选
5. 更新 input.md：为已有图标注审查结果、补充完整候选清单（含推荐等级）、更新待确认事项

### 结果与效果
- 候选半身像：15 张（EchoMimic v2 × 多张、AniPortrait × 3、SadTalker × 多张）
- 候选全身像：3 张（MimicMotion demo1 × 1 亚裔女全身⭐⭐⭐⭐⭐、UniAnimate women × 2 西方女全身）
- 有效 male 候选：AP_lyl.png（中年亚裔男性头肩照，唯一男性候选）
- input.md 已全面更新，待用户挑选确认

### 遇到的问题与解决方法
- **HuggingFace 需认证**：Champ 数据集在 HuggingFace 需登录，无法直接下载全身像
- **LivePortrait 全为艺术品**：其 source 图全是名画（蒙娜丽莎/珍珠耳环少女等），不适合作为真实 avatar 测试素材
- **男性素材稀缺**：各模型 demo 图普遍为女性，男性头像仅从 AniPortrait 获取 1 张（AP_lyl）
- **音频缺口未解决**：中文长时语音（>=5min）仍无法自动下载，须用户提供

## 2026-03-06 03:00

### 任务内容
Phase 3 素材全面整理与扩充（二次迭代）：
1. 自主从 candidates/ 挑选图片，整理至正式目录：删除 I004/I005/I007（错误素材），I008 从 full_body 移入 half_body，新增 I009-I022
2. 扩充图片来源：Hallo（I021 Mr. Bean, 3511×3511）、Hallo2（I020 西方女性面部, 624×624）、SadTalker（I022 坐姿 AI 女性, 800×1200）
3. 扩充音频：从多个模型 demo 收集更多短音频，拼接创建 A008_zh_long.wav（从 228s 扩展至 252s=4.2min 中文），从 MuseTalk 获取 A009（MT_eng, 60s 英文）
4. 搜集唱歌音频：从 Amphion VevoSing 获取 S001-S003（中/英文唱歌示例，9-13s）
5. 新增 prompt P008-P015（坐姿演讲/读书/打电话/招手/点头/唱歌/快乐/惊讶）共 8 个
6. 全面重写 input.md：更新完整素材索引（A001-A009, S001-S003, I001-I022, P001-P015）及 Condition 组合

### 结果与效果
- 半身像：16 张（I001-I016, I020-I022），覆盖亚裔/西方/男性/AI生成/站姿/坐姿
- 全身像：3 张（I017-I019），均为女性站姿
- 音频：英文 A007（5.9min）可覆盖所有档位；中文 A008（4.2min）可覆盖至 3min 档位
- Prompt：15 个（P001-P015），涵盖动作/情景/表情三类
- input.md 全面更新，Condition 组合增加至 30+

### 遇到的问题与解决方法
- **Hallo2 参考图大多为艺术品/绘画**：6 张中仅 HALLO2_6（真实人物面部照）达标，其余为油画/素描/雕塑
- **EchoMimic v2 refimag 同质化**：所有图均为同一 AI 角色"双手摊开"姿势，增加了新背景变体但姿势单一
- **唱歌音频无法获取 3min 以上**：所有 VevoSing 示例均 <15s；OpenSinger/M4Singer 需 HF 认证；其他来源无法访问。只能获取短示例
- **中文音频仍差 5min 目标**：A008 拼接 13 段中文片段后仅 252s=4.2min，仍无法覆盖 5min 档位
- **全身坐姿/男性全身图**：在可访问的 GitHub demo 仓库中未找到，记录为缺口

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

## 2026-03-06 15:00

### 任务内容
Phase 3 素材清理与 input.md 重写（用户人工筛选后）：
1. 清理 input/audio/speech 中时长 <5s 的音频文件（6 个）：A004(4.2s)、CV_zero_shot(3.5s)、EM1_chunwang(4.9s)、EM2_fighting(4.8s)、EM2_good(4.3s)、EM2_news(4.2s)
2. 根据用户人工筛选后的实际素材状态，全面重写 input.md：
   - 半身像：从 16→13 张（用户移除 I003/I008-I012/I014/I015，新增 ST_full_body_2/ST_full3/ST_full4/LP_s2/LP_s9/HALLO2_1）
   - 全身像：从 3→5 张（I022 从半身移入全身，新增 LP_s0 油画坐姿）
   - 音频：从 29→23 条（删除 6 条 <5s，A008_zh_long 已由用户删除）
   - Condition 组合：中文条件从 A008→A001 作为驱动音频，移除中文 3m/5m 档位（无足够长中文音频）
3. 更新 plan.md Phase 3 状态为已完成
4. 更新 progress.md

### 结果与效果
- 音频清理完成：剩余 23 条语音 + 3 条唱歌，所有音频 >=5s
- input.md 完整重写，准确反映用户筛选后的实际素材：13 张半身像、5 张全身像、15 个 prompt
- 素材类型更丰富：包含真实照片、AI生成图、名画(蒙娜丽莎)、油画等多种风格
- Condition 组合调整为 31 个（i+a2v 12 + t+i2v 14 + t2v 5）

### 遇到的问题与解决方法
- **中文长时音频缺口加大**：A008 已被用户删除，最长中文音频变为 A001(100s=1.7min)，中文 3min/5min 档位完全无法覆盖，需用户补充
- **无其他问题**：用户筛选结果清晰，直接基于实际文件状态重写即可

## 2026-03-06 11:00

### 任务内容
从 GitHub 远程仓库 fetch phase-3 分支，分析 Phase 3 完成情况，合并至 master 分支并更新进度记录。

### 结果与效果
**Phase 3 完成情况（来自 phase-3 分支，4 个提交）：**
- 音频：23 条语音（含英文长时 A007=5.9min 覆盖全部档位、中文 A001=100s 覆盖至 1min）+ 3 条唱歌（9-13s）
- 半身像：13 张（真实照片 × 8、AI生成 × 3、名画/油画 × 2）
- 全身像：5 张（真实照片 × 4、油画坐姿 × 1）
- Prompt：15 个（P001-P015，含情景/动作/表情三类）
- Condition 组合：31 个（i+a2v 12 + t+i2v 14 + t2v 5）
- 用户已完成人工筛选，input.md 已完整更新

**Merge 操作：**
- fetch 方式：HTTPS + network_turbo 代理（SSH pack-objects 被网络阻断，改用 HTTPS+http_proxy 绕过）
- 冲突文件：plan.md（进度总览表）、progress.md（多个会话记录）
- 冲突解决：plan.md 取 Phase 1/2 状态来自 master，Phase 3 状态来自 phase-3；progress.md 按时间顺序合并两分支全部记录

### 遇到的问题与解决方法
- **git fetch SSH 协议 hang**：SSH 连接 GitHub 时 pack-objects 下行数据传输被阻断（ls-remote 可行，push 可行，但 fetch 的接收阶段 hang），使用 HTTPS + （network_turbo 代理地址）成功解决

## 2026-03-06 11:00

### 任务内容
从 GitHub 远程仓库 fetch phase-3 分支，分析 Phase 3 完成情况，合并至 master 分支并更新进度记录。

### 结果与效果
**Phase 3 完成情况（来自 phase-3 分支，4 个提交）：**
- 音频：23 条语音（含英文长时 A007=5.9min 覆盖全部档位、中文 A001=100s 覆盖至 1min）+ 3 条唱歌（9-13s）
- 半身像：13 张（真实照片 × 8、AI生成 × 3、名画/油画 × 2）
- 全身像：5 张（真实照片 × 4、油画坐姿 × 1）
- Prompt：15 个（P001-P015，含情景/动作/表情三类）
- Condition 组合：31 个（i+a2v 12 + t+i2v 14 + t2v 5）
- 用户已完成人工筛选，input.md 已完整更新

**Merge 操作：**
- fetch 方式：HTTPS + network_turbo 代理（SSH pack-objects 被网络阻断，改用 HTTPS+http_proxy 绕过）
- 冲突文件：plan.md（进度总览表）、progress.md（多个会话记录）
- 冲突解决：plan.md 取 Phase 1/2 状态来自 master，Phase 3 状态取自 phase-3；progress.md 按时间顺序合并两分支全部记录

### 遇到的问题与解决方法
- **git fetch SSH 协议 hang**：SSH 连接 GitHub 时 pack-objects 下行数据传输被阻断（ls-remote 可行、push 可行，但 fetch 的接收阶段持续 hang），解决方案：使用 HTTPS 协议 + network_turbo 的 http 代理地址成功绕过


---

## 2026-03-06 会话 2（11:00-17:30）

### 完成的工作

#### 环境 Torch 安装
- **hunyuan-avatar-env**: torch 2.5.1+cu121 ✅（nohup 方式安装，避免 SSH 超时）
- **longcat-env**: torch 2.6.0+cu124 ✅
- **mova-env**: torch 2.5.1+cu121 ✅（venv 方式，pip 升级到 26.0.1 后重试成功）

#### 模型依赖安装
- **FantasyTalking** (fantasy-talking-env): transformers==4.46.2 + 全部依赖 ✅
- **LiveAvatar** (liveavatar-env): transformers==4.51.3, diffusers==0.37.0 + 全部依赖 ✅
- **OmniAvatar** (omniavatar-env): ⚠️ 安装被中断（xfuser 拉了错误的 torch 2.10.0），需重装

#### 权重下载
- **hallo3**: 49G ✅ 完成（fudan-generative-ai/hallo3）
- **SoulX-FlashTalk**: 35G，接近完成（仍在下载）
- 重启了死掉的下载进程：SoulX-FlashTalk、HunyuanVideo-Avatar、LongCat-Video-Avatar、MultiTalk、Wan2.1-I2V-14B-480P
- 多个下载进程再次死亡，仅 SoulX-FlashTalk 存活

#### 系统维护
- 系统盘从 16% 维持在 37%，定期清理 /tmp 和 pip cache
- 数据盘从 65% 增长到 91%（454G/500G），**需扩容**

### 遇到的问题

1. **mova-env pip 下载超时**：venv 的 pip 版本过旧（23.0.1），下载 torch 时超时。升级 pip 到 26.0.1 并加 --timeout 300 解决
2. **OmniAvatar xfuser 拉错 torch**：xfuser==0.4.1 依赖 torch，pip 从 PyPI 下载了 torch 2.10.0 替代已有的 2.5.1+cu121。需跳过 xfuser 或用 --no-deps
3. **权重下载进程频繁死亡**：多次重启后仍然死亡，原因可能是内存不足（同时运行多个下载+pip 安装）或网络超时
4. **XetHub CDN 超时**：MultiTalk、LongCat-Video-Avatar 的 HF 仓库使用 XetHub 存储，代理和直连都不稳定
5. **git fetch 挂起**：从 GitHub 拉取 phase-3 分支时 git fetch 长时间无响应，可能是大仓库+慢网络

### 当前状态

- **可测试模型**: EchoMimic v2、StableAvatar、LiveTalk（已验证）；FantasyTalking、LiveAvatar（deps 完成，需 JupyterLab 测试）
- **hallo3**: 权重完成，需安装模型依赖后可测试
- **OmniAvatar**: 权重完成，需修复 deps 后可测试
- **数据盘 91%**：等待用户扩容，暂停下载
- **待扩容后继续**：重启死掉的权重下载、安装剩余模型依赖、ltx2/skyreels torch 安装

### 扩容建议

数据盘从 500G 扩到 800G（+300G），可覆盖所有模型权重和环境安装
