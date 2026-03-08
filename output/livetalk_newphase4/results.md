# LiveTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成
- 执行脚本：test/livetalk/run_phase4_filtered.sh
- 配置文件：output/livetalk_newphase4/config.json
- 输出目录：output/livetalk_newphase4/
- 说明：本轮严格按 plan.md 4.2 的要求记录每个 Condition 的实际命令、素材路径、config 参数、输出路径、显存峰值、推理生成时间，以及失败经验与解决方法。

## 标准 Conditions
- C_half_short：input/audio/filtered/short/EM2_no_smoking.wav + input/avatar_img/filtered/half_body/13.png
- C_half_long：input/audio/filtered/long/A001.wav + input/avatar_img/filtered/half_body/2.png
- C_full_short：input/audio/filtered/short/S002_adele.wav + input/avatar_img/filtered/full_body/1.png
- C_full_long：input/audio/filtered/long/MT_eng.wav + input/avatar_img/filtered/full_body/3.png

## Condition 明细

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png
- prompt 类型：speech
- video_duration：5
- 实际命令：
  /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/livetalk-env env PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/livetalk:/root/autodl-tmp/avatar-benchmark/models/livetalk/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config /root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_half_short.yaml
  - config 参数：见 output/livetalk_newphase4/config.json 与 output/livetalk_newphase4/logs/C_half_short.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/C_half_short.mp4
- 显存峰值：21381 MB
- 推理生成时间：89 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_half_short.log
- 失败经验与解决方法：无新增问题，沿用 test/livetalk/test.md 中已验证的 frame_seq_length=1024 与 3n+2 时长映射规则。

### C_half_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/A001.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/2.png
- prompt 类型：speech
- video_duration：98
- 实际命令：
  /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/livetalk-env env PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/livetalk:/root/autodl-tmp/avatar-benchmark/models/livetalk/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config /root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_half_long.yaml
  - config 参数：见 output/livetalk_newphase4/config.json 与 output/livetalk_newphase4/logs/C_half_long.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/C_half_long.mp4
- 显存峰值：81033 MB
- 推理生成时间：221 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_half_long.log
- 失败经验与解决方法：无新增问题，沿用 test/livetalk/test.md 中已验证的 frame_seq_length=1024 与 3n+2 时长映射规则。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
- prompt 类型：singing
- video_duration：8
- 实际命令：
  /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/livetalk-env env PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/livetalk:/root/autodl-tmp/avatar-benchmark/models/livetalk/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config /root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_full_short.yaml
  - config 参数：见 output/livetalk_newphase4/config.json 与 output/livetalk_newphase4/logs/C_full_short.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/C_full_short.mp4
- 显存峰值：21867 MB
- 推理生成时间：96 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_full_short.log
- 失败经验与解决方法：无新增问题，沿用 test/livetalk/test.md 中已验证的 frame_seq_length=1024 与 3n+2 时长映射规则。

### C_full_long
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/long/MT_eng.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/3.png
- prompt 类型：speech
- video_duration：59
- 实际命令：
  /root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/livetalk-env env PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/livetalk:/root/autodl-tmp/avatar-benchmark/models/livetalk/OmniAvatar CUDA_VISIBLE_DEVICES=0 python scripts/inference_example.py --config /root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_full_long.yaml
  - config 参数：见 output/livetalk_newphase4/config.json 与 output/livetalk_newphase4/logs/C_full_long.yaml
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/C_full_long.mp4
- 显存峰值：80421 MB
- 推理生成时间：168 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/livetalk_newphase4/logs/C_full_long.log
- 失败经验与解决方法：无新增问题，沿用 test/livetalk/test.md 中已验证的 frame_seq_length=1024 与 3n+2 时长映射规则。
