# 素材索引与测试条件组合（Phase 3）

**初次收集**：2026-03-05（来源：EchoMimic v2 / Hallo3 / FantasyTalking / StableAvatar / OmniAvatar / LiveAvatar）
**补充收集**：2026-03-06（来源：SadTalker / AniPortrait / EchoMimic v2 ref set / MimicMotion / UniAnimate / Hallo / Hallo2 / V-Express / MultiTalk / Amphion-VevoSing）

---

## 素材索引

### Audio - Speech（讲话/对话）

| ID | 文件路径 | 时长 | 语言 | 来源 | 可测档位 |
|----|----------|------|------|------|----------|
| A001 | audio/speech/A001.wav | 100s (1.7min) | 中文 | StableAvatar case-1 demo | 5s/10s/30s/1min |
| A002 | audio/speech/A002.wav | 12s | 英文 | Hallo3 demo 0018 | 5s/10s |
| A003 | audio/speech/A003.wav | 11s | 英文 | Hallo3 demo 0022 | 5s/10s |
| A006 | audio/speech/A006.wav | 40s | 中文 | StableAvatar case-2 demo | 5s/10s/30s |
| A007 | audio/speech/A007.wav | 353s (5.9min) | **英文** | LiveAvatar boy demo | 5s/10s/30s/1min/3min/5min |
| A008 | audio/speech/A008_zh_long.wav | 252s (4.2min) | **中文** | 拼接：A001+A006+EM2×7+MT_sun+EM1×4+A004+A005 | 5s/10s/30s/1min/3min |
| A009 | audio/speech/MT_eng.wav | 60s | 英文 | MuseTalk english demo | 5s/10s/30s/1min |

> **A007（英文）**：5.9min，可覆盖 5min 档位 ✅
> **A008（中文）**：4.2min，可覆盖至 3min 档位；5min 中文档位仍缺口，请用户补充 >=5min 中文讲话音频。

> ⚠️ **缺口（中优先级）**：**中文长时语音 5min 档位**：A008 仅 4.2min，3min 档位可测，5min 档位待补充。
> 已尝试来源：模型 demo repo / HuggingFace（需认证）/ OpenSLR（仅 GB 级大包）/ archive.org（不可访问）。
> **请用户提供**：>=5min 中文普通话讲话音频（WAV/MP3，单人，清晰）。

---

### Audio - Singing（唱歌）

| ID | 文件路径 | 时长 | 语言 | 来源 | 备注 |
|----|----------|------|------|------|------|
| S001 | audio/singing/S001_jaychou.wav | 10s | 中文 | Amphion VevoSing demo | 周杰伦风格 |
| S002 | audio/singing/S002_adele.wav | 9s | 英文 | Amphion VevoSing demo | Adele 风格 |
| S003 | audio/singing/S003_taiyizhenren.wav | 13s | 中文 | Amphion VevoSing demo | 哪吒主题 |

> ⚠️ **缺口（中优先级）**：**唱歌音频均 <15s，不满足 >=3min 目标**。
> 已尝试来源：Wan2.2 singing demo (18.8s) / EchoMimic demo (无唱歌) / OpenSinger/M4Singer (HF需认证) / VevoSing (仅示例片段)。
> **请用户提供**：>=3min 中文或英文唱歌音频（WAV/MP3），如需测试 singing avatar 功能。
> **当前可用**：S001-S003 可用于功能验证（模型是否支持唱歌输入），但不适合长时稳定性测试。

---

### Avatar Image - 半身（half_body）

| ID | 文件路径 | 分辨率 | 来源 | 描述 | 姿势/手部 |
|----|----------|--------|------|------|-----------|
| I001 | avatar_img/half_body/I001.png | 576×768 | EchoMimic v2 demo | 亚裔女性，红色礼服，红色背景 | 站姿，手自然垂放 |
| I002 | avatar_img/half_body/I002.png | 790×790 | StableAvatar case-1 | 白人女性，播报风格，蓝色TV背景 | 站/坐姿，正面 |
| I003 | avatar_img/half_body/I003.png | 1024×1024 | FantasyTalking | AI生成西方女性面部特写，暗色背景 | 仅头部 |
| I006 | avatar_img/half_body/I006.jpeg | 1472×1104 | OmniAvatar demo | 亚裔女性，播客场景，自然坐姿 | **坐姿**，手在桌上 |
| I008 | avatar_img/half_body/I008.png | 1020×1006 | StableAvatar case-2 | 中年秃头男性，头肩照，正面 | 站/坐，正面 |
| I009 | avatar_img/half_body/I009.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白色背景，极简 | 站姿，**双手摊开** |
| I010 | avatar_img/half_body/I010.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白T恤，教室背景 | 站姿，**双手摊开** |
| I011 | avatar_img/half_body/I011.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，灰上衣，户外背景 | 站姿，**双手摊开** |
| I012 | avatar_img/half_body/I012.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，黑T恤，教室背景 | 站姿，**双手摊开** |
| I013 | avatar_img/half_body/I013.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，棕色上衣，户外背景 | 站姿，**双手摊开** |
| I014 | avatar_img/half_body/I014.png | 590×590 | AniPortrait ref | 新垣结衣，日系女性，白色背景，头肩照 | 站姿，自然 |
| I015 | avatar_img/half_body/I015.png | 653×660 | AniPortrait ref | **中年亚裔男性**，深色背景，头肩照 | 站姿，正面 |
| I016 | avatar_img/half_body/I016.png | 741×741 | AniPortrait ref | 西方年轻女性，颈部纹身，蓝色背景 | 站姿，正面 |
| I020 | avatar_img/half_body/I020.jpg | 624×624 | Hallo2 ref | 西方女性，面部特写，自然光，中性背景 | 仅头部，自然表情 |
| I021 | avatar_img/half_body/I021.jpg | 3511×3511 | Hallo ref | **西方中年男性**（Rowan Atkinson），蓝色背景，专业照 | 头肩，正面 |
| I022 | avatar_img/half_body/I022.png | 800×1200 | SadTalker examples | AI生成亚裔女性，女仆装，简洁背景 | **坐姿**，双手放于桌面 |

> 说明：I009-I013 均来自 EchoMimic v2 同一 AI 角色，姿势相同（双手摊开），背景/服装不同，适合模型对同一角色的一致性测试，但手势多样性不足。

---

### Avatar Image - 全身（full_body）

| ID | 文件路径 | 分辨率 | 来源 | 描述 | 姿势 |
|----|----------|--------|------|------|------|
| I017 | avatar_img/full_body/I017.jpg | 1080×1920 | MimicMotion demo | **亚裔女性**，蓝色休闲套装，淡色户外背景 | 站姿，手自然垂放 |
| I018 | avatar_img/full_body/I018.jpg | 750×1101 | UniAnimate data | 西方女性，格子衬衫+黑短裤，白色背景 | 站姿，时尚姿态 |
| I019 | avatar_img/full_body/I019.jpg | 750×1101 | UniAnimate data | 西方女性，白背心+牛仔短裤，白色背景 | 站姿，时尚姿态 |

> ⚠️ **缺口**：
> - **全身坐姿**：目前全身像均为站姿，无坐姿全身像
> - **男性全身**：目前全身像均为女性
> 如需补充，请用户提供或告知来源。

---

### Prompt - 情景与表情（P001–P015）

| ID | 文件路径 | 场景 | 内容摘要 |
|----|----------|------|---------|
| P001 | prompt/P001.txt | 演讲（站） | A confident person at a podium delivering a TED-style speech... |
| P002 | prompt/P002.txt | 下棋 | A person sitting at a chess board, thoughtfully studying... |
| P003 | prompt/P003.txt | 弹琴 | A person sitting at a piano, playing gracefully... |
| P004 | prompt/P004.txt | 跳舞 | A person dancing energetically with fluid full-body movements... |
| P005 | prompt/P005.txt | 微笑 | The person is smiling warmly and genuinely... |
| P006 | prompt/P006.txt | 愤怒 | The person appears visibly angry, furrowed brows... |
| P007 | prompt/P007.txt | 悲伤 | The person looks deeply sad and sorrowful... |
| P008 | prompt/P008.txt | 演讲（坐） | A person seated at a desk delivering a lecture, hands on desk... |
| P009 | prompt/P009.txt | 读书 | A person sitting and reading a book intently, looking up thoughtfully... |
| P010 | prompt/P010.txt | 打电话 | A person engaged in a phone call, holding phone to ear, gesturing... |
| P011 | prompt/P011.txt | 招手/问候 | A person greeting with a friendly wave, bright welcoming smile... |
| P012 | prompt/P012.txt | 点头 | A person nodding in agreement, calm expression, slight smile... |
| P013 | prompt/P013.txt | 唱歌 | A person singing passionately, swaying with rhythm, emotional expression... |
| P014 | prompt/P014.txt | 快乐 | The person is visibly happy and joyful, bright genuine smile, animated... |
| P015 | prompt/P015.txt | 惊讶 | The person reacts with surprise and shock, wide eyes, mouth agape... |

---

## 测试条件组合（Condition）

### image+audio→video 类模型（含 lip-sync）

| Condition ID | 输入类型 | Audio | Image | 时长 | 适用模型 |
|-------------|---------|-------|-------|------|---------|
| C_zh_5s | i+a2v | A008 | I009 | 5s | 支持中文的 avatar 模型 |
| C_zh_10s | i+a2v | A008 | I009 | 10s | 支持中文的 avatar 模型 |
| C_zh_30s | i+a2v | A008 | I009 | 30s | 支持中文的 avatar 模型 |
| C_zh_1m | i+a2v | A008 | I009 | 1min | 支持中文的 avatar 模型 |
| C_zh_3m | i+a2v | A008 | I009 | 3min | 支持中文的 avatar 模型 |
| C_zh_5m | i+a2v | （待补充中文长音频） | I009 | 5min | 待中文 5min 音频到位 |
| C_en_5s | i+a2v | A007 | I001 | 5s | 支持英文 avatar 模型 |
| C_en_10s | i+a2v | A007 | I001 | 10s | 支持英文 avatar 模型 |
| C_en_30s | i+a2v | A007 | I001 | 30s | 支持英文 avatar 模型 |
| C_en_1m | i+a2v | A007 | I001 | 1min | 支持英文 avatar 模型 |
| C_en_3m | i+a2v | A007 | I001 | 3min | 支持英文 avatar 模型 |
| C_en_5m | i+a2v | A007 | I001 | 5min | 支持英文 avatar 模型 |
| C_sing_zh | i+a2v | S001 | I001 | 10s | 支持唱歌的 avatar 模型（功能验证） |
| C_sing_en | i+a2v | S002 | I001 | 9s | 支持唱歌的 avatar 模型（功能验证） |

### text+image→video 类模型

| Condition ID | 输入类型 | Image | Prompt | 时长 | 备注 |
|-------------|---------|-------|--------|------|------|
| T_speech_10s | t+i2v | I001 | P001 | 10s | 演讲+站姿半身像 |
| T_speech_30s | t+i2v | I001 | P001 | 30s | 演讲+站姿半身像 |
| T_speech_sit_10s | t+i2v | I006 | P008 | 10s | 坐姿演讲+坐姿半身像 |
| T_dance_10s | t+i2v | I017 | P004 | 10s | 跳舞+全身像 |
| T_dance_30s | t+i2v | I017 | P004 | 30s | 跳舞+全身像 |
| T_piano_10s | t+i2v | I006 | P003 | 10s | 弹琴+坐姿半身像 |
| T_smile_10s | t+i2v | I001 | P005 | 10s | 微笑表情 |
| T_angry_10s | t+i2v | I001 | P006 | 10s | 愤怒表情 |
| T_sad_10s | t+i2v | I001 | P007 | 10s | 悲伤表情 |
| T_happy_10s | t+i2v | I001 | P014 | 10s | 快乐表情 |
| T_surprise_10s | t+i2v | I001 | P015 | 10s | 惊讶表情 |
| T_wave_10s | t+i2v | I001 | P011 | 10s | 招手/问候动作 |
| T_nod_10s | t+i2v | I001 | P012 | 10s | 点头动作 |
| T_sing_10s | t+i2v | I013 | P013 | 10s | 唱歌场景+半身像 |

### text→video 类模型

| Condition ID | 输入类型 | Prompt | 时长 | 备注 |
|-------------|---------|--------|------|------|
| P_speech_10s | t2v | P001 | 10s | 演讲场景 |
| P_piano_10s | t2v | P003 | 10s | 弹琴场景 |
| P_dance_10s | t2v | P004 | 10s | 跳舞场景 |
| P_sing_10s | t2v | P013 | 10s | 唱歌场景 |
| P_happy_10s | t2v | P014 | 10s | 快乐表情场景 |

---

## 素材现状总结

### 满足要求 ✅
- **Audio 英文长时**：A007（5.9min）满足 5min 档位所有测试
- **Image 半身像数量**：16 张（I001-I016, I020-I022），覆盖亚裔/西方/男性/AI生成
- **Image 全身像数量**：3 张（I017-I019），均为女性站姿
- **Prompt 情景**：8 个（P001-P004, P008-P010, P013）
- **Prompt 表情**：7 个（P005-P007, P011-P012, P014-P015）

### 仍有缺口 ⚠️
| 缺口 | 优先级 | 说明 |
|------|--------|------|
| 中文长时语音 5min | 高 | A008 仅 4.2min，支持 3min 档位，5min 档位需用户补充 |
| 唱歌音频（>=3min）| 中 | S001-S003 仅 9-13s，只能验证功能，不能测长时稳定性 |
| 全身像坐姿 | 低 | 全身像均为站姿，如需测坐姿请用户提供 |
| 男性全身像 | 低 | 全身像均为女性，如需测请用户提供 |
