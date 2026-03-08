# 20260308 Local Assets Manifest

## Purpose

This document records large local-only assets that are intentionally excluded from git tracking.
Current scope:

- models/
- weights_shared/
- test/shared_pydeps/
- dl_wan21_t2v14b.log

## Git Policy

- Keep lightweight source files, test scripts, configs, and markdown documents in git.
- Keep cloned upstream repositories, downloaded checkpoints, shared model assets, runtime overlays, and transient logs out of git.
- When a new model repo, shared weight bundle, or dependency overlay is added locally, update this document and progress.md in the same task.
- If a local clone under models/ contains project-specific code changes that should be preserved long-term, record the upstream repo URL, current commit, and the exact local patch entry points in this document or the corresponding test/<model>/test.md.

## Maintenance Checklist

1. Clone or download large local assets directly into their working directories.
2. Keep the directories ignored by .gitignore.
3. Record source, size, and current revision snapshot here.
4. Store reproducible setup steps in tracked shell scripts or markdown under test/.
5. Avoid placing unique hand-written logic only inside ignored directories.

## Snapshot

- Snapshot time: 2026-03-08 12:29
- Repository root: autodl-tmp/avatar-benchmark

### models/

| Directory | Size | Commit | Upstream |
|---|---:|---|---|
| HunyuanVideo-1.5 | 1.4M | 2641c0d | https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5.git |
| HunyuanVideo-Avatar | 178M | 8c31d0d | git@github.com:Tencent-Hunyuan/HunyuanVideo-Avatar.git |
| InfiniteTalk | 21G | fd63149 | git@github.com:MeiGen-AI/InfiniteTalk.git |
| LTX-2 | 231G | 9e8a28e | https://github.com/Lightricks/LTX-2.git |
| LiveAvatar | 105M | 775e363 | git@github.com:Alibaba-Quark/LiveAvatar.git |
| LongCat-Video | 149G | 09debbc | git@github.com:meituan-longcat/LongCat-Video.git |
| LongCat-Video-Avatar | 495M | 7cbb465 | git@github.com:MeiGen-AI/LongCat-Video-Avatar.git |
| LongLive | 8.9G | 2462895 | https://github.com/NVlabs/LongLive.git |
| MOVA | 73G | ee050e4 | https://github.com/OpenMOSS/MOVA.git |
| MultiTalk | 16G | 86e9854 | git@github.com:MeiGen-AI/MultiTalk.git |
| OmniAvatar | 54G | 1536bf3 | git@github.com:Omni-Avatar/OmniAvatar.git |
| Ovi | 70G | 5b69b25 | https://github.com/character-ai/Ovi.git |
| Self-Forcing | 5.5G | 33593df | https://github.com/guandeh17/Self-Forcing.git |
| SkyReels-V3 | 9.2M | 28c771e | https://github.com/SkyworkAI/SkyReels-V3.git |
| SoulX-FlashTalk | 38G | 171900c | git@github.com:Soul-AILab/SoulX-FlashTalk.git |
| Wan2.2 | 201G | c7b07b2 | git@github.com:Wan-Video/Wan2.2.git |
| echomimic_v2 | 17G | 38c8680 | git@github.com:antgroup/echomimic_v2.git |
| fantasy-talking | 65G | 8c2d0c9 | git@github.com:Fantasy-AMAP/fantasy-talking.git |
| hallo3 | 50G | e342dce | git@github.com:fudan-generative-vision/hallo3.git |
| livetalk | 6.6G | e0d555f | https://github.com/GAIR-NLP/LiveTalk.git |
| stableavatar | 11G | e647895 | https://github.com/Francis-Rings/StableAvatar.git |
| weights_shared | 6.3M | c41744b | git@github.com:Jp-17/avatar-benchmark.git |

### weights_shared/

| Directory | Size | Notes |
|---|---:|---|
| LiveAvatar | 1.3G | Shared checkpoints or reusable backbone assets |
| OmniAvatar-14B | 1.2G | Shared checkpoints or reusable backbone assets |
| Wan2.1-I2V-14B-480P | 19G | Shared checkpoints or reusable backbone assets |
| Wan2.1-I2V-14B-720P | 2.5G | Shared checkpoints or reusable backbone assets |
| Wan2.1-T2V-1.3B | 17G | Shared checkpoints or reusable backbone assets |
| chinese-wav2vec2-base | 51M | Shared checkpoints or reusable backbone assets |
| openclip-xlm-roberta-large-vit-huge-14 | 4.5G | Shared checkpoints or reusable backbone assets |
| t5-v1_1-xxl-hallo3 | 8.9G | Shared checkpoints or reusable backbone assets |
| wav2vec2-base-960h | 1.1G | Shared checkpoints or reusable backbone assets |

### test/shared_pydeps/

| Directory | Size | Purpose |
|---|---:|---|
| unified_transformers_449 | 114M | Local dependency overlay kept outside git tracking |

### dl_wan21_t2v14b.log

| File | Size | Purpose |
|---|---:|---|
| dl_wan21_t2v14b.log | 4.0K | Local download log kept for troubleshooting only |

## Update Rules

- Update the size and revision snapshot after adding a new upstream clone or completing a large weight download.
- If a directory is no longer used, remove it locally and then refresh this document.
- If a model requires custom local patches, keep the runnable script under test/<model>/ tracked in git and mention the dependency relationship here.
