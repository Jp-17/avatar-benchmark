# SoulX-FlashTalk Phase 4 长音频条件结果（正式版）

## 状态
- 当前状态：长音频条件完成
- 执行脚本：test/soulx-flashtalk/run_phase4_longaudio_official.sh
- 配置文件：output/soulx_flashtalk_newphase4_longaudio_official/config.json
- 输出目录：output/soulx_flashtalk_newphase4_longaudio_official/
- 说明：沿用 `test/soulx-flashtalk/test.md` 与 `test/soulx-flashtalk/run_phase4_filtered.sh` 的 `generate_video.py + audio_encode_mode=stream + cpu_offload` 稳定链路，正式执行 `C_half_long` / `C_full_long` 两个长音频条件。

## Condition 明细

### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + speech prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/flashtalk-env env CUDA_VISIBLE_DEVICES=0 XFORMERS_IGNORE_FLASH_VERSION_CHECK=1 python generate_video.py --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/weights/SoulX-FlashTalk-14B --wav2vec_dir /root/autodl-tmp/avatar-benchmark/models/SoulX-FlashTalk/models/chinese-wav2vec2-base --input_prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --cond_image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png --audio_path /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav --audio_encode_mode stream --save_file /root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio_official/C_full_long.mp4 --cpu_offload
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio_official/C_full_long.mp4
- 音频时长：60.000 秒
- 视频时长：60.060 秒
- 显存峰值：40039 MB
- 推理生成时间：2283 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/soulx_flashtalk_newphase4_longaudio_official/logs/C_full_long.log
- 失败经验与解决方法：沿用 cpu_offload 长链路执行正式长音频条件。
