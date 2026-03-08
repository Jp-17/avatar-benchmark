#!/bin/bash
set -euo pipefail
cd /root/autodl-tmp/avatar-benchmark
LOG=/root/autodl-tmp/avatar-benchmark/test/run_multitalk_infinitetalk_minimal.log
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1
TARGET=/root/autodl-tmp/avatar-benchmark/weights_shared/Wan2.1-I2V-14B-480P
printf "[%s] waiting for 7 diffusion shards\n" "$(date "+%F %T")"
while true; do
  COUNT=$(find "$TARGET" -maxdepth 1 -type f -name "diffusion_pytorch_model-*.safetensors" | wc -l)
  printf "[%s] shard_count=%s\n" "$(date "+%F %T")" "$COUNT"
  if [ "$COUNT" -ge 7 ]; then
    break
  fi
  sleep 60
done
printf "[%s] start MultiTalk minimal test\n" "$(date "+%F %T")"
bash /root/autodl-tmp/avatar-benchmark/test/multitalk/test_multitalk.sh
printf "[%s] MultiTalk minimal test done\n" "$(date "+%F %T")"
printf "[%s] start InfiniteTalk minimal test\n" "$(date "+%F %T")"
bash /root/autodl-tmp/avatar-benchmark/test/infinitetalk/test_infinitetalk.sh
printf "[%s] InfiniteTalk minimal test done\n" "$(date "+%F %T")"
