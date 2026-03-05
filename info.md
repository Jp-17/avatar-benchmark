1. 比较模型
- 提前调研：模型大小，资源需求（1个80g显存卡可inference），是否提供inference code和weight(可测试)，长视频生成能力，avatar生成能力
- 在 1个 80g卡下可测试推理能力，可以测同一个模型提供的不同模型大小的的效果
  1. 通用视频生成
    1. 离线视频生成模型
      1. Wan2.2
      2. Hunyuanvideo-1.5
      3. Skyreels v3
    2. 自回归视频生成模型
      1. Self-forcing
      2. Longlive
    3. 联合音视频生成
      1. Mova
      2. ltx-2
      3. ovi
  2. Avatar视频生成
    1. 离线视频生成
      1. Echomimic2
      2. Hallo3
      3. Hunyuanvideo-avatar
      4. wan2.2-s2v
      5. Omniavatar
      6. multitalk
      7. Longcat-video
      8. Stableavatar
      9. fantasytalking
    2. 自回归视频生成
      1. Liveavatar
      2. livetalk
      3. SoulX-FlashTalk
      
2. 素材和标准
- 主要测试avatar的表现能力，根据模型本身的能力，提供text/image/audio
- 提供标准可复用的提示测例text/image/audio
  1. 素材
    1. Audio
      1. 讨论/唱歌
    2. Reference image
      1. 半身/全身
      2. 站着/坐着/躺着
    3. 情景
      1. 演讲/下棋/弹琴/跳舞
      2. 微笑/愤怒/悲伤
  2. 标准（长时间生成）
    1. 画面的稳定性
    2. 人物的一致性
    3. 音频嘴形一致性
    4. 面部神态丰富度
    5. 全身动作丰富度