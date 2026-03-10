# LTX-2 Phase 4 原始音频时长补跑

## 状态
- 当前状态：已完成按原始音频时长补跑
- 执行脚本：test/ltx2/run_phase4_fullaudio.sh
- 配置文件：output/ltx2_newphase4_fullaudio/config.json
- 输出目录：output/ltx2_newphase4_fullaudio/
- 基线目录：output/ltx2_newphase4/
- 说明：沿用 test/ltx2/test.md 的稳定命令，仅将短时子集按原始音频时长重算 `num_frames`。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 源音频时长：5.355 秒
- 推理帧数：129
- 输出视频时长：5.380 秒
- 实际命令：python -m ltx_pipelines.a2vid_two_stage --checkpoint-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-dev-fp8.safetensors --gemma-root /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights --distilled-lora /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-distilled-lora-384.safetensors 0.0 --spatial-upsampler-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-spatial-upscaler-x2-1.0.safetensors --audio-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/logs/C_half_short_stereo.wav --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png 0 1.0 --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --output-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/C_half_short.mp4 --height 512 --width 512 --num-frames 129 --frame-rate 24 --seed 42
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/C_half_short.mp4
- 显存峰值：reuse MB
- 推理生成时间：0 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/logs/C_half_short.log

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 源音频时长：8.557 秒
- 推理帧数：205
- 输出视频时长：8.540 秒
- 实际命令：python -m ltx_pipelines.a2vid_two_stage --checkpoint-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-dev-fp8.safetensors --gemma-root /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights --distilled-lora /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-distilled-lora-384.safetensors 0.0 --spatial-upsampler-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-spatial-upscaler-x2-1.0.safetensors --audio-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/logs/C_full_short_stereo.wav --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png 0 1.0 --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --output-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/C_full_short.mp4 --height 512 --width 512 --num-frames 205 --frame-rate 24 --seed 42
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/C_full_short.mp4
- 显存峰值：73881 MB
- 推理生成时间：96 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4_fullaudio/logs/C_full_short.log
