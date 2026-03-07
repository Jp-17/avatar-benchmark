# 模型权重评估 - avatar-benchmark
**日期:** 2026-03-07 06:30
**服务器:** jp-video-3
**磁盘:** 841G/1000G (84%)

---

## 总览

| 类别 | 数量 | 说明 |
|------|------|------|
| 已完成全部测试 | 3 | echomimic_v2, stableavatar(运行中), livetalk |
| 权重完整可测试 | 5 | Wan2.2-S2V, LiveAvatar, MOVA, Ovi, SoulX-FlashTalk |
| 权重下载中 | 3 | OmniAvatar(75%), FantasyTalking(8%), LTX-2 text_encoder(21%) |
| 批处理运行中 | 1 | hallo3 (Cursor管理) |
| 权重严重不完整 | 9 | 需要大量下载 |

---

## GPU 占用现状 (06:30)
- stableavatar (PID 91550): 28G - C_en_5m (预计09:40完成)
- hallo3 (PID 96498): 48G - C_zh_10s
- 总占用: 76G/82G
- livetalk_wait2.sh: 等待stableavatar完成后自动运行C_en_5m

---

## 已完成全部测试

| 模型 | 环境 | 权重 | GPU | 测试状态 |
|------|------|------|-----|---------|
| echomimic_v2 | echomimic2-env | 17G (via symlinks) | ~8G | **12/12 全部完成** |
| stableavatar | stableavatar-env | 26G | ~28G | **8/11 完成**, C_en_5m运行中 |
| livetalk | livetalk-env | 23G | ~19G | **11/12 完成** (C_en_5m等待中) |

## 权重完整 - 环境就绪 - 等GPU测试

| 模型 | 环境 | 权重 | GPU需求 | 测试脚本 | 状态 |
|------|------|------|---------|---------|------|
| Ovi | ovi-env | 83G | ~24G (qint8+offload) | test/ovi/test_ovi.sh | ✅ 就绪 |
| MOVA | mova-env (venv) | 73G | ~77G (offload) | test/mova/test_mova.sh | ✅ 就绪 |
| Wan2.2-S2V | wan2.2-env | 46G | ~80G | test/wan2.2-s2v/test_wan22_s2v.sh | ✅ 就绪 |
| LiveAvatar | liveavatar-env | 47G (symlink) | ~80G (FP8) | test/liveavatar/test_liveavatar.sh | ✅ 就绪 |
| SoulX-FlashTalk | flashtalk-env | 42.5G | 未知 | test/soulx-flashtalk/test_flashtalk.sh | ✅ 就绪 |

## 权重下载中 - 环境就绪

| 模型 | 环境 | 下载进度 | GPU需求 | 测试脚本 | ETA |
|------|------|---------|---------|---------|-----|
| OmniAvatar | omniavatar-env | Wan2.1-T2V-14B: 43G/69G (62%) | ~36G | test/omniavatar/test_omniavatar.sh | ~2h |
| FantasyTalking | fantasy-talking-env | Wan2.1-I2V-14B-720P: 2.3G/28G (8%) | ~24G (24G模式) | test/fantasy-talking/test_fantasy_talking.sh | ~6h |
| LTX-2 | .venv (uv, torch 2.9.1) | text_encoder: 4.2G/19.6G (21%) | ~40G (FP8) | test/ltx2/test_ltx2.sh | ~4h |

## 批处理运行中

| 模型 | 环境 | GPU | 状态 |
|------|------|-----|------|
| hallo3 | hallo3-env | ~48G | C_zh_10s运行中, Cursor管理 |

## 权重严重不完整

| 模型 | 环境 | 现有 | 缺失 |
|------|------|------|------|
| SkyReels-V3 | skyreels-env | 2.0G | 缺主模型 (~28G) |
| HunyuanVideo-Avatar | hunyuan-avatar-env | 14G | 缺主transformer |
| LongLive | sf-longlive-env | 277M | 缺主模型 |
| MultiTalk | unified-env | 6.3G | 缺额外组件 |
| InfiniteTalk | unified-env | 21G | ~18%完成 |
| HunyuanVideo-1.5 | ltx2-hunyuan15-env | 13M | 基本空 |
| LongCat-Video-Avatar | longcat-env | 495M | 基本空 |
| Self-Forcing | (无专用env) | 143M | 缺 Wan2.1-T2V-1.3B |
| LongCat-Video | - | - | 仅代码 |

---

## 环境依赖状态

| 环境 | torch | flash_attn | 其他关键包 | 状态 |
|------|-------|------------|-----------|------|
| ovi-env | 2.5.1+cu121 | - | omegaconf, optimum-quanto | ✅ |
| mova-env | 2.5.1+cu121 | 2.8.3 | audiotools, bitsandbytes | ✅ |
| wan2.2-env | 2.5.1+cu121 | 2.8.3 | librosa, deepspeed, peft | ✅ |
| liveavatar-env | 2.5.1+cu121 | 2.8.3 | 196个包 | ✅ |
| flashtalk-env | 2.7.1+cu128 | 2.8.3 | xformers 0.0.31 | ✅ |
| omniavatar-env | 2.5.1+cu121 | 2.8.3 | xfuser, omegaconf, peft | ✅ |
| fantasy-talking-env | 2.5.1+cu121 | 2.8.3 | diffsynth, librosa | ✅ |
| LTX-2 .venv | 2.9.1+cu128 | - | ltx_pipelines, ltx_core | ✅ |

---

## 测试优先级 (等GPU空闲后)

### stableavatar完成后 (预计09:40, 释放28G → 可用34G alongside hallo3 48G)
1. **Ovi** (24G) - 立即测试 ✅ 一切就绪
2. **FantasyTalking** (24G, 24G模式) - 若Wan2.1-I2V-14B-720P下载完成

### hallo3完成后 (可用82G)
3. **SoulX-FlashTalk** - GPU需求未知
4. **MOVA** (77G with offload) - 推理~35-45min
5. **Wan2.2-S2V** (80G)
6. **LiveAvatar** (80G with FP8)
7. **LTX-2** (FP8, ~40G) - 若text_encoder下载完成
8. **OmniAvatar** (36G) - 若Wan2.1-T2V-14B下载完成

*最后更新: 2026-03-07 06:30*
