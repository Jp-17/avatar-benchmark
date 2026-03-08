# Ovi Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/ovi/run_phase4_filtered.sh
- 配置文件：output/ovi_newphase4/config.json
- 输出目录：output/ovi_newphase4/
- 说明：参考 test/ovi/test.md 的最小素材测试经验，沿用 960x960_10s + qint8 + cpu_offload 的稳定路径，只执行 text+image 的短时子集，并记录每个 condition 的命令、显存峰值与耗时。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：Ovi 当前稳定路径为 960x960_10s 固定短视频配置，不支持按 filtered 长音频扩展。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + speech prompt
- 实际命令：python inference.py --config-file /root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/logs/C_half_short.yaml
- config 参数：见 output/ovi_newphase4/config.json 与 output/ovi_newphase4/logs/C_half_short.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/C_half_short.mp4
- 显存峰值：40009 MB
- 推理生成时间：1199 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/ovi/test.md 中已验证的 qint8 + cpu_offload 稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + singing prompt
- 实际命令：python inference.py --config-file /root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/logs/C_full_short.yaml
- config 参数：见 output/ovi_newphase4/config.json 与 output/ovi_newphase4/logs/C_full_short.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/C_full_short.mp4
- 显存峰值：78627 MB
- 推理生成时间：943 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ovi_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/ovi/test.md 中已验证的 qint8 + cpu_offload 稳定路径。
