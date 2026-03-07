# 素材索引与测试条件组合（Phase 3）

**初次收集**：2026-03-05
**二次迭代**：2026-03-06
**人工筛选 & 清理**：2026-03-06（用户人工筛选图片素材，清理 <5s 短音频）
**Phase 4 固定组合**：2026-03-07（新增 `filtered` 目录，并将正式测试素材收敛为 4 组标准 Condition）

---

## 素材索引

### Audio - Speech（讲话/对话）


| ID            | 文件路径                                   | 时长            | 语言  | 来源                           | 可测档位                      |
| ------------- | -------------------------------------- | ------------- | --- | ---------------------------- | ------------------------- |
| A001          | audio/speech/A001.wav                  | 100s (1.7min) | 中文  | StableAvatar case-1 demo     | 5s/10s/30s/1min           |
| A002          | audio/speech/A002.wav                  | 12s           | 英文  | Hallo3 demo 0018             | 5s/10s                    |
| A003          | audio/speech/A003.wav                  | 11s           | 英文  | Hallo3 demo 0022             | 5s/10s                    |
| A005          | audio/speech/A005.wav                  | 6s            | 中文  | MuseTalk demo                | 5s                        |
| A006          | audio/speech/A006.wav                  | 40s           | 中文  | StableAvatar case-2 demo     | 5s/10s/30s                |
| A007          | audio/speech/A007.wav                  | 353s (5.9min) | 英文  | LiveAvatar boy demo          | 5s/10s/30s/1min/3min/5min |
| MT_eng        | audio/speech/MT_eng.wav                | 60s           | 英文  | MuseTalk english demo        | 5s/10s/30s/1min           |
| MT_sun        | audio/speech/MT_sun.wav                | 22s           | 中文  | MuseTalk sun demo            | 5s/10s                    |
| MT_yongen     | audio/speech/MT_yongen.wav             | 8s            | 中文  | MuseTalk yongen demo         | 5s                        |
| CV_cross      | audio/speech/CV_cross_lingual.wav      | 14s           | 多语  | CosyVoice cross-lingual demo | 5s/10s                    |
| EM1_chunnuan  | audio/speech/EM1_chunnuanhuakai.wav    | 11s           | 中文  | EchoMimic v1 demo            | 5s/10s                    |
| EM1_jane      | audio/speech/EM1_jane.wav              | 16s           | 英文  | EchoMimic v1 demo            | 5s/10s                    |
| EM1_mei       | audio/speech/EM1_mei.wav               | 6s            | 中文  | EchoMimic v1 demo            | 5s                        |
| EM1_walden    | audio/speech/EM1_walden.wav            | 8s            | 英文  | EchoMimic v1 demo            | 5s                        |
| EM1_yun       | audio/speech/EM1_yun.wav               | 14s           | 中文  | EchoMimic v1 demo            | 5s/10s                    |
| EM2_man       | audio/speech/EM2_echomimicv2_man.wav   | 5s            | 中文  | EchoMimic v2 demo            | 5s                        |
| EM2_woman     | audio/speech/EM2_echomimicv2_woman.wav | 6s            | 中文  | EchoMimic v2 demo            | 5s                        |
| EM2_nosmoking | audio/speech/EM2_no_smoking.wav        | 5s            | 中文  | EchoMimic v2 demo            | 5s                        |
| EM2_ultraman  | audio/speech/EM2_ultraman.wav          | 5s            | 中文  | EchoMimic v2 demo            | 5s                        |
| H3_0001       | audio/speech/H3_0001.wav               | 10s           | 英文  | Hallo3 demo                  | 5s/10s                    |
| H3_0003       | audio/speech/H3_0003.wav               | 9s            | 英文  | Hallo3 demo                  | 5s                        |
| H3_0008       | audio/speech/H3_0008.wav               | 10s           | 英文  | Hallo3 demo                  | 5s/10s                    |
| H3_0009       | audio/speech/H3_0009.wav               | 10s           | 英文  | Hallo3 demo                  | 5s/10s                    |


> 共 23 条语音音频（已清理 <5s 短音频 6 条：A004、CV_zero_shot、EM1_chunwang、EM2_fighting、EM2_good、EM2_news）。

> **关键长音频**：
>
> - A007（英文，5.9min）：可覆盖全部 6 个测试档位 ✅
> - A001（中文，1.7min）：可覆盖至 1min 档位
> - MT_eng（英文，60s）：可覆盖至 1min 档位
> - A006（中文，40s）：可覆盖至 30s 档位

> ⚠️ **缺口**：**中文长时语音 3min/5min 档位**无法覆盖（最长中文音频 A001 仅 1.7min）。如需测试请用户补充 >=5min 中文讲话音频。

---

### Audio - Singing（唱歌）


| ID   | 文件路径                                | 时长  | 语言  | 来源                    | 备注       |
| ---- | ----------------------------------- | --- | --- | --------------------- | -------- |
| S001 | audio/singing/S001_jaychou.wav      | 10s | 中文  | Amphion VevoSing demo | 周杰伦风格    |
| S002 | audio/singing/S002_adele.wav        | 9s  | 英文  | Amphion VevoSing demo | Adele 风格 |
| S003 | audio/singing/S003_taiyizhenren.wav | 13s | 中文  | Amphion VevoSing demo | 哪吒主题     |


> ⚠️ **缺口**：唱歌音频均 <15s，仅可用于功能验证，无法测试长时稳定性。

---

### Avatar Image - 半身（half_body）


| ID             | 文件路径                                    | 分辨率       | 描述                                  | 风格       |
| -------------- | --------------------------------------- | --------- | ----------------------------------- | -------- |
| I001           | avatar_img/half_body/I001.png           | 576×768   | 亚裔女性，红色礼服，红色背景，站姿                   | 真实照片     |
| I002           | avatar_img/half_body/I002.png           | 790×790   | 白人女性，播报风格，蓝色TV背景，正面                 | 真实照片     |
| I006           | avatar_img/half_body/I006.jpeg          | 1472×1104 | 亚裔女性，播客场景，**坐姿**，手在桌上               | 真实照片     |
| I013           | avatar_img/half_body/I013.png           | 1024×1024 | AI生成亚裔女性，棕色上衣，户外背景，双手摊开             | AI生成     |
| I016           | avatar_img/half_body/I016.png           | 741×741   | 西方年轻女性，纹身，蓝色背景，头肩照                  | 真实照片     |
| I020           | avatar_img/half_body/I020.jpg           | 624×624   | 西方女性，面部特写，自然光，中性背景                  | 真实照片     |
| I021           | avatar_img/half_body/I021.jpg           | 3511×3511 | **西方中年男性**（Rowan Atkinson），蓝色背景，头肩照 | 真实照片     |
| ST_full_body_2 | avatar_img/half_body/ST_full_body_2.png | 640×1024  | AI生成亚裔女性，红色武士装，暗色户外背景               | AI生成     |
| ST_full3       | avatar_img/half_body/ST_full3.png       | 512×768   | AI生成白发女性，黑色围巾，雪景背景                  | AI生成     |
| ST_full4       | avatar_img/half_body/ST_full4.jpeg      | 450×675   | AI生成亚裔女性，面部特写，暖色室内背景                | AI生成     |
| LP_s2          | avatar_img/half_body/LP_s2.jpg          | 2048×2048 | 西方年轻男性，黑白照，白色背景，衬衫                  | 真实照片(黑白) |
| LP_s9          | avatar_img/half_body/LP_s9.jpg          | 720×1280  | 蒙娜丽莎油画                              | 名画       |
| HALLO2_1       | avatar_img/half_body/HALLO2_1.jpg       | 1432×1432 | 西方少女，田园风格油画                         | 油画       |


> 共 13 张半身像。覆盖：亚裔女性 ×4、西方女性 ×3、男性 ×2（I021真人 + LP_s2黑白照）、AI生成 ×3、名画/油画 ×2。
> 含 1 张坐姿（I006）。

---

### Avatar Image - 全身（full_body）


| ID    | 文件路径                           | 分辨率       | 描述                    | 风格   |
| ----- | ------------------------------ | --------- | --------------------- | ---- |
| I017  | avatar_img/full_body/I017.jpg  | 1080×1920 | 亚裔女性，蓝色休闲套装，户外，站姿     | 真实照片 |
| I018  | avatar_img/full_body/I018.jpg  | 750×1101  | 西方女性，格子衬衫+黑短裤，白色背景，站姿 | 真实照片 |
| I019  | avatar_img/full_body/I019.jpg  | 750×1101  | 西方女性，白背心+牛仔短裤，白色背景，站姿 | 真实照片 |
| I022  | avatar_img/full_body/I022.png  | 800×1200  | AI生成女性，女仆装，站姿         | AI生成 |
| LP_s0 | avatar_img/full_body/LP_s0.jpg | 600×704   | 油画风格女性，紫色礼服，**坐姿**    | 油画   |


> 共 5 张全身像。含坐姿 1 张（LP_s0 油画），男性全身像仍缺。

---

### Prompt - 情景与表情（P001–P015）


| ID   | 文件路径            | 场景    | 内容摘要                                                                        |
| ---- | --------------- | ----- | --------------------------------------------------------------------------- |
| P001 | prompt/P001.txt | 演讲（站） | A confident person at a podium delivering a TED-style speech...             |
| P002 | prompt/P002.txt | 下棋    | A person sitting at a chess board, thoughtfully studying...                 |
| P003 | prompt/P003.txt | 弹琴    | A person sitting at a piano, playing gracefully...                          |
| P004 | prompt/P004.txt | 跳舞    | A person dancing energetically with fluid full-body movements...            |
| P005 | prompt/P005.txt | 微笑    | The person is smiling warmly and genuinely...                               |
| P006 | prompt/P006.txt | 愤怒    | The person appears visibly angry, furrowed brows...                         |
| P007 | prompt/P007.txt | 悲伤    | The person looks deeply sad and sorrowful...                                |
| P008 | prompt/P008.txt | 演讲（坐） | A person seated at a desk delivering a lecture, hands on desk...            |
| P009 | prompt/P009.txt | 读书    | A person sitting and reading a book intently, looking up thoughtfully...    |
| P010 | prompt/P010.txt | 打电话   | A person engaged in a phone call, holding phone to ear, gesturing...        |
| P011 | prompt/P011.txt | 招手/问候 | A person greeting with a friendly wave, bright welcoming smile...           |
| P012 | prompt/P012.txt | 点头    | A person nodding in agreement, calm expression, slight smile...             |
| P013 | prompt/P013.txt | 唱歌    | A person singing passionately, swaying with rhythm, emotional expression... |
| P014 | prompt/P014.txt | 快乐    | The person is visibly happy and joyful, bright genuine smile, animated...   |
| P015 | prompt/P015.txt | 惊讶    | The person reacts with surprise and shock, wide eyes, mouth agape...        |


---

## 测试条件组合（Condition）

### Phase 4 执行原则

- Phase 4 标准横评固定为 4 组人工筛选素材；每个模型最多测试这 4 组，不再扩展 5s/10s/30s/1min/3min/5min 多档位。
- 统一只使用 `input/audio/filtered/` 与 `input/avatar_img/filtered/` 下的人工筛选素材作为正式测试输入。
- 基准优先覆盖两条维度：半身 / 全身，短时 / 长时。
- 若模型不支持长时、全身或 audio-driven，只执行能力范围内可运行的子集，并在对应 `output/{model_name}/results.md` 中明确记录跳过原因。
- 本轮标准 Condition 以 image+audio→video 为统一基线；如后续需要 text+image→video 或 text→video 条件，再单独补充。

### Phase 4 标准 Condition（最多 4 组）

| Condition ID | 输入类型 | Audio 路径 | Image 路径 | 组合说明 |
| --- | --- | --- | --- | --- |
| C_half_short | i+a2v | `input/audio/filtered/short/EM2_no_smoking.wav` | `input/avatar_img/filtered/half_body/13.png` | 半身短时间 |
| C_half_long | i+a2v | `input/audio/filtered/long/A001.wav` | `input/avatar_img/filtered/half_body/2.png` | 半身长时间 |
| C_full_short | i+a2v | `input/audio/filtered/short/S002_adele.wav` | `input/avatar_img/filtered/full_body/1.png` | 全身短时间 |
| C_full_long | i+a2v | `input/audio/filtered/long/MT_eng.wav` | `input/avatar_img/filtered/full_body/3.png` | 全身长时间 |

### filtered 目录备用素材

#### Audio
- `input/audio/filtered/short/`：`EM2_no_smoking.wav`、`MT_yongen.wav`、`S001_jaychou.wav`、`S002_adele.wav`、`S003_taiyizhenren.wav`
- `input/audio/filtered/long/`：`A001.wav`、`A007.wav`、`MT_eng.wav`

#### Image
- `input/avatar_img/filtered/half_body/`：`2.png`、`12.png`、`13.png`、`7.jpg`、`9.jpg`
- `input/avatar_img/filtered/full_body/`：`1.png`、`3.png`、`5.png`、`6.png`、`8.png`

---

## 素材现状总结

- Phase 4 正式 benchmark 输入已收敛为 4 组固定组合：半身短时、半身长时、全身短时、全身长时。
- 这 4 组组合直接对应 `filtered` 目录中的人工筛选结果，后续各模型横向对比以它们为唯一默认基线。
- 其余 `filtered` 素材保留为备用候选，默认不纳入本轮标准 Phase 4 批量测试。
