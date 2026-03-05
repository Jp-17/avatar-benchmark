# 素材索引与测试条件组合（Phase 3）

**初次收集**：2026-03-05（来源：EchoMimic v2 / Hallo3 / FantasyTalking / StableAvatar / OmniAvatar / LiveAvatar）
**补充收集**：2026-03-06（来源：SadTalker / AniPortrait / EchoMimic v2 ref set / MimicMotion / UniAnimate）

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

### Avatar Image - 半身（half_body）—— 已有（含问题标注）

| ID | 文件路径 | 分辨率 | 来源 | 人工核查结果 | 备注 |
|----|----------|--------|------|------------|------|
| I001 | avatar_img/half_body/I001.png | 576×768 | EchoMimic v2 demo | ✅ 亚裔女性，红色礼服，半身，红色背景 | 背景略复杂 |
| I002 | avatar_img/half_body/I002.png | 790×790 | StableAvatar case-1 | ✅ 白人女性，播报风格头肩照，蓝色TV背景 | 背景有TV元素 |
| I003 | avatar_img/half_body/I003.png | 1024×1024 | FantasyTalking woman | ✅ 西方女性，AI生成面部特写，暗色背景 | 仅头部，无上身 |
| I004 | avatar_img/half_body/I004.jpg | 480×480 | Hallo3 demo 0001 | ❌ **拒绝**：图中为儿童在野外烤棉花糖，完全不是 avatar 图 | 需删除 |
| I005 | avatar_img/half_body/I005.jpg | 480×480 | Hallo3 demo 0018 | ⚠️ **存疑**：极度艺术化妆侧脸（花冠+橙色羽毛），偏风格化 | 用户判断 |
| I006 | avatar_img/half_body/I006.jpeg | 1472×1104 | OmniAvatar demo | ✅ 亚裔女性，播客场景半身像，自然坐姿，浅色背景 | 质量好，AI图 |

### Avatar Image - 全身（full_body）—— 已有（含问题标注）

| ID | 文件路径 | 分辨率 | 来源 | 人工核查结果 | 备注 |
|----|----------|--------|------|------------|------|
| I007 | avatar_img/full_body/I007.png | 1447×983 | FantasyTalking fig | ❌ **拒绝**：这是模型 demo 的多图对比展示截图，不是单人照片 | 需删除 |
| I008 | avatar_img/full_body/I008.png | 1020×1006 | StableAvatar case-2 | ⚠️ **分类错误**：实为中年秃头男性头肩照（非全身），分辨率可，可转至 half_body | 需重新分类 |

---

### Avatar Image - 候选素材（2026-03-06 新增，待用户审核）

所有候选文件存放在 `input/avatar_img/candidates/` 目录，供用户挑选后移入正式目录并编号。

#### 半身像候选

| 文件名 | 分辨率 | 来源 | 描述 | 推荐等级 |
|--------|--------|------|------|----------|
| ST_people_0.png | 474×474 | SadTalker examples | 优雅深发女性，灰色背景，半身，正面，专业照风格 | ⭐⭐⭐（分辨率略低于512px）|
| ST_happy.png | 256×256 | SadTalker examples | 西方年轻女性，绿色户外背景，头肩正面照 | ⭐⭐ |
| ST_happy1.png | — | SadTalker examples | 西方女性，白色背景，面部正面，干净 | ⭐⭐⭐ |
| AP_Aragaki.png | 590×590 | AniPortrait ref | 新垣结衣，日系女性，白色背景，头肩照，极简洁 | ⭐⭐⭐⭐ |
| AP_lyl.png | 653×660 | AniPortrait ref | **中年亚裔男性**，深色背景，头肩照（有男性多样性） | ⭐⭐⭐ |
| AP_solo.png | 741×741 | AniPortrait ref | 西方年轻女性，颈部纹身，蓝色背景，头肩照 | ⭐⭐⭐ |
| EM2_0014.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白T恤，教室背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0035.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白T恤，暗绿背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0047.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，灰色上衣，户外自然背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0082.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，黑色T恤，教室背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0163.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白色长袖，黑板背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0303.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，棕色上衣，户外背景，半身开手姿 | ⭐⭐⭐⭐ |
| EM2_0510.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，白色T恤，极简白色背景，半身开手姿 | ⭐⭐⭐⭐⭐ |
| EM2_0213.png | 1024×1024 | EchoMimic v2 ref | AI生成亚裔女性，蓝色上衣，教室背景，双手背后站姿 | ⭐⭐⭐⭐ |

> 注：EM2 系列均为 EchoMimic v2 专用参考图（AI 生成同一人物不同背景/服装版本），选取 2-3 张有代表性的即可。

#### 全身像候选

| 文件名 | 分辨率 | 来源 | 描述 | 推荐等级 |
|--------|--------|------|------|----------|
| MM_demo1.jpg | 1080×1920 | MimicMotion demo | **亚裔女性全身照**，蓝色休闲套装，淡色户外背景，站姿 | ⭐⭐⭐⭐⭐ |
| UA_women1.jpg | 750×1101 | UniAnimate data | 西方女性全身，格子衬衫+黑短裤，白色背景，时尚站姿 | ⭐⭐⭐⭐ |
| UA_women2.jpg | 750×1101 | UniAnimate data | 西方女性全身，白背心+牛仔短裤，白色背景，时尚站姿 | ⭐⭐⭐⭐ |

> ⚠️ **全身像缺口**：目前仅有女性全身像，**暂无男性全身像候选**。若需要，请用户提供或告知来源。

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

### 紧急（影响 Phase 4 能否进行）

1. **中文长音频（缺口未解决）**：仍需 >=5min 中文普通话讲话音频，方可支持中文 3min/5min 档位。请提供 WAV/MP3 文件或可 wget 的直链。

2. **图片审核（新）**：
   - **确认删除**：I004.jpg（儿童图，非 avatar）、I007.png（demo 截图，非单人照）
   - **确认重分类**：I008.png（秃头男性头肩照）→ 从 full_body 移至 half_body
   - **挑选正式图**：从 `avatar_img/candidates/` 中选出满意的图片，告知文件名，我来重命名为 I009/I010... 并移入正式目录
   - **推荐优先看**：EM2_0510.png（最干净半身）、AP_Aragaki.png（最自然日系女性）、AP_lyl.png（唯一男性候选）、MM_demo1.jpg（最佳全身）

### 可选（非阻塞）

3. **唱歌音频**：若要测试 singing avatar 场景，请提供 >=3min 唱歌音频（WAV/MP3）
4. **男性全身像**：目前候选中无男性全身像，若需要请提供
