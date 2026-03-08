# LTX-2 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/ltx2/run_phase4_filtered.sh
- 配置文件：output/ltx2_newphase4/config.json
- 输出目录：output/ltx2_newphase4/
- 说明：参考 test/ltx2/test.md 的最小素材测试经验，沿用去掉 fp8-cast、LoRA 强度 0.0 的固定短帧稳定路径，只执行短时子集。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：LTX-2 当前稳定路径是固定 121 帧短视频，不扩展到长时。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：python -m ltx_pipelines.a2vid_two_stage --checkpoint-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-dev-fp8.safetensors --gemma-root /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights --distilled-lora /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-distilled-lora-384.safetensors 0.0 --spatial-upsampler-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-spatial-upscaler-x2-1.0.safetensors --audio-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/logs/C_half_short_stereo.wav --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png 0 1.0 --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --output-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_half_short.mp4 --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42
- config 参数：见 output/ltx2_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_half_short.mp4
- 显存峰值：72809 MB
- 推理生成时间：85 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/ltx2/test.md 中已验证的去掉 fp8-cast 且 LoRA 强度 0.0 的短帧稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：python -m ltx_pipelines.a2vid_two_stage --checkpoint-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-dev-fp8.safetensors --gemma-root /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights --distilled-lora /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-19b-distilled-lora-384.safetensors 0.0 --spatial-upsampler-path /root/autodl-tmp/avatar-benchmark/models/LTX-2/weights/ltx-2-spatial-upscaler-x2-1.0.safetensors --audio-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/logs/C_full_short_stereo.wav --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png 0 1.0 --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --output-path /root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_full_short.mp4 --height 512 --width 512 --num-frames 121 --frame-rate 24 --seed 42
- config 参数：见 output/ltx2_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/C_full_short.mp4
- 显存峰值：72807 MB
- 推理生成时间：66 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx2_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/ltx2/test.md 中已验证的去掉 fp8-cast 且 LoRA 强度 0.0 的短帧稳定路径。
