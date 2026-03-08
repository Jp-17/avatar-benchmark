# SoulX-FlashTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/soulx-flashtalk/run_phase4_filtered.sh
- 配置文件：output/soulx_flashtalk_newphase4/config.json
- 输出目录：output/soulx_flashtalk_newphase4/
- 说明：参考 test/soulx-flashtalk/test.md 的最小素材测试经验，沿用当前稳定的短时链路，只执行短时子集。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/soulx-flashtalk/test.md 的最小稳定路径，本轮先完成短时子集。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/soulx-flashtalk/test.md 的最小稳定路径，本轮先完成短时子集。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/C_half_short.mp4 --cpu_offload
- config 参数：见 output/soulx_flashtalk_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/C_half_short.mp4
- 显存峰值：40039 MB
- 推理生成时间：256 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/soulx-flashtalk/test.md 中已验证的短时稳定路径，并保持 cpu_offload + 串行执行。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/C_full_short.mp4 --cpu_offload
- config 参数：见 output/soulx_flashtalk_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/C_full_short.mp4
- 显存峰值：40039 MB
- 推理生成时间：370 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/soulx-flashtalk/test.md 中已验证的短时稳定路径，并保持 cpu_offload + 串行执行。
