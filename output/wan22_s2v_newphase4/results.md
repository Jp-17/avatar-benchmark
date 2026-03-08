# Wan2.2-S2V Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/wan2.2-s2v/run_phase4_filtered.sh
- 配置文件：output/wan22_s2v_newphase4/config.json
- 输出目录：output/wan22_s2v_newphase4/
- 说明：参考 test/wan2.2-s2v/test.md 的最小素材测试经验，沿用已验证的 832x480 稳定路径，只执行短时子集，并记录每个 condition 的命令、显存峰值与耗时。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/wan2.2-s2v/test.md 的最小稳定路径，本轮先完成短时 filtered 横评。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png
- prompt 类型：speech
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/wan2.2-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-S2V-14B --offload_model True --convert_model_dtype --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav --save_file /root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/C_half_short.mp4 --num_clip 1
- config 参数：见 output/wan22_s2v_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/C_half_short.mp4
- 显存峰值：43523 MB
- 推理生成时间：778 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/wan2.2-s2v/test.md 中已验证的 832x480 稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
- prompt 类型：singing
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/wan2.2-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 python generate.py --task s2v-14B --size 832*480 --ckpt_dir /root/autodl-tmp/avatar-benchmark/models/Wan2.2/weights/Wan2.2-S2V-14B --offload_model True --convert_model_dtype --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --save_file /root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/C_full_short.mp4 --num_clip 1
- config 参数：见 output/wan22_s2v_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/C_full_short.mp4
- 显存峰值：43523 MB
- 推理生成时间：776 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/wan22_s2v_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/wan2.2-s2v/test.md 中已验证的 832x480 稳定路径。
