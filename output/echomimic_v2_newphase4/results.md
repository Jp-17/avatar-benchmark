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

## 2026-03-09 排查补记

- README 当前同时提供标准推理 `infer.py` 与加速推理 `infer_acc.py`；其中加速版明确以更快速度换取吞吐。当前 Phase 4 脚本实际走的是 `infer_acc.py`，并加载 `denoising_unet_acc.pth` 与 `motion_module_acc.pth`，因此“人物效果略差”更像是速度优先配置带来的预期质量损失。
- 当前脚本把所有条件都固定绑定到 `assets/halfbody_demo/pose/01/`，而 README 另外提供了 `RefImg-Pose Alignment` demo。对 full-body 素材直接套用 half-body pose，会明显拉低人物一致性与动作适配效果。
- 配置里虽然保留了 `audio_mapper_path` 与 `auto_flow_path` 字段，但当前仓库并不存在对应文件；代码搜索也表明现有 `infer.py` / `infer_acc.py` 路径并未实际读取这些字段，因此它们属于陈旧配置项，不是本轮质量下降的主因。
- 如需下轮改成“画质优先”，应优先切回标准权重 `denoising_unet.pth` + `motion_module.pth` 与标准推理 `infer.py`，并按条件补做 reference-image / pose 对齐，而不是继续直接复用当前加速半身 pose 模板。c

## 2026-03-09 进一步排查

- 已确认短音频 `C_half_short` / `C_full_short` 与最小测试输出的时长均基本对齐音频；当前明显不对齐的是两个长音频条件。
- 直接原因是 `test/echomimic_v2/run_phase4_filtered.sh` 里将推理帧数限制为 `min(max(frames, 1), 336)`，按 `24fps` 折算后上限仅约 `14s`，因此无论输入 `60s` 还是 `100s` 音频都会被截到约 `14s` 视频。
- 人物效果略弱的一个重要原因，是当前 Phase 4 仍走 `infer_acc.py` + 加速权重（`denoising_unet_acc.pth`、`motion_module_acc.pth`），同时复用固定的 half-body pose 模板 `assets/halfbody_demo/pose/01/`；这对 full-body 条件并不理想。
- 虽然配置中还能看到 `audio_mapper-50000.pth` 与 `AutoFlow` 路径，但当前实际调用链路未明显依赖它们；现阶段更关键的问题仍是帧数上限和 pose / 加速权重带来的质量折中。
- 若本轮不重跑长音频，将明确以“现有脚本天然截断长时输出，且继续放大帧数会显著增加耗时与失败风险”为原因保留结论。
