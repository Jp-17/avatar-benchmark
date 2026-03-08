# avatar-benchmark 模型调研报告

**调研日期**：2026-03-05
**硬件约束**：单张 80GB A800 GPU
**调研字段**：GitHub 链接、模型规格、推理显存、推理代码、可下载权重、最大视频时长、avatar 能力、输入模态、80G 适配性

> 图例：可测 = 80G A800 单卡可推理 + 提供推理代码和权重；条件可测 = 需开启 offload/量化等优化；待确认 = 信息不足需实测；不可测 = 硬件或权重不满足

---

## 一、通用视频生成模型

### 1.1 离线视频生成

#### Wan2.2（通用 T2V/I2V）

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Wan-Video/Wan2.2 |
| **模型规格** | T2V-14B / I2V-14B-480P / I2V-14B-720P（MoE 架构，总参数 27B，每步激活 14B） |
| **推理显存** | offload 模式约 24GB；无 offload 约 43GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: Wan-AI/Wan2.2-T2V-14B 等） |
| **最大视频时长** | 5-8s（标准分辨率），滑窗方式可延长 |
| **Avatar 生成** | No（通用 T2V/I2V，S2V 版本见 2.1 节） |
| **输入模态** | text→video / text+image→video |
| **80G A800 适配** | **可测**（开启 `--offload_model True` 约 24GB，无 offload 也在 80G 范围内） |

---

#### HunyuanVideo-1.5

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5 |
| **模型规格** | 8.3B（仅此一种规格，较原版 13B 更轻量） |
| **推理显存** | 有 offload 约 14GB；无 offload 约 24-30GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: tencent/HunyuanVideo-1.5） |
| **最大视频时长** | 5-10s（720p，SR 模块可升至 1080p） |
| **Avatar 生成** | No（标准 T2V/I2V） |
| **输入模态** | text→video / text+image→video |
| **80G A800 适配** | **可测**（8.3B 单卡轻松，推荐） |

---

#### SkyReels-V3

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/SkyworkAI/SkyReels-V3 |
| **模型规格** | 待确认（V2 有 1.3B / 14B-540P / 14B-720P 版本；V3 新增多模态+audio-driven 能力） |
| **推理显存** | 待确认（V2 14B 约 43-51GB；V3 类似估算） |
| **推理代码** | Yes（2026-01-29 发布） |
| **可下载权重** | 待确认（V3 HuggingFace 页面需核实） |
| **最大视频时长** | V2 DF 系列支持无限长；V3 待确认 |
| **Avatar 生成** | Yes（V3 新增 audio-driven avatar 能力，A2V-19B 模型） |
| **输入模态** | text→video / text+image→video / image+audio→video（V3 新增） |
| **80G A800 适配** | **待确认**（V3 权重和显存需求需实测，参考 V2 14B 约需 43-51GB） |

---

### 1.2 自回归视频生成

#### Self-Forcing

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/guandeh17/Self-Forcing |
| **模型规格** | 1.3B（基于 Wan2.1-T2V-1.3B + self_forcing_dmd.pt 权重） |
| **推理显存** | 官方最低要求 24GB+（RTX4090/A100/H100 已测试）；Self-Forcing++ 版本支持至 4 分 15 秒 |
| **推理代码** | Yes（NeurIPS 2025 Spotlight） |
| **可下载权重** | Yes（HuggingFace: gdhe17/Self-Forcing；基模型需 Wan-AI/Wan2.1-T2V-1.3B） |
| **最大视频时长** | 理论无限（流式自回归，约 16 FPS on H100）；Self-Forcing++ 约 4min15s |
| **Avatar 生成** | No（通用 T2V） |
| **输入模态** | text→video |
| **80G A800 适配** | **可测**（24GB 需求，80G 充裕） |

---

#### LongLive

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/NVlabs/LongLive |
| **模型规格** | 1.3B（基于 Wan2.1-T2V-1.3B，LongLive-1.3B） |
| **推理显存** | 官方要求 40GB+（A100/H100 已测试） |
| **推理代码** | Yes（ICLR 2026，完整训练+推理代码） |
| **可下载权重** | Yes（HuggingFace: Efficient-Large-Model/LongLive-1.3B，CC-BY-NC 4.0） |
| **最大视频时长** | 240s（单 H100，约 20.7 FPS）；已更新支持无限长 |
| **Avatar 生成** | No（通用 T2V） |
| **输入模态** | text→video |
| **80G A800 适配** | **可测**（40GB 需求，80G 可行） |

---

### 1.3 联合音视频生成

#### MOVA

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/OpenMOSS/MOVA |
| **模型规格** | MOVA-360p / MOVA-720p（MoE 架构，总 32B 参数，18B active；视频 14B + 音频 1.3B + 桥接 2.6B） |
| **推理显存** | 估算 18B active 约 36GB+；官方高吞吐示例用 8 卡；单 80G 卡理论可行但待确认 |
| **推理代码** | Yes（2026-01-29 开源，含训练+LoRA 脚本） |
| **可下载权重** | Yes（HuggingFace: OpenMOSS-Team/MOVA-360p 和 MOVA-720p） |
| **最大视频时长** | 8s（当前限制，更长时长开发中） |
| **Avatar 生成** | Yes（原生支持 lip-sync、多说话人、多语言） |
| **输入模态** | text→video+audio（T2VA） / image+audio→video（IT2VA） |
| **80G A800 适配** | **待确认**（18B active 估算约 36GB，单 80G 卡理论可行；官方推荐多卡，需实测验证） |

---

#### LTX-2

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Lightricks/LTX-2 |
| **模型规格** | 19B（视频 14B + 音频 5B）；distilled 版本约 28GB；full BF16 约 40GB+ |
| **推理显存** | FP8 优化后约 8-12GB；distilled 约 28GB；full BF16 约 40GB |
| **推理代码** | Yes（含 LoRA 训练器） |
| **可下载权重** | Yes（HuggingFace: Lightricks/LTX-2 系列） |
| **最大视频时长** | 待确认（LTX-Video 13B 支持 60s；LTX-2 设计支持长视频） |
| **Avatar 生成** | Yes（原生音视频同步，支持 lip-sync；专项 avatar 能力待确认） |
| **输入模态** | text→video+audio / image+audio→video+audio / text+image→video |
| **80G A800 适配** | **可测**（FP8 distilled 单卡可行，full BF16 约 40GB 也在 80G 范围内） |

---

#### OVI (Ovi)

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/character-ai/Ovi |
| **模型规格** | 11B（视频 5B + 音频 5B + fusion 1B）；FP8 量化版可用 |
| **推理显存** | BF16 标准 32GB；FP8 约 24GB；cpu_offload 模式低至 8.2GB |
| **推理代码** | Yes（含 Gradio UI） |
| **可下载权重** | Yes（HuggingFace: chetwinlow1/Ovi；FP8 版: rkfg/Ovi-fp8_quantized） |
| **最大视频时长** | 10s（Ovi 1.1 版本；5s 为基础版） |
| **Avatar 生成** | Yes（精确 lip-sync，支持多说话人、多语言、情绪表达） |
| **输入模态** | text→video+audio / text+image→video+audio |
| **80G A800 适配** | **可测**（FP8 模式 24GB，BF16 模式 32GB，80G A800 完全可行） |

---

## 二、Avatar 视频生成模型

### 2.1 离线生成

#### EchoMimic v2

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/antgroup/echomimic_v2 |
| **模型规格** | SD-based UNet 架构（V3 约 1.3B）；主要组件约 5-8GB 文件 |
| **推理显存** | 最低约 16GB（V100 已测）；推荐 24GB（RTX 4090D 已测）；A100 80G 已测 |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: BadToBest/EchoMimicV2） |
| **最大视频时长** | 约 5-10s（120帧 @ 24fps）；可通过滑窗方式延长 |
| **Avatar 生成** | Yes（半身 audio-driven avatar） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **可测**（官方已在 A100 80G 测试，推荐配置） |

---

#### Hallo3

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/fudan-generative-vision/hallo3 |
| **模型规格** | 基于 CogVideoX-5B I2V（约 5B 参数）+ T5-XXL + wav2vec2 + 人脸分析；总下载约 30-40GB |
| **推理显存** | CPU offload + VAE tiling 约 26GB；全精度无优化约 75-80GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: fudan-generative-ai/hallo3） |
| **最大视频时长** | 理论无限（video extrapolation 策略串联片段，每段约 6s） |
| **Avatar 生成** | Yes（portrait audio-driven avatar；仅支持英文音频） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **条件可测**（需开启 CPU offload+VAE tiling 降至 26GB；全精度接近 80G 上限，建议启用优化） |

---

#### HunyuanVideo-Avatar

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Tencent-Hunyuan/HunyuanVideo-Avatar |
| **模型规格** | 13B（MM-DiT）；FP8 量化约 14GB 显存；完整 BF16 需约 52GB+ |
| **推理显存** | 最低 24GB（极慢，704x768x129f）；推荐 96GB；FP8+CPU offload（via Wan2GP）约 10GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: tencent/HunyuanVideo-Avatar） |
| **最大视频时长** | 129 帧（约 5s @ 25fps）单次推理；支持多角色 |
| **Avatar 生成** | Yes（单/多人 audio-driven avatar，支持情绪控制） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **条件可测**（推荐 96GB，80GB 可能 OOM；建议降分辨率+FP8+CPU offload，实测确认） |

---

#### Wan2.2-S2V

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Wan-Video/Wan2.2 |
| **模型规格** | S2V-14B（MoE 架构，总 27B，激活 14B） |
| **推理显存** | 官方要求至少 80GB；`--offload_model True` + `--t5_cpu` 可降低 |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: Wan-AI/Wan2.2-S2V-14B） |
| **最大视频时长** | 待确认（Wan2.1 14B 约 5-8s；S2V 版本需实测） |
| **Avatar 生成** | Yes（audio-driven 影视级角色动画） |
| **输入模态** | image+audio→video（可选 text prompt） |
| **80G A800 适配** | **可测**（官方明确要求 80GB，建议同时开启 offload 保险） |

---

#### OmniAvatar

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Omni-Avatar/OmniAvatar |
| **模型规格** | OmniAvatar-14B / OmniAvatar-1.3B 两版本（基于 Wan2.1-T2V-14B/1.3B） |
| **推理显存** | 14B 全精度约 36GB；1.3B 约 8-12GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: OmniAvatar/OmniAvatar-14B；需同时下载 Wan2.1-T2V-14B） |
| **最大视频时长** | 待确认（480P；具体帧数上限未公开） |
| **Avatar 生成** | Yes（全身 audio-driven avatar，支持 31 种语言唇同步） |
| **输入模态** | image+audio+text→video |
| **80G A800 适配** | **可测**（官方在 A800 测试，14B 约 36GB，两个规格均可） |

---

#### MultiTalk

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/MeiGen-AI/MultiTalk |
| **模型规格** | 14B（基于 Wan2.1-I2V-14B-480P）+ MeiGen-MultiTalk adapter |
| **推理显存** | 480P 单卡 RTX 4090 可运行（低显存模式 `--num_persistent_param_in_dit 0`）；标准推理 A100 80GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: MeiGen-AI/MeiGen-MultiTalk） |
| **最大视频时长** | streaming 模式约 15s+；理论上更长 |
| **Avatar 生成** | Yes（单人/多人 audio-driven avatar，支持对话场景） |
| **输入模态** | image+audio+text→video |
| **80G A800 适配** | **可测**（A100 为官方测试平台，A800 同等规格可运行） |

---


---

#### InfiniteTalk

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/MeiGen-AI/InfiniteTalk |
| **论文** | ArXiv 2508.14033 |
| **模型规格** | 14B（基于 Wan2.1-I2V-14B-480P）+ InfiniteTalk adapter；音频编码器：Chinese-wav2vec2-base |
| **推理显存** | 低显存模式（`--num_persistent_param_in_dit 0`）约 24GB；标准模式约 80GB；支持 TeaCache 加速和 Int8 量化 |
| **推理代码** | Yes（Gradio demo 可用；ComfyUI 分支提供） |
| **可下载权重** | Yes（HuggingFace: MeiGen-AI/InfiniteTalk；需同时下载 Wan-AI/Wan2.1-I2V-14B-480P 和 Chinese-wav2vec2-base） |
| **最大视频时长** | 理论无限（流式生成）；默认 40s（1000 帧，`--max_frame_num` 可配置） |
| **Avatar 生成** | Yes（全身 audio-driven avatar；支持 V2V 配音/重配音，精确嘴形同步，自然头身动作） |
| **输入模态** | video+audio→video（V2V 配音）/ image+audio→video（I2V） |
| **80G A800 适配** | **可测**（低显存模式约 24GB；标准模式官方在 A100 80GB 测试；A800 同等规格可运行） |

---

#### LongCat-Video-Avatar

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/MeiGen-AI/LongCat-Video-Avatar |
| **模型规格** | 13.6B（密集 DiT）；提供 Single 和 Multi 两个 avatar checkpoint |
| **推理显存** | 约 80GB；官方示例为 2 卡（torchrun --nproc_per_node=2） |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: meituan-longcat/LongCat-Video-Avatar） |
| **最大视频时长** | 分钟级（LongCat-Video 原生支持 Video-Continuation，961 帧上限） |
| **Avatar 生成** | Yes（超写实长时 audio-driven avatar，单人/多人） |
| **输入模态** | audio+text→video / audio+text+image→video；支持视频续写 |
| **80G A800 适配** | **可测**（最小素材实测单卡峰值约 57.5GB；需预留足够磁盘与显存缓冲） |

---

#### StableAvatar

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Francis-Rings/StableAvatar |
| **模型规格** | 1.3B（主版本，基于 Wan2.1-Fun-V1.1-1.3B-InP）；14B 实验版（训练阶段） |
| **推理显存** | sequential_cpu_offload 约 3GB；model_cpu_offload 约减半；全加载约 15-20GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: FrancisRing/StableAvatar） |
| **最大视频时长** | 理论无限（infinite-length；VAE decode 大规模帧时可用 CPU VAE） |
| **Avatar 生成** | Yes（无限长度 audio-driven avatar，无需后处理） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **可测**（1.3B 版本显存极低，80GB 绰绰有余；推荐） |

---

#### FantasyTalking

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Fantasy-AMAP/fantasy-talking |
| **模型规格** | 14B（基于 Wan2.1-I2V-14B-720P）+ FantasyTalking adapter |
| **推理显存** | 全参数约 40GB；7B 持久参数约 20GB；零持久参数约 5GB |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: acvlab/FantasyTalking；需同时下载 Wan2.1-I2V-14B-720P） |
| **最大视频时长** | 待确认（测试用例 81 帧 @ 512x512；滑窗方式可延长） |
| **Avatar 生成** | Yes（全身/半身/近景 portrait，audio-driven avatar） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **可测**（A100 单卡已测试，40GB 全精度，80G 充裕） |

---

### 2.2 自回归生成

#### LiveAvatar

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Alibaba-Quark/LiveAvatar |
| **模型规格** | 14B（基于 Wan2.2-S2V-14B）+ LiveAvatar LoRA adapter |
| **推理显存** | 单卡 offline 需 >=80GB；FP8 量化约 48GB；实时 20FPS 需 5xH800 |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: Quark-Vision/Live-Avatar） |
| **最大视频时长** | 10,000s+（无限，block-wise autoregressive） |
| **Avatar 生成** | Yes（实时/离线无限长 audio-driven avatar） |
| **输入模态** | image+audio→video（可选 text） |
| **80G A800 适配** | **条件可测**（单卡 offline 需 >=80GB，FP8 约 48GB 更稳定；实时模式需 5 卡 H800，不适用） |

---

#### LiveTalk

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/GAIR-NLP/LiveTalk |
| **模型规格** | 1.3B（基于 Wan2.1-T2V-1.3B，LiveTalk-1.3B-V0.1） |
| **推理显存** | 约 20GB；最低需求 24GB（系统 RAM 建议 64GB） |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: GAIR/LiveTalk-1.3B-V0.1） |
| **最大视频时长** | 无限（block-wise autoregressive，约 3 latent frames/block，约 24.8 FPS，首帧延迟 0.33s） |
| **Avatar 生成** | Yes（实时多轮对话 avatar） |
| **输入模态** | image+audio→video（支持多轮多模态对话） |
| **80G A800 适配** | **可测**（约 20GB，80GB 绰绰有余；推荐） |

---

#### SoulX-FlashTalk

| 字段 | 信息 |
|------|------|
| **GitHub** | https://github.com/Soul-AILab/SoulX-FlashTalk |
| **模型规格** | 14B（SoulX-FlashTalk-14B） |
| **推理显存** | 单卡需 >64GB；`--cpu_offload` 约 40GB；实时 32FPS 需 8xH800 |
| **推理代码** | Yes |
| **可下载权重** | Yes（HuggingFace: Soul-AILab/SoulX-FlashTalk-14B） |
| **最大视频时长** | 无限（infinite streaming，自校正防质量退化） |
| **Avatar 生成** | Yes（实时无限长 audio-driven avatar，32 FPS，首帧延迟 0.87s） |
| **输入模态** | image+audio→video |
| **80G A800 适配** | **条件可测**（无 offload 需 >64GB，80GB 理论可运行；`--cpu_offload` 约 40GB 更稳；实时 32FPS 需 8 卡，不适用） |

---

## 三、80G A800 适配性汇总

| # | 模型 | 类别 | 规格 | 推理显存（最低/推荐） | 推理代码 | 权重下载 | 最大时长 | Avatar | 输入模态 | **适配性** |
|---|------|------|------|----------------------|---------|---------|---------|-------|---------|-----------|
| 1 | Wan2.2 | 通用离线 | 14B MoE | 24GB(offload)/43GB | Yes | Yes(HF) | 5-8s | No | t2v, t+i2v | **可测** |
| 2 | HunyuanVideo-1.5 | 通用离线 | 8.3B | 14GB(offload)/30GB | Yes | Yes(HF) | 5-10s | No | t2v, t+i2v | **可测** |
| 3 | SkyReels-V3 | 通用离线 | 待确认 | 待确认 | Yes | 待确认 | 无限(V2) | Yes(V3) | t2v, t+i2v, i+a2v | **待确认** |
| 4 | Self-Forcing | 通用自回归 | 1.3B | 24GB+ | Yes | Yes(HF) | 无限(~4min+) | ⏳ 已入队 | 已加入 follow-up 队列，位于 LongLive 之后执行 | **可测** |
| 5 | LongLive | 通用自回归 | 1.3B | 40GB+ | Yes | Yes(HF) | 无限(240s+) | ⏳ 已入队 | 已加入 follow-up 队列，位于 OmniAvatar 之后执行 | **可测** |
| 6 | MOVA | 音视频联合 | 18B active | 36GB+(估算) | Yes | Yes(HF) | 8s | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；输出目录与 results.md 已校验 | **待确认** |
| 7 | LTX-2 | 音视频联合 | 19B | 28GB(distil)/40GB(full) | Yes | Yes(HF) | 待确认(长) | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 | **可测** |
| 8 | OVI | 音视频联合 | 11B | 24GB(FP8)/32GB(BF16) | Yes | Yes(HF) | 10s | Yes | t2v, t+i2v | **可测** |
| 9 | EchoMimic v2 | Avatar 离线 | ~1.3B | 16-24GB | Yes | Yes(HF) | 5-10s(滑窗) | ✅ 新4条件完成 | 已完成新 Phase 4 的全量条件；输出目录与 results.md 已校验 | **可测** |
| 10 | Hallo3 | Avatar 离线 | 5B+ | 26GB(offload)/80GB | Yes | Yes(HF) | 无限(外推) | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；输出目录与 results.md 已校验 | **条件可测** |
| 11 | HunyuanVideo-Avatar | Avatar 离线 | 13B | 10GB(FP8+offload)/96GB推荐 | Yes | Yes(HF) | 5s(129帧) | Yes(单/多人) | i+a2v | **条件可测** |
| 12 | Wan2.2-S2V | Avatar 离线 | 14B MoE | 80GB(官方要求) | Yes | Yes(HF) | 待确认 | ⚠️ 首轮失败待复跑 | 2026-03-08 16:15-16:17 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 | **可测** |
| 13 | OmniAvatar-14B | Avatar 离线 | 14B | 36GB | Yes | Yes(HF) | 待确认 | Yes(全身,31语言) | i+a+t2v | **可测** |
| 13b | OmniAvatar-1.3B | Avatar 离线 | 1.3B | 8-12GB | Yes | Yes(HF) | 待确认 | Yes(全身,31语言) | i+a+t2v | **可测** |
| 14 | MultiTalk | Avatar 离线 | 14B | 24GB(低显存模式) | Yes | Yes(HF) | 15s+(streaming) | ▶️ 进行中 | 2026-03-08 16:52 起执行短时子集；当前优先队列正在运行 | **可测** |
| 15 | LongCat-Video-Avatar | Avatar 离线 | 13.6B | 80GB(2卡示例) | Yes | Yes(HF) | 分钟级(961帧) | Yes(单/多人) | i+a+t2v | **待确认** |
| 16 | StableAvatar | Avatar 离线 | 1.3B | 3-20GB | Yes | Yes(HF) | 无限 | ✅ 新4条件完成 | 已完成新 Phase 4 的全量条件；输出目录与 results.md 已校验 | **可测** |
| 17 | FantasyTalking | Avatar 离线 | 14B | 5GB(0持久)/40GB(全) | Yes | Yes(HF) | 待确认(滑窗) | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 | **可测** |
| 21 | InfiniteTalk | Avatar 离线 | 14B | 24GB(低显存)/80GB | Yes | Yes(HF) | 无限(default 40s) | ⚠️ 首轮中断待续跑 | 已完成 C_half_short；C_full_short 于 2026-03-08 17:54-18:00 因 OOM 中断，待 GPU 空闲后复跑 | **可测** |
| 18 | LiveAvatar | Avatar 自回归 | 14B | 48GB(FP8)/80GB(BF16) | Yes | Yes(HF) | 无限(10000s+) | ⚠️ 首轮失败待复跑 | 2026-03-08 16:12-16:14 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 | **条件可测** |
| 19 | LiveTalk | Avatar 自回归 | 1.3B | 20GB | Yes | Yes(HF) | 无限 | ✅ 新4条件完成 | 已完成新 Phase 4 的 C_half_short/C_half_long/C_full_short/C_full_long；results.md 已记录显存峰值与生成时间 | **可测** |
| 20 | SoulX-FlashTalk | Avatar 自回归 | 14B | 40GB(offload)/64GB+ | Yes | Yes(HF) | 无限 | ⚠️ 首轮失败待复跑 | 2026-03-08 16:14-16:15 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 | **条件可测** |

> 输入模态缩写：t2v = text→video；t+i2v = text+image→video；i+a2v = image+audio→video；i+a+t2v = image+audio+text→video

---

## 四、测试优先级建议

### 优先级考量原则

除显存/硬件约束外，测试优先级主要依据**功能方向**划分。核心目标是比较 **audio-driven avatar 视频生成**能力，尤其是自回归式流式/实时对话场景；其次是通用音视频联合生成；最后是通用视频模型在人物场景中的表现。

Phase 2 目标：**尽可能完成以下所有模型**的环境配置与权重下载，按优先级顺序推进。

---

### 第一优先：自回归音频驱动 Avatar（最核心比较对象）

这类模型是本次 benchmark 最想重点对比的方向——支持无限长度流式/自回归生成，具备实时对话场景能力。

| 模型 | 规格 | 推理显存（最低） | 适配性 | 完成状态 |
|------|------|----------------|-------|---------|
| **SoulX-FlashTalk** | 14B | 40GB (cpu_offload) | 条件可测 | [ ] 待配置 |
| **LiveAvatar** | 14B | 48GB (FP8) | 条件可测 | [ ] 待配置 |
| **LiveTalk** | 1.3B | 20GB | ✅ 可测 | [x] 已完成 |

---

### 第二优先：其他音频驱动 Avatar（主要比较对象）

非自回归但仍以 image+audio 驱动的 avatar 生成模型，是本次 benchmark 的主体内容。

| 模型 | 规格 | 推理显存（最低） | 适配性 | 完成状态 |
|------|------|----------------|-------|---------|
| **FantasyTalking** | 14B | 5GB (0持久参数) | ✅ 可测 | [ ] 待配置 |
| **StableAvatar** | 1.3B | 3GB | ✅ 可测 | [x] 已完成 |
| **LongCat-Video-Avatar** | 13.6B | ~80GB (2卡示例) | ✅ 可测 | [x] 已完成 |
| **InfiniteTalk** | 14B | 24GB (低显存) | ✅ 可测 | [ ] 待配置 |
| **MultiTalk** | 14B | 24GB (低显存) | ✅ 可测 | [ ] 待配置 |
| **OmniAvatar** | 14B/1.3B | 36GB/8GB | ✅ 可测 | [ ] 待配置 |
| **Wan2.2-S2V** | 14B MoE | 80GB | ✅ 可测 | [ ] 待配置 |
| **HunyuanVideo-Avatar** | 13B | 10GB (FP8+offload) | 条件可测 | [ ] 待配置 |
| **Hallo3** | 5B+ | 26GB (offload) | 条件可测 | [ ] 待配置 |
| **EchoMimic v2** | ~1.3B | 16GB | ✅ 可测 | [x] 已完成 |

---

### 第三优先：音视频联合生成（含人物场景能力）

这类模型原生支持音视频联合输出，虽非 avatar 专用，但可通过含人物的图像或描述人物说话的 prompt 测试其在人物视频生成上的表现。

| 模型 | 规格 | 推理显存（最低） | 适配性 | 完成状态 |
|------|------|----------------|-------|---------|
| **MOVA** | 18B active | 36GB (估算) | 待确认 | [ ] 待配置 |
| **LTX-2** | 19B | 28GB (distilled) | ✅ 可测 | [ ] 待配置 |
| **OVI** | 11B | 24GB (FP8) | ✅ 可测 | [ ] 待配置 |

---

### 第四优先：通用视频生成（可测人物生成特性）

通用 T2V/I2V 模型，不专为人物/avatar 设计，但可通过包含人物的图像或描述人物说话的 prompt，了解其生成人物视频时的质量与特点，与 avatar 专用模型形成参照对比。

| 模型 | 规格 | 推理显存（最低） | 适配性 | 完成状态 |
|------|------|----------------|-------|---------|
| **Wan2.2** | 14B MoE | 24GB (offload) | ✅ 可测 | [ ] 待配置 |
| **Self-Forcing** | 1.3B | 24GB | ✅ 可测 | [ ] 待配置 |
| **LongLive** | 1.3B | 40GB | ✅ 可测 | [ ] 待配置 |
| **HunyuanVideo-1.5** | 8.3B | 14GB (offload) | ✅ 可测 | [ ] 待配置 |
| **SkyReels-V3** | 待确认 | 待确认 | 待确认 | [ ] 待配置 |

---

## 五、Phase 2 环境与权重状态（2026-03-07 进行中更新）

### Phase 2 完成状态总览

> 图例：✅ = 完成；⚠️ = 部分完成/有条件；❌ = 未完成

| # | 模型 | 环境名 | 环境创建 | 依赖安装 | 权重下载 | 可推理 | 已测试 | 是否完成Phase4 | 备注 |
|---|------|--------|---------|---------|---------|--------|--------|----------------|------|
| 1 | EchoMimic v2 | echomimic2-env | ✅ | ✅ | ✅ 11G | ✅ | ✅ 1 test | ✅ 新4条件完成 | 已完成新 Phase 4 的全量条件；输出目录与 results.md 已校验 |
| 2 | StableAvatar | stableavatar-env | ✅ | ✅ | ✅ 26G | ✅ | ✅ 1 test | ✅ 新4条件完成 | 已完成新 Phase 4 的全量条件；输出目录与 results.md 已校验 |
| 3 | LiveTalk | livetalk-env | ✅ | ✅ | ✅ 23G | ✅ | ✅ 1 test | ✅ 新4条件完成 | 已完成新 Phase 4 的 C_half_short/C_half_long/C_full_short/C_full_long；results.md 已记录显存峰值与生成时间 |
| 4 | Hallo3 | hallo3-env | ✅ | ✅ | ✅ 49G | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；输出目录与 results.md 已校验 |
| 5 | Ovi | ovi-env | ✅ | ✅ | ✅ 83G | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；输出目录与 results.md 已校验 |
| 6 | MOVA | mova-env (venv) | ✅ | ✅ | ✅ 73G | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；输出目录与 results.md 已校验 |
| 7 | Wan2.2-S2V | wan2.2-env | ✅ | ✅ | ✅ 46G | ✅ | ✅ 1 test | ⚠️ 首轮失败待复跑 | 2026-03-08 16:15-16:17 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 |
| 8 | LiveAvatar | liveavatar-env | ✅ | ✅ | ✅ 47G | ✅ | ✅ 1 test | ⚠️ 首轮失败待复跑 | 2026-03-08 16:12-16:14 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 |
| 9 | SoulX-FlashTalk | flashtalk-env | ✅ | ✅ | ✅ 42.5G | ✅ | ✅ 1 test | ⚠️ 首轮失败待复跑 | 2026-03-08 16:14-16:15 首轮短时子集尝试因残留显存占用触发 OOM，待 GPU 串行空闲后复跑 |
| 10 | LTX-2 | .venv (uv) | ✅ | ✅ | ✅ 205G | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 |
| 11 | OmniAvatar | omniavatar-env | ✅ | ✅ | ✅ 66G | ✅ | ✅ 1 test | ▶️ 进行中 | 2026-03-08 18:00 起执行短时子集；当前正在执行 C_half_short，follow-up 队列已接管 |
| 12 | FantasyTalking | fantasy-talking-env | ✅ | ✅ | ✅ 32G | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；长时条件按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 |
| 13 | SkyReels-V3 | skyreels-env | ✅ | ⚠️ | ❌ ~2G/~30G（暂停） | ❌ | ❌ | 暂缓 | 用户要求暂不继续该模型的环境/权重任务 |
| 14 | HunyuanVideo-Avatar | hunyuan-avatar-env | ✅ | ⚠️ | ❌ 14G/~50G（暂停） | ❌ | ❌ | 暂缓 | 用户要求暂不继续该模型的环境/权重任务 |
| 15 | HunyuanVideo-1.5 | ltx2-hunyuan15-env | ✅ | ⚠️ | ❌ 13M（暂停） | ❌ | ❌ | 暂缓 | 用户要求暂不继续该模型的环境/权重任务 |
| 16 | LongLive | sf-longlive-env | ✅ | ✅ | ✅ 8.2G + 共享 Wan2.1-T2V-1.3B | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；C_half_long/C_full_long 按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 |
| 17 | LongCat-Video-Avatar | longcat-env | ✅ | ✅ | ✅ base可用 + avatar 6/6 | ✅ | ✅ 1 test | ✅ 最小测试通过 | 已补齐 avatar_single/avatar_multi 6/6；首次自动测试因 ffprobe 缺失失败，补 `torch_utils.py` fallback 后重跑通过，输出 `test/longcat-video-avatar/output/ai2v_demo_1.mp4` |
| 18 | MultiTalk | unified-env | ✅ | ✅ | ✅ 最小推理所需权重已齐 | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；C_half_long/C_full_long 按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 |
| 19 | InfiniteTalk | unified-env | ✅ | ✅ | ✅ 最小推理所需权重已齐 | ✅ | ✅ 1 test | ⚠️ 首轮中断待续跑 | 已完成 C_half_short；C_full_short 于 2026-03-08 17:54-18:00 因 OOM 中断，待 GPU 空闲后复跑 |
| 20 | Self-Forcing | sf-longlive-env（复用） | ✅ | ✅ | ✅ 5.3G + 共享 Wan2.1-T2V-1.3B | ✅ | ✅ 1 test | ✅ 支持子集完成 | 已完成新 Phase 4 的 C_half_short/C_full_short；C_half_long/C_full_long 按最小测试稳定路径跳过；results.md 已记录显存峰值与生成时间 |
| 21 | Wan2.2 T2V/I2V | wan2.2-env | ✅ | ✅ | ⚠️ T2V✅ + I2V暂停(保留49G) | ✅ | ✅ 1 test | 暂缓 | T2V 最小推理已通过；I2V 环境/权重任务暂停 |

### 统计

- **环境创建完成**：21/21
- **依赖安装完成**：16/21（含 flash_attn 分发）
- **权重下载完成**：16/21
- **可进行推理测试**：16/21
- **已进行推理测试**：10/21（EchoMimic v2, StableAvatar, LiveTalk, Hallo3, Ovi, Self-Forcing, LongLive, Wan2.2, MultiTalk, InfiniteTalk）

### 已完成推理测试的详细结果

| 模型 | 测试条件数 | 完成数 | 代表性结果 |
|------|-----------|--------|-----------|
| EchoMimic v2 | 12 | 12 | 768×768, 6步/条件, ~90s/5s视频 |
| StableAvatar | 12 | 8 | 512×512, 50步, ~10min/5s视频 |
| LiveTalk | 12 | 11 | 自回归, ~24.8FPS, 最长254s |
| Hallo3 | 10 | 3 | CogVideoX 外推, ~45min/条件 |
| Ovi | 1 | 1 | 960×960, 30步, ~25.8G GPU, ~12min |
| Self-Forcing | 1 | 1 | 21帧, 4步/块, 119s, 输出 598K MP4 |
| LongLive | 1 | 1 | 21帧, 4步/块, 133s, 输出 585K MP4 |
| Wan2.2 | 1 | 1 | T2V 17帧, 8步, 402s, 输出 661K MP4 |
| MultiTalk | 1 | 1 | 640×640, 8步, 2053s, 输出 398K MP4 |
| InfiniteTalk | 1 | 1 | 640×640, 8步, 1030s, 输出 356K MP4 |

### 未完成/暂缓的模型（5个）

| 模型 | 缺失内容 | 预估需下载量 | 阻塞原因 |
|------|---------|------------|---------|
| SkyReels-V3 | 主体权重 | ~28G | 用户要求暂缓 |
| HunyuanVideo-Avatar | 大部分权重 | ~36G | 用户要求暂缓 |
| HunyuanVideo-1.5 | 全部权重 | ~30G | 用户要求暂缓 |
| LongCat-Video-Avatar | 权重已补齐并完成最小测试 | ~25G | 2026-03-08 已完成 |
| Wan2.2 I2V | I2V-14B 权重 | ~22G | 用户要求暂缓（保留已下载 49G） |

### 当前优先级（2026-03-08 更新）

- **已完成**：LongCat-Video-Avatar / MultiTalk / InfiniteTalk 已完成权重补齐与 Phase 2 最小素材推理验证
- **提示**：LongCat 完成后 `/root/autodl-tmp` 剩余约 39G，继续下载大模型前建议先整理存储或扩容
- **暂缓推进**：SkyReels-V3、HunyuanVideo-Avatar、HunyuanVideo-1.5、Wan2.2 I2V
- **说明**：Wan2.2 仅保留 T2V 已验证结果；I2V 部分不再继续，直到用户重新开启

### flash_attn 分发状态

flash_attn 2.8.3 已从 liveavatar-env/mova-env 复制到以下环境：
- ✅ ovi-env, unified-env, skyreels-env, sf-longlive-env, liveavatar-env, longcat-env
- ✅ fantasy-talking-env（从 liveavatar-env 复制）
- ✅ omniavatar-env（从 liveavatar-env 复制）
- ✅ wan2.2-env（从 liveavatar-env 复制）

### 当前优先级（2026-03-07 更新）

- **优先推进**：LongCat-Video-Avatar，其次 MultiTalk，最后 InfiniteTalk 的环境配置、权重补齐与最小素材推理测试
- **暂缓推进**：SkyReels-V3、HunyuanVideo-Avatar、HunyuanVideo-1.5、Wan2.2 I2V
- **说明**：Wan2.2 仅保留 T2V 已验证结果；I2V 部分不再继续，直到用户重新开启

### 注意事项

- 数据盘：保留 Wan2.2 I2V 已下载 49G，当前不再继续该下载任务
- HF 下载必须使用 hf-mirror.com，不启用 network_turbo
- XetHub CDN 仓库（MultiTalk/InfiniteTalk/LongCat-Video-Avatar）需等网络条件改善
- Self-Forcing、LongLive 已验证可复用 sf-longlive-env + weights_shared/Wan2.1-T2V-1.3B
- Wan2.2 当前仅保留 T2V 结果，I2V 任务已按用户要求暂缓

### Phase 4 批推理执行状态

#### 当前 Phase 4 总览（2026-03-08 18:45）

| 模型 | 当前状态 | 说明 |
|------|----------|------|
| EchoMimic v2 | ✅ 新4条件完成 | 全量条件已完成，输出目录与 results.md 已校验。 |
| StableAvatar | ✅ 新4条件完成 | 全量条件已完成，输出目录与 results.md 已校验。 |
| LiveTalk | ✅ 新4条件完成 | 新 4 条件已完成，results.md 已记录显存峰值与生成时间。 |
| Hallo3 | ✅ 支持子集完成 | 已完成短时子集，长时条件按稳定路径跳过。 |
| Ovi | ✅ 支持子集完成 | 已完成短时子集，长时条件按稳定路径跳过。 |
| MOVA | ✅ 支持子集完成 | 已完成短时子集，长时条件按稳定路径跳过。 |
| LiveAvatar | ⚠️ 首轮失败待复跑 | 2026-03-08 16:12-16:14 因残留显存占用触发 OOM。 |
| SoulX-FlashTalk | ⚠️ 首轮失败待复跑 | 2026-03-08 16:14-16:15 因残留显存占用触发 OOM。 |
| Wan2.2-S2V | ⚠️ 首轮失败待复跑 | 2026-03-08 16:15-16:17 因残留显存占用触发 OOM。 |
| FantasyTalking | ✅ 支持子集完成 | 已完成短时子集，results.md 已记录显存峰值与生成时间。 |
| LTX-2 | ✅ 支持子集完成 | 已完成短时子集，results.md 已记录显存峰值与生成时间。 |
| MultiTalk | ✅ 支持子集完成 | 已完成短时子集，results.md 已记录显存峰值与生成时间。 |
| InfiniteTalk | ⚠️ 首轮中断待续跑 | 已完成 `C_half_short`；`C_full_short` 因 OOM 中断。 |
| OmniAvatar | ▶️ 进行中 | follow-up 队列已启动，当前正在执行 `C_half_short`。 |
| LongLive | ⏳ follow-up 待执行 | 位于 OmniAvatar 之后。 |
| Self-Forcing | ⏳ follow-up 待执行 | 位于 LongLive 之后。 |

#### EchoMimic v2（12/12 ✅ 全部完成）

| Condition | 状态 | 输出文件 |
|-----------|------|---------|
| C_zh_5s ~ C_sing_en | ✅ done | output/echomimic_v2/ |

#### LiveTalk（新 4 条件完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 |
|-----------|------|---------|---------|---------|
| C_half_short | ✅ done | output/livetalk_newphase4/C_half_short.mp4 | 21381 MB | 89s |
| C_half_long | ✅ done | output/livetalk_newphase4/C_half_long.mp4 | 81033 MB | 221s |
| C_full_short | ✅ done | output/livetalk_newphase4/C_full_short.mp4 | 21867 MB | 96s |
| C_full_long | ✅ done | output/livetalk_newphase4/C_full_long.mp4 | 80421 MB | 168s |

#### StableAvatar（8/12）

| Condition | 状态 | 备注 |
|-----------|------|------|
| C_zh_5s ~ C_zh_1m | ✅ done | 4 条件 |
| C_en_5s ~ C_en_30s | ✅ done | 3 条件 |
| C_en_1m | ✅ done | |
| C_en_3m | ❌ OOM | 与 Hallo3 同时运行导致 |
| C_en_5m | ❌ 中断 | 被 GPU benchmark 干扰 |
| C_sing_zh, C_sing_en | ❌ 未运行 | |

#### Hallo3（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | 当前稳定路径未覆盖 100s 长音频；历史记录显示 Hallo3 长时推理耗时极长。 |
| C_full_long | ⏭️ skipped | - | - | - | 当前稳定路径未覆盖 60s 长音频；本轮先完成短时横评。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_half_short.mp4 | 70487 MB | 1401 秒 | 无新增问题；继续沿用 test/hallo3/test.md 中已验证的单条件输入格式与禁用 expandable_segments 经验。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_full_short.mp4 | 74405 MB | 2459 秒 | 无新增问题；继续沿用 test/hallo3/test.md 中已验证的单条件输入格式与禁用 expandable_segments 经验。 |
#### Ovi（1 test ✅）

| 测试 | 状态 | 输出 |
|------|------|------|
| test_ovi.sh | ✅ done | 960×960, 1.7MB, 30步@20.5s/步 |

#### Ovi（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。 |
| C_full_long | ⏭️ skipped | - | - | - | Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/C_half_short.mp4 | 40009 MB | 1199 秒 | 沿用 test/ovi/test.md 中已验证的 qint8 + cpu_offload 稳定路径。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/C_full_short.mp4 | 78627 MB | 943 秒 | 沿用 test/ovi/test.md 中已验证的 qint8 + cpu_offload 稳定路径。 |

#### MOVA（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。 |
| C_full_long | ⏭️ skipped | - | - | - | MOVA 当前稳定路径是固定 97 帧短视频，不扩展到长时。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_half_short.mp4 | 41109 MB | 465 秒 | 沿用 test/mova/test.md 中已验证的固定 97 帧短视频路径。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_full_short.mp4 | 41211 MB | 461 秒 | 沿用 test/mova/test.md 中已验证的固定 97 帧短视频路径。 |

#### FantasyTalking（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。 |
| C_full_long | ⏭️ skipped | - | - | - | FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_half_short.mp4 | 63341 MB | 1032 秒 | 沿用 test/fantasy-talking/test.md 中已验证的 81 帧短视频路径，长时条件暂不扩展。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_full_short.mp4 | 20391 MB | 868 秒 | 沿用 test/fantasy-talking/test.md 中已验证的 81 帧短视频路径，长时条件暂不扩展。 |

#### LTX-2（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。 |
| C_full_long | ⏭️ skipped | - | - | - | LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_half_short.mp4 | 72809 MB | 85 秒 | 沿用 test/ltx2/test.md 中已验证的去掉 fp8-cast 且 LoRA 强度 0.0 的短帧稳定路径。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_full_short.mp4 | 72807 MB | 66 秒 | 沿用 test/ltx2/test.md 中已验证的去掉 fp8-cast 且 LoRA 强度 0.0 的短帧稳定路径。 |

#### MultiTalk（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | MultiTalk 当前稳定路径为最小短时链路，长音频 filtered 条件尚未验证。 |
| C_full_long | ⏭️ skipped | - | - | - | MultiTalk 当前稳定路径为最小短时链路，长音频 filtered 条件尚未验证。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_half_short.mp4 | 14893 MB | 1141 秒 | 无新增问题，沿用 test/multitalk/test.md 中已验证的 unified overlay + streaming 稳定路径。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_full_short.mp4 | 14893 MB | 1560 秒 | 无新增问题，沿用 test/multitalk/test.md 中已验证的 unified overlay + streaming 稳定路径。 |

#### LongLive（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | 参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。 |
| C_full_long | ⏭️ skipped | - | - | - | 参考 test/longlive/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/C_half_short.mp4 | 24803 MB | 119 秒 | 沿用 test/longlive/test.md 中已验证的 sf-longlive-env + shared Wan2.1-T2V-1.3B 稳定路径，并保留已补装的  依赖。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/C_full_short.mp4 | 24803 MB | 109 秒 | 沿用 test/longlive/test.md 中已验证的 sf-longlive-env + shared Wan2.1-T2V-1.3B 稳定路径，并保留已补装的  依赖。 |

#### Self-Forcing（支持子集完成）

| Condition | 状态 | 输出文件 | 显存峰值 | 推理时间 | 备注 |
|-----------|------|---------|---------|---------|------|
| C_half_long | ⏭️ skipped | - | - | - | 参考 test/self-forcing/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。 |
| C_full_long | ⏭️ skipped | - | - | - | 参考 test/self-forcing/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。 |
| C_half_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_half_short.mp4 | 26177 MB | 100 秒 | 沿用 test/self-forcing/test.md 中已验证的 sf-longlive-env 稳定路径，并保留  以避免写视频报错。 |
| C_full_short | ✅ done | /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_full_short.mp4 | 26177 MB | 100 秒 | 沿用 test/self-forcing/test.md 中已验证的 sf-longlive-env 稳定路径，并保留  以避免写视频报错。 |

