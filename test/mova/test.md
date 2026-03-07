# MOVA 推理测试报告

## 基本信息
- 环境：mova-env (venv, Python 3.10)
- 权重大小：73G（MOVA-360p checkpoint, 3 shards）
- 显存需求：~77G（offload group 模式）
- 推理类型：img + text → video+audio（文本引导的音视频同步生成）
- 模型参数：11.6B (audio_to_video + video_to_audio conditioners)

## 测试素材
- 图像：input/avatar_img/half_body/I001.png
- 文本："A woman is speaking to the camera with natural facial expressions and synchronized lip movements."
- 参数：352x640, 97帧, 30步推理, seed=42

## 推理命令
```bash
source /root/autodl-tmp/envs/mova-env/bin/activate
cd /root/autodl-tmp/avatar-benchmark/models/MOVA
export PYTHONPATH=/root/autodl-tmp/avatar-benchmark/models/MOVA:$PYTHONPATH
torchrun --nproc_per_node=1 scripts/inference_single.py \
    --ckpt_path /root/autodl-tmp/avatar-benchmark/models/MOVA/weights/MOVA-360p \
    --prompt "A woman is speaking..." \
    --ref_path test/mova/input/I001.png \
    --output_path test/mova/output/test_output.mp4 \
    --height 352 --width 640 \
    --num_frames 97 --num_inference_steps 30 \
    --offload group --seed 42
```

## 结果
- 是否成功运行：**部分**（12/30步后被外部进程终止）
- 输出文件：未生成（推理未完成）
- 推理速度：~75-95s/step（因GPU竞争变化较大）
- 显存占用：~77G 峰值（offload group模式，动态卸载）

## 依赖安装记录
1. flash_attn 2.8.3：从 ghfast.top 代理下载预编译 wheel 安装
2. descript-audiotools：pip install
3. bitsandbytes：pip install（训练依赖，module-level import）
4. PYTHONPATH：需手动添加（pyproject.toml requires-python>=3.12 但环境为 3.10）

## 问题与解决
1. **环境类型混淆**：mova-env 是 venv 而非 conda，需用 source activate
2. **模块导入**：无法 pip install -e .（Python版本不满足），改用 PYTHONPATH
3. **GPU竞争**：hallo3+stableavatar+livetalk 批处理占用GPU导致OOM kill（5次）
4. **Cursor watchdog**：服务器上 Cursor IDE agent 创建 watchdog 脚本终止测试进程

## 待办
- 等GPU可用后重新运行完整30步推理
- 预计单次推理总时间：~35-45分钟（无竞争时）

*最后更新: 2026-03-07*
