## 2026-03-05 今日

### 任务内容
1. 配置本地到服务器的 SSH 免密登录
2. 检查远程项目目录 /root/autodl-tmp/avatar-benchmark 是否存在（已存在）
3. 读取远程 claude.md 和 progress.md，了解项目状态
4. 检查远程 git 仓库连接状态（已连接 git@github.com:Jp-17/avatar-benchmark.git）
5. 将本地 prompt-1-20260305.md 同步到远程服务器
6. 完成项目首次 git 初始化提交，推送到 GitHub（master 分支）

### 结果与效果
- SSH 免密登录配置成功
- 远程 git 仓库 GitHub SSH 认证正常
- 三个文件（claude.md、progress.md、prompt-1-20260305.md）已成功推送到 GitHub

### 遇到的问题与解决方法
- 无明显问题，流程顺畅

## 2026-03-05 23:30

### 任务内容
Phase 3 素材收集初步执行：
1. 创建 input/ 目录结构（audio/speech, audio/singing, avatar_img/half_body, avatar_img/full_body, prompt）
2. 从各模型 demo repo 下载音频：A001-A007（7 个语音文件，包含中英文）
3. 从各模型 demo repo 下载半身图片：I001-I006（EchoMimic/StableAvatar/FantasyTalking/Hallo3/OmniAvatar）
4. 从 FantasyTalking 和 StableAvatar 下载全身图片候选：I007/I008（需用户确认）
5. 创建 7 个 prompt 文本文件（P001-P007：演讲/下棋/弹琴/跳舞/微笑/愤怒/悲伤）
6. 写入完整 input.md（含 Condition 组合规划）
7. 配置 GitHub SSH（公钥已由用户添加），切换 remote URL 为 SSH

### 结果与效果
- 英文长时语音获取成功：A007.wav（LiveAvatar boy demo，353s=5.88min，英文）
- 中英文短时语音均有备份，可支持 5s-1min 档位测试
- 7 个 prompt 文件创建完成

### 遇到的问题与解决方法
- **中文长时语音缺口**：YouTube/archive.org 不可访问；HuggingFace 音频数据集均为 parquet 格式无法直接下载单文件；ModelScope AISHELL-3 无音频实体文件。最终 A001（100s 中文）仅支持到 1min 测试，3min/5min 中文档位待补充
- **唱歌音频缺口**：模型 demo 中无符合要求的唱歌音频（Wan2.2 sing.MP3 仅 18.8s）
- **图片分类待确认**：I007/I008 是否全身像、I004/I005 分辨率是否足够，需用户检视

## 2026-03-06 01:30

### 任务内容
Phase 3 素材补充收集：图片审查与大规模候选扩充
1. 逐一查看已有 I001-I008 全部图片，发现问题：I004（儿童野外图）、I007（demo 对比截图）为错误素材；I008 分类为 full_body 但实为半身
2. 从 SadTalker、AniPortrait、EchoMimic v2 refimag set、MimicMotion、UniAnimate 共 5 个源下载候选图片
3. 逐一视觉审查所有候选，筛选质量：LivePortrait 来源的均为名画/艺术品，排除；EchoMimic v2 ref 图质量极佳（1024×1024 AI生成标准半身）
4. 新增候选目录 `input/avatar_img/candidates/`，存放 30+ 张候选图供用户挑选
5. 更新 input.md：为已有图标注审查结果、补充完整候选清单（含推荐等级）、更新待确认事项

### 结果与效果
- 候选半身像：15 张（EchoMimic v2 × 多张、AniPortrait × 3、SadTalker × 多张）
- 候选全身像：3 张（MimicMotion demo1 × 1 亚裔女全身⭐⭐⭐⭐⭐、UniAnimate women × 2 西方女全身）
- 有效 male 候选：AP_lyl.png（中年亚裔男性头肩照，唯一男性候选）
- input.md 已全面更新，待用户挑选确认

### 遇到的问题与解决方法
- **HuggingFace 需认证**：Champ 数据集在 HuggingFace 需登录，无法直接下载全身像
- **LivePortrait 全为艺术品**：其 source 图全是名画（蒙娜丽莎/珍珠耳环少女等），不适合作为真实 avatar 测试素材
- **男性素材稀缺**：各模型 demo 图普遍为女性，男性头像仅从 AniPortrait 获取 1 张（AP_lyl）
- **音频缺口未解决**：中文长时语音（>=5min）仍无法自动下载，须用户提供

## 2026-03-06 03:00

### 任务内容
Phase 3 素材全面整理与扩充（二次迭代）：
1. 自主从 candidates/ 挑选图片，整理至正式目录：删除 I004/I005/I007（错误素材），I008 从 full_body 移入 half_body，新增 I009-I022
2. 扩充图片来源：Hallo（I021 Mr. Bean, 3511×3511）、Hallo2（I020 西方女性面部, 624×624）、SadTalker（I022 坐姿 AI 女性, 800×1200）
3. 扩充音频：从多个模型 demo 收集更多短音频，拼接创建 A008_zh_long.wav（从 228s 扩展至 252s=4.2min 中文），从 MuseTalk 获取 A009（MT_eng, 60s 英文）
4. 搜集唱歌音频：从 Amphion VevoSing 获取 S001-S003（中/英文唱歌示例，9-13s）
5. 新增 prompt P008-P015（坐姿演讲/读书/打电话/招手/点头/唱歌/快乐/惊讶）共 8 个
6. 全面重写 input.md：更新完整素材索引（A001-A009, S001-S003, I001-I022, P001-P015）及 Condition 组合

### 结果与效果
- 半身像：16 张（I001-I016, I020-I022），覆盖亚裔/西方/男性/AI生成/站姿/坐姿
- 全身像：3 张（I017-I019），均为女性站姿
- 音频：英文 A007（5.9min）可覆盖所有档位；中文 A008（4.2min）可覆盖至 3min 档位
- Prompt：15 个（P001-P015），涵盖动作/情景/表情三类
- input.md 全面更新，Condition 组合增加至 30+

### 遇到的问题与解决方法
- **Hallo2 参考图大多为艺术品/绘画**：6 张中仅 HALLO2_6（真实人物面部照）达标，其余为油画/素描/雕塑
- **EchoMimic v2 refimag 同质化**：所有图均为同一 AI 角色"双手摊开"姿势，增加了新背景变体但姿势单一
- **唱歌音频无法获取 3min 以上**：所有 VevoSing 示例均 <15s；OpenSinger/M4Singer 需 HF 认证；其他来源无法访问。只能获取短示例
- **中文音频仍差 5min 目标**：A008 拼接 13 段中文片段后仅 252s=4.2min，仍无法覆盖 5min 档位
- **全身坐姿/男性全身图**：在可访问的 GitHub demo 仓库中未找到，记录为缺口

## 2026-03-06 15:00

### 任务内容
Phase 3 素材清理与 input.md 重写（用户人工筛选后）：
1. 清理 input/audio/speech 中时长 <5s 的音频文件（6 个）：A004(4.2s)、CV_zero_shot(3.5s)、EM1_chunwang(4.9s)、EM2_fighting(4.8s)、EM2_good(4.3s)、EM2_news(4.2s)
2. 根据用户人工筛选后的实际素材状态，全面重写 input.md：
   - 半身像：从 16→13 张（用户移除 I003/I008-I012/I014/I015，新增 ST_full_body_2/ST_full3/ST_full4/LP_s2/LP_s9/HALLO2_1）
   - 全身像：从 3→5 张（I022 从半身移入全身，新增 LP_s0 油画坐姿）
   - 音频：从 29→23 条（删除 6 条 <5s，A008_zh_long 已由用户删除）
   - Condition 组合：中文条件从 A008→A001 作为驱动音频，移除中文 3m/5m 档位（无足够长中文音频）
3. 更新 plan.md Phase 3 状态为已完成
4. 更新 progress.md

### 结果与效果
- 音频清理完成：剩余 23 条语音 + 3 条唱歌，所有音频 >=5s
- input.md 完整重写，准确反映用户筛选后的实际素材：13 张半身像、5 张全身像、15 个 prompt
- 素材类型更丰富：包含真实照片、AI生成图、名画(蒙娜丽莎)、油画等多种风格
- Condition 组合调整为 31 个（i+a2v 12 + t+i2v 14 + t2v 5）

### 遇到的问题与解决方法
- **中文长时音频缺口加大**：A008 已被用户删除，最长中文音频变为 A001(100s=1.7min)，中文 3min/5min 档位完全无法覆盖，需用户补充
- **无其他问题**：用户筛选结果清晰，直接基于实际文件状态重写即可
