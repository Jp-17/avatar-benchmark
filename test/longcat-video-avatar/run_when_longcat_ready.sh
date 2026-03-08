#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/run_when_longcat_ready.log
PID=/root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/run_when_longcat_ready.pid
: > "$LOG"
echo $$ > "$PID"
exec > >(tee -a "$LOG") 2>&1
TARGET=/root/autodl-tmp/avatar-benchmark/models/LongCat-Video/weights/LongCat-Video-Avatar
printf "[%s] waiting LongCat avatar shards\n" "$(date "+%F %T")"
while true; do
  single=$(find "$TARGET/avatar_single" -maxdepth 1 -type f -name "diffusion_pytorch_model-*.safetensors" | wc -l)
  multi=$(find "$TARGET/avatar_multi" -maxdepth 1 -type f -name "diffusion_pytorch_model-*.safetensors" | wc -l)
  printf "[%s] avatar_single=%s avatar_multi=%s\n" "$(date "+%F %T")" "$single" "$multi"
  if [ "$single" -ge 6 ] && [ "$multi" -ge 6 ]; then
    break
  fi
  sleep 60
done
printf "[%s] start LongCat minimal test\n" "$(date "+%F %T")"
bash /root/autodl-tmp/avatar-benchmark/test/longcat-video-avatar/test_longcat_video_avatar.sh
printf "[%s] LongCat minimal test done\n" "$(date "+%F %T")"
