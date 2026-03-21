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
| 离线生成 | EchoMimic2, Hallo3, HunyuanVideo-Avatar, Wan2.2-S2V, OmniAvatar, MultiTalk, InfiniteTalk, Longcat-Video, StableAvatar, FantasyTalking |
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
- 共享权重去重：若多个模型依赖完全相同的权重文件，优先将其统一放入 `autodl-tmp/avatar-benchmark/weights_shared/`，再在各模型目录中通过软链接引用；下载新权重前先检查 `weights_shared/` 是否已有可复用文件，避免重复占用磁盘空间。
- 权重下载策略：
  1. 优先尝试 `huggingface-cli download`、`modelscope download`、`wget/curl` 直接下载
  2. 下载缓慢或失败时，整理问题信息（URL、错误日志）后寻求帮助

### 2.2.1 最小推理验证规范

- **触发条件**：当某模型的环境和权重都已就绪后，需立即进行一次最小素材推理测试，目标仅为验证该模型可以正常跑通推理链路，不追求完整 benchmark 覆盖。
- **最小测试素材**：默认仅使用 1 组固定素材，图片使用 `autodl-tmp/avatar-benchmark/input/avatar_img/half_body/I013.png`，音频使用 `autodl-tmp/avatar-benchmark/test/echomimic_v2/input/A007_5s.wav`，若模型需要 text prompt，则使用 `autodl-tmp/avatar-benchmark/input/prompt/P011.txt`。
- **测试目录规范**：将上述素材 copy 到 `autodl-tmp/avatar-benchmark/test/{model_name}/input/`；测试结果统一输出到 `autodl-tmp/avatar-benchmark/test/{model_name}/output/`。
- **测试记录规范**：在 `autodl-tmp/avatar-benchmark/test/{model_name}/test.md` 中补充该模型的最小推理信息，格式参考 `autodl-tmp/avatar-benchmark/test/echomimic_v2/test.md`。
- **test.md 必填内容**：至少包含模型环境名称、所需资源与运行时间、实际运行命令和脚本路径、运行 config、输入素材要求（如分辨率/时长/采样率等）、遇到的问题及解决方案。
- **执行目的**：优先确认环境、权重、依赖、推理脚本、素材预处理链路均可用；若最小测试失败，先修复该模型的最小推理链路，再继续后续批量测试。

### 2.3 执行顺序与目标范围

**目标**：尽可能完成以下所有模型的配置，按优先级顺序推进。每个模型执行步骤：
1. 克隆项目到 `models/{model_name}`
2. 按 README 配置 conda 环境（优先复用已有环境）
3. 下载权重（HuggingFace 新格式仓库下载时**不启用** network_turbo 代理）
4. 运行官方 demo 或最小推理脚本验证可用性（可直接通过 SSH 执行（已确认 GPU 可用））
5. 在 model.md 中标注"已验证可运行"

#### 第一优先：自回归音频驱动 Avatar
| 模型 | 状态 |
|------|------|
| LiveTalk | [x] 环境+权重完成 |
| SoulX-FlashTalk | [x] 环境✅(flashtalk-env) + 权重✅(42.5G) + 测试脚本✅ |
| SoulX-FlashHead(Pro/Lite) | [x] 环境✅(flashhead-env) + 权重✅(~14G) + 测试脚本✅ + 最小推理✅(Lite 174s/Pro 283s) |
| LiveAvatar | [x] 环境✅(liveavatar-env) + 权重✅(47G) + 测试脚本✅ |

#### 第二优先：其他音频驱动 Avatar
| 模型 | 状态 |
|------|------|
| EchoMimic v2 | [x] 环境+权重完成 |
| StableAvatar | [x] 环境+权重完成 |
| MultiTalk | [~] 环境✅(unified-env) + 权重✖(6.3G/~50G, XetHub CDN超时) |
| InfiniteTalk | [~] 环境✅(unified-env) + 权重✖(21G/~115G, XetHub CDN超时) |
| FantasyTalking | [x] 环境✅(fantasy-talking-env) + 权重✅(32G) + 测试脚本✅ |
| OmniAvatar | [x] 环境✅(omniavatar-env) + 权重✅(66G) + 测试脚本✅ |
| HunyuanVideo-Avatar | [x] 已清理（2026-03-22 删除 hunyuan-avatar-env + 权重） |
| Hallo3 | [x] 环境✅(hallo3-env) + 权重✅(49G) + Phase4推理3/10 |
| LongCat-Video-Avatar | [~] 环境✅(longcat-env) + 权重✖(495M, XetHub CDN超时) |
| Wan2.2-S2V | [x] 环境✅(wan2.2-env) + 权重✅(46G) + 测试脚本✅ |

#### 第三优先：音视频联合生成
| 模型 | 状态 |
|------|------|
| LTX-2 | [ ] 待配置 |
| OVI | [ ] 待配置 |
| MOVA | [ ] 待配置（单卡可行性待确认） |

#### 第四优先：通用视频生成
| 模型 | 状态 |
|------|------|
| Wan2.2 | [~] 代码已克隆(Wan-Video/Wan2.2)，环境安装中(wan2.2-env)，权重待下载 |
| HunyuanVideo-1.5 | [ ] 待配置 |
| Self-Forcing | [ ] 待配置 |
| LongLive | [ ] 待配置 |
| SkyReels-V3 | [x] 已清理（2026-03-22 删除 skyreels-env + 权重） |

**产出**：model.md 中各模型补充"环境配置状态"列

**任务状态**：[~] 已完成 17 个模型的 Phase 4（3 个 4/4 全量完成 + 14 个 2/4 支持子集完成）；OmniAvatar 与 LongCat-Video-Avatar 已补齐短时支持子集；LiveAvatar 已判定停止继续投入单卡多 clip / full-audio 路径；Wan2.2-S2V / LTX-2 / FantasyTalking 的 full-audio 是否继续改为后续单独决策；Wan2.2-T2V 继续暂停。**SoulX-FlashHead（新增 2026-03-11）**：Lite + Pro 各 4 条件推理**已全部完成**（face_crop 版 + nofacecrop 对比版）。输出目录：`output/soulx_flashhead_lite_phase4/`、`output/soulx_flashhead_pro_phase4/`（face_crop）及 `_nofacecrop/` 对应目录（无 face_crop），各含 4 个 mp4 和 results.md。注意 argparse type=bool bug：`--use_face_crop False` 实际解析为 True，需完全省略该参数。

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

**任务状态**：[x] 素材收集完成，用户已完成人工筛选，input.md 已更新

---

## Phase 4：推理生成与输出管理

**前置条件**：用户已完成人工筛选，`input/audio/filtered/` 与 `input/avatar_img/filtered/` 已同步到远程服务器

**目标**：对每个已验证可运行的模型，按 input.md 中定义的 4 组标准 Condition 进行正式推理；每个模型最多输出 4 组结果，分别覆盖半身/全身与短时/长时。

### 4.1 输出目录结构

```
autodl-tmp/avatar-benchmark/output/
└── {model_name}/
    ├── C_half_short.mp4
    ├── C_half_long.mp4
    ├── C_full_short.mp4
    ├── C_full_long.mp4
    ├── config.json      # 推理参数配置（steps、resolution、seed 等）
    └── results.md       # 每个 Condition 的命令、素材、结果与报错记录
```

### 4.2 推理规范

- 本轮 Phase 4 统一只使用 `filtered` 目录中的人工筛选素材，路径以 `input/audio/filtered/` 和 `input/avatar_img/filtered/` 为准。
- 标准 Condition 固定为 4 组：
  - `C_half_short`：`input/audio/filtered/short/EM2_no_smoking.wav` + `input/avatar_img/filtered/half_body/13.png`
  - `C_half_long`：`input/audio/filtered/long/A001.wav` + `input/avatar_img/filtered/half_body/2.png`
  - `C_full_short`：`input/audio/filtered/short/S002_adele.wav` + `input/avatar_img/filtered/full_body/1.png`
  - `C_full_long`：`input/audio/filtered/long/MT_eng.wav` + `input/avatar_img/filtered/full_body/3.png`
- 每个模型最多测试上述 4 组组合，不再按 Phase 3 的 5s/10s/30s/1min/3min/5min 全档位铺开。
- 模型执行 Phase 4 正式推理时，可优先参考该模型在 Phase 2 最小素材测试阶段沉淀的可运行命令、环境变量、依赖补丁与避坑经验，相关记录统一查看 test/{model_name}/ 下的脚本与说明文件。
- 若模型不支持长时、全身或 audio-driven，只执行能力范围内可运行的子集，并在 `output/{model_name}/results.md` 中明确记录跳过原因。
- 同类型模型优先保持完全一致的 Condition 组合，便于横向对比。
- 每次推理都要将实际命令、素材路径、config 参数、输出路径、每个 Condition 组合测试时的显存占用、推理生成时间，以及失败经验与解决方法同步记录到 `output/{model_name}/results.md`。

### 4.3 评估维度（人工评估）

| 维度 | 说明 |
|------|------|
| 画面稳定性 | 长视频中是否出现闪烁、抖动、崩坏 |
| 人物一致性 | 跨帧人物外观、服装、发型是否稳定 |
| 音频嘴形一致性 | 嘴唇动作与音频节奏是否同步（仅 audio-driven 模型）|
| 面部神态丰富度 | 表情变化是否自然、多样 |
| 全身动作丰富度 | 身体动作是否自然、与内容匹配 |

**任务状态**：[~] 已完成 15 个模型的 Phase 4（3 个 4/4 全量完成 + 12 个 2/4 支持子集完成），OmniAvatar 正在补跑 `C_full_short`；LongCat-Video-Avatar 已接入夜间队列；Wan2.2-T2V 暂停；随后将对 LiveAvatar、Wan2.2-S2V、LTX-2、FantasyTalking 进行“按原始音频时长”补跑。

### 4.4 Phase 4 审计清单（2026-03-08 19:30）

| 模型 | output 目录 | 实际状态 | 与 Phase 2 最小测试一致性 | 备注 |
|------|-------------|----------|---------------------------|------|
| EchoMimic v2 | output/echomimic_v2_newphase4/ | ✅ 4/4 完成 | 基本一致 | 新 Phase 4 产物已从 legacy 目录拆分 |
| StableAvatar | output/stableavatar_newphase4/ | ✅ 4/4 完成 | 基本一致 | — |
| LiveTalk | output/livetalk_newphase4/ | ✅ 4/4 完成 | 基本一致 | — |
| Hallo3 | output/hallo3_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 长音频非绝对不支持，但当前稳定路径/耗时策略未覆盖 |
| Ovi | output/ovi_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 当前部署 960x960_10s checkpoint 实际为短时受限 |
| MOVA | output/mova_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 当前稳定脚本固定 97 帧 |
| FantasyTalking | output/fantasy_talking_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 当前稳定脚本固定 81 帧 |
| LTX-2 | output/ltx2_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 当前稳定脚本固定 121 帧 |
| MultiTalk | output/multitalk_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | streaming 代码可扩长，但仅验证短时稳定链路 |
| InfiniteTalk | output/infinitetalk_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 已完成 C_half_short / C_full_short，长时条件按当前稳定路径跳过 |
| OmniAvatar | output/omniavatar_newphase4/ | ⚠️ 1/2 完成待复跑 | 基本一致 | `C_half_short` 已回收；输出回收脚本已改为递归查找 |
| Wan2.2-S2V | output/wan22_s2v_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 已完成 C_half_short / C_full_short，长时条件按当前稳定路径跳过 |
| LiveAvatar | output/liveavatar_newphase4/ | ⚠️ 2/4 历史支持子集保留 | 仅短时基线存在明显局限 | `80f + 1clip` 可出片但尾段明显退化；`48f + 多 clip` 在 80GB 单卡上无可交付路径，停止继续投入 |
| SoulX-FlashTalk | output/soulx_flashtalk_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | 已完成 C_half_short / C_full_short，长时条件按当前稳定路径跳过 |
| LongLive | output/longlive_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | text-only，长音频条件不适用 |
| Self-Forcing | output/self_forcing_newphase4/ | ✅ 2/4 支持子集完成 | 基本一致 | text-only，长音频条件不适用 |

---

## 进度总览

| Phase | 内容 | 状态 | 产出文件 |
|-------|------|------|----------|
| Phase 0 | 项目初始化、git 配置 | 完成 | claude.md, progress.md |
| Phase 1 | 模型调研 | [x] 完成 | model.md |
| Phase 2 | 环境配置与权重下载 | [~] 14/21模型环境+权重完成,可推理测试;当前优先 MultiTalk/InfiniteTalk/LongCat，4个模型暂缓 | model.md 第五节 |
| Phase 3 | 素材收集与 input.md | [x] 用户人工筛选完成，filtered 目录已同步 | input.md, input/ 目录 |
| Phase 4 | 推理生成 | [~] 已完成 17 个模型；OmniAvatar 与 LongCat-Video-Avatar 已完成支持子集；原始音频时长补跑在 LiveAvatar 阶段暂停；Wan2.2-S2V / LTX-2 / FantasyTalking 尚未开始；当前全部任务已按指示停止 | output/ 目录 |

---

## P3/P4 配置进度（2026-03-08 审计更新）

### P3 音视频联合生成（完成）

| 模型 | 状态 |
|------|------|
| LTX-2 | [x] 代码✅ + 环境✅(.venv, uv) + 权重✅(205G) + 测试脚本✅ |
| OVI | [x] 代码✅ + 环境✅(ovi-env) + 权重✅(83G) + 推理测试✅(1 test) |
| MOVA | [x] 代码✅ + 环境✅(mova-env, venv) + 权重✅(73G) + 测试脚本✅ |

### P4 通用视频生成（部分完成）

#### 当前优先级（2026-03-08 审计更新）

- **当前现状**：OmniAvatar 与 LongCat-Video-Avatar 均已完成 `C_half_short` / `C_full_short`。
- **最终判定**：LiveAvatar 单卡多 clip / 原始音频时长补跑已停止继续投入；官方近似 `48f + 多 clip` 路径稳定 OOM，`offload_kv_cache` 多 clip 路径稳定软卡住，`80f + 1clip` 虽可出片但尾段质量明显退化。
- **已停止**：按当前指示，夜间总控队列与相关推理进程已全部停止，等待下一步决策。
- **待续推进**：不再以 LiveAvatar 作为后续 full-audio 扩展前置条件；Wan2.2-S2V → LTX-2 → FantasyTalking 是否继续，改由后续单独决策。
- **继续暂缓**：HunyuanVideo-1.5、Wan2.2-T2V。SkyReels-V3 与 HunyuanVideo-Avatar 环境+权重已于 2026-03-22 清理；Wan2.2 I2V 权重已于 2026-03-22 删除。

| 模型 | 状态 |
|------|------|
| LiveAvatar | [x] 环境/权重/最小基线✅；Phase 4 支持子集完成 |
| Wan2.2 | [x] T2V 最小测试✅ + I2V 权重已删除(2026-03-22)；S2V Phase 4 支持子集完成 |
| SoulX-FlashTalk | [x] 环境/权重/最小测试✅；Phase 4 支持子集完成 |
| OmniAvatar | [x] 环境/权重/最小测试✅；Phase 4 支持子集完成 |
| Self-Forcing | [x] 环境/权重/最小测试✅；Phase 4 支持子集完成 |
| LongLive | [x] 环境/权重/最小测试✅；Phase 4 支持子集完成 |
| MultiTalk | [x] 环境/共享 Wan 权重/最小测试✅；Phase 4 支持子集完成 |
| InfiniteTalk | [x] 环境/共享 Wan 权重/最小测试✅；Phase 4 支持子集完成 |
| LongCat-Video-Avatar | [x] 权重补齐 + 最小测试✅；Phase 4 支持子集完成 |
| SkyReels-V3 | [x] 已清理（2026-03-22） |
| HunyuanVideo-Avatar | [x] 已清理（2026-03-22） |
| HunyuanVideo-1.5 | [ ] 暂缓 |

### 4.5 2026-03-09 夜间队列与原始音频时长补跑

| 项目 | 当前状态 | 说明 |
|------|----------|------|
| OmniAvatar | 运行中 | `test/omniavatar/run_phase4_resume_cfull.sh` 正在补 `C_full_short`。 |
| LongCat-Video-Avatar | 已入队 | `test/phase4_overnight_queue.sh` 会在 OmniAvatar 结束后启动 `test/longcat-video-avatar/run_phase4_filtered.sh`。 |
| LiveAvatar | 已入队 | 以 `test/liveavatar/test.md` 的稳定 80 帧基线为底，仅将短时条件按原始音频时长重算 `infer_frames`（136 / 216）。 |
| Wan2.2-S2V | 已入队 | 沿用 `test/wan2.2-s2v/test.md` 的稳定命令，短时条件改为按原始音频时长重算 `infer_frames`（88 / 140）。 |
| LTX-2 | 已入队 | 沿用 `test/ltx2/test.md` 的稳定命令，短时条件改为按原始音频时长重算 `num_frames`（129 / 206）。 |
| FantasyTalking | 已入队 | 沿用 `test/fantasy-talking/test.md` 的稳定命令，短时条件改为按原始音频时长重算 `max_num_frames`（124 / 197）。 |
| Wan2.2-T2V | 暂停 | 按最新用户指示，本轮夜间任务不再尝试。 |

- 夜间总控脚本：`test/phase4_overnight_queue.sh`
- 夜间日志：`test/phase4_overnight_queue.log`
- 当前 PID：以 `test/phase4_overnight_queue.pid` 为准
- 存储提醒：`/root/autodl-tmp` 当前约 98% 已用，仅约 39G 可用；队列会持续在日志中记录磁盘告警。


### 4.6 2026-03-09 停机前快照

| 项目 | 状态 | 说明 |
|------|------|------|
| OmniAvatar | 已完成支持子集 | `output/omniavatar_newphase4/C_half_short.mp4` 与 `output/omniavatar_newphase4/C_full_short.mp4` 均已落盘。 |
| LongCat-Video-Avatar | 已完成支持子集 | `output/longcat_video_avatar_newphase4/C_half_short.mp4` 与 `output/longcat_video_avatar_newphase4/C_full_short.mp4` 均已落盘。 |
| LiveAvatar full-audio | 停止继续投入 | 官方近似 `48f + 多 clip` 在当前 80GB 单卡上稳定 OOM / 软卡，`80f + 1clip` 又存在明显尾段退化，因此不再继续单卡多 clip / full-audio 补跑。 |
| Wan2.2-S2V / LTX-2 / FantasyTalking full-audio | 尚未开始 | 不再受 LiveAvatar 作为前置条件约束，是否继续改为后续单独决策。 |
| 夜间总控队列 | 已停止 | 原 `test/phase4_overnight_queue.sh` 已按用户要求停止。 |
| 存储 | 风险持续 | 截至 2026-03-09 10:37:29 CST，`/root/autodl-tmp` 仍约 98% 已用，剩余约 39G。 |

### 4.7 2026-03-09 长音频核查（以实际产物为准）

| 模型 | 当前结论 | 说明 |
|------|----------|------|
| LiveTalk | ✅ 真长音频完成 | `A001.wav 100.03s -> C_half_long 98.06s`，`MT_eng.wav 60.00s -> C_full_long 59.06s`。 |
| StableAvatar | ✅ 真长音频完成 | `C_half_long 99.88s`、`C_full_long 59.90s`，与输入音频基本对齐。 |
| EchoMimic v2 | ⚠️ 名义长条件完成但被脚本截断 | `test/echomimic_v2/run_phase4_filtered.sh` 将帧数上限固定为 `336`，两个 long 输出都只有约 `14.02s`。 |
| SoulX-FlashTalk | ⚠️ 长音频探针部分完成 | `C_full_long` 实际成片约 `60.06s`；`C_half_long` 在进入生成阶段后提前结束，当前日志无明确 Traceback。 |
| OmniAvatar | ⏭️ 未执行长音频 | 当前仅完成短时支持子集；单个 short case 已耗时约 `3679s / 5414s`。 |
| InfiniteTalk | ⏭️ 未执行长音频 | 当前仅完成短时 image-input fallback + streaming 稳定链路。 |
| LongCat-Video-Avatar | ⏭️ 未执行长音频 | 当前仅完成短时 ai2v 稳定链路。 |

- 长音频核查阶段未启动新的 Phase 4 推理；截至 `2026-03-09 19:28 CST`，GPU 已空闲，可进入下一轮顺序执行。
- `output/soulx_flashtalk_newphase4_longaudio/results.md` 中 `1.000s` 的时长字段来自旧脚本统计 bug，真实产物时长应以 `ffmpeg -i` / 实际文件为准。

### 4.8 2026-03-09 长音频正式顺序执行计划

| 顺序 | 模型 | 执行脚本 | 输出目录 | 说明 |
|------|------|----------|----------|------|
| 1 | OmniAvatar | `test/omniavatar/run_phase4_longaudio.sh` | `output/omniavatar_newphase4_longaudio/` | 沿用 `scripts/inference.py + configs/inference.yaml` 稳定链路，正式执行 `C_half_long` / `C_full_long`。 |
| 2 | InfiniteTalk | `test/infinitetalk/run_phase4_longaudio.sh` | `output/infinitetalk_newphase4_longaudio/` | 沿用 image-input fallback + streaming 稳定链路，正式执行 `C_half_long` / `C_full_long`。 |
| 3 | LongCat-Video-Avatar | `test/longcat-video-avatar/run_phase4_longaudio.sh` | `output/longcat_video_avatar_newphase4_longaudio/` | 沿用 base Python wrapper + `--context_parallel_size=1` 稳定链路，正式执行 `C_half_long` / `C_full_long`。 |
| 4 | SoulX-FlashTalk | `test/soulx-flashtalk/run_phase4_longaudio_official.sh` | `output/soulx_flashtalk_newphase4_longaudio_official/` | 使用正式 benchmark prompt 映射（`C_half_long` / `C_full_long` 均为 `speech`），不再沿用旧探针输出目录。 |

- 本轮按用户最新顺序执行：`OmniAvatar -> InfiniteTalk -> LongCat-Video-Avatar -> SoulX-FlashTalk`。
- 四个脚本都已补齐 `config.json`、`results.md`、显存峰值、音视频时长、失败记录与可重跑跳过逻辑；执行前已通过 `bash -n` 静态检查。
- `SoulX-FlashTalk` 旧探针目录 `output/soulx_flashtalk_newphase4_longaudio/` 仅保留历史排查信息；正式结果统一写入 `output/soulx_flashtalk_newphase4_longaudio_official/`。
