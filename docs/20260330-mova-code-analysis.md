# MOVA 代码实现分析

## 说明范围

本文基于仓库中已公开的 **MOVA 推理 / 训练代码、权重配置，以及远程环境中的 `diffusers` `AutoencoderKLWan` 源码** 分析 `MOVA` 的真实实现形态，重点回答以下问题：

- `video VAE` / `audio VAE` 是否是 causal
- 训练和推理分别分成哪些阶段
- `video_dit_2` 到底是什么
- `dual_tower_bridge` 做了什么，算不算核心创新
- 代码里的“MoE / 32B total, 18B active”到底如何落到实现上
- 它是否属于 self-forcing / 流式推理模型，若不是，改造成那种形态难点在哪里

**直接可确认的内容**：

- `models/MOVA/scripts/inference_single.py`
- `models/MOVA/mova/diffusion/pipelines/pipeline_mova.py`
- `models/MOVA/mova/diffusion/pipelines/mova_train.py`
- `models/MOVA/mova/diffusion/models/wan_video_dit.py`
- `models/MOVA/mova/diffusion/models/wan_audio_dit.py`
- `models/MOVA/mova/diffusion/models/interactionv2.py`
- `models/MOVA/mova/diffusion/models/dac_vae.py`
- `models/MOVA/mova/datasets/video_audio_dataset.py`
- `models/MOVA/weights/MOVA-360p/*/config.json`
- 远程 `mova-env` 中的 `diffusers/models/autoencoders/autoencoder_kl_wan.py`

**基于代码的推断**：

- README / model card 中 “MoE, 32B total / 18B active” 在公开视频代码里没有显式 `router` 或 `expert` 模块名；本文会给出“为什么我判断它更像按噪声区间 hard switch 的 expert split”的证据链，但这部分仍属于**基于代码结构与参数量的推断**。
- 是否可以改成 self-forcing / 流式推理，也只能从现有实现反推改造难度，不能等同于官方训练设计。

## 关键结论

1. `MOVA` 当前公开实现是 **整段 latent 一次性去噪的双模态 diffusion 模型**，不是 self-forcing，也不是 autoregressive / streaming 生成模型。
2. 视频侧不是单个 DiT，而是 **两个结构相同、权重不同的 video tower**：`video_dit` 和 `video_dit_2`。推理时通过 `boundary_ratio=0.9` 在高噪声 / 低噪声区间之间 **硬切换**；其中 `video_dit_2` 是低噪声 expert。
3. 从权重参数量看，`video_dit + video_dit_2 + audio_dit + dual_tower_bridge` 合计约 **32.657B** 参数；而单步去噪时只会激活 `video_dit` 或 `video_dit_2` 其中一个，因此活跃参数约为 **18.368B**。这个数值与 model card 的 “32B total / 18B active” 高度吻合。
4. 公开视频代码里 **没有显式 sparse MoE router / token-level expert**。因此代码层面可见的“expert 化”主要就是：**双视频 tower 按噪声区间切换**，而不是标准的 token-level sparse MoE。
5. `video VAE` 使用 `AutoencoderKLWan`，内部时间卷积是 `WanCausalConv3d`，而且带缓存推理逻辑，因此 **video VAE 是 causal 的**。
6. `audio VAE` 虽然类名是 `DAC`，但这份 checkpoint 的配置是 `continuous=true`，所以实际跑的是 **连续高斯 latent VAE**，不是离散 RVQ token codec；同时它的卷积实现是**对称 padding + delay 补偿**，因此 **audio VAE 不是 causal**。
7. `dual_tower_bridge` 是当前公开代码里最有“方法创新感”的部分：它不是简单把 audio / video token 拼在一起，而是保持 **video tower + audio tower 分塔**，再通过 **双向 conditional cross-attention + cross-modal RoPE 对齐** 在 30 个重叠层上交互。
8. 公开视频训练代码主要发布的是 **LoRA fine-tuning 路线**。虽然 `mova_train.py` 自身有完整 `training_step()`，但仓库没有公开完整预训练数据构造、标签生成、长视频分片对齐等全流程脚本。

## 当前代码入口

### 推理入口

- `models/MOVA/scripts/inference_single.py`
- `models/MOVA/mova/diffusion/pipelines/pipeline_mova.py`

### 训练入口

- `models/MOVA/scripts/training_scripts/accelerate_train.py`
- `models/MOVA/scripts/training_scripts/low_resource_train.py`
- `models/MOVA/mova/diffusion/pipelines/mova_train.py`
- `models/MOVA/mova/datasets/video_audio_dataset.py`

### 核心模型实现

- `models/MOVA/mova/diffusion/models/wan_video_dit.py`
- `models/MOVA/mova/diffusion/models/wan_audio_dit.py`
- `models/MOVA/mova/diffusion/models/interactionv2.py`
- `models/MOVA/mova/diffusion/models/dac_vae.py`
- `mova-env` 中的 `diffusers/models/autoencoders/autoencoder_kl_wan.py`

## 1. 整体推理流程

`inference_single.py` 的输入很简单：

- 文本 prompt
- 参考首帧图像 `ref_path`
- 输出时长 / 分辨率 / 步数 / CFG / seed

但底层真正执行的是一个 **video latent + audio latent 并行去噪** 的流程。

### 1.1 文本、首帧、噪声 latent 的准备

在 `pipeline_mova.py::__call__()` 中：

1. 用 `UMT5EncoderModel` 把 prompt 编成 text embedding
2. 把参考图 resize 到目标分辨率
3. 构造视频噪声 latent：
   - shape 约为 `[B, 16, (F-1)/4+1, H/8, W/8]`
4. 构造音频噪声 latent：
   - shape 约为 `[B, 128, T_audio_latent]`
5. 把首帧图像通过 `video_vae.encode()` 编码成 video latent 条件
6. 再拼接一个 first-frame mask，形成 `condition`

这里有个非常关键的实现细节：

- 视频噪声 latent 是 `16` 通道
- 首帧条件是 `mask(4) + first-frame latent(16) = 20` 通道
- 两者在推理时直接 `torch.cat([latents, condition], dim=1)`
- 所以 `video_dit` 的 `in_dim=36` 正好对上权重配置

这说明 `MOVA` 的视频侧不是“先生成全视频，再单独给首帧约束”，而是一开始就把 **首帧约束作为额外 latent 通道** 喂给视频 tower。

### 1.2 调度器：video / audio 共用 flow-matching 风格步进

调度器是 `FlowMatchPairScheduler`：

- 它支持返回 `(video_timestep, audio_timestep)` 成对时间步
- 也支持把 video / audio schedule 改成不同曲线
- 但当前公开推理路径里，`dual_sigma_shift` 相关代码是注释掉的

因此默认公开脚本里：

- video 与 audio **基本走同一套时间步表**
- 每一步都同时预测 video noise residual 和 audio noise residual
- 再分别更新各自 latent

这依然是“联合生成”，但不是两边用完全不同 schedule 的强耦合调度版本。

### 1.3 双 tower + bridge 的单步前向

每个 diffusion step 里，`inference_single_step()` 会做这些事：

1. 为当前 timestep 生成 `visual_t_mod` 与 `audio_t_mod`
2. 把 text embedding 投到 video tower / audio tower 各自 hidden size
3. 把 video latent patchify 成 video token 序列
4. 把 audio latent patchify 成 audio token 序列
5. 分别构造 video / audio 的 RoPE 频率
6. 调用 `forward_dual_tower_dit()`
7. 得到 video / audio 输出后，再分别 unpatchify 回 latent 形状

所以 `MOVA` 的核心不是“一个统一 transformer 同时处理三种 token”，而是：

- video token 有自己的一座大 tower
- audio token 有自己的一座 tower
- 两者在中间若干层通过 bridge 交互

### 1.4 推理阶段的真正“分阶段”含义

`MOVA` 推理可以分成 4 段：

1. 条件编码阶段
   - 文本编码
   - 首帧图像编码
2. 联合 diffusion 阶段
   - video latent 与 audio latent 并行去噪
3. 视频解码阶段
   - `video_vae.decode(video_latents)`
4. 音频解码阶段
   - `audio_vae.decode(audio_latents)`

但 diffusion 阶段内部又再分两段：

- 高噪声阶段：使用 `video_dit`
- 低噪声阶段：切到 `video_dit_2`

也就是说，**真正的 stage split 发生在视频 tower 上**。

## 2. `video_dit_2` 到底是什么

这是 `MOVA` 最关键、也最容易被 README 一笔带过的点。

### 2.1 它不是 LoRA，也不是小补丁模块

从 `weights/MOVA-360p/video_dit/config.json` 和 `video_dit_2/config.json` 可以直接看到：

- 两者结构参数完全相同
- 都是 `WanModel`
- 都是 `dim=5120`
- 都是 `num_layers=40`
- 都是 `num_heads=40`
- 都是 `ffn_dim=13824`
- 都是 `patch_size=(1,2,2)`

所以 `video_dit_2` 不是“小头”或者轻量 refinement head，而是**第二套完整视频 DiT 权重**。

### 2.2 它在推理里的职责

`pipeline_mova.py::__call__()` 中的逻辑是：

- 初始 `cur_visual_dit = self.video_dit`
- `boundary_timestep = boundary_ratio * num_train_timesteps`
- 当 `timestep < boundary_timestep` 时切换到 `self.video_dit_2`

默认 `boundary_ratio=0.9`，即边界是 `900 / 1000`。

由于时间步表是从高噪声往低噪声走：

- `t >= 900` 的前几步，使用 `video_dit`
- `t < 900` 的后续大部分步骤，使用 `video_dit_2`

因此 `video_dit_2` 很明显就是：

- **低噪声阶段的 video expert**
- 负责后期结构细化、纹理稳定、表情与嘴形的精修

### 2.3 `remove_video_dit` 的真实含义

README 里的 `--remove_video_dit` 容易让人误解。

它不是“删除旧模型并换成别的模式”，而是：

- 当推理切换到 `video_dit_2` 后
- 如果开启了 `remove_video_dit`
- 就把 `self.video_dit = None`
- 以便 offload 模式下释放第一阶段 tower 的 Host RAM 占用

这进一步证明：

- `video_dit` 与 `video_dit_2` 是 **互斥使用** 的两个完整 expert
- 不是同一步一起跑的 ensemble

## 3. 训练流程：公开代码里到底训练了什么

### 3.1 数据读取流程

`VideoAudioDataset` 的输入格式非常直接：

- 一个 `metadata.json`
- 每条样本至少包含 `video_path`
- 可选 `caption`

每个样本在 `__getitem__()` 中做的是：

1. 用 `VideoDecoder` 读取视频前 `num_frames` 帧
2. center crop 到目标长宽比，再 resize 到训练分辨率
3. 像素归一化到 `[-1,1]`
4. 用 `AudioDecoder` 从同一个视频容器直接抽音频
5. 把音频裁到 `num_frames / fps` 对应时长，不足则 pad
6. 把视频首帧额外单独返回

这说明当前公开训练代码默认假设：

- **video 与 audio 原本就已经在同一个 mp4/container 里严格对齐**
- 数据准备阶段没有公开额外的音效切分、说话人标注、多语言嘴形对齐脚本

### 3.2 训练 step 内部阶段

`mova_train.py::training_step()` 的顺序是：

1. 文本编码
   - `caption -> T5 embeddings`
2. 视频编码
   - `video -> video_vae.encode() -> video_latents`
3. 首帧条件编码
   - `first_frame -> video_vae.encode()`
   - 再拼 `mask`
4. 音频编码
   - `audio -> audio_vae.encode() -> audio_latents`
5. 采样时间步
6. 往 video / audio latent 中各自加噪
7. 选一个当前 visual expert：`video_dit` 或 `video_dit_2`
8. 前向预测 `video_pred` / `audio_pred`
9. 计算 flow matching 目标：`target = noise - sample`
10. 分别做 video MSE 与 audio MSE，再相加

因此从代码上看，公开视频训练目标是：

- **联合预测 video latent velocity + audio latent velocity**
- 训练信号直接落在两个 latent 空间上
- 没有单独的 lipsync discriminator、声学对比损失等额外 objective 暴露在公开代码中

### 3.3 `video_dit` / `video_dit_2` 在训练里怎么分工

这是另一个很重要的点。

训练里不是每个 batch 同时更新两个 video tower，而是：

- 先通过 `boundary_ratio` 算出一个高噪声 / 低噪声边界
- `global_step` 偶数时：采样边界前那一段 timestep，并训练 `video_dit`
- `global_step` 奇数时：采样边界后那一段 timestep，并训练 `video_dit_2`

因此它更像：

- **显式按噪声区间分工的双 expert 训练**
- 而不是标准单塔 DiT 覆盖全噪声范围

### 3.4 公开训练脚本的真实定位

虽然 `mova_train.py` 自身支持完整 `training_step()`，但 README 与 configs 真正公开出来的训练 recipe 主要是：

- `Accelerate LoRA (1 GPU)`
- `Accelerate + FSDP LoRA (8 GPU)`
- `Low-resource LoRA (single GPU)`

并且低资源路径明确使用：

- LoRA 注入
- gradient checkpointing
- FP8 CPU offload
- 8-bit AdamW

因此更准确的说法是：

- **公开视频代码已经有“可训练 pipeline”**
- 但**官方明确提供的可复现 recipe 主要是 LoRA fine-tuning，不是 full pretraining**

## 4. 模型架构复杂度

### 4.1 各组件参数量

我直接统计了 `weights/MOVA-360p` 的权重参数量，结果如下：

| 组件 | 参数量 | 作用 |
|---|---:|---|
| `video_dit` | 14.289B | 高噪声视频 expert |
| `video_dit_2` | 14.289B | 低噪声视频 expert |
| `audio_dit` | 1.419B | 音频 latent 去噪 tower |
| `dual_tower_bridge` | 2.660B | 双向 cross-modal bridge |
| `text_encoder` | 5.681B | `UMT5` 文本编码器 |
| `video_vae` | 0.127B | Wan video VAE |
| `audio_vae` | 0.372B | 连续 latent DAC VAE |

若只看 diffusion 核心：

- 总参数量：`14.289 + 14.289 + 1.419 + 2.660 = 32.657B`
- 单步活跃参数：`14.289 + 1.419 + 2.660 = 18.368B`

这和 model card 里的：

- `32B total`
- `18B active during inference`

几乎完全对上。

### 4.2 为什么说它很复杂

从配置上看：

#### 视频 tower

- hidden size: `5120`
- layers: `40`
- heads: `40`
- FFN dim: `13824`
- patch size: `(1,2,2)`
- 输入通道: `36`

#### 音频 tower

- hidden size: `1536`
- layers: `30`
- heads: `12`
- FFN dim: `8960`
- patch size: `1`
- 输入通道: `128`

#### Bridge

- video hidden dim: `5120`
- audio hidden dim: `1536`
- interaction strategy: `full`
- 在前 `30` 个对齐层上双向交互

这意味着它不是“video model + 小 audio adapter”，而是：

- 一座超大 40 层 video tower
- 一座 30 层 audio tower
- 再加一套非常重的双向桥接器

所以它的复杂度主要来自：

1. **双塔并行**，不是单塔统一 token
2. **双视频 expert**，不是单个 video DiT
3. **30 层 bridge 交互**，不是只在头尾交互 1-2 次
4. **文本、视频、音频三条条件链同时参与**

## 5. `dual_tower_bridge` 到底做了什么

这是 MOVA 代码里最值得单独分析的一块。

### 5.1 它不是简单 concat，而是“分塔后双向 cross-attn”

`DualTowerConditionalBridge` 的做法是：

- video token 留在 video tower 内部走自己的 block
- audio token 留在 audio tower 内部走自己的 block
- 在指定层上：
  - `audio -> video` 做一次 conditional cross-attention
  - `video -> audio` 再做一次 conditional cross-attention

因此交互方式是 **bidirectional conditional control**，不是把 token 粗暴拼成单流序列。

### 5.2 为什么叫 asymmetric dual-tower

从代码看，“asymmetric” 主要体现在：

1. video tower 更大
   - 40 layers / 5120 dim
2. audio tower 更小
   - 30 layers / 1536 dim
3. 两边只有前 30 个重叠层能双向交互
4. video 还有额外 10 层尾部 refinement，不再和 audio 对齐层数

也就是说，audio 不是完全对等的大模型分支，更像一个规模明显更小、但仍被允许反向影响视频的条件 tower。

### 5.3 `interaction_strategy="full"` 的真实含义

bridge 配置里 `interaction_strategy` 是 `full`，意味着：

- `layer 0 ~ 29` 的每一层都允许交互
- 不是只在浅层或少数层交互

这与 README 里“bidirectional cross-attention mechanism”是一致的，而且从实现上看强度不低。

### 5.4 cross-modal RoPE 对齐是它最像“创新点”的地方

`build_aligned_freqs()` 会：

- 把 video latent 的时间位置按 `video_fps / 4` 对齐
  - 因为 video VAE temporal stride 是 `4`
- 把 audio latent 的时间位置按 `audio_fps=50.0` 对齐
  - 这来自 `48000 / hop_length(960) = 50`
- 再为两边分别构造可对齐的 rotary cos/sin

这样在 cross-attention 时：

- video token 与 audio token 的相对时间位置不是各自瞎编码
- 而是被显式映射到一个共享的时间坐标系里

对嘴形同步、语音节奏与动作同步来说，这个设计非常关键。

### 5.5 `pooled_adaln` 是可选设计，但当前 checkpoint 没开

`ConditionalCrossAttentionBlock` 里还有一个可选分支：

- 先把视频 token 做 per-frame attention pooling
- 再把 pooled 结果喂给 AdaLayerNorm

但当前 bridge 配置是：

- `pooled_adaln=false`

所以公开权重实际使用的是：

- **纯 cross-attention conditioned residual**
- 没有启用这条更复杂的 pooled AdaLN 控制路径

## 6. VAE 是否 causal

### 6.1 Video VAE：是 causal 的

这部分可以直接从远程 `diffusers` 的 `autoencoder_kl_wan.py` 确认。

关键证据有三条：

1. 使用了 `WanCausalConv3d`
2. `WanCausalConv3d` 会把时间维 padding 改成 **只在过去侧补**
3. encode / decode 里都维护了 `feat_cache` / `first_chunk`，支持按时间块缓存

因此 `video_vae` 的时间建模明确是 **causal conv + cache-based chunk processing**。

这也解释了为什么：

- 它虽然是离线扩散模型的一部分
- 但 VAE 本身具备“按时间块处理视频 latent”的基础设施

### 6.2 Audio VAE：不是 causal 的

`dac_vae.py` 里的 `Encoder` / `Decoder` / `ResidualUnit` 用的是：

- `Conv1d`
- `ConvTranspose1d`
- 对称 padding
- 以及 `get_delay()` / `zero_pad(self.delay, self.delay)` 这种前后补偿

例如：

- `ResidualUnit` 的 `pad = ((7 - 1) * dilation) // 2`
- `Encoder` / `Decoder` 的卷积也都是居中式 padding
- `compress()` 在 chunked 模式下会在**左右两边**补 delay

这说明它并不是“只看过去”的 causal 音频 codec，而是一个**离线、近似居中感受野**的 1D 卷积编解码器。

### 6.3 当前这份 audio VAE 还是 continuous latent，不是离散 codebook 版

这点很容易被类名 `DAC` 误导。

在 `weights/MOVA-360p/audio_vae/config.json` 中：

- `continuous = true`

对应到 `dac_vae.py::__init__()`：

- 若 `continuous=false`，才会构建 `ResidualVectorQuantize`
- 若 `continuous=true`，则改为 `quant_conv / post_quant_conv`，输出 `DiagonalGaussianDistribution`

而训练 / 推理代码实际调用的是：

- `z = self.audio_vae.encode(...)`
- `audio_latents = z.mode()`

因此当前 MOVA checkpoint 的 audio latent 形态是：

- **连续高斯 latent**
- 不是离散 RVQ token 序列

更准确地说，它是“借用了 DAC encoder/decoder 骨架的 continuous audio latent VAE”。

## 7. “MoE 怎么参与的”

### 7.1 公开代码里没有看到标准 sparse MoE 结构

我检查了：

- `mova/` 代码
- `weights/MOVA-360p/*/config.json`
- `video_dit` / `video_dit_2` 的 safetensors index key

没有看到公开的：

- `router`
- `expert`
- `moe`
- token-level gate

换句话说，**公开视频代码没有暴露出常见 sparse MoE block**。

### 7.2 但“32B total / 18B active”与双 video tower 精确匹配

如果把下面这四个模块视为 diffusion 核心：

- `video_dit`
- `video_dit_2`
- `audio_dit`
- `dual_tower_bridge`

那么：

- 总参数量约 `32.657B`
- 每一步只活跃一个视频 tower，因此活跃参数约 `18.368B`

这与 model card 的描述几乎逐项对齐。

### 7.3 因此更合理的代码级解释是：它是“按噪声区间切换 expert”

基于公开实现，我更倾向于认为：

- MOVA 所谓的 “MoE” 在代码层面最可见的形态
- 不是 token-level sparse MoE
- 而是 **两个完整 video expert 按 denoising stage hard switch**

也就是：

- 高噪声 expert：`video_dit`
- 低噪声 expert：`video_dit_2`

这是一种 **stage-wise expertization**，而不是传统 router-based sparse expert routing。

### 7.4 这里要明确区分“代码事实”和“合理推断”

- **事实**：仓库里有两套完整 14.289B 的视频 tower，且按 boundary 硬切换
- **事实**：总参数 / 活跃参数与 model card 数字匹配
- **推断**：model card 所说 MoE 很可能就是这套按噪声区间切换的 expert 设计

如果官方论文对 “MoE” 有更细的定义，那部分并没有在当前公开视频实现中直接显露出来。

## 8. 它是不是 self-forcing / 流式推理模型

### 8.1 不是

从当前代码看，`MOVA` **不是 self-forcing，也不是流式推理模型**。

原因非常直接：

1. **整段 latent 一次性初始化**
   - video latent 一上来就是整段 clip 的噪声张量
   - audio latent 也是整段音频长度的噪声张量
2. **DiT self-attention 不是 causal mask**
   - `wan_video_dit.py` / `wan_audio_dit.py` 的 self-attention 都是全序列 attention
   - 没有 token-by-token 自回归采样
3. **bridge 也是全序列 cross-attention**
   - audio / video 序列会在完整时序上交互
4. **scheduler 是全局 diffusion step**
   - 每一步都对整段 clip latent 更新
   - 不是 chunk-by-chunk 增量生成

### 8.2 哪些部分“看起来像能流式”，但其实还不够

当前代码里，只有少数组件具备一点“块处理”味道：

- `video_vae` 的 causal conv + feature cache
- `audio_vae.compress()/decompress()` 的窗口处理
- context parallel / long-context attention 替换能力

但这些都只是：

- **编解码层面的 chunking**
- 或 **长上下文并行计算优化**

并不等于主生成器已经变成 streaming model。

### 8.3 如果要改成 self-forcing / streaming，难点在哪里

如果真要把 MOVA 改成 self-forcing / 流式推理模型，至少要同时改掉这些点：

1. **生成粒度**
   - 从“整段 clip latent 一次性扩散”改成“时间块递进式生成”
2. **video/audio tower 注意力**
   - 需要 causal / local / cached attention
   - 当前实现没有 KV cache 风格的生成接口
3. **bridge 状态传递**
   - 当前 bridge 假设可看到完整 audio/video token 序列
   - 若改成流式，需要设计 chunk 间状态、边界对齐、历史摘要
4. **训练目标**
   - 现有训练就是 full-clip flow matching
   - self-forcing 需要新的 teacher-forcing / prefix conditioning / chunk rollout 训练范式
5. **音视频同步边界问题**
   - 现在 cross-modal RoPE 是按整段时间轴对齐
   - 流式后要解决 chunk 边界的时序一致性与重叠区域稳定性

所以这不是“把 video VAE 换成 causal 就行”的事情，而是**主生成器训练范式都要变**。

## 9. 其它值得记录的实现细节

### 9.1 README 提到 `Dual CFG`，但公开推理代码没有完整开放出来

README 在评测部分提到 `Dual CFG enabled`，但从 `pipeline_mova.py` 的公开逻辑看：

- `cfg_mode = "text"`
- 只实现了标准正负 prompt CFG 分支
- `"dual"` 分支直接 `NotImplemented`

因此至少在当前公开推理入口里：

- **并没有完整开放 dual-CFG 推理路径**

### 9.2 `FlowMatchPairScheduler` 支持双模态不同 schedule，但默认没启用

调度器支持：

- video/audio 不同 shift
- pair-wise timestep postprocess

但 `pipeline_mova.py` 中对应的：

- `set_pair_postprocess_by_name("dual_sigma_shift", ...)`

是注释掉的。

所以当前公开推理默认仍然是：

- video / audio 同步 schedule 为主
- 而不是完全分离的双 schedule 版本

## 10. 总结

如果只看公开代码，`MOVA` 最准确的工程画像是：

- 一个 **离线、整段 latent 扩散** 的视频音频联合生成模型
- 视频侧用 **两套完整 Wan-style video DiT** 按噪声区间切换
- 音频侧用 **一套较小 audio DiT** 全程参与
- 两边通过 **`dual_tower_bridge` 的双向 cross-attention + cross-modal RoPE** 深度交互
- 视频 VAE 是 **causal 3D VAE**，但音频 VAE **不是 causal**，而且当前 checkpoint 还是 **continuous latent DAC VAE**
- 所谓 “32B total / 18B active” 在代码层面最像 **stage-wise dual-expert video tower**，而不是公开可见的 token-level sparse MoE
- 它离 self-forcing / streaming 还很远；要改，需要改主生成器、bridge 和训练范式，而不是只改 VAE
