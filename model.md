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
| **80G A800 适配** | **待确认**（官方推荐约 80GB，但通常用 2 卡；单 80GB 卡运行存在风险，需实测） |

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
| 4 | Self-Forcing | 通用自回归 | 1.3B | 24GB+ | Yes | Yes(HF) | 无限(~4min+) | No | t2v | **可测** |
| 5 | LongLive | 通用自回归 | 1.3B | 40GB+ | Yes | Yes(HF) | 无限(240s+) | No | t2v | **可测** |
| 6 | MOVA | 音视频联合 | 18B active | 36GB+(估算) | Yes | Yes(HF) | 8s | Yes | i+a2v, t2v | **待确认** |
| 7 | LTX-2 | 音视频联合 | 19B | 28GB(distil)/40GB(full) | Yes | Yes(HF) | 待确认(长) | Yes | i+a2v, t2v, t+i2v | **可测** |
| 8 | OVI | 音视频联合 | 11B | 24GB(FP8)/32GB(BF16) | Yes | Yes(HF) | 10s | Yes | t2v, t+i2v | **可测** |
| 9 | EchoMimic v2 | Avatar 离线 | ~1.3B | 16-24GB | Yes | Yes(HF) | 5-10s(滑窗) | Yes(半身) | i+a2v | **可测** |
| 10 | Hallo3 | Avatar 离线 | 5B+ | 26GB(offload)/80GB | Yes | Yes(HF) | 无限(外推) | Yes(portrait) | i+a2v | **条件可测** |
| 11 | HunyuanVideo-Avatar | Avatar 离线 | 13B | 10GB(FP8+offload)/96GB推荐 | Yes | Yes(HF) | 5s(129帧) | Yes(单/多人) | i+a2v | **条件可测** |
| 12 | Wan2.2-S2V | Avatar 离线 | 14B MoE | 80GB(官方要求) | Yes | Yes(HF) | 待确认 | Yes(影视级) | i+a2v | **可测** |
| 13 | OmniAvatar-14B | Avatar 离线 | 14B | 36GB | Yes | Yes(HF) | 待确认 | Yes(全身,31语言) | i+a+t2v | **可测** |
| 13b | OmniAvatar-1.3B | Avatar 离线 | 1.3B | 8-12GB | Yes | Yes(HF) | 待确认 | Yes(全身,31语言) | i+a+t2v | **可测** |
| 14 | MultiTalk | Avatar 离线 | 14B | 24GB(低显存模式) | Yes | Yes(HF) | 15s+(streaming) | Yes(单/多人) | i+a+t2v | **可测** |
| 15 | LongCat-Video-Avatar | Avatar 离线 | 13.6B | 80GB(2卡示例) | Yes | Yes(HF) | 分钟级(961帧) | Yes(单/多人) | i+a+t2v | **待确认** |
| 16 | StableAvatar | Avatar 离线 | 1.3B | 3-20GB | Yes | Yes(HF) | 无限 | Yes(portrait) | i+a2v | **可测** |
| 17 | FantasyTalking | Avatar 离线 | 14B | 5GB(0持久)/40GB(全) | Yes | Yes(HF) | 待确认(滑窗) | Yes(全/半身) | i+a2v | **可测** |
| 21 | InfiniteTalk | Avatar 离线 | 14B | 24GB(低显存)/80GB | Yes | Yes(HF) | 无限(default 40s) | Yes(全身,V2V+I2V) | v+a2v, i+a2v | **可测** |
| 18 | LiveAvatar | Avatar 自回归 | 14B | 48GB(FP8)/80GB(BF16) | Yes | Yes(HF) | 无限(10000s+) | Yes(实时) | i+a2v | **条件可测** |
| 19 | LiveTalk | Avatar 自回归 | 1.3B | 20GB | Yes | Yes(HF) | 无限 | Yes(实时对话) | i+a2v | **可测** |
| 20 | SoulX-FlashTalk | Avatar 自回归 | 14B | 40GB(offload)/64GB+ | Yes | Yes(HF) | 无限 | Yes(实时) | i+a2v | **条件可测** |

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
| **LongCat-Video-Avatar** | 13.6B | ~80GB (2卡示例) | 待确认 | [ ] 待配置 |
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

## 五、Phase 2/P3/P4 环境与权重状态（2026-03-06 15:30 更新）

### 环境 Torch 安装状态

| 环境名 | Torch 版本 | 状态 | 使用模型 |
|--------|-----------|------|---------|
| echomimic2-env | 2.5.1+cu121 | ✅ 完成 | EchoMimic v2 |
| stableavatar-env | 2.7.0+cu128 | ✅ 完成 | StableAvatar |
| livetalk-env | 2.10.0+cu128 | ✅ 完成 | LiveTalk |
| unified-env | 2.5.1+cu121 | ✅ 完成 | SoulX-FlashTalk, MultiTalk, InfiniteTalk |
| sf-longlive-env | 2.5.1+cu121 | ✅ torch+diffusers | Self-Forcing, LongLive |
| liveavatar-env | 2.5.1+cu121 | ✅ torch已装 | LiveAvatar |
| fantasy-talking-env | 2.5.1+cu121 | ✅ torch已装 | FantasyTalking |
| omniavatar-env | 2.5.1+cu121 | ✅ torch已装 | OmniAvatar |
| wan2.2-env | 2.5.1+cu121 | ✅ torch已装(flash_attn需JupyterLab) | Wan2.2-S2V, Wan2.2-T2V |
| hallo3-env | 2.4.0+cu121 | ✅ torch已装 | Hallo3 |
| ovi-env | 2.5.1+cu121 | ✅ torch已装 | OVI |
| hunyuan-avatar-env | 2.5.1+cu121 | 🔄 torch安装中 | HunyuanVideo-Avatar |
| longcat-env | - | ❌ 需安装torch 2.6.0+cu124 | LongCat-Video-Avatar |
| mova-env | - | ❌ 需安装torch | MOVA |
| ltx2-hunyuan15-env | - | ❌ 需安装torch 2.7.1+cu126 | LTX-2, HunyuanVideo-1.5 |
| skyreels-env | - | ❌ 需安装torch 2.8.0+cu126 | SkyReels-V3 |

### 权重下载状态

#### 已完成
| 模型 | 权重大小 | 说明 |
|------|---------|------|
| EchoMimic v2 | 11G | ModelScope下载完成 |
| StableAvatar | 26G | HF下载完成 |
| LiveTalk | 23G | HF下载完成 |
| FantasyTalking | 3.7G | adapter, HF下载完成 |
| LiveAvatar | 1.3G | LoRA adapter, HF下载完成 |
| OmniAvatar-14B | 1.2G | adapter, HF下载完成 |

#### 下载中（活跃进程）
| 模型 | 当前大小 | 进度 | 说明 |
|------|---------|------|------|
| hallo3 | 35G | 7/35 files (20%) | fudan-generative-ai/hallo3 |
| InfiniteTalk | 94G | 6/24 files (25%) | MeiGen-AI/InfiniteTalk + adapter |

#### 需重启下载（进程已死）
| 模型 | 当前大小 | 错误原因 | HF Repo |
|------|---------|---------|---------|
| SoulX-FlashTalk | 2.6G | 进程死亡 | Soul-AILab/SoulX-FlashTalk-14B |
| HunyuanVideo-Avatar | 4.0G | 进程死亡 | tencent/HunyuanVideo-Avatar |
| LongCat-Video-Avatar | 5.5G | XetHub CDN超时 | meituan-longcat/LongCat-Video-Avatar |
| MultiTalk | 8.6G | XetHub CDN超时 | MeiGen-AI/MeiGen-MultiTalk |
| Wan2.1-I2V-14B-480P (共享) | 未知 | 进程死亡 | Wan-AI/Wan2.1-I2V-14B-480P |

#### P3/P4 权重下载
| 模型 | 当前大小 | 状态 | HF Repo |
|------|---------|------|---------|
| Ovi | 2.7G | ❌ 需检查/重启 | chetwinlow1/Ovi |
| LTX-2 | 862M | ❌ 需检查/重启 | Lightricks/LTX-2 |
| SkyReels-V3 | 682M | ❌ 需检查/重启 | Skywork/SkyReels-V3-A2V-19B |
| Wan2.2-T2V | 1.1G | ⏳ 待下载 | Wan-AI/Wan2.2-T2V-A14B |
| HunyuanVideo-1.5 | - | ⏳ 待下载 | tencent/HunyuanVideo-1.5 |
| Self-Forcing | - | ⏳ 待下载 | gdhe17/Self-Forcing |
| LongLive | - | ⏳ 待下载 | Efficient-Large-Model/LongLive-1.3B |
| Wan2.1-T2V-1.3B (共享) | - | ⏳ 待下载 | Wan-AI/Wan2.1-T2V-1.3B |

### 权重共享策略

- `weights_shared/Wan2.1-I2V-14B-480P`: MultiTalk + InfiniteTalk 共享基础模型
- `weights_shared/chinese-wav2vec2-base`: SoulX-FlashTalk + MultiTalk + InfiniteTalk
- `weights_shared/wav2vec2-base-960h`: OmniAvatar + FantasyTalking + Hallo3
- `LiveAvatar/ckpt/Wan2.2-S2V-14B`: LiveAvatar + Wan2.2-S2V 共享

### 环境冲突说明

| 模型 | 冲突原因 | 解决方案 |
|------|---------|---------|
| FantasyTalking | transformers==4.46.2 | fantasy-talking-env |
| LiveAvatar | transformers<=4.51.3 | liveavatar-env |
| OmniAvatar | transformers==4.52.3 | omniavatar-env |
| HunyuanVideo-Avatar | diffusers==0.33.0 | hunyuan-avatar-env |
| Hallo3 | CogVideoX基, torch==2.4.0 | hallo3-env |
| LongCat | torch==2.6.0+cu124 | longcat-env |
| Wan2.2 | transformers<=4.51.3 | wan2.2-env |
| OVI | transformers<=4.51.3 | ovi-env |
| LTX-2/HunyuanVideo-1.5 | torch~=2.7 | ltx2-hunyuan15-env |
| MOVA | python>=3.12 | mova-env |
| SkyReels-V3 | torch==2.8.0 | skyreels-env |
| Self-Forcing/LongLive | diffusers==0.31.0 | sf-longlive-env |

### flash_attn 待安装列表（需 JupyterLab）

| 模型 | 环境 | 安装命令 |
|------|------|---------|
| Wan2.2-S2V / T2V | wan2.2-env | `pip install flash-attn --no-build-isolation` |
| LongCat-Video-Avatar | longcat-env | `pip install flash-attn --no-build-isolation` |
| LiveAvatar | liveavatar-env | `pip install flash-attn --no-build-isolation` |
| InfiniteTalk | unified-env | `pip install flash-attn --no-build-isolation` |
| SkyReels-V3 | skyreels-env | `pip install flash-attn==2.7.4.post1 --no-build-isolation` |

### 注意事项

- git clone: 须先运行 `source /etc/network_turbo`
- HF 权重下载: 勿用 network_turbo，仅设 `HF_ENDPOINT=https://hf-mirror.com`（XetHub CDN 被代理阻断）
- GPU 仅在 JupyterLab 终端可用，SSH 中 CUDA 不可用
- 磁盘: 系统盘 30G（需保持 <85%），数据盘 500G（当前约 321G/500G）
