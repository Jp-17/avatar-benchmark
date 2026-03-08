# OmniAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：部分完成，待复跑
- 执行脚本：test/omniavatar/run_phase4_filtered.sh
- 配置文件：output/omniavatar_newphase4/config.json
- 输出目录：output/omniavatar_newphase4/
- 说明：参考 test/omniavatar/test.md 的最小素材测试经验，沿用 image+audio+prompt 的稳定链路，只执行短时子集，并记录显存峰值与推理时长。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/omniavatar/test.md，当前稳定路径只验证到短时单条输入；长音频链路单 case 耗时已接近 1 小时，暂不扩展。


### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/prompts/C_half_short.txt
- 实际命令：conda activate /root/autodl-tmp/envs/omniavatar-env && torchrun --standalone --nproc_per_node=1 scripts/inference.py --config configs/inference.yaml --input_file /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_half_short.infer.txt
- config 参数：见 output/omniavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/C_half_short.mp4
- 显存峰值：79043 MB
- 推理生成时间：3679 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/logs/C_half_short.log
- 失败经验与解决方法：模型主体推理成功并在 `models/OmniAvatar/demo_out/.../result_000_000_wav.mp4` 生成输出，但脚本只在 `demo_out` 的第一层查找 mp4，未识别嵌套目录，导致后处理阶段误报 “output not found”。本轮已回收该输出，且脚本的输出回收逻辑已修正为递归查找嵌套结果。


### C_full_short
- 状态：❌ not_run
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4/prompts/C_full_short.txt
- 跳过原因：首轮运行在 `C_half_short` 输出回收阶段中断，未进入 `C_full_short`。现已修正 `test/omniavatar/run_phase4_filtered.sh` 为递归查找 `demo_out` 嵌套结果，后续可直接补跑剩余条件。
