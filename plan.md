# avatar-benchmark 项目计划

## 项目目标

构建一个标准化的 avatar 视频生成模型 benchmark，覆盖主流通用视频生成模型与 avatar 专用模型，通过统一的素材输入（audio/image/text）进行推理测试，评估各模型在长视频稳定性、人物一致性、音频嘴形同步、面部神态丰富度、全身动作丰富度等维度的表现。

---

## Phase 1：模型调研（→ model.md）

**目标**：对 info.md 中所有候选模型逐一调研，整理关键信息，判断是否可在单张 80G A800 上进行推理测试。

**调研字段**（每个模型）：
- GitHub 链接
- 模型大小（所有可用 checkpoint 规格）
- 资源需求（显存、GPU 数量）
- 是否提供推理代码
- 是否提供可用权重（公开下载）
- 是否支持长视频生成（>30s）及最大支持时长
- 是否支持 avatar 生成
- 支持的输入模态：image+audio→video / text→video / text+image→video

**候选模型列表**：

### 通用视频生成

| 类别 | 模型 |
|------|------|
| 离线生成 | Wan2.2, HunyuanVideo-1.5, Skyreels-v3 |
| 自回归生成 | Self-forcing, LongLive |
| 联合音视频生成 | MoVA, LTX-2, OVI |

### Avatar 视频生成

| 类别 | 模型 |
|------|------|
| 离线生成 | EchoMimic2, Hallo3, HunyuanVideo-Avatar, Wan2.2-S2V, OmniAvatar, MultiTalk, Longcat-Video, StableAvatar, FantasyTalking |
| 自回归生成 | LiveAvatar, LiveTalk, SoulX-FlashTalk |

**产出**：`autodl-tmp/avatar-benchmark/model.md`
- 以表格形式记录上述所有字段
- 标注"可测"（80G A800 可推理 + 提供推理代码和权重）或"不可测"及原因
- 同一模型多个尺寸版本均列出，可测的均标注

**任务状态**：[ ] 待执行

---

## Phase 2：环境配置与权重下载

**目标**：为可测试的模型完成 conda 环境配置、代码克隆和权重下载，验证可正常推理。

### 2.1 Conda 环境规划

- **环境目录映射**：将 conda 环境目录从 `~/miniconda3/envs` 映射到 `autodl-tmp/envs`，实际存储在 autodl-tmp，conda 使用不受影响
  ```bash
  # 在 ~/.condarc 中添加：
  envs_dirs:
    - /root/autodl-tmp/envs
    - /root/miniconda3/envs
  ```
- **统一环境优先**：优先在 `unified-env` 中安装所有模型依赖，减少环境数量
- **独立环境兜底**：存在严重依赖冲突且无法解决时，为该模型单独创建命名环境（如 `echomimic2-env`）

### 2.2 代码与权重管理

- 代码克隆路径：`autodl-tmp/avatar-benchmark/models/{model_name}/`
- 权重存放路径：`autodl-tmp/avatar-benchmark/models/{model_name}/weights/`（或按项目 README 指定位置）
- 权重下载策略：
  1. 优先尝试 `huggingface-cli download`、`modelscope download`、`wget/curl` 直接下载
  2. 下载缓慢或失败时，整理问题信息（URL、错误日志）后寻求帮助

### 2.3 执行顺序

按模型可测性（Phase 1 调研结果）和资源需求从小到大排序，逐个执行：
1. 克隆项目到 `models/{model_name}`
2. 按 README 配置 conda 环境（优先 unified-env）
3. 下载权重
4. 运行官方 demo 或最小推理脚本验证可用性
5. 在 model.md 中标注"已验证可运行"

**产出**：model.md 中各模型补充"环境配置状态"列

**任务状态**：[ ] 待 Phase 1 完成后执行

---

## Phase 3：素材收集与管理（→ input.md）

**目标**：从各模型官方网站/demo 页爬取示例素材，经预处理后建立标准化测试素材库，覆盖 info.md 中规定的素材类型，并在时长维度上覆盖多个测试档位。

### 3.1 素材目录结构

```
autodl-tmp/avatar-benchmark/input/
├── audio/
│   ├── speech/          # 演讲/对话类
│   │   ├── A001.wav     # 建议原始音频 >=5min，可截取各时长片段
│   │   └── A002.wav
│   └── singing/         # 唱歌类
│       ├── A003.wav
│       └── A004.wav
├── avatar_img/
│   ├── half_body/       # 半身像
│   │   ├── I001.png     # 站姿
│   │   └── I002.png     # 坐姿
│   └── full_body/       # 全身像
│       ├── I003.png     # 站姿
│       └── I004.png     # 坐姿
└── prompt/
    ├── P001.txt         # 演讲场景
    ├── P002.txt         # 下棋场景
    ├── P003.txt         # 弹琴场景
    ├── P004.txt         # 跳舞场景
    ├── P005.txt         # 微笑表情
    ├── P006.txt         # 愤怒表情
    └── P007.txt         # 悲伤表情
```

### 3.2 素材覆盖要求

| 类别 | 要求 | 数量目标 |
|------|------|----------|
| Audio - 讨论/对话 | 清晰人声，原始时长 >=5min，中英文各备 | >=4 条 |
| Audio - 唱歌 | 人声歌唱，原始时长 >=3min | >=2 条 |
| Avatar Image - 半身站/坐 | 正面或略侧，背景简洁，分辨率 >=512px | >=2 张 |
| Avatar Image - 全身站/坐 | 全身可见，背景简洁，分辨率 >=512px | >=2 张 |
| Prompt - 情景 | 演讲/下棋/弹琴/跳舞各一条 | >=4 条 |
| Prompt - 表情 | 微笑/愤怒/悲伤各一条 | >=3 条 |

### 3.3 测试时长覆盖

测试时长档位：**5s / 10s / 30s / 1min / 3min / 5min**

每个模型根据其声称支持的最长生成时长决定测试哪些档位：

| 模型支持范围 | 测试档位 |
|-------------|---------|
| 仅支持短视频（<=15s） | 5s、10s |
| 支持中等长度（<=1min） | 5s、10s、30s、1min |
| 支持长视频（<=5min） | 5s、10s、30s、1min、3min |
| 支持无限或极长视频 | 5s、10s、30s、1min、3min、5min |

**注意**：
- audio 素材原始时长建议 >=5min，测试时按需截取对应时长片段
- Condition ID 中编码时长信息，格式：`C{内容编号}_{时长}`
  - 时长编码规则：5s → `5s`，10s → `10s`，30s → `30s`，1min → `1m`，3min → `3m`，5min → `5m`
  - 示例：`C001_5s`、`C001_30s`、`C001_3m`

### 3.4 素材来源

- 优先从各模型官网 demo 页爬取示例音频和图像
- 辅助来源：公开数据集（LRS3、HDTF、CelebV-HQ 等）
- 实在无法获取的类别素材，整理缺口后寻求帮助

### 3.5 input.md 结构

`input.md` 记录所有可用素材及测试条件组合（condition），格式如下：

```markdown
## 素材索引

### Audio
| ID  | 文件路径 | 类别 | 原始时长 | 语言 | 描述 |
|-----|----------|------|----------|------|------|
| A001 | audio/speech/A001.wav | 讨论 | 6min | 中文 | 女声，正常语速，新闻播报风格 |
...

### Avatar Image
| ID  | 文件路径 | 类别 | 姿态 | 描述 |
|-----|----------|------|------|------|
| I001 | avatar_img/half_body/I001.png | 半身 | 站姿 | 亚裔女性，白色背景，正面 |
...

### Prompt
| ID  | 文件路径 | 场景 | 内容摘要 |
|-----|----------|------|----------|
| P001 | prompt/P001.txt | 演讲 | "A confident woman giving a TED talk..." |
...

## 测试条件组合（Condition）

| Condition ID | 输入类型 | Audio | Image | Prompt | 时长 | 备注 |
|-------------|----------|-------|-------|--------|------|------|
| C001_5s | image+audio->video | A001 | I001 | - | 5s | 半身像+中文演讲音频 |
| C001_10s | image+audio->video | A001 | I001 | - | 10s | 半身像+中文演讲音频 |
| C001_30s | image+audio->video | A001 | I001 | - | 30s | 半身像+中文演讲音频 |
| C001_1m | image+audio->video | A001 | I001 | - | 1min | 半身像+中文演讲音频 |
| C001_3m | image+audio->video | A001 | I001 | - | 3min | 半身像+中文演讲音频 |
| C001_5m | image+audio->video | A001 | I001 | - | 5min | 半身像+中文演讲音频 |
| C002_5s | image+audio->video | A002 | I003 | - | 5s | 全身像+英文音频 |
| C002_30s | image+audio->video | A002 | I003 | - | 30s | 全身像+英文音频 |
| C004_10s | text+image->video | - | I001 | P001 | 10s | 半身像+演讲 prompt |
| C004_30s | text+image->video | - | I001 | P001 | 30s | 半身像+演讲 prompt |
| C006_10s | text->video | - | - | P003 | 10s | 纯文本弹琴 |
...
```

**注意**：每个模型根据其支持的输入模态，选用对应的 Condition：
- 支持 image+audio->video 的模型 -> 优先使用 C001/C002 系列
- 不支持 audio driven -> 使用 text+image（C004 系列）或 text（C006 系列）
- 每个模型只测其支持时长范围内的 Condition

**任务状态**：[ ] 与 Phase 2 并行执行，完成后需用户检查素材质量

---

## Phase 4：推理生成与输出管理

**前置条件**：用户已检查并确认 Phase 3 的素材收集质量

**目标**：对每个已验证可运行的模型，使用 input.md 中的标准 Condition 进行推理，输出视频统一存放。

### 4.1 输出目录结构

```
autodl-tmp/avatar-benchmark/output/
└── {model_name}/
    ├── C001_5s.mp4
    ├── C001_30s.mp4
    ├── C001_3m.mp4
    └── config.json      # 推理参数配置（steps、resolution、seed 等）
```

### 4.2 推理规范

- 每个模型使用与其能力匹配的 Condition（image+audio->video / text+image->video / text->video）
- 时长测试范围根据模型支持能力确定（参照 Phase 3 § 3.3 的档位规则）
- 同类型模型尽量使用完全相同的 Condition 组合，便于横向对比
- 记录每次推理的参数配置（steps、resolution、seed 等）到 `output/{model_name}/config.json`

### 4.3 评估维度（人工评估）

| 维度 | 说明 |
|------|------|
| 画面稳定性 | 长视频中是否出现闪烁、抖动、崩坏 |
| 人物一致性 | 跨帧人物外观、服装、发型是否稳定 |
| 音频嘴形一致性 | 嘴唇动作与音频节奏是否同步（仅 audio-driven 模型）|
| 面部神态丰富度 | 表情变化是否自然、多样 |
| 全身动作丰富度 | 身体动作是否自然、与内容匹配 |

**任务状态**：[ ] 待用户确认素材后执行

---

## 进度总览

| Phase | 内容 | 状态 | 产出文件 |
|-------|------|------|----------|
| Phase 0 | 项目初始化、git 配置 | 完成 | claude.md, progress.md |
| Phase 1 | 模型调研 | [ ] 待执行 | model.md |
| Phase 2 | 环境配置与权重下载 | [ ] 待 Phase 1 完成 | model.md 补充状态列 |
| Phase 3 | 素材收集与 input.md | [ ] 与 Phase 2 并行 | input.md, input/ 目录 |
| Phase 4 | 推理生成 | [ ] 待用户确认素材 | output/ 目录 |
