# LiveAvatar Phase 4 结果记录（新 Condition）

## 状态
- 当前状态：已完成支持子集（历史基线，仅保留参考）
- 执行脚本：test/liveavatar/run_phase4_filtered.sh
- 配置文件：output/liveavatar_newphase4/config.json
- 输出目录：output/liveavatar_newphase4/
- 说明：参考 test/liveavatar/test.md 的最小素材测试经验，沿用已验证成功的 80 帧稳定链路；并保持串行执行，避免与其他大模型并行导致显存冲突。

## Condition 明细

### C_half_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。

### C_full_long
- 状态：⏭️ skipped
- 跳过原因：参考 test/liveavatar/test.md，目前稳定链路只验证到短时；长时 infer_frames 路径未完成验证。

### C_half_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav + speech prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=29171 minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt 'A person speaking directly to the camera with natural facial expressions and synchronized lip movements.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/half_body/13.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/EM2_no_smoking.wav --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_half_short.mp4 --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/
- config 参数：见 output/liveavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_half_short.mp4
- 显存峰值：52153 MB
- 推理生成时间：572 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/logs/C_half_short.log
- 失败经验与解决方法：沿用 test/liveavatar/test.md 中已验证的短时稳定路径；必须串行执行以避免与其他 14B/18B 模型并行时触发 OOM。

### C_full_short
- 状态：✅ done
- 素材：/root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png + /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav + singing prompt
- 实际命令：/root/miniconda3/bin/conda run --no-capture-output -p /root/autodl-tmp/envs/liveavatar-env env TOKENIZERS_PARALLELISM=false CUDA_VISIBLE_DEVICES=0 TORCH_COMPILE_DISABLE=1 TORCHDYNAMO_DISABLE=1 ENABLE_COMPILE=false NCCL_DEBUG=WARN PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True torchrun --nproc_per_node=1 --master_port=29171 minimal_inference/s2v_streaming_interact.py --ulysses_size 1 --task s2v-14B --size 704*384 --base_seed 42 --training_config liveavatar/configs/s2v_causal_sft.yaml --offload_model True --convert_model_dtype --prompt 'A person singing naturally with expressive facial animation and synchronized mouth motion.' --image /root/autodl-tmp/avatar-benchmark/input/avatar_img/filtered/full_body/1.png --audio /root/autodl-tmp/avatar-benchmark/input/audio/filtered/short/S002_adele.wav --save_file /root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_full_short.mp4 --infer_frames 80 --load_lora --lora_path_dmd ckpt/LiveAvatar/liveavatar.safetensors --sample_steps 4 --sample_guide_scale 0 --num_clip 1 --num_gpus_dit 1 --sample_solver euler --single_gpu --offload_kv_cache --ckpt_dir ckpt/Wan2.2-S2V-14B/
- config 参数：见 output/liveavatar_newphase4/config.json
- 输出路径：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/C_full_short.mp4
- 显存峰值：52133 MB
- 推理生成时间：639 秒
- 日志：/root/autodl-tmp/avatar-benchmark/output/liveavatar_newphase4/logs/C_full_short.log
- 失败经验与解决方法：沿用 test/liveavatar/test.md 中已验证的短时稳定路径；必须串行执行以避免与其他 14B/18B 模型并行时触发 OOM。

## 2026-03-09 排查补记

- 已复核旧 Phase 4 短时产物：`C_half_short.mp4` 仅约 `3.08` 秒，对应源音频约 `5.355` 秒；`C_full_short.mp4` 仅约 `3.12` 秒，对应源音频约 `8.558` 秒，均明显短于音频要求。
- 直接根因是脚本把 `--num_clip` 写死为 `1`，实际只生成单个 `80` 帧 clip；旧 `test/liveavatar/run_phase4_fullaudio.sh` 也同样写死 `num_clip=1`，只是把 `infer_frames` 拉长，因此更容易卡住而不是稳妥扩时长。
- 旧短时产物的尾帧像素分布明显塌陷，存在“开头正常、尾部发灰/发暗”的退化现象，因此当前目录下的旧短时结果不再视为最终可信版本。
- 已修正 `test/liveavatar/run_phase4_filtered.sh` 与 `test/liveavatar/run_phase4_fullaudio.sh`：统一保留单 clip `80` 帧稳定路径，改为按音频时长计算 `num_clip`。
- 已于 `2026-03-09 11:11 CST` 后台启动修正版重跑：`output/liveavatar_debug_archive/phase4_audiofix_bg/run_liveavatar_audiofix_bg.sh`；当前顺序为 `C_half_short(num_clip=2)` → `C_full_short(num_clip=3)`，运行日志位于 `output/liveavatar_debug_archive/phase4_audiofix_bg/runner.log` 与 `output/liveavatar_debug_archive/phase4_audiofix_bg/logs/`。

## 2026-03-09 13:45 CST 补充说明

- 先前记录中的后台补跑队列 `output/liveavatar_debug_archive/phase4_audiofix_bg/run_liveavatar_audiofix_bg.sh` 已停止，不再作为当前有效执行链路；后续重跑统一改为前台 `bash` 直接跟踪，并按 5 分钟周期巡检 GPU / 日志 / 输出文件增长。
- 结合 `models/LiveAvatar/infinite_inference_single_gpu.sh` 与 README，官方单卡推理基线为 `--offload_model True`、`--infer_frames 48`、超大 `--num_clip` 流式续推，并未启用 `--offload_kv_cache`。
- 本地排查中，`num_clip > 1` 时已先修复 KV cache 容量问题；但在 `--offload_kv_cache` 打开的情况下，多 clip 前台测试出现“CPU 高占用 + GPU 利用率掉到 0 + 输出文件不增长”的软卡住现象，因此下一轮前台重跑会优先移除 `--offload_kv_cache`，并回归更接近官方脚本的 `48` 帧单 clip 粒度。
- 短音频重跑目标仍是尽可能贴近音频时长：`num_clip = ceil(audio_seconds * sample_fps / infer_frames)`；长音频组合仅在短音频链路确认稳定后再尝试，否则在本文件中补充无法执行原因。

## 2026-03-09 15:25 CST 前台复测结论

- 以 `test/liveavatar/output/liveavatar_minimal_48f3clip_nokv_20260309.log` 为代表，按照更接近官方单卡脚本的 `infer_frames=48`、`num_clip=3`、`offload_model=True`、`offload_kv_cache=False` 路径进行最小复测时，会在 `complete prepare conditional inputs` 之后初始化 KV cache 阶段稳定 OOM。
- 加上 `fp8` 之后（`test/liveavatar/output/liveavatar_minimal_48f3clip_nokv_fp8_20260309.log`）仍然在同一位置 OOM，说明当前单卡 80GB 环境下，现有多 clip KV cache 分配策略仍然超出显存。
- 切换到 `offload_kv_cache=True + fp8` 后（`test/liveavatar/output/liveavatar_minimal_48f3clip_kvoffload_fp8_20260309.log`），显存占用降到约 `58.4 GB`，但两次 5 分钟巡检都表现为 `GPU util = 0`、日志停在 `complete prepare conditional inputs`、无输出文件增长，属于稳定复现的软卡住。
- 因此，LiveAvatar 当前在本机单卡环境下的 Phase 4 短音频“按音频时长补齐多 clip”链路仍未恢复到可交付状态；长音频组合更不具备继续尝试的条件，本轮不再盲目发起长音频重跑。

## 2026-03-09 最终结论（停止继续投入）

- 结合 `output/liveavatar_official_nearby/results.md` 的官方近似多 clip 复测：`48f + 多 clip + no offload_kv_cache + fp8` 在当前 80GB 单卡环境下会在 KV cache 初始化阶段稳定 OOM。
- 结合此前前台复测：`48f + 多 clip + offload_kv_cache + fp8` 会稳定卡在 `complete prepare conditional inputs`，GPU 利用率归零。
- 结合 `output/liveavatar_singleclip_compare/results.md` 的单 clip 对照实验：`48f + 1clip` 稳定，而 `80f + 1clip` 尾段存在明显亮度/饱和度塌陷（`YAVG 148.03 -> 95.40`，`SATAVG 10.86 -> 5.02`）。
- 因此，当前目录中的 `C_half_short` / `C_full_short` 仅保留为历史支持子集基线，不再作为推荐交付结果；在本机 80GB 单卡环境下，LiveAvatar 暂无可交付的多 clip / full-audio 推理路径。
- 决策：停止继续投入 LiveAvatar 单卡多 clip / 原始音频时长补跑。后续若再恢复该模型，只考虑代码级内存策略改造或更大显存/多卡环境。
- 目录说明：排查型原始日志已整理至 `output/liveavatar_debug_archive/`；支持性结论见 `output/liveavatar_official_nearby/results.md` 与 `output/liveavatar_singleclip_compare/results.md`。
