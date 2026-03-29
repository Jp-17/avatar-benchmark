# Wan2.2 T2V/I2V 最小推理测试

## 环境信息
- 环境名：wan2.2-env（由 Wan2.2-S2V 继续复用）
- 模型目录：/root/autodl-tmp/avatar-benchmark/models/Wan2.2
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/wan2.2-t2v-i2v

## 最小测试素材
- 图片：input/I013.png
- Prompt：input/P011.txt

## 当前状态
- T2V 测试脚本：已清理（2026-03-29 删除 `test_wan22_t2v.sh` 与 `Wan2.2-T2V-A14B` 118G 权重）
- I2V 测试脚本：`test_wan22_i2v.sh`
- 当前状态：仅保留 T2V 历史最小验证记录；T2V 权重与专用脚本已清理，I2V 权重已于 2026-03-22 删除

## T2V 历史最小测试结果
- 结果：成功生成 output/wan2.2_t2v_minimal.mp4
- 输出大小：676600 bytes（约 661K）
- 运行时间：402s
- 配置：480x832, 17帧, 8步, offload_model=True, convert_model_dtype=True, t5_cpu=True
- 当前说明：保留历史产物 `output/wan2.2_t2v_minimal.mp4` 与日志作为记录，但当前仓库已不再保留可直接复跑 T2V 的权重与专用脚本。

## I2V 当前状态
- I2V 权重已于 2026-03-22 清理
- 如后续需要恢复 I2V 测试，需先重新下载权重，再执行 `test_wan22_i2v.sh`

## 问题与解决方案
1. Wan2.2 T2V 初始下载结束后，high_noise_model 缺少 `diffusion_pytorch_model-00006-of-00006.safetensors`。
2. 原因：首轮整仓下载中断，导致高噪声分支最后一个 shard 未完成移动。
3. 解决：单独用 huggingface-cli 定向补下缺失 shard 后，T2V 最小推理通过。
