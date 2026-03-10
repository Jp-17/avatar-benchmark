# Hallo3 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/hallo3/run_phase4_filtered.sh
- 配置文件：output/hallo3_newphase4/config.json
- 输出目录：output/hallo3_newphase4/
- 说明：参考 test/hallo3/test.md 的最小素材测试经验，本轮沿用已验证的短时稳定路径先完成支持子集；从历史记录看长时链路理论上可继续外推，但耗时极长，暂不纳入本轮横评。

## 条件范围
- 已执行：C_half_short, C_full_short
- 跳过：C_half_long, C_full_long

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：并非确认模型绝对不支持长音频，而是当前稳定路径未覆盖 100s 长音频；历史记录显示单 case 长时推理耗时极长，本轮按策略跳过。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：并非确认模型绝对不支持长音频，而是当前稳定路径未覆盖 60s 长音频；本轮先完成短时横评。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png
- prompt 类型：speech
- 实际命令：WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/hallo3-env python hallo3/sample_video.py --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml --seed 42 --input-file /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/logs/C_half_short.txt --output-dir /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_half_short_tmp
- config 参数：见 output/hallo3_newphase4/config.json 与 output/hallo3_newphase4/logs/C_half_short.txt
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_half_short.mp4
- 显存峰值：70487 MB
- 推理生成时间：1401 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/logs/C_half_short.log
- 失败经验与解决方法：无新增问题；继续沿用 test/hallo3/test.md 中已验证的单条件输入格式与禁用 expandable_segments 经验。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
- prompt 类型：singing
- 实际命令：WORLD_SIZE=1 RANK=0 LOCAL_RANK=0 LOCAL_WORLD_SIZE=1 /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/hallo3-env python hallo3/sample_video.py --base ./configs/cogvideox_5b_i2v_s2.yaml ./configs/inference.yaml --seed 42 --input-file /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/logs/C_full_short.txt --output-dir /root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_full_short_tmp
- config 参数：见 output/hallo3_newphase4/config.json 与 output/hallo3_newphase4/logs/C_full_short.txt
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/C_full_short.mp4
- 显存峰值：74405 MB
- 推理生成时间：2459 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/hallo3_newphase4/logs/C_full_short.log
- 失败经验与解决方法：无新增问题；继续沿用 test/hallo3/test.md 中已验证的单条件输入格式与禁用 expandable_segments 经验。

## 2026-03-09 排查补记

- README 明确要求：参考图应为 `1:1` 或 `3:2`，驱动音频必须为 `WAV`，且音频最好是英文、声线清晰；Hallo3 本身是 `talking-head` 路线，因此对唱歌与 full-body 条件天然会更敏感。
- 复查现有产物后确认并非真正“无声”：文件内有音轨且音量正常，但此前输出为 `MP3-in-MP4`，部分播放器兼容性较差，容易表现成“视频有画面但没声音”。
- 已将现有 `output/hallo3_newphase4/*.mp4` 与 `test/hallo3/output/hallo3_minimal.mp4` 统一转为 `AAC` 音轨，并修正 `test/hallo3/test_hallo3.sh` 与 `test/hallo3/run_phase4_filtered.sh`，后续生成结果默认输出兼容性更好的 `AAC` 音频。
- 权重侧未发现会直接阻断推理的核心缺失；`face_analysis` 相关 onnx 与 landmarker 已正常加载。`buffalo_l.zip` 虽未解压成目录，但当前日志显示检测、识别与 landmark 模型均已工作，不是本轮画质/音频问题主因。

## 2026-03-09 排查补记

- 两个短音频 Phase 4 结果的时长已经基本贴合音频时长；目前主要修复点是统一改为 AAC 音轨，避免播放器误判为“无声”。
- 长音频组合本轮暂未前台重跑，原因不是功能缺失，而是 Hallo3 长时链路历史耗时极长；在 GPU 需串行排队的前提下，优先级低于 LiveAvatar 的明显时长异常修复。
- 若本轮最终仍不执行长音频条件，将以“GPU 排队 + 单条长音频耗时过长，不利于本轮横评闭环”为最终原因保留在本文件。

## 2026-03-09 15:25 CST 最小重测补记

- 为了补一个新的 `test/` 最小素材文件，已前台启动 `test/hallo3/test_hallo3.sh` 的不覆盖版本；但执行过程中被新的外部 SoulX-FlashTalk 任务抢占显存，最终在音频分离阶段 OOM。
- 当前 `output/hallo3_newphase4/` 下已有短音频 Phase 4 结果的音轨与时长结论不受这次失败影响；待 GPU 真正空闲后，再补新的 `test/hallo3/output/` 文件即可。
