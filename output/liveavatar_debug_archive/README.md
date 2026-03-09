# LiveAvatar Debug Archive

本目录用于集中存放 LiveAvatar 在单卡 80GB 环境下的历史排查产物，避免继续散落在 `output/` 根目录。

## 子目录说明
- `phase4_audiofix_bg/`：后台版多 clip 音频时长修复尝试，已停止。
- `phase4_audiofix_test/`：单 case 预排查日志，已停止。

## 当前结论
- 这些目录仅保留为排查留痕，不再作为当前有效执行链路。
- LiveAvatar 单卡多 clip / full-audio 路径已停止继续投入；支持性结论见：
  - `output/liveavatar_newphase4/results.md`
  - `output/liveavatar_newphase4_fullaudio/results.md`
  - `output/liveavatar_official_nearby/results.md`
  - `output/liveavatar_singleclip_compare/results.md`
