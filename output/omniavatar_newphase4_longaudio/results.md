# OmniAvatar Phase 4 长音频条件结果

## 状态
- 当前状态：长音频条件部分完成
- 执行脚本：test/omniavatar/run_phase4_longaudio.sh
- 配置文件：output/omniavatar_newphase4_longaudio/config.json
- 输出目录：output/omniavatar_newphase4_longaudio/
- 说明：沿用 `test/omniavatar/test.md` 与 `test/omniavatar/run_phase4_filtered.sh` 的稳定链路，仅执行 `C_half_long` / `C_full_long` 两个长音频条件。

## Condition 明细

### C_half_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav + /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/prompts/C_half_long.txt
- 实际命令：conda activate /root/autodl-tmp/envs/omniavatar-env && torchrun --standalone --nproc_per_node=1 --master_port=30241 scripts/inference.py --config configs/inference.yaml --input_file /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/logs/C_half_long.infer.txt
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/C_half_long.mp4
- 音频时长：100.030 秒
- 视频时长：100.400 秒
- 显存峰值：21747 MB
- 推理生成时间：61597 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/logs/C_half_long.log
- 失败经验与解决方法：沿用  稳定路径，并继续使用 PATH 中的 ffmpeg。

### C_full_long
- 状态：❌ failed
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav
- 实际命令：conda activate /root/autodl-tmp/envs/omniavatar-env && torchrun --standalone --nproc_per_node=1 --master_port=30242 scripts/inference.py --config configs/inference.yaml --input_file /root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/logs/C_full_long.infer.txt
- 推理生成时间：202 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/omniavatar_newphase4_longaudio/logs/C_full_long.log
- 跳过原因：用户手动取消，C_full_long（MT_eng.wav，60s）单次推理预计耗时约 10h，代价过高，按用户指示跳过，当前仅保留 C_half_long（A001.wav，100s）结果。
