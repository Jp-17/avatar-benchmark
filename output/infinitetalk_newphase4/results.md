# InfiniteTalk Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/infinitetalk/run_phase4_filtered.sh
- 配置文件：output/infinitetalk_newphase4/config.json
- 输出目录：output/infinitetalk_newphase4/
- 说明：参考 test/infinitetalk/test.md 的最小素材测试经验，沿用 infinitetalk-480 + 8 步 streaming 稳定路径，只执行短时子集，并记录命令、显存峰值与耗时。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：InfiniteTalk 当前稳定路径为最小短时 image-input 链路，长音频 filtered 条件尚未验证。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png
- prompt 类型：speech
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/logs/C_half_short.json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/C_half_short
- config 参数：见 output/infinitetalk_newphase4/config.json 与 output/infinitetalk_newphase4/logs/C_half_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/C_half_short.mp4
- 显存峰值：46437 MB
- 推理生成时间：958 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/logs/C_half_short.log
- 失败经验与解决方法：无新增问题，沿用 test/infinitetalk/test.md 中已验证的 image-input fallback + streaming 稳定路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png
- prompt 类型：singing
- 实际命令：env CUDA_VISIBLE_DEVICES=0 LD_LIBRARY_PATH=/root/autodl-tmp/envs/unified-env/lib:/root/miniconda3/lib PYTHONPATH=/root/autodl-tmp/avatar-benchmark/test/shared_pydeps/unified_transformers_449:/root/autodl-tmp/envs/unified-env/lib/python3.10/site-packages /root/miniconda3/bin/python -S generate_infinitetalk.py --ckpt_dir weights/Wan2.1-I2V-14B-480P --wav2vec_dir weights/chinese-wav2vec2-base --infinitetalk_dir weights/InfiniteTalk/single/infinitetalk.safetensors --input_json /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/logs/C_full_short.json --size infinitetalk-480 --sample_steps 8 --mode streaming --motion_frame 9 --save_file /root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/C_full_short
- config 参数：见 output/infinitetalk_newphase4/config.json 与 output/infinitetalk_newphase4/logs/C_full_short.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/C_full_short.mp4
- 显存峰值：46437 MB
- 推理生成时间：1279 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/infinitetalk_newphase4/logs/C_full_short.log
- 失败经验与解决方法：无新增问题，沿用 test/infinitetalk/test.md 中已验证的 image-input fallback + streaming 稳定路径。
