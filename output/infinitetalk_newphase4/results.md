# InfiniteTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：进行中
- 执行脚本：test/infinitetalk/run_phase4_filtered.sh
- 配置文件：output/infinitetalk_newphase4/config.json
- 输出目录：output/infinitetalk_newphase4/
- 说明：参考 test/infinitetalk/test.md 的最小素材测试经验，沿用 infinitetalk-480 + 8 步 streaming 稳定路径，只执行短时子集，并记录命令、显存峰值与耗时。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。
