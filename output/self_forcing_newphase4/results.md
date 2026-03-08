# Self-Forcing Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/self-forcing/run_phase4_filtered.sh
- 配置文件：output/self_forcing_newphase4/config.json
- 输出目录：output/self_forcing_newphase4/
- 说明：参考 test/self-forcing/test.md 的最小素材测试经验，沿用 text-only 21 帧稳定路径；由于模型不支持 audio-driven，本轮用 prompt 语义映射 half/full short 条件。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/self-forcing/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/self-forcing/test.md，当前稳定路径只验证到 21 帧短视频；长时推理尚未纳入本轮横评。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/prompts/C_half_short.txt
- 实际命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path configs/self_forcing_dmd.yaml --checkpoint_path /root/autodl-tmp/avatar-benchmark/models/Self-Forcing/checkpoints/self_forcing_dmd.pt --data_path /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/prompts/C_half_short.txt --output_folder /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_half_short_tmp --num_output_frames 21 --num_samples 1 --use_ema --save_with_index
- config 参数：见 output/self_forcing_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_half_short.mp4
- 显存峰值：26177 MB
- 推理生成时间：100 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/self-forcing/test.md 中已验证的 sf-longlive-env 稳定路径，并保留  以避免写视频报错。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/prompts/C_full_short.txt
- 实际命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path configs/self_forcing_dmd.yaml --checkpoint_path /root/autodl-tmp/avatar-benchmark/models/Self-Forcing/checkpoints/self_forcing_dmd.pt --data_path /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/prompts/C_full_short.txt --output_folder /root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_full_short_tmp --num_output_frames 21 --num_samples 1 --use_ema --save_with_index
- config 参数：见 output/self_forcing_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/C_full_short.mp4
- 显存峰值：26177 MB
- 推理生成时间：100 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/self_forcing_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/self-forcing/test.md 中已验证的 sf-longlive-env 稳定路径，并保留  以避免写视频报错。
