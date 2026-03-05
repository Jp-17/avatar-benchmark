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
