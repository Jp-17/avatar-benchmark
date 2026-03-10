# InfiniteTalk Phase 4 长音频条件结果

## 状态
- 当前状态：长音频条件部分完成
- 执行脚本：test/infinitetalk/run_phase4_longaudio.sh
- 配置文件：output/infinitetalk_newphase4_longaudio/config.json
- 输出目录：output/infinitetalk_newphase4_longaudio/
- 说明：沿用 `test/infinitetalk/test.md` 与 `test/infinitetalk/run_phase4_filtered.sh` 的稳定 image-input fallback + streaming 路径，仅执行 `C_half_long` / `C_full_long` 两个长音频条件。

## Condition 明细

### C_half_long
- 状态：❌ failed
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/logs/C_half_long.json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/C_half_long
- 推理生成时间：4725 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/logs/C_half_long.log
- 失败经验与解决方法：长音频条件执行失败，需结合日志继续排查。

### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png
- prompt 类型：speech
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/logs/C_full_long.json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/C_full_long
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/C_full_long.mp4
- 音频时长：60.000 秒
- 视频时长：40.060 秒
- 显存峰值：46443 MB
- 推理生成时间：4803 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4_longaudio/logs/C_full_long.log
- 失败经验与解决方法：沿用 image-input fallback + streaming 稳定路径完成本轮长音频条件执行。
