# daVinci-MagiHuman 推理测试报告

## 基本信息
- 环境：davinci-magihuman-env (conda, Python 3.12.13)
- 当前状态：`[x]` 环境、exact 官方权重、最小验证、自定义 full_body/3 推理均已完成
- 主模型：GAIR/daVinci-MagiHuman base（ModelScope 官方 `GAIR/daVinci-MagiHuman`）
- 文本编码器：google/t5gemma-9b-9b-ul2（ModelScope 官方 `google/t5gemma-9b-9b-ul2`）
- 音频 VAE：stabilityai/stable-audio-open-1.0（ModelScope 官方 `stabilityai/stable-audio-open-1.0`）
- 共享 VAE：复用 `models/Ovi/ckpts/Wan2.2-TI2V-5B/Wan2.2_VAE.pth`

## 脚本与目录
- 最小验证脚本：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/test_davinci_magihuman.sh`
- 自定义全身 prompt 脚本：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/run_custom_fullbody3_fusion_prompt.sh`
- 最小验证输出目录：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/output/`
- New Phase4 记录目录：`/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/`
- Base 权重目录：`/root/autodl-tmp/avatar-benchmark/models/davinci-magihuman/weights/base`
- T5 权重目录：`/root/autodl-tmp/avatar-benchmark/weights_shared/t5gemma-9b-9b-ul2`
- Audio VAE 目录：`/root/autodl-tmp/avatar-benchmark/weights_shared/stable-audio-open-1.0`

## 已完成
- `davinci-magihuman-env` 创建，repo `requirements.txt` / `requirements-nodeps.txt` 安装完成
- `MagiCompiler` 安装完成，导入名确认使用 `magi_compiler`
- `flash-attn==2.8.3` 编译完成，`flash_attn.flash_attn_interface` / `magi_compiler` / `inference.pipeline.entry` 导入预检通过
- `opencv-python-headless` 已补装，用于无 `ffprobe` 环境下探测视频属性
- `GAIR/daVinci-MagiHuman` base、`google/t5gemma-9b-9b-ul2`、`stabilityai/stable-audio-open-1.0` 均已按 ModelScope 官方仓库完整下载，并通过 safetensors index / shard 完整性校验

## 最小推理验证
- 输入图片：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/input/I013.png`
- 输入文本：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/input/P011.txt`
- 实际输出：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/output/davinci_magihuman_minimal_4s_384x384.mp4`
- 实际规格：`384x384 / 25fps / 101f`
- 运行时长：`303s`
- 显存峰值：`49489 MB`
- 日志：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/output/davinci_magihuman_minimal.log`
- 探针：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/output/davinci_magihuman_minimal.probe.txt`
- 结果：成功。日志中存在 `torch._dynamo` / `sympy` / NCCL 清理 warning，但不影响出片。

## 自定义 full_body/3 推理
- 参考输出：`/root/autodl-tmp/fusion_forcing/test_outputs/ltx23_distilled_compare_20260322_053332/distilled_compare_768x768_249f.mp4`
- 输入图片：`/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png`
- 实际输出：`/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/full_body_3_fusion_prompt_approx_768x768_251f_10s_384x384.mp4`
- 实际规格：`768x768 / 25fps / 249f`
- 运行时长：`264s`
- 显存峰值：`49487 MB`
- 记录脚本：`/root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/run_custom_fullbody3_fusion_prompt.sh`
- 记录配置：`/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/config_full_body_3_fusion_prompt_approx_768x768_251f.json`
- 运行配置：`/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/runtime_full_body_3_fusion_prompt_approx_768x768_251f.json`
- 日志：`/root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/logs/full_body_3_fusion_prompt_approx_768x768_251f.log`
- 说明：运行链路仍按 `--seconds 10` 进入内部 `251` 长度时序，但最终编码 mp4 的探针结果为 `249` 帧，与目标帧数一致。

## 遇到的问题与处理
1. `--config-load-path` 不能混入 benchmark 元数据字段；已拆分 `config_*.json`（记录用）和 `runtime_*.json`（实际推理入参）。
2. 裸 `python` 在远程环境中不可靠；脚本已统一显式调用 `$ENV/bin/python`。
3. 服务器缺少 `ffprobe`；通过安装 `opencv-python-headless` 并使用 `cv2` 写 probe 文件解决。
