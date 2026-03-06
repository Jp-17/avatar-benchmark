# 素材索引与测试条件组合（Phase 3）

**初次收集**：2026-03-05
**二次迭代**：2026-03-06
**人工筛选 & 清理**：2026-03-06（用户人工筛选图片素材，清理 <5s 短音频）

---

## 素材索引

### Audio - Speech（讲话/对话）

| ID | 文件路径 | 时长 | 语言 | 来源 | 可测档位 |
|----|----------|------|------|------|----------|
| A001 | audio/speech/A001.wav | 100s (1.7min) | 中文 | StableAvatar case-1 demo | 5s/10s/30s/1min |
| A002 | audio/speech/A002.wav | 12s | 英文 | Hallo3 demo 0018 | 5s/10s |
| A003 | audio/speech/A003.wav | 11s | 英文 | Hallo3 demo 0022 | 5s/10s |
| A005 | audio/speech/A005.wav | 6s | 中文 | MuseTalk demo | 5s |
| A006 | audio/speech/A006.wav | 40s | 中文 | StableAvatar case-2 demo | 5s/10s/30s |
| A007 | audio/speech/A007.wav | 353s (5.9min) | 英文 | LiveAvatar boy demo | 5s/10s/30s/1min/3min/5min |
| MT_eng | audio/speech/MT_eng.wav | 60s | 英文 | MuseTalk english demo | 5s/10s/30s/1min |
| MT_sun | audio/speech/MT_sun.wav | 22s | 中文 | MuseTalk sun demo | 5s/10s |
| MT_yongen | audio/speech/MT_yongen.wav | 8s | 中文 | MuseTalk yongen demo | 5s |
| CV_cross | audio/speech/CV_cross_lingual.wav | 14s | 多语 | CosyVoice cross-lingual demo | 5s/10s |
| EM1_chunnuan | audio/speech/EM1_chunnuanhuakai.wav | 11s | 中文 | EchoMimic v1 demo | 5s/10s |
| EM1_jane | audio/speech/EM1_jane.wav | 16s | 英文 | EchoMimic v1 demo | 5s/10s |
| EM1_mei | audio/speech/EM1_mei.wav | 6s | 中文 | EchoMimic v1 demo | 5s |
| EM1_walden | audio/speech/EM1_walden.wav | 8s | 英文 | EchoMimic v1 demo | 5s |
| EM1_yun | audio/speech/EM1_yun.wav | 14s | 中文 | EchoMimic v1 demo | 5s/10s |
| EM2_man | audio/speech/EM2_echomimicv2_man.wav | 5s | 中文 | EchoMimic v2 demo | 5s |
| EM2_woman | audio/speech/EM2_echomimicv2_woman.wav | 6s | 中文 | EchoMimic v2 demo | 5s |
| EM2_nosmoking | audio/speech/EM2_no_smoking.wav | 5s | 中文 | EchoMimic v2 demo | 5s |
| EM2_ultraman | audio/speech/EM2_ultraman.wav | 5s | 中文 | EchoMimic v2 demo | 5s |
| H3_0001 | audio/speech/H3_0001.wav | 10s | 英文 | Hallo3 demo | 5s/10s |
| H3_0003 | audio/speech/H3_0003.wav | 9s | 英文 | Hallo3 demo | 5s |
| H3_0008 | audio/speech/H3_0008.wav | 10s | 英文 | Hallo3 demo | 5s/10s |
| H3_0009 | audio/speech/H3_0009.wav | 10s | 英文 | Hallo3 demo | 5s/10s |

> 共 23 条语音音频（已清理 <5s 短音频 6 条：A004、CV_zero_shot、EM1_chunwang、EM2_fighting、EM2_good、EM2_news）。

> **关键长音频**：
> - A007（英文，5.9min）：可覆盖全部 6 个测试档位 ✅
> - A001（中文，1.7min）：可覆盖至 1min 档位
> - MT_eng（英文，60s）：可覆盖至 1min 档位
> - A006（中文，40s）：可覆盖至 30s 档位

> ⚠️ **缺口**：**中文长时语音 3min/5min 档位**无法覆盖（最长中文音频 A001 仅 1.7min）。如需测试请用户补充 >=5min 中文讲话音频。

---

### Audio - Singing（唱歌）

| ID | 文件路径 | 时长 | 语言 | 来源 | 备注 |
|----|----------|------|------|------|------|
| S001 | audio/singing/S001_jaychou.wav | 10s | 中文 | Amphion VevoSing demo | 周杰伦风格 |
| S002 | audio/singing/S002_adele.wav | 9s | 英文 | Amphion VevoSing demo | Adele 风格 |
| S003 | audio/singing/S003_taiyizhenren.wav | 13s | 中文 | Amphion VevoSing demo | 哪吒主题 |

> ⚠️ **缺口**：唱歌音频均 <15s，仅可用于功能验证，无法测试长时稳定性。

---

### Avatar Image - 半身（half_body）

| ID | 文件路径 | 分辨率 | 描述 | 风格 |
|----|----------|--------|------|------|
| I001 | avatar_img/half_body/I001.png | 576×768 | 亚裔女性，红色礼服，红色背景，站姿 | 真实照片 |
| I002 | avatar_img/half_body/I002.png | 790×790 | 白人女性，播报风格，蓝色TV背景，正面 | 真实照片 |
| I006 | avatar_img/half_body/I006.jpeg | 1472×1104 | 亚裔女性，播客场景，**坐姿**，手在桌上 | 真实照片 |
| I013 | avatar_img/half_body/I013.png | 1024×1024 | AI生成亚裔女性，棕色上衣，户外背景，双手摊开 | AI生成 |
| I016 | avatar_img/half_body/I016.png | 741×741 | 西方年轻女性，纹身，蓝色背景，头肩照 | 真实照片 |
| I020 | avatar_img/half_body/I020.jpg | 624×624 | 西方女性，面部特写，自然光，中性背景 | 真实照片 |
| I021 | avatar_img/half_body/I021.jpg | 3511×3511 | **西方中年男性**（Rowan Atkinson），蓝色背景，头肩照 | 真实照片 |
| ST_full_body_2 | avatar_img/half_body/ST_full_body_2.png | 640×1024 | AI生成亚裔女性，红色武士装，暗色户外背景 | AI生成 |
| ST_full3 | avatar_img/half_body/ST_full3.png | 512×768 | AI生成白发女性，黑色围巾，雪景背景 | AI生成 |
| ST_full4 | avatar_img/half_body/ST_full4.jpeg | 450×675 | AI生成亚裔女性，面部特写，暖色室内背景 | AI生成 |
| LP_s2 | avatar_img/half_body/LP_s2.jpg | 2048×2048 | 西方年轻男性，黑白照，白色背景，衬衫 | 真实照片(黑白) |
| LP_s9 | avatar_img/half_body/LP_s9.jpg | 720×1280 | 蒙娜丽莎油画 | 名画 |
| HALLO2_1 | avatar_img/half_body/HALLO2_1.jpg | 1432×1432 | 西方少女，田园风格油画 | 油画 |

> 共 13 张半身像。覆盖：亚裔女性 ×4、西方女性 ×3、男性 ×2（I021真人 + LP_s2黑白照）、AI生成 ×3、名画/油画 ×2。
> 含 1 张坐姿（I006）。

---

### Avatar Image - 全身（full_body）

| ID | 文件路径 | 分辨率 | 描述 | 风格 |
|----|----------|--------|------|------|
| I017 | avatar_img/full_body/I017.jpg | 1080×1920 | 亚裔女性，蓝色休闲套装，户外，站姿 | 真实照片 |
| I018 | avatar_img/full_body/I018.jpg | 750×1101 | 西方女性，格子衬衫+黑短裤，白色背景，站姿 | 真实照片 |
| I019 | avatar_img/full_body/I019.jpg | 750×1101 | 西方女性，白背心+牛仔短裤，白色背景，站姿 | 真实照片 |
| I022 | avatar_img/full_body/I022.png | 800×1200 | AI生成女性，女仆装，站姿 | AI生成 |
| LP_s0 | avatar_img/full_body/LP_s0.jpg | 600×704 | 油画风格女性，紫色礼服，**坐姿** | 油画 |

> 共 5 张全身像。含坐姿 1 张（LP_s0 油画），男性全身像仍缺。

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
| C_zh_5s | i+a2v | A001 | I001 | 5s | 支持中文的 avatar 模型 |
| C_zh_10s | i+a2v | A001 | I001 | 10s | 支持中文的 avatar 模型 |
| C_zh_30s | i+a2v | A001 | I001 | 30s | 支持中文的 avatar 模型 |
| C_zh_1m | i+a2v | A001 | I001 | 1min | 支持中文的 avatar 模型 |
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
- **Audio 英文长时**：A007（5.9min）满足全部 6 个时长档位
- **Audio 英文中时**：MT_eng（60s）满足至 1min 档位
- **Audio 中文中时**：A001（100s）满足至 1min 档位
- **Image 半身像**：13 张，覆盖亚裔/西方/男性/AI生成/名画油画
- **Image 全身像**：5 张（含 1 张坐姿油画），较上次增加 2 张
- **Prompt**：15 个（8 情景 + 7 表情），充足

### 仍有缺口 ⚠️
| 缺口 | 优先级 | 说明 |
|------|--------|------|
| 中文长时语音 3min/5min | 高 | 最长中文音频 A001 仅 1.7min，3min/5min 档位无法覆盖 |
| 唱歌音频（>=3min）| 中 | S001-S003 仅 9-13s，只能验证功能 |
| 男性全身像 | 低 | 全身像均为女性（LP_s0 为油画） |
