# OmniAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
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
