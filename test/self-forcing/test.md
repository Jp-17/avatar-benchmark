# Self-Forcing 最小推理测试

## 环境信息
- 环境名：sf-longlive-env（与 LongLive 复用）
- 模型目录：/root/autodl-tmp/avatar-benchmark/models/Self-Forcing
- 测试目录：/root/autodl-tmp/avatar-benchmark/test/self-forcing
- 复用基座：/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-T2V-1.3B
- 推理 checkpoint：/root/autodl-tmp/avatar-benchmark/models/Self-Forcing/checkpoints/self_forcing_dmd.pt

## 最小测试素材
- Prompt：input/P011.txt

## 最小测试命令
- 脚本：test_self_forcing.sh
- 命令：conda run --no-capture-output -n sf-longlive-env env CUDA_VISIBLE_DEVICES=0 python inference.py --config_path configs/self_forcing_dmd.yaml --checkpoint_path /root/autodl-tmp/avatar-benchmark/models/Self-Forcing/checkpoints/self_forcing_dmd.pt --data_path /root/autodl-tmp/avatar-benchmark/test/self-forcing/input/P011.txt --output_folder /root/autodl-tmp/avatar-benchmark/test/self-forcing/output --num_output_frames 21 --num_samples 1 --use_ema --save_with_index

## 测试结果
- 结果：成功生成 output/0-0_ema.mp4
- 输出大小：611824 bytes（约 598K）
- 运行时间：119s
- 启动时空闲显存：58.93 GB
- 备注：log 中可见 1 条 prompt 完成推理，输出 21 帧视频

## 问题与解决方案
1. 首次推理已完成主生成流程，但在 torchvision.io.write_video 阶段报错：TypeError: an integer is required。
2. 原因：此前补依赖时安装了 av 16.1.0，与当前 torchvision 0.20.1 的写视频接口不兼容。
3. 解决：将 sf-longlive-env 中 av 降级到 12.3.0 后重跑，最小推理通过。
