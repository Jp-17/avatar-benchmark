# 素材索引与测试条件组合（Phase 3）

**收集日期**：2026-03-05  
**来源**：各模型 GitHub demo repo（EchoMimic v2 / Hallo3 / FantasyTalking / StableAvatar / OmniAvatar / LiveAvatar）

---

## 素材索引

### Audio - Speech（讲话/对话）

| ID | 文件路径 | 时长 | 语言 | 来源 | 可测档位 |
|----|----------|------|------|------|----------|
| A001 | audio/speech/A001.wav | 100s (1.7min) | 中文 | StableAvatar case-1 demo | 5s/10s/30s/1min |
| A002 | audio/speech/A002.wav | 12s | 英文 | Hallo3 demo 0018 | 5s/10s |
| A003 | audio/speech/A003.wav | 11s | 英文 | Hallo3 demo 0022 | 5s/10s |
| A004 | audio/speech/A004.wav | 4s | 中文 | EchoMimic v2 news | 5s |
| A005 | audio/speech/A005.wav | 6s | 中文 | EchoMimic v2 woman demo | 5s |
| A006 | audio/speech/A006.wav | 40s | 中文 | StableAvatar case-2 demo | 5s/10s/30s |
| A007 | audio/speech/A007.wav | 353s (5.9min) | **英文** | LiveAvatar boy demo | 5s/10s/30s/1min/3min/5min |

> ⚠️ **缺口 1（高优先级）**：**中文长时语音（>=5min）暂缺**。  
> 已尝试来源：模型 demo repo / HuggingFace（VoxPopuli/WenetSpeech/GigaSpeech，parquet 格式不可直接下载）/ ModelScope（AISHELL-3 无音频文件）/ YouTube（不可访问）/ archive.org（不可访问）。  
> **请用户提供**：一段 >=5 分钟的中文普通话讲话音频（WAV/MP3，单人，清晰无背景噪声），或告知可从哪个 URL 直接 wget/curl 下载。

### Audio - Singing（唱歌）

> ⚠️ **缺口 2（中优先级）**：**唱歌音频暂缺**（目标 >=2 条，每条 >=3min）。  
> 已尝试：模型 demo repo（Wan2.2 sing.MP3 仅 18.8s，Five Hundred Miles.MP3 仅 5s）/ HuggingFace 上无直接可访问的公开唱歌数据集。  
> **请用户提供**：若需测试 singing avatar，请提供唱歌音频文件，或告知下载来源。

---

### Avatar Image - 半身（half_body）

| ID | 文件路径 | 大小 | 来源 | 描述 |
|----|----------|------|------|------|
| I001 | avatar_img/half_body/I001.png | 756KB | EchoMimic v2 demo | 亚裔女性，半身正面，简洁背景（需确认） |
| I002 | avatar_img/half_body/I002.png | 642KB | StableAvatar case-1 | 半身人物（需确认性别/构图） |
| I003 | avatar_img/half_body/I003.png | 1.1MB | FantasyTalking woman | 女性半身像，浅色背景 |
| I004 | avatar_img/half_body/I004.jpg | 23KB | Hallo3 demo 0001 | portrait 头像（分辨率小，需确认） |
| I005 | avatar_img/half_body/I005.jpg | 25KB | Hallo3 demo 0018 | portrait 头像（分辨率小，需确认） |
| I006 | avatar_img/half_body/I006.jpeg | 126KB | OmniAvatar demo | 半身像（需确认） |

> ⚠️ I004/I005 文件仅 23-25KB，可能分辨率不足（要求 >=512px）；建议用户检视后决定是否保留。

### Avatar Image - 全身（full_body）

| ID | 文件路径 | 大小 | 来源 | 描述 |
|----|----------|------|------|------|
| I007 | avatar_img/full_body/I007.png | 1.6MB | FantasyTalking fig0_1_0 | 疑似全身像（需用户确认） |
| I008 | avatar_img/full_body/I008.png | 689KB | StableAvatar case-2 | 疑似全身像（需用户确认） |

> ⚠️ **I007/I008 分类待确认**：这两张图片来自模型 demo，文件大但实际构图需人工查看确认是否为全身像。若为半身像，则全身像数量为 0，需额外补充。

---

### Prompt - 情景与表情（已完成）

| ID | 文件路径 | 场景 | 内容摘要 |
|----|----------|------|---------|
| P001 | prompt/P001.txt | 演讲 | A confident person at a podium delivering a TED-style speech... |
| P002 | prompt/P002.txt | 下棋 | A person sitting at a chess board, thoughtfully studying... |
| P003 | prompt/P003.txt | 弹琴 | A person sitting at a piano, playing gracefully... |
| P004 | prompt/P004.txt | 跳舞 | A person dancing energetically with fluid full-body movements... |
| P005 | prompt/P005.txt | 微笑 | The person is smiling warmly and genuinely... |
| P006 | prompt/P006.txt | 愤怒 | The person appears visibly angry, furrowed brows... |
| P007 | prompt/P007.txt | 悲伤 | The person looks deeply sad and sorrowful... |

---

## 测试条件组合（Condition）

### image+audio→video 类模型（含 lip-sync）

| Condition ID | 输入类型 | Audio | Image | 时长 | 适用模型 |
|-------------|---------|-------|-------|------|---------|
| C_zh_5s | i+a2v | A001 | I001 | 5s | 支持中文的 avatar 模型 |
| C_zh_10s | i+a2v | A001 | I001 | 10s | 支持中文的 avatar 模型 |
| C_zh_30s | i+a2v | A001 | I001 | 30s | 支持中文的 avatar 模型 |
| C_zh_1m | i+a2v | A001 | I001 | 1min | 支持中文的 avatar 模型 |
| C_zh_3m | i+a2v | （待补充中文长音频） | I001 | 3min | 待中文长音频到位 |
| C_zh_5m | i+a2v | （待补充中文长音频） | I001 | 5min | 待中文长音频到位 |
| C_en_5s | i+a2v | A007 | I003 | 5s | 支持英文 avatar 模型（Hallo3 等） |
| C_en_10s | i+a2v | A007 | I003 | 10s | 支持英文 avatar 模型 |
| C_en_30s | i+a2v | A007 | I003 | 30s | 支持英文 avatar 模型 |
| C_en_1m | i+a2v | A007 | I003 | 1min | 支持英文 avatar 模型 |
| C_en_3m | i+a2v | A007 | I003 | 3min | 支持英文 avatar 模型 |
| C_en_5m | i+a2v | A007 | I003 | 5min | 支持英文 avatar 模型 |

### text+image→video 类模型

| Condition ID | 输入类型 | Image | Prompt | 时长 | 备注 |
|-------------|---------|-------|--------|------|------|
| T_speech_10s | t+i2v | I001 | P001 | 10s | 演讲+半身像 |
| T_speech_30s | t+i2v | I001 | P001 | 30s | 演讲+半身像 |
| T_dance_10s | t+i2v | I007 | P004 | 10s | 跳舞+全身像 |
| T_dance_30s | t+i2v | I007 | P004 | 30s | 跳舞+全身像 |
| T_piano_10s | t+i2v | I001 | P003 | 10s | 弹琴+半身像 |
| T_smile_10s | t+i2v | I001 | P005 | 10s | 微笑表情 |
| T_angry_10s | t+i2v | I001 | P006 | 10s | 愤怒表情 |
| T_sad_10s | t+i2v | I001 | P007 | 10s | 悲伤表情 |

### text→video 类模型

| Condition ID | 输入类型 | Prompt | 时长 | 备注 |
|-------------|---------|--------|------|------|
| P_speech_10s | t2v | P001 | 10s | 演讲场景 |
| P_piano_10s | t2v | P003 | 10s | 弹琴场景 |
| P_dance_10s | t2v | P004 | 10s | 跳舞场景 |

---

## 待用户确认事项

1. **中文长音频**：请提供 >=5min 中文普通话讲话音频，或可直接 wget 的下载链接（WAV/MP3）
2. **唱歌音频**：若需 singing 测试，请提供（可选，非必须）
3. **图片确认**：请检视以下图片是否符合要求：
   - half_body/I004.jpg（23KB，可能太小��
   - half_body/I005.jpg（25KB，可能太小）
   - full_body/I007.png 和 I008.png（是否真为全身像？）
