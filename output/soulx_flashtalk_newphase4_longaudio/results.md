# SoulX-FlashTalk Phase 4 长音频探针结果

## 状态
- 当前状态：进行中
- 执行脚本：test/soulx-flashtalk/run_phase4_longaudio.sh
- 配置文件：output/soulx_flashtalk_newphase4_longaudio/config.json
- 输出目录：output/soulx_flashtalk_newphase4_longaudio/
- 参考短时目录：output/soulx_flashtalk_newphase4/
- 说明：沿用 generate_video.py + audio_encode_mode=stream + cpu_offload 的稳定链路，直接验证 Phase 4 长音频条件是否能扩展到接近音频原始时长。

## Condition 明细

### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + singing prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/C_full_long.mp4 --cpu_offload
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/C_full_long.mp4
- 音频时长：1.000 秒
- 视频时长：1.000 秒
- 时长差（视频-音频）：0.000 秒
- 显存峰值：81143 MB
- 推理生成时间：2256 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/logs/C_full_long.log
- 失败经验与解决方法：长音频探针成功完成，可继续据此评估是否纳入正式长音频批跑。

### C_half_long
- 状态：❌ failed
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav + speech prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/C_half_long.mp4 --cpu_offload
- 推理耗时：957 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio/logs/C_half_long.log
- 失败经验与解决方法：长音频探针执行失败，需结合日志继续排查。
