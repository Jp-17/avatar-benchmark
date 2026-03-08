# MultiTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/multitalk/run_phase4_filtered.sh
- 配置文件：output/multitalk_newphase4/config.json
- 输出目录：output/multitalk_newphase4/
- 说明：参考 test/multitalk/test.md 的最小素材测试经验，沿用 `multitalk-480` + 8 步 streaming 稳定路径，只执行短时子集，并记录命令、显存峰值与耗时。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：MultiTalk 代码层支持 streaming 扩展更长帧数，但当前稳定脚本只验证了最小短时链路；filtered 长音频条件尚未完成同路径验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：MultiTalk 代码层支持 streaming 扩展更长帧数，但当前稳定脚本只验证了最小短时链路；filtered 长音频条件尚未完成同路径验证。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png
- prompt 类型：speech
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_multitalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --input_json /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/logs/C_half_short.json --size multitalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --num_persistent_param_in_dit 0 --save_file /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_half_short
- config 参数：见 output/multitalk_newphase4/config.json 与 output/multitalk_newphase4/logs/C_half_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_half_short.mp4
- 显存峰值：14893 MB
- 推理生成时间：1141 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/logs/C_half_short.log
- 失败经验与解决方法：无新增问题，沿用 test/multitalk/test.md 中已验证的 unified overlay + streaming 稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
- prompt 类型：singing
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_multitalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --input_json /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/logs/C_full_short.json --size multitalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --num_persistent_param_in_dit 0 --save_file /root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_full_short
- config 参数：见 output/multitalk_newphase4/config.json 与 output/multitalk_newphase4/logs/C_full_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/C_full_short.mp4
- 显存峰值：14893 MB
- 推理生成时间：1560 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/multitalk_newphase4/logs/C_full_short.log
- 失败经验与解决方法：无新增问题，沿用 test/multitalk/test.md 中已验证的 unified overlay + streaming 稳定路径。
