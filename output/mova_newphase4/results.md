# MOVA Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集
- 执行脚本：test/mova/run_phase4_filtered.sh
- 配置文件：output/mova_newphase4/config.json
- 输出目录：output/mova_newphase4/
- 说明：参考 test/mova/test.md 的最小素材测试经验，沿用固定 97 帧的当前稳定路径，仅执行 text+image 的短时子集；理论上参数可继续外推，但本轮未做同路径长时验证。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：当前稳定脚本固定为 97 帧短视频；理论上可进一步调参尝试更长序列，但尚未完成与最小测试同路径的长时验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：当前稳定脚本固定为 97 帧短视频；理论上可进一步调参尝试更长序列，但尚未完成与最小测试同路径的长时验证。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + speech prompt
- 实际命令：torchrun --nproc_per_node=1 scripts/inference_single.py --ckpt_path /root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p --cp_size 1 --height 512 --width 512 --num_frames 97 --num_inference_steps 30 --prompt 'A person speaking directly to the camera with natural facial expressions, synchronized lip movements, and gentle upper-body motion.' --ref_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --output_path /root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_half_short.mp4 --offload cpu --remove_video_dit --seed 42
- config 参数：见 output/mova_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_half_short.mp4
- 显存峰值：41109 MB
- 推理生成时间：465 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/mova_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/mova/test.md 中已验证的固定 97 帧短视频路径。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + singing prompt
- 实际命令：torchrun --nproc_per_node=1 scripts/inference_single.py --ckpt_path /root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p --cp_size 1 --height 512 --width 512 --num_frames 97 --num_inference_steps 30 --prompt 'A person singing to the camera with expressive facial animation, natural body rhythm, and strong performance energy.' --ref_path /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --output_path /root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_full_short.mp4 --offload cpu --remove_video_dit --seed 42
- config 参数：见 output/mova_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/mova_newphase4/C_full_short.mp4
- 显存峰值：41211 MB
- 推理生成时间：461 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/mova_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/mova/test.md 中已验证的固定 97 帧短视频路径。
