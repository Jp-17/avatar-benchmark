# LongLive Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/longlive/run_phase4_filtered.sh
- 配置文件：output/longlive_newphase4/config.json
- 输出目录：output/longlive_newphase4/
- 说明：参考 test/longlive/test.md 的最小素材测试经验，沿用 text-only 21 帧稳定路径；由于模型不支持 audio-driven，本轮用 prompt 语义映射 half/full short 条件。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：LongLive 为 text-only 模型，不支持 audio-driven；本轮 benchmark 中的长音频条件本身不适用，且当前稳定路径仅验证到 21 帧短视频。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：LongLive 为 text-only 模型，不支持 audio-driven；本轮 benchmark 中的长音频条件本身不适用，且当前稳定路径仅验证到 21 帧短视频。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/prompts/C_half_short.txt
- 实际命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path /root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/logs/C_half_short.yaml
- config 参数：见 output/longlive_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/C_half_short.mp4
- 显存峰值：24803 MB
- 推理生成时间：119 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/longlive/test.md 中已验证的 sf-longlive-env + shared Wan2.1-T2V-1.3B 稳定路径，未新增异常。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/prompts/C_full_short.txt
- 实际命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path /root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/logs/C_full_short.yaml
- config 参数：见 output/longlive_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/C_full_short.mp4
- 显存峰值：24803 MB
- 推理生成时间：109 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/longlive_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/longlive/test.md 中已验证的 sf-longlive-env + shared Wan2.1-T2V-1.3B 稳定路径，未新增异常。
