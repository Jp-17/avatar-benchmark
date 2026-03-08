# 20260308-本地资产清单

## 文档目的

本文件记录当前保留在仓库目录内、但故意不纳入 git 跟踪的大体量本地资产，方便后续快速定位：

- 这些资产从哪里来
- 现在占了多少空间
- 主要被哪些测试脚本或模型复用

当前纳入本清单的范围：

- models/
- weights_shared/
- test/shared_pydeps/
- dl_wan21_t2v14b.log

## Git 管理原则

- git 只跟踪轻量源码、测试脚本、配置文件和 markdown 文档。
- 上游模型 clone、下载得到的权重、共享依赖 overlay、临时运行日志继续保留在本地目录中，但统一通过 .gitignore 排除。
- 新增、删除或替换大型本地资产时，需要同步更新本文件和 progress.md。
- 如果某个被 ignore 的目录里出现了需要长期保留的手工修改，必须把可复现入口同步到 test/<model>/ 下的脚本或说明文档中。

## 维护要求

1. 大模型源码继续放在 models/ 下。
2. 共享权重继续放在 weights_shared/ 下。
3. 兼容性依赖 overlay 继续放在 test/shared_pydeps/ 下。
4. 每次新增本地大目录后，补记目录名、体量、上游来源、当前 commit 和本地用途。
5. 如果某目录已经废弃，先删除本地目录，再更新本文件。

## 当前快照

- 快照时间：2026-03-08 12:35
- 仓库根目录：autodl-tmp/avatar-benchmark

### models/

| 目录 | 体量 | 当前提交 | 上游来源 | 本地用途/关联测试目录 |
|---|---:|---|---|---|
| HunyuanVideo-1.5 | 1.4M | 2641c0d | https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5.git | 预留源码快照；当前暂无专属测试目录 |
| HunyuanVideo-Avatar | 178M | 8c31d0d | git@github.com:Tencent-Hunyuan/HunyuanVideo-Avatar.git | 预留源码快照；当前暂无专属测试目录 |
| InfiniteTalk | 21G | fd63149 | git@github.com:MeiGen-AI/InfiniteTalk.git | InfiniteTalk 最小测试与权重排查；关联 test/infinitetalk |
| LTX-2 | 231G | 9e8a28e | https://github.com/Lightricks/LTX-2.git | 联合音视频最小推理与质量修复；关联 test/ltx2 |
| LiveAvatar | 105M | 775e363 | git@github.com:Alibaba-Quark/LiveAvatar.git | 音频驱动 Avatar 最小推理与 80 帧 GPU 实验；关联 test/liveavatar |
| LongCat-Video | 149G | 09debbc | git@github.com:meituan-longcat/LongCat-Video.git | LongCat 基座仓库；供 LongCat-Video-Avatar 共用；关联 test/longcat-video-avatar |
| LongCat-Video-Avatar | 495M | 7cbb465 | git@github.com:MeiGen-AI/LongCat-Video-Avatar.git | LongCat Avatar 最小测试与下载脚本；关联 test/longcat-video-avatar |
| LongLive | 8.9G | 2462895 | https://github.com/NVlabs/LongLive.git | 自回归长视频最小测试；关联 test/longlive |
| MOVA | 73G | ee050e4 | https://github.com/OpenMOSS/MOVA.git | 联合音视频最小测试；关联 test/mova |
| MultiTalk | 16G | 86e9854 | git@github.com:MeiGen-AI/MultiTalk.git | 多人说话 Avatar 最小测试与权重下载；关联 test/multitalk |
| OmniAvatar | 54G | 1536bf3 | git@github.com:Omni-Avatar/OmniAvatar.git | 音频驱动 Avatar 最小测试；关联 test/omniavatar |
| Ovi | 70G | 5b69b25 | https://github.com/character-ai/Ovi.git | 联合音视频最小测试；关联 test/ovi |
| Self-Forcing | 5.5G | 33593df | https://github.com/guandeh17/Self-Forcing.git | 自回归通用视频最小测试；关联 test/self-forcing |
| SkyReels-V3 | 9.2M | 28c771e | https://github.com/SkyworkAI/SkyReels-V3.git | 预留源码快照；当前暂无专属测试目录 |
| SoulX-FlashTalk | 38G | 171900c | git@github.com:Soul-AILab/SoulX-FlashTalk.git | 音频驱动 Avatar 最小测试；关联 test/soulx-flashtalk |
| Wan2.2 | 201G | c7b07b2 | git@github.com:Wan-Video/Wan2.2.git | Wan2.2 的 S2V / T2V / I2V 测试；关联 test/wan2.2-s2v、test/wan2.2-t2v-i2v |
| echomimic_v2 | 17G | 38c8680 | git@github.com:antgroup/echomimic_v2.git | EchoMimic v2 最小测试与 Phase 4 脚本；关联 test/echomimic_v2 |
| fantasy-talking | 65G | 8c2d0c9 | git@github.com:Fantasy-AMAP/fantasy-talking.git | Avatar 最小测试；关联 test/fantasy-talking |
| hallo3 | 50G | e342dce | git@github.com:fudan-generative-vision/hallo3.git | Avatar 最小测试；关联 test/hallo3 |
| livetalk | 6.6G | e0d555f | https://github.com/GAIR-NLP/LiveTalk.git | 音频驱动 Avatar 最小测试；关联 test/livetalk |
| stableavatar | 11G | e647895 | https://github.com/Francis-Rings/StableAvatar.git | Avatar 最小测试与新 Phase 4 脚本；关联 test/stableavatar |
| weights_shared | 6.3M | c41744b | git@github.com:Jp-17/avatar-benchmark.git | models/ 内辅助目录；排查共享权重引用时与根目录 weights_shared/ 一起查看 |

### weights_shared/

| 目录 | 体量 | 主要来源/内容 | 本地用途/关联测试目录 |
|---|---:|---|---|
| LiveAvatar | 1.3G | LiveAvatar 相关共享权重 | LiveAvatar 推理复用；关联 test/liveavatar |
| OmniAvatar-14B | 1.2G | OmniAvatar 14B 相关共享权重 | OmniAvatar 推理复用；关联 test/omniavatar |
| Wan2.1-I2V-14B-480P | 19G | Wan2.1 I2V 14B 480P 基座与编码器资源 | MultiTalk / InfiniteTalk 等共享底座；关联 test/multitalk、test/infinitetalk |
| Wan2.1-I2V-14B-720P | 2.5G | Wan2.1 I2V 14B 720P 资源 | 共享高分辨率 I2V 资产预留；按需供后续测试复用 |
| Wan2.1-T2V-1.3B | 17G | Wan2.1 T2V 1.3B 基座 | LongLive 等通用视频链路复用；关联 test/longlive |
| chinese-wav2vec2-base | 51M | 中文 wav2vec 音频编码器 | MultiTalk / InfiniteTalk / LongCat 音频编码复用；关联 test/multitalk、test/infinitetalk、test/longcat-video-avatar |
| openclip-xlm-roberta-large-vit-huge-14 | 4.5G | OpenCLIP XLM-R 编码器 | Wan 系 / LongCat 等编码链路复用；关联 test/longcat-video-avatar、test/multitalk、test/infinitetalk |
| t5-v1_1-xxl-hallo3 | 8.9G | Hallo3 依赖的 T5 文本编码器 | Hallo3 推理复用；关联 test/hallo3 |
| wav2vec2-base-960h | 1.1G | 通用 wav2vec2 英文音频编码器 | 通用音频驱动模型备用共享资产；按需供相关测试复用 |

### test/shared_pydeps/

| 目录 | 体量 | 主要内容 | 本地用途/关联测试目录 |
|---|---:|---|---|
| unified_transformers_449 | 114M | transformers 4.49.0 / tokenizers 0.21.0 / huggingface_hub 0.28.1 等兼容层 | MultiTalk / InfiniteTalk 的本地 overlay 依赖；关联 test/multitalk、test/infinitetalk |

### 根目录本地日志

| 文件 | 体量 | 本地用途/关联任务 |
|---|---:|---|
| dl_wan21_t2v14b.log | 4.0K | Wan2.1 T2V 14B 下载排查日志；仅本地留存，按需人工查看 |

## 更新规则

- 新增模型源码后，更新 models/ 表中的体量、当前提交、上游来源和本地用途。
- 完成大权重下载或清理后，更新 weights_shared/ 表中的体量与用途说明。
- 兼容层依赖版本发生变化时，更新 test/shared_pydeps/ 表中的主要内容说明。
- 如果某项资产已废弃、改名或改为软链，先处理本地目录，再同步修改本文件。
- 后续排查某个模型时，优先查看“本地用途/关联测试目录”列，快速定位对应的 test 脚本与说明。
