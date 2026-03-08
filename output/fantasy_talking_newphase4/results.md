# FantasyTalking Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/fantasy-talking/run_phase4_filtered.sh
- 配置文件：output/fantasy_talking_newphase4/config.json
- 输出目录：output/fantasy_talking_newphase4/
- 说明：参考 test/fantasy-talking/test.md 的最小素材测试经验，沿用已验证的短时配置，只执行短时子集。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：FantasyTalking 当前稳定路径固定为 81 帧短视频，不扩展到长时。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：conda activate /root/autodl-tmp/envs/fantasy-talking-env && python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --output_dir /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_half_short_tmp --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42
- config 参数：见 output/fantasy_talking_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_half_short.mp4
- 显存峰值：63341 MB
- 推理生成时间：1032 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/fantasy-talking/test.md 中已验证的 81 帧短视频路径，长时条件暂不扩展。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：conda activate /root/autodl-tmp/envs/fantasy-talking-env && python infer.py --wan_model_dir ./models/Wan2.1-I2V-14B-720P --fantasytalking_model_path ./models/fantasytalking_model.ckpt --wav2vec_model_dir ./models/wav2vec2-base-960h --image_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --output_dir /root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_full_short_tmp --image_size 512 --audio_scale 1.0 --prompt_cfg_scale 5.0 --audio_cfg_scale 5.0 --max_num_frames 81 --fps 23 --num_persistent_param_in_dit 7000000000 --seed 42
- config 参数：见 output/fantasy_talking_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/C_full_short.mp4
- 显存峰值：20391 MB
- 推理生成时间：868 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/fantasy_talking_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/fantasy-talking/test.md 中已验证的 81 帧短视频路径，长时条件暂不扩展。
