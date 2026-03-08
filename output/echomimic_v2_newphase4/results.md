# EchoMimic v2 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成
- 执行脚本：test/echomimic_v2/run_phase4_filtered.sh
- 配置文件：output/echomimic_v2_newphase4/config.json
- 输出目录：output/echomimic_v2_newphase4/
- 说明：本轮严格按 plan.md 中 Phase 4 的 4 组 filtered 条件执行。

## Conditions
- C_half_short：input/audio/filtered/short/EM2_no_smoking.wav + input/avatar_img/filtered/half_body/13.png
- C_half_long：input/audio/filtered/long/A001.wav + input/avatar_img/filtered/half_body/2.png
- C_full_short：input/audio/filtered/short/S002_adele.wav + input/avatar_img/filtered/full_body/1.png
- C_full_long：input/audio/filtered/long/MT_eng.wav + input/avatar_img/filtered/full_body/3.png

## 结果记录
- C_half_short：output/echomimic_v2_newphase4/C_half_short.mp4
- C_half_long：output/echomimic_v2_newphase4/C_half_long.mp4
- C_full_short：output/echomimic_v2_newphase4/C_full_short.mp4
- C_full_long：output/echomimic_v2_newphase4/C_full_long.mp4

## 备注
- EchoMimic v2 仍沿用固定 pose 序列 `assets/halfbody_demo/pose/01/`。
- 长音频条件受模型/pose 长度限制，脚本将帧数上限裁到 336 帧。
- 旧版多语言基线产物 `C_en_* / C_zh_* / C_sing_*` 保留在 `output/echomimic_v2/`，不再与本轮 Phase 4 结果混放。
