# LongLive 最小推理测试

## 环境信息
- 环境名：sf-longlive-env（与 Self-Forcing 复用）
- 模型目录：/root/autodl-tmp/avatar-benchmark/models/LongLive
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/longlive
- 复用基座：/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-T2V-1.3B
- 目标权重：longlive_models/models/longlive_base.pt + longlive_models/models/lora.pt

## 最小测试素材
- Prompt：input/P011.txt

## 最小测试命令
- 脚本：test_longlive.sh
- 命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path /root/autodl-tmp/avatar-benchmark/test/longlive/longlive_inference_minimal.yaml

## 测试结果
- 结果：成功生成 output/rank0-0-0_lora.mp4
- 输出大小：598975 bytes（约 585K）
- 运行时间：133s
- 启动时空闲显存：57.84 GB
- 备注：单 prompt 最小测试通过，LoRA 加载成功，输出 21 帧视频

## 问题与解决方案
1. 首次测试失败于 `ModuleNotFoundError: No module named datasets`。
2. 原因：LongLive 代码路径会导入 `utils.dataset`，其依赖 `datasets` 包，而 sf-longlive-env 初始未安装该包。
3. 解决：在 sf-longlive-env 中补装 `datasets` 后重跑，最小推理通过。
