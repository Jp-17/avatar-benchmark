# LiveAvatar Phase 4 原始音频时长补跑

## 状态
- 当前状态：进行中
- 执行脚本：test/liveavatar/run_phase4_fullaudio.sh
- 配置文件：output/liveavatar_newphase4_fullaudio/config.json
- 输出目录：output/liveavatar_newphase4_fullaudio/
- 基线目录：output/liveavatar_newphase4/
- 说明：沿用 test/liveavatar/test.md 的稳定参数，仅将短时子集按原始音频时长重算 。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。
