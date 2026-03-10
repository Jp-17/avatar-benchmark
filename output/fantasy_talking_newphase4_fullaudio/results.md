# FantasyTalking Phase 4 原始音频时长补跑

## 状态
- 当前状态：部分失败（原始音频时长补跑未全过）
- 执行脚本：test/fantasy-talking/run_phase4_fullaudio.sh
- 配置文件：output/fantasy_talking_newphase4_fullaudio/config.json
- 输出目录：output/fantasy_talking_newphase4_fullaudio/
- 基线目录：output/fantasy_talking_newphase4/
- 说明：沿用 test/fantasy-talking/test.md 的稳定命令，仅将短时子集按原始音频时长重算 `max_num_frames`。

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
- 推理帧数：124
- 推理生成时间：133 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/logs/C_half_short.log

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 源音频时长：8.557 秒
- 推理帧数：197
- 输出视频时长：8.600 秒
- 实际命令：conda activate /root/autodl-tmp/envs/fantasy-talking-env && python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --output_dir /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/C_full_short_tmp --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 197 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/C_full_short.mp4
- 显存峰值：58575 MB
- 推理生成时间：3933 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/logs/C_full_short.log

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 源音频时长：8.557 秒
- 推理帧数：197
- 输出视频时长：8.600 秒
- 实际命令：conda activate /root/autodl-tmp/envs/fantasy-talking-env && python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --output_dir /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/C_full_short_tmp --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 197 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/C_full_short.mp4
- 显存峰值：58575 MB
- 推理生成时间：3893 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4_fullaudio/logs/C_full_short.log
