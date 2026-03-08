# Hallo3 Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/hallo3/run_phase4_filtered.sh
- 配置文件：output/hallo3_newphase4/config.json
- 输出目录：output/hallo3_newphase4/
- 说明：参考 test/hallo3/test.md 的最小素材测试经验，本轮先执行稳定的短时子集，并按 plan.md 4.2 记录每个 Condition 的命令、素材、显存峰值、耗时与日志。

## 条件范围
- 已执行：C_half_short, C_full_short
- 跳过：C_half_long, C_full_long

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：当前稳定路径未覆盖 100s 长音频；历史记录显示 Hallo3 长时推理耗时极长。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：当前稳定路径未覆盖 60s 长音频；本轮先完成短时横评。

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
