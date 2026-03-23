# LTX-2.3 Phase 4 结果记录

## 状态
- 当前状态：已完成
- 执行脚本：test/ltx2/run_phase4_ltx23.sh
- 配置文件：output/ltx23_newphase4/config.json
- 输出目录：output/ltx23_newphase4/
- 模型版本：LTX-2.3 (22B)
- 文本编码器：Gemma 3 12B QAT (Lightricks/gemma-3-12b-it-qat-q4_0-unquantized)
- LoRA 强度：0.8
- 帧数计算：num_frames = round(audio_sec * 24)

## Condition 明细

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 音频时长：5.36s
- 帧数：129
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/C_half_short.mp4
- 输出视频时长：5.38s
- 显存峰值：41879 MB
- 推理生成时间：82 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/logs/C_half_short.log


### C_half_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav + speech prompt
- 音频时长：100.03s
- 帧数：2401
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/C_half_long.mp4
- 输出视频时长：100.04s
- 显存峰值：60329 MB
- 推理生成时间：766 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/logs/C_half_long.log


### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 音频时长：8.56s
- 帧数：205
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/C_full_short.mp4
- 输出视频时长：8.54s
- 显存峰值：43267 MB
- 推理生成时间：81 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/logs/C_full_short.log


### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + speech prompt
- 音频时长：60.00s
- 帧数：1440
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/C_full_long.mp4
- 输出视频时长：60.00s
- 显存峰值：52845 MB
- 推理生成时间：409 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/ltx23_newphase4/logs/C_full_long.log

