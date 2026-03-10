# Wan2.2-S2V Phase 4 原始音频时长补跑

## 状态
- 当前状态：部分失败（原始音频时长补跑未全过）
- 执行脚本：test/wan2.2-s2v/run_phase4_fullaudio.sh
- 配置文件：output/wan22_s2v_newphase4_fullaudio/config.json
- 输出目录：output/wan22_s2v_newphase4_fullaudio/
- 基线目录：output/wan22_s2v_newphase4/
- 说明：沿用 test/wan2.2-s2v/test.md 的稳定命令，仅将短时子集按原始音频时长重算 `infer_frames`。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_half_short
- 状态：❌ failed
- 源音频时长：5.355 秒
- 推理帧数：88
- 推理生成时间：100 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4_fullaudio/logs/C_half_short.log

### C_full_short
- 状态：❌ failed
- 源音频时长：8.557 秒
- 推理帧数：140
- 推理生成时间：95 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4_fullaudio/logs/C_full_short.log

### C_half_short
- 状态：❌ failed
- 源音频时长：5.355 秒
- 推理帧数：88
- 推理生成时间：324 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4_fullaudio/logs/C_half_short.log

### C_full_short
- 状态：❌ failed
- 源音频时长：8.557 秒
- 推理帧数：140
- 推理生成时间：123 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4_fullaudio/logs/C_full_short.log
