# LiveAvatar Phase 4 原始音频时长补跑

## 状态
- 当前状态：已停止继续投入（单卡 80GB 多 clip 路径关闭）
- 执行脚本：test/liveavatar/run_phase4_fullaudio.sh
- 配置文件：output/liveavatar_newphase4_fullaudio/config.json
- 输出目录：output/liveavatar_newphase4_fullaudio/
- 基线目录：output/liveavatar_newphase4/
- 说明：沿用 test/liveavatar/test.md 的稳定参数，仅将短时子集按原始音频时长重算 。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：本轮只补跑短时条件的原始音频时长版本；长音频条件仍不在夜间队列范围内。

## 2026-03-09 13:45 CST 补充说明

- 该目录记录的是早期“直接拉长单 clip 帧数”的 full-audio 尝试，应视为历史排查产物，不再作为当前推荐方案。
- 已确认旧方案的核心问题不是简单把 `infer_frames` 继续增大，而是旧脚本长期把 `num_clip` 固定为 `1`；这会导致视频时长无法按音频长度线性扩展，并放大尾段灰屏/退化风险。
- 结合官方单卡脚本，当前更合理的修复方向是：保留 `--offload_model True`，按音频长度计算 `num_clip`，优先使用 `infer_frames=48`，并避免额外打开 `--offload_kv_cache`。
- 后续若长音频条件不执行，将以“短音频多 clip 链路仍未充分稳定，且单条耗时显著增加”为由在最终结果中明确说明。

## 2026-03-09 15:25 CST 前台复测补记

- 已额外做三组前台最小复测来验证 full-audio 修复链路是否可行：
  - `48f + 3clip + no offload_kv_cache`：稳定 OOM；
  - `48f + 3clip + no offload_kv_cache + fp8`：仍稳定 OOM；
  - `48f + 3clip + offload_kv_cache + fp8`：不 OOM，但稳定卡在 `complete prepare conditional inputs`，10 分钟内 GPU 利用率保持 `0%`。
- 这说明当前阻塞点不是脚本是否切换为前台，而是 LiveAvatar 多 clip 单卡推理本身在本环境下同时面临“不开 `offload_kv_cache` 会 OOM、开启后会软卡”的双重约束。
- 在这个根因没有进一步修掉之前，本目录下不再继续追加新的 short/fullaudio 产物，以免生成不可用或不完整结果。

## 2026-03-09 最终结论（停止继续投入）

- 本目录对应的“按原始音频时长扩展”方案现已终止，不再继续追加新的 full-audio / 多 clip 产物。
- 根因已经明确：
  - `48f + 多 clip + no offload_kv_cache` 在当前 80GB 单卡环境下稳定 OOM；
  - `48f + 多 clip + offload_kv_cache` 稳定软卡在 `complete prepare conditional inputs`；
  - `80f + 1clip` 虽可出片，但 `output/liveavatar_singleclip_compare/results.md` 已证实其尾段存在明显亮度/饱和度塌陷，不适合作为可交付 workaround。
- 因此，LiveAvatar 在本机单卡环境下暂时不存在可交付的多 clip / full-audio 推理路径，停止继续投入。
- 后续若再恢复该模型，仅考虑两类前提：
  - 直接修改代码级 KV cache / condition cache 内存策略；
  - 切换到更大显存或多卡环境。
