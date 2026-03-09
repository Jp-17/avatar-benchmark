# LongCat-Video-Avatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/longcat-video-avatar/run_phase4_filtered.sh
- 配置文件：output/longcat_video_avatar_newphase4/config.json
- 输出目录：output/longcat_video_avatar_newphase4/
- 说明：参考 test/longcat-video-avatar/test.md 的最小素材测试经验，沿用 base Python wrapper + context_parallel_size=1 + num_inference_steps=8 的稳定路径，只执行短时子集。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：LongCat 当前稳定路径仅验证了最小短时单条输入；长音频条件暂不扩展。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/logs/C_half_short.json --num_inference_steps 8 --output_dir /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/tmp/C_half_short
- config 参数：见 output/longcat_video_avatar_newphase4/config.json 与 output/longcat_video_avatar_newphase4/logs/C_half_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/C_half_short.mp4
- 显存峰值：57549 MB
- 推理生成时间：458 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/longcat-video-avatar/test.md 中已验证的 base Python wrapper +  +  稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/longcat-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/envs/longcat-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S -m torch.distributed.run --nproc_per_node=1 run_demo_avatar_single_audio_to_video.py --context_parallel_size=1 --checkpoint_dir ./weights/LongCat-Video-Avatar --stage_1 ai2v --input_json /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/logs/C_full_short.json --num_inference_steps 8 --output_dir /root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/tmp/C_full_short
- config 参数：见 output/longcat_video_avatar_newphase4/config.json 与 output/longcat_video_avatar_newphase4/logs/C_full_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/C_full_short.mp4
- 显存峰值：57623 MB
- 推理生成时间：436 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/longcat_video_avatar_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/longcat-video-avatar/test.md 中已验证的 base Python wrapper +  +  稳定路径。
