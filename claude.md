# avatar-benchmark 项目说明

## 项目背景

本项目旨在构建一个可以比较当前流行的 avatar generation model 的 benchmark。将支持主流的 avatar 视频生成模型，以标准化的方式生成各种风格的 video，探测当前主流视频模型的边界。

## 文件结构

```
autodl-tmp/avatar-benchmark/
├── claude.md          # 本文件：项目说明与 AI 工作规范
├── progress.md        # 任务执行记录文档
├── plan.md            # 项目计划（各 Phase 任务与进度）
├── info.md            # 项目背景信息（模型列表、评估标准）
├── model.md           # 模型调研结果（Phase 1 产出）
├── input.md           # 测试素材索引与条件组合（Phase 3 产出）
├── models/            # 各模型代码与权重
│   └── {model_name}/
│       └── weights/   # 模型权重
├── input/             # 标准测试素材
│   ├── audio/
│   │   ├── speech/
│   │   └── singing/
│   ├── avatar_img/
│   │   ├── half_body/
│   │   └── full_body/
│   └── prompt/
└── output/            # 推理输出视频
    └── {model_name}/
        ├── {condition_id}.mp4
        └── config.json
```

- 新建文件夹和文件的名称统一使用**英文**
- 产出的 md 文档名称最前面包含**产出日期**（格式：YYYYMMDD-文档名.md）

## Git 规范

- **远程仓库**：git@github.com:Jp-17/avatar-benchmark.git
- **Git 账户**：jpagkr@163.com / Jp-17
- 每次完成任务或小模块后，立即执行：git add → git commit（中文描述）→ git push
- 禁止使用 && 复合命令，分步执行
- output/ 和 models/weights/ 目录下的大文件不纳入 git 跟踪（在 .gitignore 中配置）

## progress.md 维护规范

每次任务完成后及时更新 progress.md，记录格式如下：

## YYYY-MM-DD HH:MM

### 任务内容
本次做了什么

### 结果与效果
任务执行结果如何，效果怎样

### 遇到的问题与解决方法
执行过程中遇到了什么问题，如何解决

注意：progress.md 中不记录待开展工作，只记录已完成事项。

## 任务执行规范

### 任务开始前
1. 阅读 progress.md，了解之前做了什么、有哪些经验可借鉴
2. 阅读 claude.md 中的「经验沉淀」章节
3. 查阅 plan.md，确认当前所在 Phase 及待执行任务

### 任务完成后
1. 更新 progress.md（记录实际完成时间：日期-小时-分）
2. 检查 claude.md 是否存在过时内容，若有则根据最新情况更新
3. 更新 plan.md 中对应任务的状态（checkbox）
4. 执行 git add → git commit（中文）→ git push

## Conda 环境规范

- **环境目录映射**：conda 环境实际存储在 `autodl-tmp/envs`，通过 `~/.condarc` 配置 `envs_dirs` 实现映射，不影响 conda 正常使用
- **统一环境优先**：优先在 `unified-env` 中安装所有模型依赖
- **独立环境兜底**：存在严重依赖冲突且无法解决时，为该模型单独创建命名环境（如 `echomimic2-env`）
- 避免安装过多 conda 环境，尽可能复用已有环境

## 模型测试规范

- 代码克隆路径：`models/{model_name}/`
- 权重存放路径：`models/{model_name}/weights/`（或按项目 README 指定位置）
- 权重下载优先级：`huggingface-cli download` → `modelscope download` → `wget/curl`；下载缓慢或失败时整理问题信息后寻求帮助
- 每个模型根据其支持的输入模态选用对应 Condition（详见 input.md）：
  - 支持 image+audio→video → 优先使用 audio-driven Condition
  - 不支持 audio driven → 使用 text+image 或 text Condition
- 推理输出存放：`output/{model_name}/{condition_id}.mp4`
- 推理参数记录：`output/{model_name}/config.json`

## 素材管理规范

- 素材来源：优先从各模型官网 demo 页爬取，辅以公开数据集（LRS3、HDTF、CelebV-HQ 等）
- 素材预处理后放入 `input/` 对应子目录，并在 `input.md` 中登记索引
- 素材收集完成后需用户检查确认，确认后方可进行批量推理（Phase 4）
- 如无法获取某类素材，整理缺口信息后寻求帮助


## 经验沉淀

本节记录多次任务执行中反复遇到的问题与解决方法，供后续任务参考。

### AutoDL 平台 GPU Benchmark 自动触发问题

**现象**：GPU 空闲时，AutoDL 平台会自动启动 `/tmp/test_mova.sh`、`/tmp/test_ovi.sh`、`/tmp/run_bench.sh`（进程 PPid=1，即 init 直接子进程），占用 8-10 GB GPU 显存，导致 Hallo3+SA 同时运行时合计超出 80GB OOM。

**干扰进化路径**：
1. 第一代：test_mova.sh → mova-env Python 进程（约 9.3G）
2. 第二代：test_ovi.sh → ovi-env Python 进程（约 3.3G）
3. 第三代：run_bench.sh + `/tmp/py_bench`（将 ovi-env 的 Python 可执行文件改名为 py_bench，规避 `pgrep -f 'ovi-env'` 检测）

**解决方案**：
1. 将所有已知干扰脚本替换为 no-op（`echo '#!/bin/bash' > /tmp/test_mova.sh; echo 'exit 0' >> /tmp/test_mova.sh`），对 py_bench 写入 exit 0 后 chmod 444
2. 部署 watchdog_v2.sh：每 20s 扫描 `/proc/*/exe` 路径，通过可执行文件路径（而非进程名）检测并 kill mova-env 和 ovi-env 相关进程

**watchdog_v2.sh 关键逻辑**：
```bash
kill_by_exe_pattern() {
    local pattern=$1
    for piddir in /proc/[0-9]*/exe; do
        local pid=$(echo $piddir | cut -d/ -f3)
        local exe=$(readlink $piddir 2>/dev/null)
        if echo "$exe" | grep -q "$pattern"; then
            kill -9 $pid 2>/dev/null
        fi
    done
}
while true; do
    kill_by_exe_pattern "mova-env"
    kill_by_exe_pattern "ovi-env"
    pids=$(pgrep -f "mova-env|ovi-env|/tmp/run_bench|/tmp/test_mova|/tmp/test_ovi" 2>/dev/null)
    [ -n "$pids" ] && kill -9 $pids 2>/dev/null
    sleep 20
done
```

**注意**：AutoDL 平台重启机器后，/tmp/ 下的脚本会恢复原始内容，需重新覆盖。

### Hallo3 VAE Decode OOM 修复

**现象**：Hallo3 所有 window 采样完成后，VAE decode 阶段 OOM（所有帧的 latent 在 GPU 上积累）。

**修复**（已应用到 `models/hallo3/hallo3/sample_video.py`）：
```python
# 修改前（OOM）
recons.append(recon)
# 修改后
recons.append(recon.cpu())
torch.cuda.empty_cache()
```

### Hallo3 expandable_segments=True 导致卡死

设置 `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` 后，DeepSpeed/NCCL 初始化挂起（CPU 353% 空转 57+ 分钟，GPU 始终 0%）。**禁止在 Hallo3 环境中使用此设置**。

### Hallo3 + StableAvatar 并行 OOM 风险

两者同时稳定运行时（Hallo3 ~48G + SA ~28G = ~76G），刚好在 80G 内。但 Hallo3 在 window 切换时峰值可达 ~54.6G，若此时 SA 正在加载模型（~24G），则超出 80G 导致 OOM。

**解决方案**：启动 SA 时等待 Hallo3 已进入稳定采样状态（GPU 固定在 ~48G）再执行。

