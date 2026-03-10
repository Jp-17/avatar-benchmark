# LongCat-Video-Avatar Phase 4 长音频条件结果

## 状态
- 当前状态：长音频条件完成
- 执行脚本：test/longcat-video-avatar/run_phase4_longaudio.sh
- 配置文件：output/longcat_video_avatar_newphase4_longaudio/config.json
- 输出目录：output/longcat_video_avatar_newphase4_longaudio/
- 说明：沿用稳定路径，num_segments=12 对应 60s 音频，仅执行 C_full_long 长音频条件。

## Condition 明细

### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + speech prompt
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4_longaudio/logs/C_full_long.json --num_inference_steps 8 --num_segments 12 --output_dir /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4_longaudio/tmp/C_full_long
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4_longaudio/C_full_long.mp4
- 音频时长：60.000 秒
- 视频时长：45.880 秒
- 显存峰值：66689 MB
- 推理生成时间：6764 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4_longaudio/logs/C_full_long.log
- 说明：num_segments=12，对应 60s 音频正常生成长视频。
